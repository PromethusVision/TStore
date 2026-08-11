-- =============================================================
-- Esnafta Var - QR + verified purchase release hardening
-- =============================================================
-- Additive migration. Run only after supabase_migration_qr_verification.sql.
--
-- This migration replaces the two existing SECURITY DEFINER RPC bodies; it
-- does not rewrite or delete migration history and does not mutate live data.
-- It closes two release-critical race windows:
-- - QR creation now locks the catalog rows used by the immutable snapshot, so
--   product activation, availability, name, or price cannot change mid-copy.
-- - QR confirmation refreshes its authoritative clock only after all possibly
--   blocking locks are held, so a lock wait cannot make an expired QR valid.
--
-- Stock is deliberately not reserved or decremented here. The established QR
-- model is physical-purchase proof, not checkout or inventory reservation.
-- =============================================================

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '5min';

DO $preflight$
DECLARE
  v_missing_tables TEXT;
  v_missing_columns TEXT;
BEGIN
  SELECT string_agg(required_table, ', ' ORDER BY required_table)
    INTO v_missing_tables
  FROM (
    VALUES
      ('auth.users'),
      ('public.profiles'),
      ('public.products'),
      ('public.shops'),
      ('public.shop_products'),
      ('public.carts'),
      ('public.cart_items_v2'),
      ('public.qr_sessions'),
      ('public.qr_session_items'),
      ('public.verified_transactions'),
      ('public.verified_transaction_items')
  ) AS required_tables(required_table)
  WHERE to_regclass(required_table) IS NULL;

  IF v_missing_tables IS NOT NULL THEN
    RAISE EXCEPTION
      'Required QR tables are missing: %. Run prerequisite migrations first.',
      v_missing_tables
      USING ERRCODE = '42P01';
  END IF;

  SELECT string_agg(
           format('%I.%I.%I', schema_name, table_name, column_name),
           ', '
           ORDER BY schema_name, table_name, column_name
         )
    INTO v_missing_columns
  FROM (
    VALUES
      ('public', 'products', 'id'),
      ('public', 'products', 'name'),
      ('public', 'products', 'is_active'),
      ('public', 'shops', 'id'),
      ('public', 'shops', 'owner_user_id'),
      ('public', 'shops', 'name'),
      ('public', 'shops', 'is_active'),
      ('public', 'shop_products', 'id'),
      ('public', 'shop_products', 'shop_id'),
      ('public', 'shop_products', 'product_id'),
      ('public', 'shop_products', 'price'),
      ('public', 'shop_products', 'is_active'),
      ('public', 'shop_products', 'is_available'),
      ('public', 'carts', 'id'),
      ('public', 'carts', 'user_id'),
      ('public', 'carts', 'shop_id'),
      ('public', 'carts', 'status'),
      ('public', 'cart_items_v2', 'id'),
      ('public', 'cart_items_v2', 'cart_id'),
      ('public', 'cart_items_v2', 'shop_product_id'),
      ('public', 'cart_items_v2', 'quantity'),
      ('public', 'qr_sessions', 'id'),
      ('public', 'qr_sessions', 'session_token'),
      ('public', 'qr_sessions', 'user_id'),
      ('public', 'qr_sessions', 'cart_id'),
      ('public', 'qr_sessions', 'shop_id'),
      ('public', 'qr_sessions', 'status'),
      ('public', 'qr_sessions', 'expires_at'),
      ('public', 'qr_sessions', 'used_at'),
      ('public', 'qr_sessions', 'item_count'),
      ('public', 'qr_sessions', 'total_amount'),
      ('public', 'qr_sessions', 'confirmed_by_user_id')
  ) AS required_columns(schema_name, table_name, column_name)
  WHERE NOT EXISTS (
    SELECT 1
    FROM information_schema.columns AS c
    WHERE c.table_schema = schema_name
      AND c.table_name = table_name
      AND c.column_name = column_name
  );

  IF v_missing_columns IS NOT NULL THEN
    RAISE EXCEPTION
      'Required QR columns are missing: %. Run prerequisite migrations first.',
      v_missing_columns
      USING ERRCODE = '42703';
  END IF;
END
$preflight$;

