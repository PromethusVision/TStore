-- EsnaftaVar canonical migration 0004: QR verification and durable purchase
-- proof. Final race-safe RPC bodies are installed directly; no weak interim
-- function is created.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';

DO $preflight$
BEGIN
  IF to_regclass('public.profiles') IS NULL
     OR to_regclass('public.products') IS NULL
     OR to_regclass('public.shops') IS NULL
     OR to_regclass('public.shop_products') IS NULL
     OR to_regclass('public.carts') IS NULL
     OR to_regclass('public.cart_items_v2') IS NULL THEN
    RAISE EXCEPTION
      'Migration 0004 requires canonical migrations 0001 through 0003'
      USING ERRCODE = '42P01';
  END IF;

  IF to_regnamespace('extensions') IS NULL THEN
    RAISE EXCEPTION
      'Supabase managed extensions schema is required before migration 0004'
      USING ERRCODE = '3F000';
  END IF;

  IF to_regprocedure('public.set_updated_at()') IS NULL THEN
    RAISE EXCEPTION 'Migration 0004 requires public.set_updated_at()'
      USING ERRCODE = '42883';
  END IF;
END
$preflight$;

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

CREATE TABLE public.qr_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_token TEXT NOT NULL
    DEFAULT encode(extensions.gen_random_bytes(32), 'hex'),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
  shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE RESTRICT,
  status TEXT NOT NULL DEFAULT 'active',
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '2 minutes'),
  used_at TIMESTAMPTZ,
  total_amount NUMERIC NOT NULL DEFAULT 0,
  item_count INTEGER NOT NULL DEFAULT 0,
  confirmed_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT qr_sessions_session_token_key UNIQUE (session_token),
  CONSTRAINT qr_sessions_status_check
    CHECK (status IN ('active', 'used', 'expired', 'cancelled')),
  CONSTRAINT qr_sessions_total_amount_nonnegative_check
    CHECK (total_amount >= 0),
  CONSTRAINT qr_sessions_item_count_nonnegative_check CHECK (item_count >= 0),
  CONSTRAINT qr_sessions_used_state_check
    CHECK (
      (status = 'used' AND used_at IS NOT NULL)
      OR
      (status <> 'used' AND used_at IS NULL AND confirmed_by_user_id IS NULL)
    )
);

-- shop_product_id is a snapshot identifier, deliberately not a foreign key.
CREATE TABLE public.qr_session_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  qr_session_id UUID NOT NULL
    REFERENCES public.qr_sessions(id) ON DELETE CASCADE,
  shop_product_id UUID NOT NULL,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price NUMERIC NOT NULL,
  line_total NUMERIC GENERATED ALWAYS AS (unit_price * quantity) STORED,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT qr_session_items_quantity_positive_check CHECK (quantity > 0),
  CONSTRAINT qr_session_items_unit_price_nonnegative_check
    CHECK (unit_price >= 0),
  CONSTRAINT qr_session_items_session_shop_product_key
    UNIQUE (qr_session_id, shop_product_id)
);

-- Durable commercial proof intentionally uses UUID/name/value snapshots and
-- no FK to mutable users, shops, carts, QR sessions, or catalog listings.
CREATE TABLE public.verified_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_qr_session_id UUID NOT NULL,
  customer_user_id UUID NOT NULL,
  shop_id UUID NOT NULL,
  shop_name TEXT NOT NULL,
  confirmed_by_user_id UUID NOT NULL,
  item_count INTEGER NOT NULL,
  total_amount NUMERIC NOT NULL,
  confirmed_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT verified_transactions_source_qr_session_key
    UNIQUE (source_qr_session_id),
  CONSTRAINT verified_transactions_item_count_positive_check
    CHECK (item_count > 0),
  CONSTRAINT verified_transactions_total_amount_nonnegative_check
    CHECK (total_amount >= 0)
);

CREATE TABLE public.verified_transaction_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verified_transaction_id UUID NOT NULL
    REFERENCES public.verified_transactions(id) ON DELETE CASCADE,
  shop_product_id UUID NOT NULL,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price NUMERIC NOT NULL,
  line_total NUMERIC NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT verified_transaction_items_quantity_positive_check
    CHECK (quantity > 0),
  CONSTRAINT verified_transaction_items_unit_price_nonnegative_check
    CHECK (unit_price >= 0),
  CONSTRAINT verified_transaction_items_line_total_nonnegative_check
    CHECK (line_total >= 0),
  CONSTRAINT verified_transaction_items_source_item_key
    UNIQUE (verified_transaction_id, shop_product_id)
);

CREATE INDEX qr_sessions_user_idx ON public.qr_sessions(user_id);
CREATE INDEX qr_sessions_cart_idx ON public.qr_sessions(cart_id);
CREATE INDEX qr_sessions_shop_status_expires_idx
  ON public.qr_sessions(shop_id, status, expires_at);
