-- ===========================================
-- Esnafta Var - qr_sessions Migration Draft
-- ===========================================
-- This file is a draft.
-- It must be manually reviewed before running in Supabase SQL Editor.
-- It does not modify existing carts, cart_items_v2, shops, orders, or payments.
-- This table is for CartV2 in-store QR proof sessions only.
-- It is not a payment, order, reservation, or stock guarantee.
-- QR payloads should contain only the opaque session_token, not sensitive data.
-- Sessions are short-lived; the first MVP expects about 2 minutes.
-- Clients must not insert rows directly. QR sessions are created through
-- public.create_qr_session(p_cart_id UUID), which sets token, status, and
-- expiry on the server side.
-- ===========================================

-- ====================
-- Extensions
-- ====================
-- Required for gen_random_bytes(32), used to create unpredictable QR tokens.
-- Supabase normally supports pgcrypto, but this statement should still be
-- manually reviewed in the target project before running.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ====================
-- qr_sessions
-- ====================
CREATE TABLE IF NOT EXISTS public.qr_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_token TEXT NOT NULL DEFAULT encode(gen_random_bytes(32), 'hex'),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
  shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'active',
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (now() + interval '2 minutes'),
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT qr_sessions_status_check
    CHECK (status IN ('active', 'used', 'expired', 'cancelled'))
);

-- ====================
-- Indexes
-- ====================
CREATE UNIQUE INDEX IF NOT EXISTS idx_qr_sessions_session_token
  ON public.qr_sessions(session_token);

CREATE INDEX IF NOT EXISTS idx_qr_sessions_user_id
  ON public.qr_sessions(user_id);

CREATE INDEX IF NOT EXISTS idx_qr_sessions_cart_id
  ON public.qr_sessions(cart_id);

CREATE INDEX IF NOT EXISTS idx_qr_sessions_shop_id
  ON public.qr_sessions(shop_id);

CREATE INDEX IF NOT EXISTS idx_qr_sessions_status
  ON public.qr_sessions(status);

CREATE INDEX IF NOT EXISTS idx_qr_sessions_expires_at
  ON public.qr_sessions(expires_at);

CREATE INDEX IF NOT EXISTS idx_qr_sessions_shop_status_expires_at
  ON public.qr_sessions(shop_id, status, expires_at);

-- ====================
-- Row Level Security
-- ====================
ALTER TABLE public.qr_sessions ENABLE ROW LEVEL SECURITY;

-- ====================
-- Policy idempotency guards
-- ====================
DROP POLICY IF EXISTS "Users can create own qr sessions" ON public.qr_sessions;
DROP POLICY IF EXISTS "Users can read own qr sessions" ON public.qr_sessions;
DROP POLICY IF EXISTS "Users can update own qr sessions" ON public.qr_sessions;
DROP POLICY IF EXISTS "Users can delete own qr sessions" ON public.qr_sessions;

-- ====================
-- qr_sessions policies
-- ====================
-- Users can read only their own QR sessions.
CREATE POLICY "Users can read own qr sessions"
  ON public.qr_sessions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- No client INSERT, UPDATE, or DELETE policy is created in the first MVP.
-- QR sessions are created only by public.create_qr_session(p_cart_id UUID).
-- used/expired/cancelled transitions should be handled later by a trusted
-- server path, Edge Function, or shop/staff verification flow.

-- ====================
-- RPC: create_qr_session
-- ====================
DROP FUNCTION IF EXISTS public.create_qr_session(UUID);

CREATE FUNCTION public.create_qr_session(p_cart_id UUID)
RETURNS public.qr_sessions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, auth
AS $$
DECLARE
  v_user_id UUID;
  v_cart public.carts%ROWTYPE;
  v_session public.qr_sessions%ROWTYPE;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required'
      USING ERRCODE = '28000';
  END IF;

  SELECT *
    INTO v_cart
    FROM public.carts
    WHERE id = p_cart_id
      AND user_id = v_user_id
      AND status = 'active';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Active cart not found'
      USING ERRCODE = 'P0002';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.cart_items_v2 AS ci
    WHERE ci.cart_id = v_cart.id
  ) THEN
    RAISE EXCEPTION 'Cannot create QR session for an empty cart'
      USING ERRCODE = 'P0001';
  END IF;

  UPDATE public.qr_sessions
    SET status = 'expired'
    WHERE cart_id = v_cart.id
      AND user_id = v_user_id
      AND status = 'active'
      AND expires_at <= now();

  SELECT *
    INTO v_session
    FROM public.qr_sessions
    WHERE cart_id = v_cart.id
      AND user_id = v_user_id
      AND status = 'active'
      AND expires_at > now()
    ORDER BY created_at DESC
    LIMIT 1;

  IF FOUND THEN
    RETURN v_session;
  END IF;

  INSERT INTO public.qr_sessions (
    session_token,
    user_id,
    cart_id,
    shop_id,
    status,
    expires_at,
    used_at
  )
  VALUES (
    encode(gen_random_bytes(32), 'hex'),
    v_user_id,
    v_cart.id,
    v_cart.shop_id,
    'active',
    now() + interval '2 minutes',
    NULL
  )
  RETURNING * INTO v_session;

  RETURN v_session;
END;
$$;

-- ====================
-- Grants
-- ====================
REVOKE ALL ON public.qr_sessions FROM anon;
REVOKE ALL ON public.qr_sessions FROM authenticated;

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON public.qr_sessions TO authenticated;

REVOKE ALL ON FUNCTION public.create_qr_session(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.create_qr_session(UUID) TO authenticated;

-- ====================
-- updated_at trigger
-- ====================
-- If public.update_updated_at() exists, QR session updates made by trusted
-- server-side paths will refresh updated_at. If it does not exist, this draft
-- keeps the project pattern and raises a notice instead of creating a function.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'update_updated_at'
      AND n.nspname = 'public'
  ) THEN
    DROP TRIGGER IF EXISTS update_qr_sessions_updated_at ON public.qr_sessions;
    CREATE TRIGGER update_qr_sessions_updated_at
      BEFORE UPDATE ON public.qr_sessions
      FOR EACH ROW
      EXECUTE FUNCTION public.update_updated_at();
  ELSE
    RAISE NOTICE 'public.update_updated_at() function not found; updated_at trigger was not created.';
  END IF;
END
$$;
