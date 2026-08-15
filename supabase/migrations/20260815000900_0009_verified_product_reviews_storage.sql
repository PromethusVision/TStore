-- EsnaftaVar canonical migration 0009: durable product purchase evidence,
-- verified product reviews, and the active trusted-media Storage contract.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';

DO $preflight$
BEGIN
  IF to_regclass('public.products') IS NULL
     OR to_regclass('public.shop_products') IS NULL
     OR to_regclass('public.qr_sessions') IS NULL
     OR to_regclass('public.qr_session_items') IS NULL
     OR to_regclass('public.verified_transactions') IS NULL
     OR to_regclass('public.verified_transaction_items') IS NULL
     OR to_regclass('public.reviews') IS NULL
     OR to_regclass('storage.buckets') IS NULL
     OR to_regclass('storage.objects') IS NULL THEN
    RAISE EXCEPTION
      'Migration 0009 requires canonical migrations 0001 through 0008 and Supabase managed Storage'
      USING ERRCODE = '42P01';
  END IF;

  IF to_regprocedure('public.create_qr_session(uuid)') IS NULL
     OR to_regprocedure('public.confirm_qr_session(text)') IS NULL
     OR to_regprocedure(
          'public.get_qr_session_for_verification(text)'
        ) IS NULL
     OR to_regprocedure(
          'public.refresh_product_rating_after_review()'
        ) IS NULL THEN
    RAISE EXCEPTION 'Migration 0009 requires the canonical QR and review functions'
      USING ERRCODE = '42883';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'storage'
      AND table_name = 'buckets'
      AND column_name IN (
        'id', 'name', 'public', 'file_size_limit', 'allowed_mime_types'
      )
    GROUP BY table_schema, table_name
    HAVING COUNT(*) = 5
  ) THEN
    RAISE EXCEPTION 'Supabase managed Storage bucket contract is unavailable'
      USING ERRCODE = '42703';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_catalog.pg_class AS relation
    JOIN pg_catalog.pg_namespace AS relation_namespace
      ON relation_namespace.oid = relation.relnamespace
    WHERE relation_namespace.nspname = 'storage'
      AND relation.relname = 'objects'
      AND relation.relrowsecurity = true
  ) THEN
    RAISE EXCEPTION 'Supabase managed storage.objects must have RLS enabled'
      USING ERRCODE = '55000';
  END IF;
END
$preflight$;

-- Historical rows remain nullable because a present-day catalog join is not
-- authoritative historical evidence. Every row inserted after this migration
-- is required to carry the server-derived immutable product UUID snapshot.
ALTER TABLE public.qr_session_items
  ADD COLUMN product_id UUID;
ALTER TABLE public.verified_transaction_items
  ADD COLUMN product_id UUID;

CREATE INDEX qr_session_items_product_idx
  ON public.qr_session_items(product_id);
CREATE INDEX verified_transaction_items_product_idx
  ON public.verified_transaction_items(product_id);

CREATE FUNCTION public.enforce_qr_product_snapshot()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.product_id IS NULL THEN
    RAISE EXCEPTION '[QR_PRODUCT_SNAPSHOT_REQUIRED] product_id is required for new QR snapshot rows'
      USING ERRCODE = '23502';
  END IF;

  IF TG_OP = 'UPDATE'
     AND (
       OLD.qr_session_id IS DISTINCT FROM NEW.qr_session_id
       OR OLD.shop_product_id IS DISTINCT FROM NEW.shop_product_id
       OR OLD.product_id IS DISTINCT FROM NEW.product_id
       OR OLD.product_name IS DISTINCT FROM NEW.product_name
       OR OLD.quantity IS DISTINCT FROM NEW.quantity
       OR OLD.unit_price IS DISTINCT FROM NEW.unit_price
       OR OLD.created_at IS DISTINCT FROM NEW.created_at
     ) THEN
    RAISE EXCEPTION '[QR_PRODUCT_SNAPSHOT_IMMUTABLE] QR item snapshots cannot be changed'
      USING ERRCODE = '55000';
  END IF;

  RETURN NEW;
END;
$function$;

CREATE FUNCTION public.enforce_verified_transaction_item_snapshot()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.product_id IS NULL THEN
    RAISE EXCEPTION '[VERIFIED_PRODUCT_SNAPSHOT_REQUIRED] product_id is required for new verified transaction items'
      USING ERRCODE = '23502';
  END IF;

  IF TG_OP = 'UPDATE' THEN
    RAISE EXCEPTION '[VERIFIED_PRODUCT_SNAPSHOT_IMMUTABLE] verified transaction items cannot be changed'
      USING ERRCODE = '55000';
  END IF;

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.enforce_qr_product_snapshot()
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.enforce_verified_transaction_item_snapshot()
  FROM PUBLIC, anon, authenticated;

CREATE TRIGGER enforce_qr_product_snapshot
  BEFORE INSERT OR UPDATE ON public.qr_session_items
  FOR EACH ROW EXECUTE FUNCTION public.enforce_qr_product_snapshot();
