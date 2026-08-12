-- EsnaftaVar canonical migration 0001: core auth and catalog.
-- Fresh Supabase project bootstrap only. This migration never resets data.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $preflight$
BEGIN
  IF to_regclass('auth.users') IS NULL THEN
    RAISE EXCEPTION
      'Managed Supabase table auth.users is required before migration 0001'
      USING ERRCODE = '42P01';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM pg_class AS relation
    JOIN pg_namespace AS namespace
      ON namespace.oid = relation.relnamespace
    WHERE namespace.nspname = 'auth'
      AND relation.relname = 'users'
      AND relation.relkind NOT IN ('r', 'p')
  ) THEN
    RAISE EXCEPTION 'auth.users must be a managed table'
      USING ERRCODE = '42809';
  END IF;
END
$preflight$;

REVOKE CREATE ON SCHEMA public FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA public TO anon, authenticated;

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'customer',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT profiles_email_key UNIQUE (email),
  CONSTRAINT profiles_role_check
    CHECK (role IN ('customer', 'merchant', 'admin'))
);

CREATE TABLE public.legal_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL,
  document_version TEXT NOT NULL,
  source TEXT NOT NULL DEFAULT 'customer_signup',
  accepted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT legal_consents_document_type_check
    CHECK (
      document_type IN (
        'privacy_notice_acknowledged',
        'terms_of_use_accepted'
      )
    ),
  CONSTRAINT legal_consents_document_version_not_empty_check
    CHECK (length(btrim(document_version)) > 0),
  CONSTRAINT legal_consents_source_check
    CHECK (source = 'customer_signup'),
  CONSTRAINT legal_consents_user_document_version_key
    UNIQUE (user_id, document_type, document_version)
);

CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  parent_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT categories_name_not_empty_check
    CHECK (length(btrim(name)) > 0)
);

CREATE TABLE public.brands (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  is_featured BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT brands_name_not_empty_check
    CHECK (length(btrim(name)) > 0)
);

CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC(10, 2) NOT NULL,
  sale_price NUMERIC(10, 2),
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  brand_id UUID REFERENCES public.brands(id) ON DELETE SET NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  thumbnail TEXT,
  images TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  rating NUMERIC(2, 1) NOT NULL DEFAULT 0,
  reviews_count INTEGER NOT NULL DEFAULT 0,
  is_featured BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  attributes JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT products_name_not_empty_check
    CHECK (length(btrim(name)) > 0),
  CONSTRAINT products_price_nonnegative_check CHECK (price >= 0),
  CONSTRAINT products_sale_price_nonnegative_check
    CHECK (sale_price IS NULL OR sale_price >= 0),
  CONSTRAINT products_stock_nonnegative_check CHECK (stock >= 0),
  CONSTRAINT products_rating_range_check CHECK (rating BETWEEN 0 AND 5),
  CONSTRAINT products_reviews_count_nonnegative_check
    CHECK (reviews_count >= 0)
);

CREATE TABLE public.addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  city TEXT NOT NULL,
  state TEXT,
  postal_code TEXT,
  country TEXT NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.customer_saved_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  address_text TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT customer_saved_locations_name_length_check
    CHECK (char_length(btrim(name)) BETWEEN 1 AND 50),
  CONSTRAINT customer_saved_locations_address_length_check
    CHECK (char_length(btrim(address_text)) BETWEEN 1 AND 200),
  CONSTRAINT customer_saved_locations_latitude_check
    CHECK (latitude BETWEEN -90 AND 90),
  CONSTRAINT customer_saved_locations_longitude_check
    CHECK (longitude BETWEEN -180 AND 180)
);

CREATE TABLE public.wishlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT wishlist_user_product_key UNIQUE (user_id, product_id)
);

-- Legacy order records remain only for the existing product-review contract.
-- The active Cart V2 / QR flow is deliberately not linked to these tables.
CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  address_id UUID REFERENCES public.addresses(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  subtotal NUMERIC(10, 2) NOT NULL,
  shipping_cost NUMERIC(10, 2) NOT NULL DEFAULT 0,
  discount NUMERIC(10, 2) NOT NULL DEFAULT 0,
  total NUMERIC(10, 2) NOT NULL,
  coupon_code TEXT,
  payment_method TEXT NOT NULL,
  payment_status TEXT NOT NULL DEFAULT 'pending',
  notes TEXT,
  shipping_address JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT orders_subtotal_nonnegative_check CHECK (subtotal >= 0),
  CONSTRAINT orders_shipping_cost_nonnegative_check CHECK (shipping_cost >= 0),
  CONSTRAINT orders_discount_nonnegative_check CHECK (discount >= 0),
  CONSTRAINT orders_total_nonnegative_check CHECK (total >= 0)
);