-- ====================
-- Customer RPC: locked, immutable QR snapshot
-- ====================
CREATE OR REPLACE FUNCTION public.create_qr_session(p_cart_id UUID)
RETURNS public.qr_sessions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  v_user_id UUID;
  v_now TIMESTAMPTZ;
  v_cart public.carts%ROWTYPE;
  v_session public.qr_sessions%ROWTYPE;
  v_cart_line_count INTEGER;
  v_snapshot_line_count INTEGER;
  v_snapshot_item_count INTEGER;
  v_snapshot_total NUMERIC;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required'
      USING ERRCODE = '28000';
  END IF;

  -- Cart-item mutation triggers use this same parent row as their
  -- serialization point.
  SELECT c.*
    INTO v_cart
  FROM public.carts AS c
  WHERE c.id = p_cart_id
    AND c.user_id = v_user_id
    AND c.status = 'active'
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Active cart not found'
      USING ERRCODE = 'P0002';
  END IF;

  -- Keep shop activation stable until snapshot creation commits.
  PERFORM s.id
  FROM public.shops AS s
  WHERE s.id = v_cart.shop_id
    AND s.is_active = TRUE
  FOR SHARE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Shop is not active'
      USING ERRCODE = '55000';
  END IF;

  SELECT COUNT(*)::INTEGER
    INTO v_cart_line_count
  FROM public.cart_items_v2 AS ci
  WHERE ci.cart_id = v_cart.id;

  IF v_cart_line_count = 0 THEN
    RAISE EXCEPTION 'Cannot create QR session for an empty cart'
      USING ERRCODE = 'P0001';
  END IF;

  -- Lock every catalog row represented by the immutable snapshot. Without
  -- these locks, a price/availability/name update could commit between the
  -- eligibility check and the INSERT ... SELECT below.
  PERFORM sp.id
  FROM public.cart_items_v2 AS ci
  JOIN public.shop_products AS sp ON sp.id = ci.shop_product_id
  JOIN public.products AS p ON p.id = sp.product_id
  WHERE ci.cart_id = v_cart.id
  ORDER BY sp.id, p.id
  FOR SHARE OF sp, p;

  IF EXISTS (
    SELECT 1
    FROM public.cart_items_v2 AS ci
    LEFT JOIN public.shop_products AS sp ON sp.id = ci.shop_product_id
    LEFT JOIN public.products AS p ON p.id = sp.product_id
    WHERE ci.cart_id = v_cart.id
      AND (
        sp.id IS NULL
        OR p.id IS NULL
        OR sp.shop_id IS DISTINCT FROM v_cart.shop_id
        OR sp.is_active IS NOT TRUE
        OR sp.is_available IS NOT TRUE
        OR p.is_active IS NOT TRUE
        OR sp.price IS NULL
        OR sp.price < 0
      )
  ) THEN
    RAISE EXCEPTION 'Cart contains an unavailable or different shop item'
      USING ERRCODE = '23514';
  END IF;

  -- Refresh the clock only after every potentially blocking lock is held.
  v_now := clock_timestamp();

  UPDATE public.qr_sessions AS qs
  SET status = 'expired'
  WHERE qs.cart_id = v_cart.id
    AND qs.user_id = v_user_id
    AND qs.status = 'active'
    AND qs.expires_at <= v_now;

  SELECT qs.*
    INTO v_session
  FROM public.qr_sessions AS qs
  WHERE qs.cart_id = v_cart.id
    AND qs.user_id = v_user_id
    AND qs.status = 'active'
    AND qs.expires_at > v_now
  LIMIT 1
  FOR UPDATE;

  IF FOUND THEN
    SELECT
      COUNT(*)::INTEGER,
      COALESCE(SUM(qsi.quantity), 0)::INTEGER,
      COALESCE(SUM(qsi.line_total), 0)
      INTO
        v_snapshot_line_count,
        v_snapshot_item_count,
        v_snapshot_total
    FROM public.qr_session_items AS qsi
    WHERE qsi.qr_session_id = v_session.id;

    IF v_snapshot_line_count > 0
       AND v_session.item_count = v_snapshot_item_count
       AND v_session.total_amount = v_snapshot_total THEN
      RETURN v_session;
    END IF;

    UPDATE public.qr_sessions
    SET status = 'cancelled'
    WHERE id = v_session.id;
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
  )
  VALUES (
    encode(gen_random_bytes(32), 'hex'),
    v_user_id,
    v_cart.id,
    v_cart.shop_id,
    'active',
    v_now + interval '2 minutes',
    NULL,
    0,
    0,
    NULL
  )
  RETURNING * INTO v_session;

  INSERT INTO public.qr_session_items (
    qr_session_id,
    shop_product_id,
    product_name,
    quantity,
    unit_price
  )
  SELECT
    v_session.id,
    sp.id,
    p.name,
    ci.quantity,
    sp.price
  FROM public.cart_items_v2 AS ci
  JOIN public.shop_products AS sp
    ON sp.id = ci.shop_product_id
   AND sp.shop_id = v_cart.shop_id
   AND sp.is_active = TRUE
   AND sp.is_available = TRUE
  JOIN public.products AS p
    ON p.id = sp.product_id
   AND p.is_active = TRUE
  WHERE ci.cart_id = v_cart.id
  ORDER BY ci.id;

  GET DIAGNOSTICS v_snapshot_line_count = ROW_COUNT;

  IF v_snapshot_line_count <> v_cart_line_count THEN
    RAISE EXCEPTION
      'Cart snapshot is incomplete (% of % lines copied)',
      v_snapshot_line_count,
      v_cart_line_count
      USING ERRCODE = 'P0001';
  END IF;

  SELECT
    COALESCE(SUM(qsi.quantity), 0)::INTEGER,
    COALESCE(SUM(qsi.line_total), 0)
    INTO v_snapshot_item_count, v_snapshot_total
  FROM public.qr_session_items AS qsi
  WHERE qsi.qr_session_id = v_session.id;

  UPDATE public.qr_sessions
  SET item_count = v_snapshot_item_count,
      total_amount = v_snapshot_total
  WHERE id = v_session.id
  RETURNING * INTO v_session;

  RETURN v_session;
