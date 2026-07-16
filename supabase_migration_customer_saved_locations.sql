BEGIN;

CREATE TABLE IF NOT EXISTS public.customer_saved_locations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(btrim(name)) BETWEEN 1 AND 50),
  address_text TEXT NOT NULL CHECK (
    char_length(btrim(address_text)) BETWEEN 1 AND 200
  ),
  latitude DOUBLE PRECISION NOT NULL CHECK (latitude BETWEEN -90 AND 90),
  longitude DOUBLE PRECISION NOT NULL CHECK (longitude BETWEEN -180 AND 180),
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_customer_saved_locations_user_created
  ON public.customer_saved_locations(user_id, created_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS idx_customer_saved_locations_one_default
  ON public.customer_saved_locations(user_id)
  WHERE is_default = true;

ALTER TABLE public.customer_saved_locations ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.customer_saved_locations FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE public.customer_saved_locations
  TO authenticated;

DROP POLICY IF EXISTS "Customers can view own saved locations"
  ON public.customer_saved_locations;
CREATE POLICY "Customers can view own saved locations"
  ON public.customer_saved_locations
  FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Customers can create own saved locations"
  ON public.customer_saved_locations;
CREATE POLICY "Customers can create own saved locations"
  ON public.customer_saved_locations
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Customers can update own saved locations"
  ON public.customer_saved_locations;
CREATE POLICY "Customers can update own saved locations"
  ON public.customer_saved_locations
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Customers can delete own saved locations"
  ON public.customer_saved_locations;
CREATE POLICY "Customers can delete own saved locations"
  ON public.customer_saved_locations
  FOR DELETE
  USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.touch_customer_saved_locations_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS touch_customer_saved_locations_updated_at
  ON public.customer_saved_locations;
CREATE TRIGGER touch_customer_saved_locations_updated_at
  BEFORE UPDATE ON public.customer_saved_locations
  FOR EACH ROW
  EXECUTE FUNCTION public.touch_customer_saved_locations_updated_at();

CREATE OR REPLACE FUNCTION public.set_default_customer_saved_location(
  p_location_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM public.customer_saved_locations
    WHERE id = p_location_id
      AND user_id = auth.uid()
  ) THEN
    RETURN false;
  END IF;

  UPDATE public.customer_saved_locations
  SET is_default = false
  WHERE user_id = auth.uid()
    AND is_default = true;

  UPDATE public.customer_saved_locations
  SET is_default = true
  WHERE id = p_location_id
    AND user_id = auth.uid();

  RETURN true;
END;
$$;

CREATE OR REPLACE FUNCTION public.delete_customer_saved_location(
  p_location_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  deleted_was_default BOOLEAN;
BEGIN
  DELETE FROM public.customer_saved_locations
  WHERE id = p_location_id
    AND user_id = auth.uid()
  RETURNING is_default INTO deleted_was_default;

  IF NOT FOUND THEN
    RETURN false;
  END IF;

  IF deleted_was_default THEN
    UPDATE public.customer_saved_locations
    SET is_default = true
    WHERE id = (
      SELECT id
      FROM public.customer_saved_locations
      WHERE user_id = auth.uid()
      ORDER BY created_at DESC
      LIMIT 1
    );
  END IF;

  RETURN true;
END;
$$;

REVOKE ALL ON FUNCTION public.set_default_customer_saved_location(UUID)
  FROM PUBLIC;
REVOKE ALL ON FUNCTION public.delete_customer_saved_location(UUID)
  FROM PUBLIC;
REVOKE ALL ON FUNCTION public.touch_customer_saved_locations_updated_at()
  FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.set_default_customer_saved_location(UUID)
  TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_customer_saved_location(UUID)
  TO authenticated;

COMMIT;