CREATE TABLE public.order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
  product_name TEXT NOT NULL,
  product_image TEXT,
  price NUMERIC(10, 2) NOT NULL,
  quantity INTEGER NOT NULL,
  selected_attributes JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT order_items_price_nonnegative_check CHECK (price >= 0),
  CONSTRAINT order_items_quantity_positive_check CHECK (quantity > 0)
);

CREATE TABLE public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL,
  title TEXT,
  comment TEXT,
  images TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  is_verified_purchase BOOLEAN NOT NULL DEFAULT false,
  helpful_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT reviews_rating_range_check CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT reviews_helpful_count_nonnegative_check CHECK (helpful_count >= 0),
  CONSTRAINT reviews_user_product_key UNIQUE (user_id, product_id)
);

CREATE TABLE public.banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url TEXT NOT NULL,
  title TEXT,
  subtitle TEXT,
  action_url TEXT,
  action_type TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT banners_date_order_check
    CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

CREATE TABLE public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type TEXT NOT NULL DEFAULT 'text',
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chat_messages_content_length_check
    CHECK (char_length(btrim(content)) BETWEEN 1 AND 1000),
  CONSTRAINT chat_messages_message_type_check
    CHECK (message_type IN ('text', 'image', 'system'))
);

CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'system',
  data JSONB,
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT notifications_type_check
    CHECK (type IN ('system', 'order', 'promotion', 'chat'))
);

CREATE INDEX profiles_role_idx ON public.profiles(role);
CREATE INDEX legal_consents_user_accepted_at_idx
  ON public.legal_consents(user_id, accepted_at DESC);
CREATE INDEX categories_parent_sort_idx
  ON public.categories(parent_id, sort_order);
CREATE INDEX products_category_idx ON public.products(category_id);
CREATE INDEX products_brand_idx ON public.products(brand_id);
CREATE INDEX products_featured_idx
  ON public.products(is_featured) WHERE is_featured = true;
CREATE INDEX products_active_idx
  ON public.products(is_active) WHERE is_active = true;
CREATE INDEX addresses_user_idx ON public.addresses(user_id);
CREATE INDEX customer_saved_locations_user_created_idx
  ON public.customer_saved_locations(user_id, created_at DESC);
CREATE UNIQUE INDEX customer_saved_locations_one_default_idx
  ON public.customer_saved_locations(user_id) WHERE is_default = true;
CREATE INDEX wishlist_user_idx ON public.wishlist(user_id);
CREATE INDEX orders_user_created_idx
  ON public.orders(user_id, created_at DESC);
CREATE INDEX orders_status_idx ON public.orders(status);
CREATE INDEX order_items_product_idx ON public.order_items(product_id);
CREATE INDEX reviews_product_created_idx
  ON public.reviews(product_id, created_at DESC);
CREATE INDEX chat_messages_sender_idx ON public.chat_messages(sender_id);
CREATE INDEX chat_messages_receiver_idx ON public.chat_messages(receiver_id);
CREATE INDEX notifications_user_created_idx
  ON public.notifications(user_id, created_at DESC);
CREATE INDEX notifications_user_unread_idx
  ON public.notifications(user_id, created_at DESC) WHERE is_read = false;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_consents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_saved_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_select_own
  ON public.profiles FOR SELECT TO authenticated
  USING (id = auth.uid());
CREATE POLICY profiles_insert_own
  ON public.profiles FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid());
CREATE POLICY profiles_update_own
  ON public.profiles FOR UPDATE TO authenticated
  USING (id = auth.uid()) WITH CHECK (id = auth.uid());

CREATE POLICY legal_consents_select_own
  ON public.legal_consents FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY categories_read_active
  ON public.categories FOR SELECT TO anon, authenticated
  USING (is_active = true);
CREATE POLICY brands_read_active
  ON public.brands FOR SELECT TO anon, authenticated
  USING (is_active = true);
CREATE POLICY products_read_active
  ON public.products FOR SELECT TO anon, authenticated
  USING (is_active = true);

