-- ===========================================
-- Esnafta Var - shops + shop_products Seed Draft
-- ===========================================
-- This file is a seed draft.
-- Do not run this before supabase_migration_shops_shop_products.sql.
-- It does not contain DROP TABLE, DELETE, or TRUNCATE statements.
-- It does not modify existing products, cart_items, categories, brands,
-- or profiles data.
-- Goal: add demo rows only to public.shops and public.shop_products.
-- ===========================================

-- ====================
-- Demo shops
-- ====================
INSERT INTO public.shops (
  id,
  owner_user_id,
  name,
  description,
  address,
  latitude,
  longitude,
  phone,
  opening_hours,
  is_active,
  rating
) VALUES
  (
    'e5000000-0000-0000-0000-000000000001',
    NULL,
    'Esnafta Var Elektronik',
    'Mahallede elektronik, aksesuar ve teknoloji urunleri satan demo esnaf.',
    'Kadikoy, Istanbul',
    40.9900,
    29.0300,
    '+90 216 000 00 01',
    '{"mon_fri":"09:00-20:00","sat":"10:00-19:00","sun":"closed"}'::jsonb,
    true,
    4.7
  ),
  (
    'e5000000-0000-0000-0000-000000000002',
    NULL,
    'Mahalle Giyim & Ayakkabi',
    'Giyim, ayakkabi ve gunluk aksesuarlar icin demo yerel magaza.',
    'Besiktas, Istanbul',
    41.0430,
    29.0050,
    '+90 212 000 00 02',
    '{"mon_sat":"10:00-21:00","sun":"12:00-18:00"}'::jsonb,
    true,
    4.5
  ),
  (
    'e5000000-0000-0000-0000-000000000003',
    NULL,
    'Evim Yakinda',
    'Ev, mobilya ve aksesuar urunleri satan demo mahalle esnafi.',
    'Uskudar, Istanbul',
    41.0250,
    29.0150,
    '+90 216 000 00 03',
    '{"mon_fri":"09:30-19:30","sat":"10:00-18:00","sun":"closed"}'::jsonb,
    true,
    4.6
  )
ON CONFLICT (id) DO UPDATE SET
  owner_user_id = EXCLUDED.owner_user_id,
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  phone = EXCLUDED.phone,
  opening_hours = EXCLUDED.opening_hours,
  is_active = EXCLUDED.is_active,
  rating = EXCLUDED.rating,
  updated_at = now();

-- ====================
-- Demo shop products
-- ====================
INSERT INTO public.shop_products (
  shop_id,
  product_id,
  price,
  is_available,
  description,
  images,
  is_active
) VALUES
  -- Esnafta Var Elektronik: electronics
  ('e5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 119.99, true, 'Magazada denenebilir kablosuz kulaklik.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000002', 89.99, true, 'Konforlu kulaklik modeli stokta.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000003', 29.99, true, 'Kablosuz mouse ayni gun magazadan alinabilir.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000004', 24.99, true, 'Telefon kilifi raf urunu.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000005', 1149.99, true, 'Profesyonel laptop icin demo magaza fiyati.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000006', 39.99, true, 'Kucuk ev elektrigi urunu stokta.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000007', 79.99, true, 'Kirmizi kulaklik modeli magazada.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000008', 1499.99, true, 'Gaming laptop demo listing.', '{}'::text[], true),

  -- Mahalle Giyim & Ayakkabi: clothes and shoes
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000009', 29.99, true, 'Pamuklu beyaz t-shirt.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000010', 24.99, true, 'Siyah t-shirt indirimli magaza fiyati.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000011', 54.99, true, 'Gri hoodie stokta.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000012', 89.99, true, 'Kapusonlu sweatshirt.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000013', 19.99, true, 'Ayarlanabilir sapka.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000014', 99.99, true, 'Deri loafer ayakkabi.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000015', 89.99, true, 'Renkli sneaker modeli.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000016', 64.99, true, 'Pembe sneaker indirimli.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000017', 59.99, true, 'Denim sandalet yazlik stokta.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000018', 119.99, true, 'Glitter topuklu ayakkabi.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000019', 119.99, true, 'Patent deri ayakkabi.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000020', 129.99, true, 'Futbol kramponu stokta.', '{}'::text[], true),

  -- Evim Yakinda: furniture and accessories
  ('e5000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000021', 249.99, true, 'Ergonomik ofis sandalyesi.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000022', 899.99, true, 'Tas tablali yemek masasi.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000023', 499.99, true, 'Ahsap yemek masasi.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000024', 1099.99, true, 'Modern deri koltuk.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000025', 399.99, true, 'Arazi tipi go-kart.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000026', 149.99, true, 'Yesil kabin boy valiz.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000027', 79.99, true, 'Seffaf moda cantasi.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000028', 39.99, true, 'Cam bardak seti.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000029', 1299.99, true, 'Elektrikli bisiklet.', '{}'::text[], true),

  -- Duplicate product listings to demo same product in different shops
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 124.99, true, 'Giyim magazasinda aksesuar rafinda alternatif fiyat.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000009', 31.99, true, 'Elektronik magazasinda promosyon t-shirt.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000021', 279.99, true, 'Elektronik magazasi ofis bolumu alternatif fiyat.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000026', 159.99, true, 'Giyim magazasinda seyahat aksesuari alternatif fiyat.', '{}'::text[], true),
  ('e5000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000029', 1399.99, true, 'Spor/ulasim urunu olarak alternatif magaza fiyati.', '{}'::text[], true)
ON CONFLICT (shop_id, product_id) DO UPDATE SET
  price = EXCLUDED.price,
  is_available = EXCLUDED.is_available,
  description = EXCLUDED.description,
  images = EXCLUDED.images,
  is_active = EXCLUDED.is_active,
  updated_at = now();