CREATE TRIGGER enforce_verified_transaction_item_snapshot
  BEFORE INSERT OR UPDATE ON public.verified_transaction_items
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_verified_transaction_item_snapshot();

CREATE OR REPLACE FUNCTION public.get_qr_session_for_verification(
  p_session_token TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  current_user_id UUID := auth.uid();
  v_current_time TIMESTAMPTZ := clock_timestamp();
  payload JSONB;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '28000';
  END IF;

  IF p_session_token IS NULL OR btrim(p_session_token) = '' THEN
    RAISE EXCEPTION 'QR session token is required' USING ERRCODE = '22023';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.profiles AS profile
    WHERE profile.id = current_user_id
      AND profile.role IN ('merchant', 'admin')
  ) THEN
    RAISE EXCEPTION 'Merchant access required' USING ERRCODE = '42501';
  END IF;

  UPDATE public.qr_sessions AS session_row
  SET status = 'expired'
  WHERE session_row.session_token = p_session_token
    AND session_row.status = 'active'
    AND session_row.expires_at <= v_current_time
    AND EXISTS (
      SELECT 1 FROM public.shops AS owned_shop
      WHERE owned_shop.id = session_row.shop_id
        AND owned_shop.owner_user_id = current_user_id
        AND owned_shop.is_active = true
    );

  SELECT jsonb_build_object(
           'session_id', session_row.id,
           'session_token', session_row.session_token,
           'status', session_row.status,
           'expires_at', session_row.expires_at,
           'used_at', session_row.used_at,
           'shop_id', session_row.shop_id,
           'shop_name', shop.name,
           'item_count', session_row.item_count,
           'total_amount', session_row.total_amount,
           'items', COALESCE(
             (
               SELECT jsonb_agg(
                        jsonb_build_object(
                          'id', item.id,
                          'shop_product_id', item.shop_product_id,
                          'product_id', item.product_id,
                          'product_name', item.product_name,
                          'quantity', item.quantity,
                          'unit_price', item.unit_price,
                          'line_total', item.line_total
                        ) ORDER BY item.created_at, item.id
                      )
               FROM public.qr_session_items AS item
               WHERE item.qr_session_id = session_row.id
             ),
             '[]'::JSONB
           )
         )
    INTO payload
  FROM public.qr_sessions AS session_row
  JOIN public.shops AS shop
    ON shop.id = session_row.shop_id
   AND shop.owner_user_id = current_user_id
   AND shop.is_active = true
  WHERE session_row.session_token = p_session_token;

  IF payload IS NULL THEN
    RAISE EXCEPTION 'QR session not found for this shop'
      USING ERRCODE = 'P0002';
  END IF;

  RETURN payload;
END;
$function$;