CREATE POLICY addresses_select_own
  ON public.addresses FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY addresses_insert_own
  ON public.addresses FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY addresses_update_own
  ON public.addresses FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY addresses_delete_own
  ON public.addresses FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY customer_saved_locations_select_own
  ON public.customer_saved_locations FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY customer_saved_locations_insert_own
  ON public.customer_saved_locations FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY customer_saved_locations_update_own
  ON public.customer_saved_locations FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY customer_saved_locations_delete_own
  ON public.customer_saved_locations FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY wishlist_select_own
  ON public.wishlist FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY wishlist_insert_own
  ON public.wishlist FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY wishlist_delete_own
  ON public.wishlist FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY legacy_orders_select_own
  ON public.orders FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY legacy_orders_insert_own
  ON public.orders FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY legacy_order_items_select_own
  ON public.order_items FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.orders AS customer_order
      WHERE customer_order.id = order_items.order_id
        AND customer_order.user_id = auth.uid()
    )
  );
CREATE POLICY legacy_order_items_insert_own
  ON public.order_items FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders AS customer_order
      WHERE customer_order.id = order_items.order_id
        AND customer_order.user_id = auth.uid()
    )
  );

CREATE POLICY reviews_read_all
  ON public.reviews FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY reviews_insert_own
  ON public.reviews FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY reviews_update_own
  ON public.reviews FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY reviews_delete_own
  ON public.reviews FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY banners_read_active
  ON public.banners FOR SELECT TO anon, authenticated
  USING (
    is_active = true
    AND (start_date IS NULL OR start_date <= now())
    AND (end_date IS NULL OR end_date >= now())
  );

CREATE POLICY chat_messages_select_participant
  ON public.chat_messages FOR SELECT TO authenticated
  USING (sender_id = auth.uid() OR receiver_id = auth.uid());
CREATE POLICY chat_messages_insert_sender
  ON public.chat_messages FOR INSERT TO authenticated
  WITH CHECK (sender_id = auth.uid());
CREATE POLICY chat_messages_update_receiver
  ON public.chat_messages FOR UPDATE TO authenticated
  USING (receiver_id = auth.uid())
  WITH CHECK (receiver_id = auth.uid());

CREATE POLICY notifications_select_own
  ON public.notifications FOR SELECT TO authenticated
  USING (user_id = auth.uid());
CREATE POLICY notifications_update_own
  ON public.notifications FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY notifications_delete_own
  ON public.notifications FOR DELETE TO authenticated
  USING (user_id = auth.uid());

REVOKE ALL ON TABLE
  public.profiles,
  public.legal_consents,
  public.categories,
  public.brands,
  public.products,
  public.addresses,
  public.customer_saved_locations,
  public.wishlist,
  public.orders,
  public.order_items,
  public.reviews,
  public.banners,
  public.chat_messages,
  public.notifications
FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE ON TABLE public.profiles TO authenticated;
GRANT SELECT ON TABLE public.legal_consents TO authenticated;
GRANT SELECT ON TABLE public.categories, public.brands, public.products,
  public.banners TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.addresses,
  public.customer_saved_locations TO authenticated;
GRANT SELECT, INSERT, DELETE ON TABLE public.wishlist TO authenticated;
GRANT SELECT, INSERT ON TABLE public.orders, public.order_items
  TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.reviews
  TO authenticated;
GRANT SELECT ON TABLE public.reviews TO anon;
GRANT SELECT, INSERT ON TABLE public.chat_messages TO authenticated;
GRANT UPDATE (is_read) ON TABLE public.chat_messages TO authenticated;
-- Notification table privileges are finalized in migration 0006. Direct
-- authenticated INSERT is intentionally never granted.

CREATE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $function$
BEGIN
  NEW.updated_at := pg_catalog.clock_timestamp();
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.set_updated_at()
  FROM PUBLIC, anon, authenticated;

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_categories_updated_at
  BEFORE UPDATE ON public.categories
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_brands_updated_at
  BEFORE UPDATE ON public.brands
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_addresses_updated_at
  BEFORE UPDATE ON public.addresses
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_customer_saved_locations_updated_at
  BEFORE UPDATE ON public.customer_saved_locations
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_orders_updated_at
  BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_reviews_updated_at
  BEFORE UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE FUNCTION public.prevent_profile_role_client_escalation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
  IF auth.role() = 'authenticated' THEN
    IF TG_OP = 'INSERT'
       AND pg_catalog.coalesce(NEW.role, 'customer') <> 'customer' THEN
      RAISE EXCEPTION
        'Setting a privileged profile role from the client is not allowed'
        USING ERRCODE = '42501';
    END IF;

    IF TG_OP = 'UPDATE' AND OLD.role IS DISTINCT FROM NEW.role THEN
      RAISE EXCEPTION
        'Changing a profile role from the client is not allowed'
        USING ERRCODE = '42501';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.prevent_profile_role_client_escalation()
  FROM PUBLIC, anon, authenticated;