CREATE INDEX qr_sessions_confirmed_by_idx
  ON public.qr_sessions(confirmed_by_user_id);
CREATE UNIQUE INDEX qr_sessions_one_active_per_cart_idx
  ON public.qr_sessions(cart_id) WHERE status = 'active';
CREATE INDEX qr_session_items_session_idx
  ON public.qr_session_items(qr_session_id);
CREATE INDEX verified_transactions_customer_confirmed_idx
  ON public.verified_transactions(customer_user_id, confirmed_at DESC);
CREATE INDEX verified_transactions_shop_confirmed_idx
  ON public.verified_transactions(shop_id, confirmed_at DESC);
CREATE INDEX verified_transactions_confirmer_idx
  ON public.verified_transactions(confirmed_by_user_id);
CREATE INDEX verified_transaction_items_transaction_idx
  ON public.verified_transaction_items(verified_transaction_id);

ALTER TABLE public.qr_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.qr_session_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verified_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verified_transaction_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY qr_sessions_select_own
  ON public.qr_sessions FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY qr_session_items_select_own
  ON public.qr_session_items FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.qr_sessions AS owned_session
      WHERE owned_session.id = qr_session_items.qr_session_id
        AND owned_session.user_id = auth.uid()
    )
  );
CREATE POLICY verified_transactions_select_participant
  ON public.verified_transactions FOR SELECT TO authenticated
  USING (
    customer_user_id = auth.uid()
    OR confirmed_by_user_id = auth.uid()
  );
CREATE POLICY verified_transaction_items_select_participant
  ON public.verified_transaction_items FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.verified_transactions AS transaction_row
      WHERE transaction_row.id =
        verified_transaction_items.verified_transaction_id
        AND (
          transaction_row.customer_user_id = auth.uid()
          OR transaction_row.confirmed_by_user_id = auth.uid()
        )
    )
  );

REVOKE ALL ON TABLE
  public.qr_sessions,
  public.qr_session_items,
  public.verified_transactions,
  public.verified_transaction_items
FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE
  public.qr_sessions,
  public.qr_session_items,
  public.verified_transactions,
  public.verified_transaction_items
TO authenticated;

CREATE TRIGGER set_qr_sessions_updated_at
  BEFORE UPDATE ON public.qr_sessions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE FUNCTION public.cancel_active_qr_after_cart_item_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  old_cart_id UUID;
  new_cart_id UUID;
BEGIN
  IF TG_OP = 'UPDATE'
     AND OLD.cart_id IS NOT DISTINCT FROM NEW.cart_id
     AND OLD.shop_product_id IS NOT DISTINCT FROM NEW.shop_product_id
     AND OLD.quantity IS NOT DISTINCT FROM NEW.quantity THEN
    RETURN NEW;
  END IF;

  IF TG_OP IN ('UPDATE', 'DELETE') THEN
    old_cart_id := OLD.cart_id;
  END IF;

  IF TG_OP IN ('INSERT', 'UPDATE') THEN
    new_cart_id := NEW.cart_id;
  END IF;

  PERFORM cart_row.id
  FROM public.carts AS cart_row
  WHERE cart_row.id = ANY (
    array_remove(ARRAY[old_cart_id, new_cart_id]::UUID[], NULL)
  )
  ORDER BY cart_row.id
  FOR UPDATE;

  IF EXISTS (
    SELECT 1 FROM public.carts AS cart_row
    WHERE cart_row.id = ANY (
      array_remove(ARRAY[old_cart_id, new_cart_id]::UUID[], NULL)
    )
      AND cart_row.status <> 'active'
  ) THEN
    RAISE EXCEPTION 'Cart is no longer active'
      USING ERRCODE = '55000';
  END IF;

  UPDATE public.qr_sessions AS session_row
  SET status = 'cancelled'
  WHERE session_row.status = 'active'
    AND session_row.cart_id = ANY (
      array_remove(ARRAY[old_cart_id, new_cart_id]::UUID[], NULL)
    );

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$function$;

CREATE FUNCTION public.cancel_active_qr_after_cart_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
BEGIN
  IF OLD.user_id IS NOT DISTINCT FROM NEW.user_id
     AND OLD.shop_id IS NOT DISTINCT FROM NEW.shop_id
     AND OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  UPDATE public.qr_sessions AS session_row
  SET status = 'cancelled'
  WHERE session_row.cart_id = NEW.id
    AND session_row.status = 'active';

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.cancel_active_qr_after_cart_item_change()
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.cancel_active_qr_after_cart_change()
  FROM PUBLIC, anon, authenticated;

