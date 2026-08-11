# Development seed plan

Bu dizin otomatik çalıştırılabilir seed verisi içermez. Kanonik migration zinciri
yalnız şemadır; remote Development veya Production'a bu görev kapsamında seed
uygulanmamıştır.

Mevcut referanslar:

1. `supabase_sample_data.sql`: non-idempotent örnek katalog verisi içerir ve
   artık kanonik olmayan `coupons` tablosuna da veri yazdığı için olduğu gibi
   çalıştırılamaz.
2. `supabase_seed_shops_shop_products.sql`: katalog kayıtları mevcut olduktan
   sonra shop/listing seed'i sağlar; hedef kullanıcı ve ürün varsayımları fresh
   ortamda ayrıca doğrulanmalıdır.
3. `supabase_migration_customer_category_localization.sql`: şema migration'ı
   değil, belirli örnek kategori adlarına bağlı data transformation'dır.

İleride otomatik seed istenirse yeni ve ayrı bir çalışma:

- yalnız Development ortamı olduğunu doğrulamalı,
- canonical 0001–0007 tamamlandıktan sonra çalışmalı,
- sabit ve belgeli kimliklerle idempotent olmalı,
- kullanıcı/credential/secret içermemeli,
- olmayan `coupons` veya legacy `cart_items` tablolarına bağımlı olmamalı,
- category localization'ı katalog seed'inden sonra uygulamalıdır.

Bu koşullar sağlanmadan kök SQL dosyaları birleştirilmemeli ve
`supabase/seed.sql` adıyla otomatik çalıştırılmamalıdır.