CREATE TRIGGER prevent_profile_role_client_escalation
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_profile_role_client_escalation();

CREATE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone, role)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'phone',
    'customer'
  );

  IF NEW.raw_user_meta_data->>'privacy_notice_acknowledged' = 'true'
     AND NEW.raw_user_meta_data->>'privacy_notice_version' = '2026-07-17' THEN
    INSERT INTO public.legal_consents (
      user_id, document_type, document_version
    ) VALUES (
      NEW.id, 'privacy_notice_acknowledged', '2026-07-17'
    ) ON CONFLICT (user_id, document_type, document_version) DO NOTHING;
  END IF;

  IF NEW.raw_user_meta_data->>'terms_of_use_accepted' = 'true'
     AND NEW.raw_user_meta_data->>'terms_of_use_version' = '2026-07-17' THEN
    INSERT INTO public.legal_consents (
      user_id, document_type, document_version
    ) VALUES (
      NEW.id, 'terms_of_use_accepted', '2026-07-17'
    ) ON CONFLICT (user_id, document_type, document_version) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.handle_new_user()
  FROM PUBLIC, anon, authenticated;

DO $signup_trigger$
DECLARE
  existing_function_name TEXT;
BEGIN
  SELECT function_namespace.nspname || '.' || function_proc.proname
    INTO existing_function_name
  FROM pg_trigger AS trigger_row
  JOIN pg_proc AS function_proc ON function_proc.oid = trigger_row.tgfoid
  JOIN pg_namespace AS function_namespace
    ON function_namespace.oid = function_proc.pronamespace
  WHERE trigger_row.tgrelid = 'auth.users'::regclass
    AND trigger_row.tgname = 'on_auth_user_created'
    AND NOT trigger_row.tgisinternal;

  IF existing_function_name IS NULL THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
  ELSIF existing_function_name <> 'public.handle_new_user' THEN
    RAISE EXCEPTION
      'auth.users trigger on_auth_user_created already calls %. Review it manually; canonical migration will not drop it.',
      existing_function_name
      USING ERRCODE = '42710';
  END IF;
END
$signup_trigger$;

CREATE FUNCTION public.set_default_customer_saved_location(
  p_location_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog, public, auth
AS $function$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM public.customer_saved_locations
    WHERE id = p_location_id AND user_id = auth.uid()
  ) THEN
    RETURN false;
  END IF;

  UPDATE public.customer_saved_locations
  SET is_default = false
  WHERE user_id = auth.uid() AND is_default = true;

  UPDATE public.customer_saved_locations
  SET is_default = true
  WHERE id = p_location_id AND user_id = auth.uid();

  RETURN true;
END;
$function$;

CREATE FUNCTION public.delete_customer_saved_location(
  p_location_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog, public, auth
AS $function$
DECLARE
  deleted_was_default BOOLEAN;
BEGIN
  DELETE FROM public.customer_saved_locations
  WHERE id = p_location_id AND user_id = auth.uid()
  RETURNING is_default INTO deleted_was_default;

  IF NOT FOUND THEN
    RETURN false;
  END IF;

  IF deleted_was_default THEN
    UPDATE public.customer_saved_locations
    SET is_default = true
    WHERE id = (
      SELECT id
      FROM public.customer_saved_locations
      WHERE user_id = auth.uid()
      ORDER BY created_at DESC
      LIMIT 1
    );
  END IF;

  RETURN true;
END;
$function$;

REVOKE ALL ON FUNCTION public.set_default_customer_saved_location(UUID)
  FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.delete_customer_saved_location(UUID)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_default_customer_saved_location(UUID)
  TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_customer_saved_location(UUID)
  TO authenticated;

CREATE FUNCTION public.refresh_product_rating_after_review()
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

CREATE TRIGGER refresh_product_rating_after_review
  AFTER INSERT OR UPDATE OR DELETE ON public.reviews
  FOR EACH ROW
  EXECUTE FUNCTION public.refresh_product_rating_after_review();

COMMIT;