CREATE TRIGGER cancel_active_qr_after_cart_item_change
  BEFORE INSERT OR UPDATE OR DELETE ON public.cart_items_v2
  FOR EACH ROW
  EXECUTE FUNCTION public.cancel_active_qr_after_cart_item_change();
CREATE TRIGGER cancel_active_qr_after_cart_change
  AFTER UPDATE OF user_id, shop_id, status ON public.carts
  FOR EACH ROW
  EXECUTE FUNCTION public.cancel_active_qr_after_cart_change();

CREATE FUNCTION public.get_qr_session_for_verification(
  p_session_token TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  current_user_id UUID := auth.uid();
  current_time TIMESTAMPTZ := clock_timestamp();
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
    AND session_row.expires_at <= current_time
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

CREATE FUNCTION public.create_qr_session(p_cart_id UUID)
RETURNS public.qr_sessions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  current_user_id UUID;
  current_time TIMESTAMPTZ;
  active_cart public.carts%ROWTYPE;
  session_row public.qr_sessions%ROWTYPE;
  cart_line_count INTEGER;
  snapshot_line_count INTEGER;
  snapshot_item_count INTEGER;
  snapshot_total NUMERIC;
BEGIN
  current_user_id := auth.uid();

  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '28000';
  END IF;

  -- Cart-item writes use this parent row as the same serialization point.
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

  -- Lock every catalog row represented by the immutable snapshot.
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

  -- Capture time only after all potentially blocking locks are held.
  current_time := clock_timestamp();

  UPDATE public.qr_sessions AS existing_session
  SET status = 'expired'
  WHERE existing_session.cart_id = active_cart.id
    AND existing_session.user_id = current_user_id
    AND existing_session.status = 'active'
    AND existing_session.expires_at <= current_time;

  SELECT existing_session.*
    INTO session_row
  FROM public.qr_sessions AS existing_session
  WHERE existing_session.cart_id = active_cart.id
    AND existing_session.user_id = current_user_id
    AND existing_session.status = 'active'
    AND existing_session.expires_at > current_time
  LIMIT 1
  FOR UPDATE;

  IF FOUND THEN
    SELECT
      COUNT(*)::INTEGER,
      COALESCE(SUM(item.quantity), 0)::INTEGER,
      COALESCE(SUM(item.line_total), 0)
      INTO snapshot_line_count, snapshot_item_count, snapshot_total
    FROM public.qr_session_items AS item
    WHERE item.qr_session_id = session_row.id;

    IF snapshot_line_count > 0
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
    current_time + INTERVAL '2 minutes',
    NULL,
    0,
    0,
    NULL
  )
  RETURNING * INTO session_row;

  INSERT INTO public.qr_session_items (
    qr_session_id,
    shop_product_id,
    product_name,
    quantity,
    unit_price
  )
  SELECT
    session_row.id,
    listing.id,
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

CREATE FUNCTION public.confirm_qr_session(p_session_token TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, auth
AS $function$
DECLARE
  current_user_id UUID := auth.uid();
  current_time TIMESTAMPTZ;
  session_id UUID;
  session_cart_id UUID;
  locked_cart public.carts%ROWTYPE;
  locked_session public.qr_sessions%ROWTYPE;
  snapshot_line_count INTEGER;
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

  -- Keep authorization stable throughout confirmation.
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

  -- Every confirmation path locks cart, then QR session, in this order.
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

  -- Refresh time only after every blocking lock is held.
  current_time := clock_timestamp();

  IF locked_session.status = 'used'
     OR locked_session.used_at IS NOT NULL
     OR locked_session.confirmed_by_user_id IS NOT NULL THEN
    RAISE EXCEPTION 'QR session has already been confirmed'
      USING ERRCODE = '55000';
  END IF;

  IF locked_session.status <> 'active' THEN
    RAISE EXCEPTION 'QR session is not active' USING ERRCODE = '55000';
  END IF;

  IF locked_session.expires_at <= current_time THEN
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
    COALESCE(SUM(item.quantity), 0)::INTEGER,
    COALESCE(SUM(item.line_total), 0)
    INTO snapshot_line_count, snapshot_item_count, snapshot_total
  FROM public.qr_session_items AS item
  WHERE item.qr_session_id = locked_session.id;

  IF snapshot_line_count = 0
     OR locked_session.item_count IS DISTINCT FROM snapshot_item_count
     OR locked_session.total_amount IS DISTINCT FROM snapshot_total THEN
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
    locked_session.id,
    locked_session.user_id,
    locked_session.shop_id,
    shop.name,
    current_user_id,
    locked_session.item_count,
    locked_session.total_amount,
    current_time
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
    product_name,
    quantity,
    unit_price,
    line_total
  )
  SELECT
    transaction_id,
    item.shop_product_id,
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
      used_at = current_time,
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

COMMIT;
