-- ===========================================
-- Esnafta Var - carts + cart_items_v2 Migration Draft
-- ===========================================
-- This file is a draft.
-- It must be manually reviewed before running in Supabase SQL Editor.
-- It does not modify the existing public.cart_items table.
-- This file does not contain DROP TABLE statements.
-- It does not delete existing products, cart_items, shops, or shop_products data.
-- This migration only adds public.carts and public.cart_items_v2 tables.
-- ===========================================

-- ====================
-- carts
-- ====================
CREATE TABLE IF NOT EXISTS public.carts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Expected status values:
-- active
-- checked_out
-- cancelled
-- expired

-- ====================
-- cart_items_v2
-- ====================
CREATE TABLE IF NOT EXISTS public.cart_items_v2 (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
  shop_product_id UUID NOT NULL REFERENCES public.shop_products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (cart_id, shop_product_id)
);

-- ====================
-- Indexes
-- ====================
CREATE INDEX IF NOT EXISTS idx_carts_user_id
  ON public.carts(user_id);

CREATE INDEX IF NOT EXISTS idx_carts_shop_id
  ON public.carts(shop_id);

CREATE INDEX IF NOT EXISTS idx_carts_status
  ON public.carts(status);

CREATE UNIQUE INDEX IF NOT EXISTS idx_carts_one_active_per_user
  ON public.carts(user_id)
  WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_cart_items_v2_cart_id
  ON public.cart_items_v2(cart_id);

CREATE INDEX IF NOT EXISTS idx_cart_items_v2_shop_product_id
  ON public.cart_items_v2(shop_product_id);

-- ====================
-- Row Level Security
-- ====================
ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items_v2 ENABLE ROW LEVEL SECURITY;

-- ====================
-- Policy idempotency guards
-- ====================
DROP POLICY IF EXISTS "Users can read own carts" ON public.carts;
DROP POLICY IF EXISTS "Users can create own carts" ON public.carts;
DROP POLICY IF EXISTS "Users can update own carts" ON public.carts;
DROP POLICY IF EXISTS "Users can delete own carts" ON public.carts;

DROP POLICY IF EXISTS "Users can read own cart items v2" ON public.cart_items_v2;
DROP POLICY IF EXISTS "Users can create own cart items v2" ON public.cart_items_v2;
DROP POLICY IF EXISTS "Users can update own cart items v2" ON public.cart_items_v2;
DROP POLICY IF EXISTS "Users can delete own cart items v2" ON public.cart_items_v2;

-- ====================
-- carts policies
-- ====================
CREATE POLICY "Users can read own carts"
  ON public.carts
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own carts"
  ON public.carts
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own carts"
  ON public.carts
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own carts"
  ON public.carts
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- ====================
-- cart_items_v2 policies
-- ====================
CREATE POLICY "Users can read own cart items v2"
  ON public.cart_items_v2
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.carts AS c
      WHERE c.id = cart_id
        AND c.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create own cart items v2"
  ON public.cart_items_v2
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.carts AS c
      WHERE c.id = cart_id
        AND c.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own cart items v2"
  ON public.cart_items_v2
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.carts AS c
      WHERE c.id = cart_id
        AND c.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.carts AS c
      WHERE c.id = cart_id
        AND c.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own cart items v2"
  ON public.cart_items_v2
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.carts AS c
      WHERE c.id = cart_id
        AND c.user_id = auth.uid()
    )
  );

-- ====================
-- Grants
-- ====================
GRANT USAGE ON SCHEMA public TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.carts TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cart_items_v2 TO authenticated;

-- ====================
-- updated_at triggers
-- ====================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'update_updated_at'
      AND n.nspname = 'public'
  ) THEN
    DROP TRIGGER IF EXISTS update_carts_updated_at ON public.carts;
    CREATE TRIGGER update_carts_updated_at
      BEFORE UPDATE ON public.carts
      FOR EACH ROW
      EXECUTE FUNCTION public.update_updated_at();

    DROP TRIGGER IF EXISTS update_cart_items_v2_updated_at ON public.cart_items_v2;
    CREATE TRIGGER update_cart_items_v2_updated_at
      BEFORE UPDATE ON public.cart_items_v2
      FOR EACH ROW
      EXECUTE FUNCTION public.update_updated_at();
  ELSE
    RAISE NOTICE 'public.update_updated_at() function not found; updated_at triggers were not created.';
  END IF;
END
$$;
