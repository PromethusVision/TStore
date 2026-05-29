-- ===========================================
-- Esnafta Var - shops + shop_products Migration Draft
-- ===========================================
-- This file is a draft.
-- It must be manually reviewed before running in Supabase SQL Editor.
-- This is not a reset file.
-- This file does not contain DROP TABLE statements.
-- DROP POLICY / DROP TRIGGER statements are included only to avoid name
-- conflicts when this draft is re-run.
-- It does not delete existing table data.
-- Goal: add only public.shops and public.shop_products without changing
-- existing products, cart_items, categories, brands, or profiles tables.
-- ===========================================

-- ====================
-- shops
-- ====================
CREATE TABLE IF NOT EXISTS public.shops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  description TEXT,
  address TEXT,
  latitude NUMERIC,
  longitude NUMERIC,
  phone TEXT,
  opening_hours JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT true,
  rating NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ====================
-- shop_products
-- ====================
CREATE TABLE IF NOT EXISTS public.shop_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  price NUMERIC NOT NULL,
  is_available BOOLEAN DEFAULT true,
  description TEXT,
  images TEXT[] DEFAULT '{}'::text[],
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (shop_id, product_id)
);

-- ====================
-- Indexes
-- ====================
CREATE INDEX IF NOT EXISTS idx_shops_is_active
  ON public.shops(is_active);

CREATE INDEX IF NOT EXISTS idx_shop_products_shop_id
  ON public.shop_products(shop_id);

CREATE INDEX IF NOT EXISTS idx_shop_products_product_id
  ON public.shop_products(product_id);

CREATE INDEX IF NOT EXISTS idx_shop_products_is_available
  ON public.shop_products(is_available);

CREATE INDEX IF NOT EXISTS idx_shop_products_is_active
  ON public.shop_products(is_active);

-- ====================
-- Row Level Security
-- ====================
ALTER TABLE public.shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_products ENABLE ROW LEVEL SECURITY;

-- ====================
-- Policy idempotency guards
-- ====================
DROP POLICY IF EXISTS "Public read active shops" ON public.shops;
DROP POLICY IF EXISTS "Shop owners can read own shops" ON public.shops;
DROP POLICY IF EXISTS "Shop owners can create own shops" ON public.shops;
DROP POLICY IF EXISTS "Shop owners can update own shops" ON public.shops;
DROP POLICY IF EXISTS "Shop owners can delete own shops" ON public.shops;

DROP POLICY IF EXISTS "Public read active available shop products" ON public.shop_products;
DROP POLICY IF EXISTS "Shop owners can read own shop products" ON public.shop_products;
DROP POLICY IF EXISTS "Shop owners can create own shop products" ON public.shop_products;
DROP POLICY IF EXISTS "Shop owners can update own shop products" ON public.shop_products;
DROP POLICY IF EXISTS "Shop owners can delete own shop products" ON public.shop_products;

-- ====================
-- Public read policies
-- ====================
CREATE POLICY "Public read active shops"
  ON public.shops
  FOR SELECT
  TO anon, authenticated
  USING (is_active = true);

CREATE POLICY "Public read active available shop products"
  ON public.shop_products
  FOR SELECT
  TO anon, authenticated
  USING (
    is_active = true
    AND is_available = true
    AND EXISTS (
      SELECT 1
      FROM public.shops AS s
      WHERE s.id = shop_id
        AND s.is_active = true
    )
  );

-- ====================
-- Owner policies: shops
-- ====================
CREATE POLICY "Shop owners can read own shops"
  ON public.shops
  FOR SELECT
  TO authenticated
  USING (auth.uid() = owner_user_id);

CREATE POLICY "Shop owners can create own shops"
  ON public.shops
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = owner_user_id);

CREATE POLICY "Shop owners can update own shops"
  ON public.shops
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner_user_id)
  WITH CHECK (auth.uid() = owner_user_id);

CREATE POLICY "Shop owners can delete own shops"
  ON public.shops
  FOR DELETE
  TO authenticated
  USING (auth.uid() = owner_user_id);

-- ====================
-- Owner policies: shop_products
-- ====================
CREATE POLICY "Shop owners can read own shop products"
  ON public.shop_products
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.shops AS s
      WHERE s.id = shop_id
        AND s.owner_user_id = auth.uid()
    )
  );

CREATE POLICY "Shop owners can create own shop products"
  ON public.shop_products
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.shops AS s
      WHERE s.id = shop_id
        AND s.owner_user_id = auth.uid()
    )
  );

CREATE POLICY "Shop owners can update own shop products"
  ON public.shop_products
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.shops AS s
      WHERE s.id = shop_id
        AND s.owner_user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.shops AS s
      WHERE s.id = shop_id
        AND s.owner_user_id = auth.uid()
    )
  );

CREATE POLICY "Shop owners can delete own shop products"
  ON public.shop_products
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.shops AS s
      WHERE s.id = shop_id
        AND s.owner_user_id = auth.uid()
    )
  );

-- ====================
-- Grants
-- ====================
GRANT USAGE ON SCHEMA public TO anon, authenticated;

GRANT SELECT ON public.shops TO anon, authenticated;
GRANT SELECT ON public.shop_products TO anon, authenticated;

GRANT INSERT, UPDATE, DELETE ON public.shops TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.shop_products TO authenticated;

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
    DROP TRIGGER IF EXISTS update_shops_updated_at ON public.shops;
    CREATE TRIGGER update_shops_updated_at
      BEFORE UPDATE ON public.shops
      FOR EACH ROW
      EXECUTE FUNCTION public.update_updated_at();

    DROP TRIGGER IF EXISTS update_shop_products_updated_at ON public.shop_products;
    CREATE TRIGGER update_shop_products_updated_at
      BEFORE UPDATE ON public.shop_products
      FOR EACH ROW
      EXECUTE FUNCTION public.update_updated_at();
  ELSE
    RAISE NOTICE 'public.update_updated_at() function not found; updated_at triggers were not created.';
  END IF;
END
$$;