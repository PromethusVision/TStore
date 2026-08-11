-- EsnaftaVar canonical migration 0002: shops and merchant-owned catalog.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $preflight$
BEGIN
  IF to_regclass('public.profiles') IS NULL
     OR to_regclass('public.products') IS NULL THEN
    RAISE EXCEPTION
      'Migration 0002 requires public.profiles and public.products from 0001'
      USING ERRCODE = '42P01';
  END IF;

  IF to_regprocedure('public.set_updated_at()') IS NULL THEN
    RAISE EXCEPTION 'Migration 0002 requires public.set_updated_at()'
      USING ERRCODE = '42883';
  END IF;
END
$preflight$;

CREATE TABLE public.shops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  description TEXT,
  address TEXT,
  latitude NUMERIC,
  longitude NUMERIC,
  phone TEXT,
  opening_hours JSONB NOT NULL DEFAULT '{}'::JSONB,
  is_active BOOLEAN NOT NULL DEFAULT true,
  rating NUMERIC(3, 2) NOT NULL DEFAULT 0,
  rating_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT shops_name_not_empty_check
    CHECK (length(btrim(name)) > 0),
  CONSTRAINT shops_latitude_check
    CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
  CONSTRAINT shops_longitude_check
    CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
  CONSTRAINT shops_rating_range_check CHECK (rating BETWEEN 0 AND 5),
  CONSTRAINT shops_rating_count_nonnegative_check CHECK (rating_count >= 0)
);

CREATE TABLE public.shop_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
  price NUMERIC NOT NULL,
  is_available BOOLEAN NOT NULL DEFAULT true,
  description TEXT,
  images TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT shop_products_price_nonnegative_check CHECK (price >= 0),
  CONSTRAINT shop_products_shop_product_key UNIQUE (shop_id, product_id)
);

CREATE UNIQUE INDEX shops_owner_user_id_unique_idx
  ON public.shops(owner_user_id) WHERE owner_user_id IS NOT NULL;
CREATE INDEX shops_active_idx ON public.shops(is_active);
CREATE INDEX shops_location_idx ON public.shops(latitude, longitude)
  WHERE is_active = true AND latitude IS NOT NULL AND longitude IS NOT NULL;
CREATE INDEX shop_products_shop_idx ON public.shop_products(shop_id);
CREATE INDEX shop_products_product_idx ON public.shop_products(product_id);
CREATE INDEX shop_products_public_catalog_idx
  ON public.shop_products(product_id, shop_id)
  WHERE is_active = true AND is_available = true;

ALTER TABLE public.shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_products ENABLE ROW LEVEL SECURITY;

CREATE POLICY shops_read_active
  ON public.shops FOR SELECT TO anon, authenticated
  USING (is_active = true);
CREATE POLICY shops_owner_read_own
  ON public.shops FOR SELECT TO authenticated
  USING (owner_user_id = auth.uid());
CREATE POLICY shops_owner_create_role_gated
  ON public.shops FOR INSERT TO authenticated
  WITH CHECK (
    owner_user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles AS owner_profile
      WHERE owner_profile.id = auth.uid()
        AND owner_profile.role IN ('merchant', 'admin')
    )
  );
CREATE POLICY shops_owner_update_role_gated
  ON public.shops FOR UPDATE TO authenticated
  USING (
    owner_user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles AS owner_profile
      WHERE owner_profile.id = auth.uid()
        AND owner_profile.role IN ('merchant', 'admin')
    )
  )
  WITH CHECK (
    owner_user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles AS owner_profile
      WHERE owner_profile.id = auth.uid()
        AND owner_profile.role IN ('merchant', 'admin')
    )
  );
-- Shop deletion is intentionally unavailable to clients. Commercial history
-- is retained by deactivating shops through the owner update policy.

CREATE POLICY shop_products_read_active
  ON public.shop_products FOR SELECT TO anon, authenticated
  USING (
    is_active = true
    AND is_available = true
    AND EXISTS (
      SELECT 1 FROM public.shops AS product_shop
      WHERE product_shop.id = shop_products.shop_id
        AND product_shop.is_active = true
    )
  );
CREATE POLICY shop_products_owner_read_own
  ON public.shop_products FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.shops AS owned_shop
      WHERE owned_shop.id = shop_products.shop_id
        AND owned_shop.owner_user_id = auth.uid()
    )
  );
CREATE POLICY shop_products_owner_create_role_gated
  ON public.shop_products FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.shops AS owned_shop
      JOIN public.profiles AS owner_profile
        ON owner_profile.id = owned_shop.owner_user_id
      WHERE owned_shop.id = shop_products.shop_id
        AND owned_shop.owner_user_id = auth.uid()
        AND owner_profile.role IN ('merchant', 'admin')
    )
  );
CREATE POLICY shop_products_owner_update_role_gated
  ON public.shop_products FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.shops AS owned_shop
      JOIN public.profiles AS owner_profile
        ON owner_profile.id = owned_shop.owner_user_id
      WHERE owned_shop.id = shop_products.shop_id
        AND owned_shop.owner_user_id = auth.uid()
        AND owner_profile.role IN ('merchant', 'admin')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.shops AS owned_shop
      JOIN public.profiles AS owner_profile
        ON owner_profile.id = owned_shop.owner_user_id
      WHERE owned_shop.id = shop_products.shop_id
        AND owned_shop.owner_user_id = auth.uid()
        AND owner_profile.role IN ('merchant', 'admin')
    )
  );
CREATE POLICY shop_products_owner_delete_role_gated
  ON public.shop_products FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.shops AS owned_shop
      JOIN public.profiles AS owner_profile
        ON owner_profile.id = owned_shop.owner_user_id
      WHERE owned_shop.id = shop_products.shop_id
        AND owned_shop.owner_user_id = auth.uid()
        AND owner_profile.role IN ('merchant', 'admin')
    )
  );

REVOKE ALL ON TABLE public.shops, public.shop_products
  FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.shops, public.shop_products
  TO anon, authenticated;
GRANT INSERT, UPDATE ON TABLE public.shops TO authenticated;
GRANT INSERT, UPDATE, DELETE ON TABLE public.shop_products TO authenticated;

CREATE TRIGGER set_shops_updated_at
  BEFORE UPDATE ON public.shops
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_shop_products_updated_at
  BEFORE UPDATE ON public.shop_products
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

COMMIT;