REVOKE ALL ON FUNCTION public.get_qr_session_for_verification(TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_qr_session_for_verification(TEXT)
  TO authenticated;

CREATE OR REPLACE FUNCTION public.create_qr_session(p_cart_id UUID)
RETURNS public.qr_sessions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  current_user_id UUID;
  v_current_time TIMESTAMPTZ;
  active_cart public.carts%ROWTYPE;
  session_row public.qr_sessions%ROWTYPE;
  cart_line_count INTEGER;
  snapshot_line_count INTEGER;
  snapshot_product_count INTEGER;
  snapshot_item_count INTEGER;
  snapshot_total NUMERIC;
BEGIN
  current_user_id := auth.uid();

  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '28000';
  END IF;

  SELECT cart_row.*
    INTO active_cart
  FROM public.carts AS cart_row
  WHERE cart_row.id = p_cart_id
    AND cart_row.user_id = current_user_id
    AND cart_row.status = 'active'
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Active cart not found' USING ERRCODE = 'P0002';
  END IF;

  PERFORM shop.id
  FROM public.shops AS shop
  WHERE shop.id = active_cart.shop_id
    AND shop.is_active = true
  FOR SHARE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Shop is not active' USING ERRCODE = '55000';
  END IF;

  SELECT COUNT(*)::INTEGER
    INTO cart_line_count
  FROM public.cart_items_v2 AS cart_item
  WHERE cart_item.cart_id = active_cart.id;

  IF cart_line_count = 0 THEN
    RAISE EXCEPTION 'Cannot create QR session for an empty cart'
      USING ERRCODE = 'P0001';
  END IF;

  PERFORM listing.id
  FROM public.cart_items_v2 AS cart_item
  JOIN public.shop_products AS listing
    ON listing.id = cart_item.shop_product_id
  JOIN public.products AS product ON product.id = listing.product_id
  WHERE cart_item.cart_id = active_cart.id
  ORDER BY listing.id, product.id
  FOR SHARE OF listing, product;

  IF EXISTS (
    SELECT 1
    FROM public.cart_items_v2 AS cart_item
    LEFT JOIN public.shop_products AS listing
      ON listing.id = cart_item.shop_product_id
    LEFT JOIN public.products AS product ON product.id = listing.product_id
    WHERE cart_item.cart_id = active_cart.id
      AND (
        listing.id IS NULL
        OR product.id IS NULL
        OR listing.shop_id IS DISTINCT FROM active_cart.shop_id
        OR listing.is_active IS NOT TRUE
        OR listing.is_available IS NOT TRUE
        OR product.is_active IS NOT TRUE
        OR listing.price IS NULL
        OR listing.price < 0
      )
  ) THEN
    RAISE EXCEPTION 'Cart contains an unavailable or different shop item'
      USING ERRCODE = '23514';
  END IF;

  v_current_time := clock_timestamp();

  UPDATE public.qr_sessions AS existing_session
  SET status = 'expired'
  WHERE existing_session.cart_id = active_cart.id
    AND existing_session.user_id = current_user_id
    AND existing_session.status = 'active'
    AND existing_session.expires_at <= v_current_time;

  SELECT existing_session.*
    INTO session_row
  FROM public.qr_sessions AS existing_session
  WHERE existing_session.cart_id = active_cart.id
    AND existing_session.user_id = current_user_id
    AND existing_session.status = 'active'
    AND existing_session.expires_at > v_current_time
  LIMIT 1
  FOR UPDATE;

  IF FOUND THEN
    SELECT
      COUNT(*)::INTEGER,
      COUNT(item.product_id)::INTEGER,
      COALESCE(SUM(item.quantity), 0)::INTEGER,
      COALESCE(SUM(item.line_total), 0)
      INTO
        snapshot_line_count,
        snapshot_product_count,
        snapshot_item_count,
        snapshot_total
    FROM public.qr_session_items AS item
    WHERE item.qr_session_id = session_row.id;

    IF snapshot_line_count > 0
       AND snapshot_product_count = snapshot_line_count
       AND session_row.item_count = snapshot_item_count
       AND session_row.total_amount = snapshot_total THEN
      RETURN session_row;
    END IF;

    UPDATE public.qr_sessions
    SET status = 'cancelled'
    WHERE id = session_row.id;
  END IF;

  INSERT INTO public.qr_sessions (
    session_token,
    user_id,
    cart_id,
    shop_id,
    status,
    expires_at,
    used_at,
    total_amount,
    item_count,
    confirmed_by_user_id
  ) VALUES (
    encode(extensions.gen_random_bytes(32), 'hex'),
    current_user_id,
    active_cart.id,
    active_cart.shop_id,
    'active',
    v_current_time + INTERVAL '2 minutes',
    NULL,
    0,
    0,
    NULL
  )
  RETURNING * INTO session_row;

  INSERT INTO public.qr_session_items (
    qr_session_id,
    shop_product_id,
    product_id,
    product_name,
    quantity,
    unit_price
  )
  SELECT
    session_row.id,
    listing.id,
    product.id,
    product.name,
    cart_item.quantity,
    listing.price
  FROM public.cart_items_v2 AS cart_item
  JOIN public.shop_products AS listing
    ON listing.id = cart_item.shop_product_id
   AND listing.shop_id = active_cart.shop_id
   AND listing.is_active = true
   AND listing.is_available = true
  JOIN public.products AS product
    ON product.id = listing.product_id
   AND product.is_active = true
  WHERE cart_item.cart_id = active_cart.id
  ORDER BY cart_item.id;

  GET DIAGNOSTICS snapshot_line_count = ROW_COUNT;

  IF snapshot_line_count <> cart_line_count THEN
    RAISE EXCEPTION
      'Cart snapshot is incomplete (% of % lines copied)',
      snapshot_line_count,
      cart_line_count
      USING ERRCODE = 'P0001';
  END IF;

  SELECT
    COALESCE(SUM(item.quantity), 0)::INTEGER,
    COALESCE(SUM(item.line_total), 0)
    INTO snapshot_item_count, snapshot_total
  FROM public.qr_session_items AS item
  WHERE item.qr_session_id = session_row.id;

  UPDATE public.qr_sessions
  SET item_count = snapshot_item_count,
      total_amount = snapshot_total
  WHERE id = session_row.id
  RETURNING * INTO session_row;

  RETURN session_row;
END;
$function$;

REVOKE ALL ON FUNCTION public.create_qr_session(UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_qr_session(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.confirm_qr_session(p_session_token TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  current_user_id UUID := auth.uid();
  v_current_time TIMESTAMPTZ;
  session_id UUID;
  session_cart_id UUID;
  locked_cart public.carts%ROWTYPE;
  locked_session public.qr_sessions%ROWTYPE;
  snapshot_line_count INTEGER;
  snapshot_product_count INTEGER;
  snapshot_item_count INTEGER;
  snapshot_total NUMERIC;
  transaction_id UUID;
  verified_item_count INTEGER;
  payload JSONB;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '28000';
  END IF;

  IF p_session_token IS NULL OR btrim(p_session_token) = '' THEN
    RAISE EXCEPTION 'QR session token is required' USING ERRCODE = '22023';
  END IF;

  PERFORM profile.id
  FROM public.profiles AS profile
  WHERE profile.id = current_user_id
    AND profile.role IN ('merchant', 'admin')
  FOR SHARE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Merchant access required' USING ERRCODE = '42501';
  END IF;

  SELECT session_row.id, session_row.cart_id
    INTO session_id, session_cart_id
  FROM public.qr_sessions AS session_row
  JOIN public.shops AS shop
    ON shop.id = session_row.shop_id
   AND shop.owner_user_id = current_user_id
   AND shop.is_active = true
  WHERE session_row.session_token = p_session_token;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'QR session not found for this shop'
      USING ERRCODE = 'P0002';
  END IF;

  SELECT cart_row.*
    INTO locked_cart
  FROM public.carts AS cart_row
  WHERE cart_row.id = session_cart_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart not found for QR session'
      USING ERRCODE = 'P0002';
  END IF;

  SELECT session_row.*
    INTO locked_session
  FROM public.qr_sessions AS session_row
  WHERE session_row.id = session_id
    AND session_row.cart_id = locked_cart.id
    AND session_row.session_token = p_session_token
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'QR session not found for this shop'
      USING ERRCODE = 'P0002';
  END IF;

  PERFORM shop.id
  FROM public.shops AS shop
  WHERE shop.id = locked_session.shop_id
    AND shop.owner_user_id = current_user_id
    AND shop.is_active = true
  FOR SHARE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'QR session not found for this shop'
      USING ERRCODE = 'P0002';
  END IF;

  v_current_time := clock_timestamp();

  IF locked_session.status = 'used'
     OR locked_session.used_at IS NOT NULL
     OR locked_session.confirmed_by_user_id IS NOT NULL THEN
    RAISE EXCEPTION 'QR session has already been confirmed'
      USING ERRCODE = '55000';
  END IF;

  IF locked_session.status <> 'active' THEN
    RAISE EXCEPTION 'QR session is not active' USING ERRCODE = '55000';
  END IF;

  IF locked_session.expires_at <= v_current_time THEN
    RAISE EXCEPTION 'QR session has expired' USING ERRCODE = '55000';
  END IF;

  IF locked_cart.status <> 'active'
     OR locked_cart.user_id IS DISTINCT FROM locked_session.user_id
     OR locked_cart.shop_id IS DISTINCT FROM locked_session.shop_id THEN
    RAISE EXCEPTION 'Cart is no longer eligible for confirmation'
      USING ERRCODE = '55000';
  END IF;

  SELECT
    COUNT(*)::INTEGER,
    COUNT(item.product_id)::INTEGER,
    COALESCE(SUM(item.quantity), 0)::INTEGER,
    COALESCE(SUM(item.line_total), 0)
    INTO
      snapshot_line_count,
      snapshot_product_count,
      snapshot_item_count,
      snapshot_total
  FROM public.qr_session_items AS item
  WHERE item.qr_session_id = locked_session.id;

  IF snapshot_line_count = 0
     OR snapshot_product_count <> snapshot_line_count
     OR locked_session.item_count IS DISTINCT FROM snapshot_item_count
     OR locked_session.total_amount IS DISTINCT FROM snapshot_total THEN
    RAISE EXCEPTION '[QR_PRODUCT_SNAPSHOT_MISSING] QR session snapshot is missing or inconsistent'
      USING ERRCODE = '55000';
  END IF;

  INSERT INTO public.verified_transactions (
    source_qr_session_id,
    customer_user_id,
    shop_id,
    shop_name,
    confirmed_by_user_id,
    item_count,
    total_amount,
    confirmed_at
  )
  SELECT
    locked_session.id,
    locked_session.user_id,
    locked_session.shop_id,
    shop.name,
    current_user_id,
    locked_session.item_count,
    locked_session.total_amount,
    v_current_time
  FROM public.shops AS shop
  WHERE shop.id = locked_session.shop_id
    AND shop.owner_user_id = current_user_id
    AND shop.is_active = true
  RETURNING id INTO transaction_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Verified transaction could not be created'
      USING ERRCODE = '55000';
  END IF;

  INSERT INTO public.verified_transaction_items (
    verified_transaction_id,
    shop_product_id,
    product_id,
    product_name,
    quantity,
    unit_price,
    line_total
  )
  SELECT
    transaction_id,
    item.shop_product_id,
    item.product_id,
    item.product_name,
    item.quantity,
    item.unit_price,
    item.line_total
  FROM public.qr_session_items AS item
  WHERE item.qr_session_id = locked_session.id
  ORDER BY item.created_at, item.id;

  GET DIAGNOSTICS verified_item_count = ROW_COUNT;

  IF verified_item_count <> snapshot_line_count THEN
    RAISE EXCEPTION 'Verified transaction item copy is incomplete'
      USING ERRCODE = '55000';
  END IF;

  UPDATE public.qr_sessions
  SET status = 'used',
      used_at = v_current_time,
      confirmed_by_user_id = current_user_id
  WHERE id = locked_session.id AND status = 'active'
  RETURNING * INTO locked_session;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'QR session could not be confirmed'
      USING ERRCODE = '55000';
  END IF;

  UPDATE public.carts
  SET status = 'checked_out'
  WHERE id = locked_cart.id
    AND status = 'active'
    AND user_id = locked_session.user_id
    AND shop_id = locked_session.shop_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart could not be checked out'
      USING ERRCODE = '55000';
  END IF;

  SELECT jsonb_build_object(
           'session_id', session_row.id,
           'session_token', session_row.session_token,
           'status', session_row.status,
           'expires_at', session_row.expires_at,
           'used_at', session_row.used_at,
           'shop_id', session_row.shop_id,
           'shop_name', shop.name,
           'item_count', session_row.item_count,
           'total_amount', session_row.total_amount,
           'items', COALESCE(
             (
               SELECT jsonb_agg(
                        jsonb_build_object(
                          'id', item.id,
                          'shop_product_id', item.shop_product_id,
                          'product_id', item.product_id,
                          'product_name', item.product_name,
                          'quantity', item.quantity,
                          'unit_price', item.unit_price,
                          'line_total', item.line_total
                        ) ORDER BY item.created_at, item.id
                      )
               FROM public.qr_session_items AS item
               WHERE item.qr_session_id = session_row.id
             ),
             '[]'::JSONB
           )
         )
    INTO payload
  FROM public.qr_sessions AS session_row
  JOIN public.shops AS shop ON shop.id = session_row.shop_id
  WHERE session_row.id = locked_session.id;

  RETURN payload;
END;
$function$;

REVOKE ALL ON FUNCTION public.confirm_qr_session(TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_qr_session(TEXT) TO authenticated;

-- The evidence UUID is nullable only for preserved legacy reviews. New rows
-- are accepted exclusively through submit_product_review and must have a
-- matching server-created verified transaction item.
ALTER TABLE public.reviews
  ADD COLUMN verified_transaction_item_id UUID
  REFERENCES public.verified_transaction_items(id) ON DELETE RESTRICT;

CREATE INDEX reviews_verified_transaction_item_idx
  ON public.reviews(verified_transaction_item_id)
  WHERE verified_transaction_item_id IS NOT NULL;

-- Legacy client booleans are not proof. Preserve their content and timestamps
-- while removing the untrusted verified badge before installing the guard.
ALTER TABLE public.reviews DISABLE TRIGGER set_reviews_updated_at;
UPDATE public.reviews
SET is_verified_purchase = false
WHERE verified_transaction_item_id IS NULL
  AND is_verified_purchase IS DISTINCT FROM false;
ALTER TABLE public.reviews ENABLE TRIGGER set_reviews_updated_at;

DROP POLICY IF EXISTS reviews_insert_own ON public.reviews;
DROP POLICY IF EXISTS reviews_update_own ON public.reviews;
DROP POLICY IF EXISTS reviews_delete_own ON public.reviews;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.reviews FROM authenticated;

CREATE FUNCTION public.enforce_product_review_evidence()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF OLD.user_id IS DISTINCT FROM NEW.user_id
       OR OLD.product_id IS DISTINCT FROM NEW.product_id
       OR OLD.verified_transaction_item_id IS DISTINCT FROM
          NEW.verified_transaction_item_id
       OR OLD.is_verified_purchase IS DISTINCT FROM
          NEW.is_verified_purchase THEN
      RAISE EXCEPTION '[REVIEW_EVIDENCE_IMMUTABLE] review ownership and verification evidence cannot be changed'
        USING ERRCODE = '42501';
    END IF;

    RETURN NEW;
  END IF;

  IF NEW.verified_transaction_item_id IS NULL THEN
    RAISE EXCEPTION '[REVIEW_NOT_VERIFIED] a verified transaction item is required'
      USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.verified_transaction_items AS verified_item
    JOIN public.verified_transactions AS verified_transaction
      ON verified_transaction.id = verified_item.verified_transaction_id
    WHERE verified_item.id = NEW.verified_transaction_item_id
      AND verified_item.product_id = NEW.product_id
      AND verified_transaction.customer_user_id = NEW.user_id
  ) THEN
    RAISE EXCEPTION '[REVIEW_EVIDENCE_MISMATCH] review evidence does not match the customer and product'
      USING ERRCODE = '42501';
  END IF;

  NEW.is_verified_purchase := true;
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.enforce_product_review_evidence()
  FROM PUBLIC, anon, authenticated;

CREATE TRIGGER enforce_product_review_evidence
  BEFORE INSERT OR UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.enforce_product_review_evidence();

CREATE OR REPLACE FUNCTION public.refresh_product_rating_after_review()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $function$
DECLARE
  target_product_id UUID;
BEGIN
  target_product_id := CASE WHEN TG_OP = 'DELETE'
    THEN OLD.product_id ELSE NEW.product_id END;

  UPDATE public.products AS product
  SET rating = summary.average_rating,
      reviews_count = summary.review_count
  FROM (
    SELECT
      COALESCE(ROUND(AVG(review.rating)::NUMERIC, 1), 0) AS average_rating,
      COUNT(*)::INTEGER AS review_count
    FROM public.reviews AS review
    WHERE review.product_id = target_product_id
      AND review.verified_transaction_item_id IS NOT NULL
      AND review.is_verified_purchase = true
  ) AS summary
  WHERE product.id = target_product_id;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.refresh_product_rating_after_review()
  FROM PUBLIC, anon, authenticated;

-- Recalculate cached product summaries because pre-0009 values included
-- reviews whose client-provided verified flag was not authoritative.
UPDATE public.products AS product
SET rating = COALESCE(
      (
        SELECT ROUND(AVG(review.rating)::NUMERIC, 1)
        FROM public.reviews AS review
        WHERE review.product_id = product.id
          AND review.verified_transaction_item_id IS NOT NULL
          AND review.is_verified_purchase = true
      ),
      0
    ),
    reviews_count = (
      SELECT COUNT(*)::INTEGER
      FROM public.reviews AS review
      WHERE review.product_id = product.id
        AND review.verified_transaction_item_id IS NOT NULL
        AND review.is_verified_purchase = true
    );

CREATE FUNCTION public.get_product_reviews(
  p_product_id UUID,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, auth
AS $function$
DECLARE
  payload JSONB;
BEGIN
  IF p_product_id IS NULL
     OR p_limit IS NULL OR p_limit < 1 OR p_limit > 50
     OR p_offset IS NULL OR p_offset < 0 THEN
    RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT] invalid product, limit, or offset'
      USING ERRCODE = '22023';
  END IF;

  SELECT jsonb_build_object(
           'product_id', product.id,
           'average_rating', product.rating,
           'review_count', product.reviews_count,
           'rating_distribution', jsonb_build_object(
             '1', COUNT(review.id) FILTER (WHERE review.rating = 1),
             '2', COUNT(review.id) FILTER (WHERE review.rating = 2),
             '3', COUNT(review.id) FILTER (WHERE review.rating = 3),
             '4', COUNT(review.id) FILTER (WHERE review.rating = 4),
             '5', COUNT(review.id) FILTER (WHERE review.rating = 5)
           ),
           'reviews', COALESCE(
             (
               SELECT jsonb_agg(
                        jsonb_build_object(
                          'id', page.id,
                          'user_id', page.user_id,
                          'product_id', page.product_id,
                          'rating', page.rating,
                          'title', page.title,
                          'comment', page.comment,
                          'images', page.images,
                          'is_verified_purchase',
                            page.verified_transaction_item_id IS NOT NULL,
                          'helpful_count', page.helpful_count,
                          'created_at', page.created_at,
                          'updated_at', page.updated_at,
                          'can_edit',
                            COALESCE(page.user_id = auth.uid(), false)
                        ) ORDER BY page.created_at DESC, page.id DESC
                      )
               FROM (
                 SELECT review_page.*
                 FROM public.reviews AS review_page
                 WHERE review_page.product_id = p_product_id
                 ORDER BY review_page.created_at DESC, review_page.id DESC
                 LIMIT p_limit OFFSET p_offset
               ) AS page
             ),
             '[]'::JSONB
           )
         )
    INTO payload
  FROM public.products AS product
  LEFT JOIN public.reviews AS review
    ON review.product_id = product.id
   AND review.verified_transaction_item_id IS NOT NULL
   AND review.is_verified_purchase = true
  WHERE product.id = p_product_id
    AND product.is_active = true
  GROUP BY product.id, product.rating, product.reviews_count;

  IF payload IS NULL THEN
    RAISE EXCEPTION '[REVIEW_PRODUCT_NOT_FOUND] active product not found'
      USING ERRCODE = 'P0002';
  END IF;

  RETURN payload;
END;
$function$;

CREATE FUNCTION public.get_product_review_eligibility(p_product_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, auth
AS $function$
DECLARE
  current_user_id UUID := auth.uid();
  existing_review_id UUID;
  evidence_item_id UUID;
  evidence_transaction_id UUID;
  evidence_confirmed_at TIMESTAMPTZ;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION '[REVIEW_AUTH_REQUIRED] authentication required'
      USING ERRCODE = '28000';
  END IF;

  IF p_product_id IS NULL THEN
    RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT] product_id is required'
      USING ERRCODE = '22023';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.products AS product
    WHERE product.id = p_product_id
  ) THEN
    RAISE EXCEPTION '[REVIEW_PRODUCT_NOT_FOUND] product not found'
      USING ERRCODE = 'P0002';
  END IF;

  SELECT review.id
    INTO existing_review_id
  FROM public.reviews AS review
  WHERE review.user_id = current_user_id
    AND review.product_id = p_product_id;

  SELECT
    verified_item.id,
    verified_transaction.id,
    verified_transaction.confirmed_at
    INTO
      evidence_item_id,
      evidence_transaction_id,
      evidence_confirmed_at
  FROM public.verified_transaction_items AS verified_item
  JOIN public.verified_transactions AS verified_transaction
    ON verified_transaction.id = verified_item.verified_transaction_id
  WHERE verified_transaction.customer_user_id = current_user_id
    AND verified_item.product_id = p_product_id
  ORDER BY verified_transaction.confirmed_at, verified_item.id
  LIMIT 1;

  RETURN jsonb_build_object(
    'product_id', p_product_id,
    'eligible', evidence_item_id IS NOT NULL,
    'can_submit',
      evidence_item_id IS NOT NULL AND existing_review_id IS NULL,
    'existing_review_id', existing_review_id,
    'verified_transaction_item_id', evidence_item_id,
    'verified_transaction_id', evidence_transaction_id,
    'verified_at', evidence_confirmed_at
  );
END;
$function$;

CREATE FUNCTION public.submit_product_review(
  p_product_id UUID,
  p_rating INTEGER,
  p_title TEXT DEFAULT NULL,
  p_comment TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, auth
AS $function$
DECLARE
  current_user_id UUID := auth.uid();
  evidence_item_id UUID;
  review_row public.reviews%ROWTYPE;
  was_created BOOLEAN := false;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION '[REVIEW_AUTH_REQUIRED] authentication required'
      USING ERRCODE = '28000';
  END IF;

  IF p_product_id IS NULL THEN
    RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT] product_id is required'
      USING ERRCODE = '22023';
  END IF;

  IF p_rating IS NULL OR p_rating < 1 OR p_rating > 5 THEN
    RAISE EXCEPTION '[REVIEW_INVALID_RATING] rating must be between 1 and 5'
      USING ERRCODE = '22023';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.products AS product
    WHERE product.id = p_product_id
  ) THEN
    RAISE EXCEPTION '[REVIEW_PRODUCT_NOT_FOUND] product not found'
      USING ERRCODE = 'P0002';
  END IF;

  SELECT review.*
    INTO review_row
  FROM public.reviews AS review
  WHERE review.user_id = current_user_id
    AND review.product_id = p_product_id
  FOR UPDATE;

  IF NOT FOUND THEN
    SELECT verified_item.id
      INTO evidence_item_id
    FROM public.verified_transaction_items AS verified_item
    JOIN public.verified_transactions AS verified_transaction
      ON verified_transaction.id = verified_item.verified_transaction_id
    WHERE verified_transaction.customer_user_id = current_user_id
      AND verified_item.product_id = p_product_id
    ORDER BY verified_transaction.confirmed_at, verified_item.id
    LIMIT 1;

    IF evidence_item_id IS NULL THEN
      RAISE EXCEPTION '[REVIEW_NOT_VERIFIED] verified physical purchase not found'
        USING ERRCODE = '42501';
    END IF;

    BEGIN
      INSERT INTO public.reviews (
        user_id,
        product_id,
        rating,
        title,
        comment,
        images,
        is_verified_purchase,
        verified_transaction_item_id
      ) VALUES (
        current_user_id,
        p_product_id,
        p_rating,
        NULLIF(btrim(p_title), ''),
        NULLIF(btrim(p_comment), ''),
        '{}'::TEXT[],
        true,
        evidence_item_id
      )
      RETURNING * INTO review_row;
      was_created := true;
    EXCEPTION
      WHEN unique_violation THEN
        SELECT review.*
          INTO review_row
        FROM public.reviews AS review
        WHERE review.user_id = current_user_id
          AND review.product_id = p_product_id;

        IF NOT FOUND THEN
          RAISE;
        END IF;
    END;
  END IF;

  RETURN jsonb_build_object(
    'created', was_created,
    'review', jsonb_build_object(
      'id', review_row.id,
      'user_id', review_row.user_id,
      'product_id', review_row.product_id,
      'rating', review_row.rating,
      'title', review_row.title,
      'comment', review_row.comment,
      'images', review_row.images,
      'is_verified_purchase',
        review_row.verified_transaction_item_id IS NOT NULL,
      'helpful_count', review_row.helpful_count,
      'created_at', review_row.created_at,
      'updated_at', review_row.updated_at
    )
  );
END;
$function$;

CREATE FUNCTION public.update_product_review(
  p_review_id UUID,
  p_rating INTEGER,
  p_title TEXT DEFAULT NULL,
  p_comment TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, auth
AS $function$
DECLARE
  current_user_id UUID := auth.uid();
  review_row public.reviews%ROWTYPE;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION '[REVIEW_AUTH_REQUIRED] authentication required'
      USING ERRCODE = '28000';
  END IF;

  IF p_review_id IS NULL THEN
    RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT] review_id is required'
      USING ERRCODE = '22023';
  END IF;

  IF p_rating IS NULL OR p_rating < 1 OR p_rating > 5 THEN
    RAISE EXCEPTION '[REVIEW_INVALID_RATING] rating must be between 1 and 5'
      USING ERRCODE = '22023';
  END IF;

  UPDATE public.reviews AS review
  SET rating = p_rating,
      title = NULLIF(btrim(p_title), ''),
      comment = NULLIF(btrim(p_comment), '')
  WHERE review.id = p_review_id
    AND review.user_id = current_user_id
  RETURNING review.* INTO review_row;

  IF NOT FOUND THEN
    RAISE EXCEPTION '[REVIEW_NOT_FOUND] review not found'
      USING ERRCODE = 'P0002';
  END IF;

  RETURN jsonb_build_object(
    'id', review_row.id,
    'user_id', review_row.user_id,
    'product_id', review_row.product_id,
    'rating', review_row.rating,
    'title', review_row.title,
    'comment', review_row.comment,
    'images', review_row.images,
    'is_verified_purchase',
      review_row.verified_transaction_item_id IS NOT NULL,
    'helpful_count', review_row.helpful_count,
    'created_at', review_row.created_at,
    'updated_at', review_row.updated_at
  );
END;
$function$;

CREATE FUNCTION public.delete_product_review(p_review_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, auth
AS $function$
DECLARE
  current_user_id UUID := auth.uid();
  deleted_review_id UUID;
BEGIN
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION '[REVIEW_AUTH_REQUIRED] authentication required'
      USING ERRCODE = '28000';
  END IF;

  IF p_review_id IS NULL THEN
    RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT] review_id is required'
      USING ERRCODE = '22023';
  END IF;

  DELETE FROM public.reviews AS review
  WHERE review.id = p_review_id
    AND review.user_id = current_user_id
  RETURNING review.id INTO deleted_review_id;

  RETURN jsonb_build_object(
    'review_id', p_review_id,
    'deleted', deleted_review_id IS NOT NULL
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.get_product_reviews(UUID, INTEGER, INTEGER)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.get_product_review_eligibility(UUID)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.submit_product_review(UUID, INTEGER, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.update_product_review(UUID, INTEGER, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.delete_product_review(UUID)
  FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.get_product_reviews(UUID, INTEGER, INTEGER)
  TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_product_review_eligibility(UUID)
  TO authenticated;
GRANT EXECUTE ON FUNCTION public.submit_product_review(UUID, INTEGER, TEXT, TEXT)
  TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_product_review(UUID, INTEGER, TEXT, TEXT)
  TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_product_review(UUID)
  TO authenticated;

-- Only the three active public-read media buckets are provisioned. No
-- storage.objects SELECT/INSERT/UPDATE/DELETE policy is created for anon or
-- authenticated: public object download is provided by the bucket flag while
-- listing and every client mutation remain denied by RLS.
INSERT INTO storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
) VALUES
  (
    'product-images',
    'product-images',
    true,
    8388608,
    ARRAY['image/jpeg', 'image/png', 'image/webp']::TEXT[]
  ),
  (
    'category-images',
    'category-images',
    true,
    2097152,
    ARRAY['image/jpeg', 'image/png', 'image/webp']::TEXT[]
  ),
  (
    'banner-images',
    'banner-images',
    true,
    5242880,
    ARRAY['image/jpeg', 'image/png', 'image/webp']::TEXT[]
  )
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

CREATE FUNCTION public.enforce_active_media_storage_contract()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  uuid_pattern CONSTANT TEXT :=
    '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}';
  version_file_pattern CONSTANT TEXT :=
    'v[0-9]{14}/[a-z0-9][a-z0-9._-]{0,127}\.(jpg|jpeg|png|webp)';
BEGIN
  IF NEW.bucket_id = 'product-images'
     AND NOT (
       NEW.name ~ (
         '^catalog/' || uuid_pattern || '/' || version_file_pattern || '$'
       )
       OR NEW.name ~ (
         '^shops/' || uuid_pattern || '/' || uuid_pattern || '/' ||
         version_file_pattern || '$'
       )
     ) THEN
    RAISE EXCEPTION '[STORAGE_INVALID_PATH] invalid product-images object path'
      USING ERRCODE = '23514';
  ELSIF NEW.bucket_id = 'category-images'
        AND NEW.name !~ (
          '^catalog/' || uuid_pattern || '/' ||
          version_file_pattern || '$'
        ) THEN
    RAISE EXCEPTION '[STORAGE_INVALID_PATH] invalid category-images object path'
      USING ERRCODE = '23514';
  ELSIF NEW.bucket_id = 'banner-images'
        AND NEW.name !~ (
          '^catalog/' || uuid_pattern || '/' ||
          version_file_pattern || '$'
        ) THEN
    RAISE EXCEPTION '[STORAGE_INVALID_PATH] invalid banner-images object path'
      USING ERRCODE = '23514';
  END IF;

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.enforce_active_media_storage_contract()
  FROM PUBLIC, anon, authenticated;

CREATE TRIGGER enforce_active_media_storage_path
  BEFORE INSERT OR UPDATE OF bucket_id, name ON storage.objects
  FOR EACH ROW EXECUTE FUNCTION public.enforce_active_media_storage_contract();

COMMIT;
