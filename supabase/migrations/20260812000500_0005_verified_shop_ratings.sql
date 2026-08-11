-- EsnaftaVar canonical migration 0005: one rating per verified transaction.
-- Product review eligibility remains on the legacy order contract.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $preflight$
BEGIN
  IF to_regclass('public.shops') IS NULL
     OR to_regclass('public.verified_transactions') IS NULL THEN
    RAISE EXCEPTION
      'Migration 0005 requires shops and verified_transactions'
      USING ERRCODE = '42P01';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'shops'
      AND column_name IN ('rating', 'rating_count')
    GROUP BY table_schema, table_name
    HAVING COUNT(*) = 2
  ) THEN
    RAISE EXCEPTION 'Migration 0005 requires final shop rating columns'
      USING ERRCODE = '42703';
  END IF;
END
$preflight$;

CREATE TABLE public.shop_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verified_transaction_id UUID NOT NULL
    REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  customer_user_id UUID NOT NULL,
  shop_id UUID NOT NULL,
  rating SMALLINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT shop_ratings_rating_range_check CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT shop_ratings_verified_transaction_key
    UNIQUE (verified_transaction_id)
);

CREATE INDEX shop_ratings_customer_idx
  ON public.shop_ratings(customer_user_id);
CREATE INDEX shop_ratings_shop_idx ON public.shop_ratings(shop_id);
CREATE INDEX shop_ratings_created_idx
  ON public.shop_ratings(created_at DESC);

ALTER TABLE public.shop_ratings ENABLE ROW LEVEL SECURITY;

CREATE POLICY shop_ratings_select_participant
  ON public.shop_ratings FOR SELECT TO authenticated
  USING (
    customer_user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.shops AS rated_shop
      WHERE rated_shop.id = shop_ratings.shop_id
        AND rated_shop.owner_user_id = auth.uid()
    )
  );

REVOKE ALL ON TABLE public.shop_ratings FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.shop_ratings TO authenticated;

CREATE FUNCTION public.refresh_verified_shop_rating(p_shop_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $function$
BEGIN
  UPDATE public.shops AS shop
  SET rating = summary.average_rating,
      rating_count = summary.rating_count
  FROM (
    SELECT
      COALESCE(ROUND(AVG(rating_row.rating)::NUMERIC, 2), 0)
        AS average_rating,
      COUNT(*)::INTEGER AS rating_count
    FROM public.shop_ratings AS rating_row
    WHERE rating_row.shop_id = p_shop_id
  ) AS summary
  WHERE shop.id = p_shop_id;
END;
$function$;

CREATE FUNCTION public.handle_verified_shop_rating_change()
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

REVOKE ALL ON FUNCTION public.refresh_verified_shop_rating(UUID)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.handle_verified_shop_rating_change()
  FROM PUBLIC, anon, authenticated;

CREATE TRIGGER refresh_verified_shop_rating_after_change
  AFTER INSERT OR UPDATE OR DELETE ON public.shop_ratings
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_verified_shop_rating_change();

CREATE FUNCTION public.submit_verified_shop_rating(
  p_qr_session_id UUID,
  p_rating INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $function$
DECLARE
  current_user_id UUID := auth.uid();
  transaction_row public.verified_transactions%ROWTYPE;
  rating_id UUID;
  average_rating NUMERIC;
  rating_count INTEGER;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '28000';
  END IF;

  IF p_qr_session_id IS NULL THEN
    RAISE EXCEPTION 'Verified purchase not found' USING ERRCODE = 'P0002';
  END IF;

  IF p_rating IS NULL OR p_rating < 1 OR p_rating > 5 THEN
    RAISE EXCEPTION 'Rating must be between 1 and 5'
      USING ERRCODE = '22023';
  END IF;

  SELECT transaction_source.*
    INTO transaction_row
  FROM public.verified_transactions AS transaction_source
  WHERE transaction_source.source_qr_session_id = p_qr_session_id
    AND transaction_source.customer_user_id = current_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Verified purchase not found' USING ERRCODE = 'P0002';
  END IF;

  BEGIN
    INSERT INTO public.shop_ratings (
      verified_transaction_id,
      customer_user_id,
      shop_id,
      rating
    ) VALUES (
      transaction_row.id,
      current_user_id,
      transaction_row.shop_id,
      p_rating
    )
    RETURNING id INTO rating_id;
  EXCEPTION
    WHEN unique_violation THEN
      RAISE EXCEPTION 'Verified purchase already rated'
        USING ERRCODE = '23505';
  END;

  SELECT shop.rating, shop.rating_count
    INTO average_rating, rating_count
  FROM public.shops AS shop
  WHERE shop.id = transaction_row.shop_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Shop not found' USING ERRCODE = 'P0002';
  END IF;

  RETURN jsonb_build_object(
    'rating_id', rating_id,
    'shop_id', transaction_row.shop_id,
    'rating', p_rating,
    'average_rating', average_rating,
    'rating_count', rating_count
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.submit_verified_shop_rating(UUID, INTEGER)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.submit_verified_shop_rating(UUID, INTEGER)
  TO authenticated;

COMMIT;
