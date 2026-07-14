-- Esnafta Var - Verified shop ratings migration
-- =====================================================
-- Additive migration: no existing records are deleted.
-- A customer can rate a shop only after a verified QR transaction.
-- Each verified transaction can create at most one shop rating.
-- =====================================================

BEGIN;

ALTER TABLE public.shops
  ADD COLUMN IF NOT EXISTS rating_count INTEGER NOT NULL DEFAULT 0;

ALTER TABLE public.shops
  ALTER COLUMN rating_count SET DEFAULT 0;

UPDATE public.shops
SET rating_count = 0
WHERE rating_count IS NULL;

ALTER TABLE public.shops
  ALTER COLUMN rating_count SET NOT NULL;

CREATE TABLE IF NOT EXISTS public.shop_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verified_transaction_id UUID NOT NULL
    REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  customer_user_id UUID NOT NULL,
  shop_id UUID NOT NULL,
  rating SMALLINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT shop_ratings_rating_range_check
    CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT shop_ratings_verified_transaction_unique
    UNIQUE (verified_transaction_id)
);

CREATE INDEX IF NOT EXISTS idx_shop_ratings_customer_user_id
  ON public.shop_ratings(customer_user_id);
CREATE INDEX IF NOT EXISTS idx_shop_ratings_shop_id
  ON public.shop_ratings(shop_id);
CREATE INDEX IF NOT EXISTS idx_shop_ratings_created_at
  ON public.shop_ratings(created_at DESC);

ALTER TABLE public.shop_ratings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Participants can read shop ratings"
  ON public.shop_ratings;
CREATE POLICY "Participants can read shop ratings"
  ON public.shop_ratings
  FOR SELECT
  TO authenticated
  USING (
    customer_user_id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM public.shops AS s
      WHERE s.id = shop_ratings.shop_id
        AND s.owner_user_id = auth.uid()
    )
  );

REVOKE ALL PRIVILEGES ON TABLE public.shop_ratings
  FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.shop_ratings TO authenticated;

CREATE OR REPLACE FUNCTION public.refresh_verified_shop_rating(
  p_shop_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $function$
BEGIN
  UPDATE public.shops AS s
  SET
    rating = summary.average_rating,
    rating_count = summary.rating_count
  FROM (
    SELECT
      COALESCE(ROUND(AVG(sr.rating)::NUMERIC, 2), 0) AS average_rating,
      COUNT(*)::INTEGER AS rating_count
    FROM public.shop_ratings AS sr
    WHERE sr.shop_id = p_shop_id
  ) AS summary
  WHERE s.id = p_shop_id;
END;
$function$;

CREATE OR REPLACE FUNCTION public.handle_verified_shop_rating_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $function$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM public.refresh_verified_shop_rating(OLD.shop_id);
    RETURN OLD;
  END IF;

  PERFORM public.refresh_verified_shop_rating(NEW.shop_id);

  IF TG_OP = 'UPDATE' AND OLD.shop_id IS DISTINCT FROM NEW.shop_id THEN
    PERFORM public.refresh_verified_shop_rating(OLD.shop_id);
  END IF;

  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS refresh_verified_shop_rating_after_change
  ON public.shop_ratings;
CREATE TRIGGER refresh_verified_shop_rating_after_change
  AFTER INSERT OR UPDATE OR DELETE ON public.shop_ratings
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_verified_shop_rating_change();

REVOKE ALL ON FUNCTION public.refresh_verified_shop_rating(UUID)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.handle_verified_shop_rating_change()
  FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.submit_verified_shop_rating(
  p_qr_session_id UUID,
  p_rating INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $function$
DECLARE
  v_user_id UUID := auth.uid();
  v_transaction public.verified_transactions%ROWTYPE;
  v_rating_id UUID;
  v_average_rating NUMERIC;
  v_rating_count INTEGER;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required'
      USING ERRCODE = '28000';
  END IF;

  IF p_qr_session_id IS NULL THEN
    RAISE EXCEPTION 'Verified purchase not found'
      USING ERRCODE = 'P0002';
  END IF;

  IF p_rating IS NULL OR p_rating < 1 OR p_rating > 5 THEN
    RAISE EXCEPTION 'Rating must be between 1 and 5'
      USING ERRCODE = '22023';
  END IF;

  SELECT vt.*
  INTO v_transaction
  FROM public.verified_transactions AS vt
  WHERE vt.source_qr_session_id = p_qr_session_id
    AND vt.customer_user_id = v_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Verified purchase not found'
      USING ERRCODE = 'P0002';
  END IF;

  BEGIN
    INSERT INTO public.shop_ratings (
      verified_transaction_id,
      customer_user_id,
      shop_id,
      rating
    )
    VALUES (
      v_transaction.id,
      v_user_id,
      v_transaction.shop_id,
      p_rating
    )
    RETURNING id INTO v_rating_id;
  EXCEPTION
    WHEN unique_violation THEN
      RAISE EXCEPTION 'Verified purchase already rated'
        USING ERRCODE = '23505';
  END;

  SELECT s.rating, s.rating_count
  INTO v_average_rating, v_rating_count
  FROM public.shops AS s
  WHERE s.id = v_transaction.shop_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Shop not found'
      USING ERRCODE = 'P0002';
  END IF;

  RETURN jsonb_build_object(
    'rating_id', v_rating_id,
    'shop_id', v_transaction.shop_id,
    'rating', p_rating,
    'average_rating', v_average_rating,
    'rating_count', v_rating_count
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.submit_verified_shop_rating(UUID, INTEGER)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.submit_verified_shop_rating(UUID, INTEGER)
  TO authenticated;

COMMIT;

-- Read-only verification queries:
-- SELECT to_regclass('public.shop_ratings') AS shop_ratings_table;
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_schema = 'public'
--   AND table_name = 'shops'
--   AND column_name IN ('rating', 'rating_count')
-- ORDER BY column_name;
-- SELECT has_function_privilege(
--   'authenticated',
--   'public.submit_verified_shop_rating(uuid, integer)',
--   'EXECUTE'
-- ) AS authenticated_can_submit_rating;