END;
$function$;

REVOKE ALL ON FUNCTION public.create_qr_session(UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_qr_session(UUID) TO authenticated;

-- ====================
-- Merchant RPC: one-time atomic confirmation
-- ====================
CREATE OR REPLACE FUNCTION public.confirm_qr_session(p_session_token TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  v_user_id UUID := auth.uid();
  v_now TIMESTAMPTZ;
  v_session_id UUID;
  v_cart_id UUID;
  v_cart public.carts%ROWTYPE;
  v_session public.qr_sessions%ROWTYPE;
  v_snapshot_line_count INTEGER;
  v_snapshot_item_count INTEGER;
  v_snapshot_total NUMERIC;
  v_verified_transaction_id UUID;
  v_verified_item_count INTEGER;
  v_payload JSONB;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required'
      USING ERRCODE = '28000';
  END IF;

  IF p_session_token IS NULL OR btrim(p_session_token) = '' THEN
    RAISE EXCEPTION 'QR session token is required'
      USING ERRCODE = '22023';
  END IF;

  -- Keep the authorization role stable for the whole confirmation.
  PERFORM p.id
  FROM public.profiles AS p
  WHERE p.id = v_user_id
    AND p.role IN ('merchant', 'admin')
  FOR SHARE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Merchant access required'
      USING ERRCODE = '42501';
  END IF;

  SELECT qs.id, qs.cart_id
    INTO v_session_id, v_cart_id
  FROM public.qr_sessions AS qs
  JOIN public.shops AS s
    ON s.id = qs.shop_id
   AND s.owner_user_id = v_user_id
   AND s.is_active = TRUE
  WHERE qs.session_token = p_session_token;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'QR session not found for this shop'
      USING ERRCODE = 'P0002';
  END IF;

  -- All confirmation paths serialize cart -> QR session.
  SELECT c.*
    INTO v_cart
  FROM public.carts AS c
  WHERE c.id = v_cart_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart not found for QR session'
      USING ERRCODE = 'P0002';
  END IF;

  SELECT qs.*
    INTO v_session
  FROM public.qr_sessions AS qs
  WHERE qs.id = v_session_id
    AND qs.cart_id = v_cart.id
    AND qs.session_token = p_session_token
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'QR session not found for this shop'
      USING ERRCODE = 'P0002';
  END IF;

  -- Re-check and lock the owned shop after any cart/session lock wait.
  PERFORM owned_shop.id
  FROM public.shops AS owned_shop
  WHERE owned_shop.id = v_session.shop_id
    AND owned_shop.owner_user_id = v_user_id
    AND owned_shop.is_active = TRUE
  FOR SHARE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'QR session not found for this shop'
      USING ERRCODE = 'P0002';
  END IF;

  -- This must be after every blocking lock. A timestamp captured at function
  -- entry can become stale while another confirmation or cart edit holds them.
  v_now := clock_timestamp();

  IF v_session.status = 'used'
     OR v_session.used_at IS NOT NULL
     OR v_session.confirmed_by_user_id IS NOT NULL THEN
    RAISE EXCEPTION 'QR session has already been confirmed'
      USING ERRCODE = '55000';
  END IF;

  IF v_session.status <> 'active' THEN
    RAISE EXCEPTION 'QR session is not active'
      USING ERRCODE = '55000';
  END IF;

  IF v_session.expires_at <= v_now THEN
    RAISE EXCEPTION 'QR session has expired'
      USING ERRCODE = '55000';
  END IF;

  IF v_cart.status <> 'active'
     OR v_cart.user_id IS DISTINCT FROM v_session.user_id
     OR v_cart.shop_id IS DISTINCT FROM v_session.shop_id THEN
    RAISE EXCEPTION 'Cart is no longer eligible for confirmation'
      USING ERRCODE = '55000';
  END IF;

  SELECT
    COUNT(*)::INTEGER,
    COALESCE(SUM(qsi.quantity), 0)::INTEGER,
    COALESCE(SUM(qsi.line_total), 0)
    INTO
      v_snapshot_line_count,
      v_snapshot_item_count,
      v_snapshot_total
  FROM public.qr_session_items AS qsi
  WHERE qsi.qr_session_id = v_session.id;

  IF v_snapshot_line_count = 0
     OR v_session.item_count IS DISTINCT FROM v_snapshot_item_count
     OR v_session.total_amount IS DISTINCT FROM v_snapshot_total THEN
    RAISE EXCEPTION 'QR session snapshot is missing or inconsistent'
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
    v_session.id,
    v_session.user_id,
    v_session.shop_id,
    s.name,
    v_user_id,
    v_session.item_count,
    v_session.total_amount,
    v_now
  FROM public.shops AS s
  WHERE s.id = v_session.shop_id
    AND s.owner_user_id = v_user_id
    AND s.is_active = TRUE
  RETURNING id INTO v_verified_transaction_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Verified transaction could not be created'
      USING ERRCODE = '55000';
  END IF;

  INSERT INTO public.verified_transaction_items (
    verified_transaction_id,
    shop_product_id,
    product_name,
    quantity,
    unit_price,
    line_total
  )
  SELECT
    v_verified_transaction_id,
    qsi.shop_product_id,
    qsi.product_name,
    qsi.quantity,
    qsi.unit_price,
    qsi.line_total
  FROM public.qr_session_items AS qsi
  WHERE qsi.qr_session_id = v_session.id
  ORDER BY qsi.created_at, qsi.id;

  GET DIAGNOSTICS v_verified_item_count = ROW_COUNT;

  IF v_verified_item_count <> v_snapshot_line_count THEN
    RAISE EXCEPTION 'Verified transaction item copy is incomplete'
      USING ERRCODE = '55000';
  END IF;

  UPDATE public.qr_sessions
  SET status = 'used',
      used_at = v_now,
      confirmed_by_user_id = v_user_id
  WHERE id = v_session.id
    AND status = 'active'
  RETURNING * INTO v_session;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'QR session could not be confirmed'
      USING ERRCODE = '55000';
  END IF;

  UPDATE public.carts
  SET status = 'checked_out'
  WHERE id = v_cart.id
    AND status = 'active'
    AND user_id = v_session.user_id
    AND shop_id = v_session.shop_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cart could not be checked out'
      USING ERRCODE = '55000';
  END IF;

  SELECT jsonb_build_object(
           'session_id', qs.id,
           'session_token', qs.session_token,
           'status', qs.status,
           'expires_at', qs.expires_at,
           'used_at', qs.used_at,
           'shop_id', qs.shop_id,
           'shop_name', s.name,
           'item_count', qs.item_count,
           'total_amount', qs.total_amount,
           'items', COALESCE(
             (
               SELECT jsonb_agg(
                        jsonb_build_object(
                          'id', qsi.id,
                          'shop_product_id', qsi.shop_product_id,
                          'product_name', qsi.product_name,
                          'quantity', qsi.quantity,
                          'unit_price', qsi.unit_price,
                          'line_total', qsi.line_total
                        )
                        ORDER BY qsi.created_at, qsi.id
                      )
               FROM public.qr_session_items AS qsi
               WHERE qsi.qr_session_id = qs.id
             ),
             '[]'::JSONB
           )
         )
    INTO v_payload
  FROM public.qr_sessions AS qs
  JOIN public.shops AS s ON s.id = qs.shop_id
  WHERE qs.id = v_session.id;

  RETURN v_payload;
END;
$function$;

REVOKE ALL ON FUNCTION public.confirm_qr_session(TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_qr_session(TEXT) TO authenticated;

COMMIT;

-- Read-only postflight examples (run manually in a non-production review
-- environment if available):
-- SELECT pg_get_functiondef(
--   'public.create_qr_session(uuid)'::regprocedure
-- );
-- SELECT pg_get_functiondef(
--   'public.confirm_qr_session(text)'::regprocedure
-- );
-- SELECT has_function_privilege(
--   'authenticated',
--   'public.create_qr_session(uuid)',
--   'EXECUTE'
-- ) AS authenticated_can_create_qr;
-- SELECT has_function_privilege(
--   'authenticated',
--   'public.confirm_qr_session(text)',
--   'EXECUTE'
-- ) AS authenticated_can_confirm_qr;
