-- EsnaftaVar canonical migration 0003: active Cart V2 model.
-- This model has no dependency on legacy orders or order_items.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $preflight$
BEGIN
  IF to_regclass('auth.users') IS NULL
     OR to_regclass('public.shops') IS NULL
     OR to_regclass('public.shop_products') IS NULL THEN
    RAISE EXCEPTION
      'Migration 0003 requires auth.users, public.shops, and public.shop_products'
      USING ERRCODE = '42P01';
  END IF;

  IF to_regprocedure('public.set_updated_at()') IS NULL THEN
    RAISE EXCEPTION 'Migration 0003 requires public.set_updated_at()'
      USING ERRCODE = '42883';
  END IF;
END
$preflight$;

CREATE TABLE public.carts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE RESTRICT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT carts_status_check
    CHECK (status IN ('active', 'checked_out', 'cancelled', 'expired'))
);

CREATE TABLE public.cart_items_v2 (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
  shop_product_id UUID NOT NULL
    REFERENCES public.shop_products(id) ON DELETE RESTRICT,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT cart_items_v2_quantity_positive_check CHECK (quantity > 0),
  CONSTRAINT cart_items_v2_cart_shop_product_key
    UNIQUE (cart_id, shop_product_id)
);

CREATE INDEX carts_user_idx ON public.carts(user_id);
CREATE INDEX carts_shop_idx ON public.carts(shop_id);
CREATE INDEX carts_status_idx ON public.carts(status);
CREATE UNIQUE INDEX carts_one_active_per_user_idx
  ON public.carts(user_id) WHERE status = 'active';
CREATE INDEX cart_items_v2_cart_idx ON public.cart_items_v2(cart_id);
CREATE INDEX cart_items_v2_shop_product_idx
  ON public.cart_items_v2(shop_product_id);

ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items_v2 ENABLE ROW LEVEL SECURITY;

CREATE POLICY carts_select_own
  ON public.carts FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY carts_insert_own_active
  ON public.carts FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() AND status = 'active');
CREATE POLICY carts_update_own_active
  ON public.carts FOR UPDATE TO authenticated
  USING (user_id = auth.uid() AND status = 'active')
  WITH CHECK (
    user_id = auth.uid()
    AND status IN ('active', 'cancelled')
  );
CREATE POLICY carts_delete_own_unverified
  ON public.carts FOR DELETE TO authenticated
  USING (
    user_id = auth.uid()
    AND status IN ('active', 'cancelled')
  );

CREATE POLICY cart_items_v2_select_own
  ON public.cart_items_v2 FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.carts AS owned_cart
      WHERE owned_cart.id = cart_items_v2.cart_id
        AND owned_cart.user_id = auth.uid()
    )
  );
CREATE POLICY cart_items_v2_insert_own_active
  ON public.cart_items_v2 FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.carts AS owned_cart
      JOIN public.shop_products AS listing
        ON listing.id = cart_items_v2.shop_product_id
      WHERE owned_cart.id = cart_items_v2.cart_id
        AND owned_cart.user_id = auth.uid()
        AND owned_cart.status = 'active'
        AND listing.shop_id = owned_cart.shop_id
        AND listing.is_active = true
        AND listing.is_available = true
    )
  );
CREATE POLICY cart_items_v2_update_own_active
  ON public.cart_items_v2 FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.carts AS owned_cart
      WHERE owned_cart.id = cart_items_v2.cart_id
        AND owned_cart.user_id = auth.uid()
        AND owned_cart.status = 'active'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.carts AS owned_cart
      JOIN public.shop_products AS listing
        ON listing.id = cart_items_v2.shop_product_id
      WHERE owned_cart.id = cart_items_v2.cart_id
        AND owned_cart.user_id = auth.uid()
        AND owned_cart.status = 'active'
        AND listing.shop_id = owned_cart.shop_id
        AND listing.is_active = true
        AND listing.is_available = true
    )
  );
CREATE POLICY cart_items_v2_delete_own_active
  ON public.cart_items_v2 FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.carts AS owned_cart
      WHERE owned_cart.id = cart_items_v2.cart_id
        AND owned_cart.user_id = auth.uid()
        AND owned_cart.status = 'active'
    )
  );

REVOKE ALL ON TABLE public.carts, public.cart_items_v2
  FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE public.carts, public.cart_items_v2
  TO authenticated;

CREATE TRIGGER set_carts_updated_at
  BEFORE UPDATE ON public.carts
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_cart_items_v2_updated_at
  BEFORE UPDATE ON public.cart_items_v2
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

COMMIT;
