# CartV2 Manuel Test Verisi Runbook

## 1. Amaç

- `public.carts` ve `public.cart_items_v2` tablolarını test etmek.
- `CartV2View` dolu state testine hazırlık yapmak.
- Eski `public.cart_items` tablosuna ve eski sepet akışına dokunmadan ilerlemek.
- Bu belge SQL çalıştırma talimatı değil, kontrollü test hazırlık runbook'udur.

## 2. Mevcut durum

- `CartV2View` read-only skeleton olarak eklendi.
- `CartV2View` henüz navigation'a bağlı değil.
- `CartV2Cubit`, `getActiveCartItems` ile active cart item'larını okuyabiliyor.
- `ProductSellersSection` hâlâ read-only.
- Eski `CartView`, badge ve `BottomAddToCart` eski `product_id` sepetini kullanıyor.

## 3. Test verisi için gerekli bilgiler

- Test kullanıcısının `auth.users.id` değeri.
- `public.shops` içinden kullanılacak `shop_id`.
- `public.shop_products` içinden kullanılacak `shop_product_id`.
- Seçilen `shop_product` kaydının `is_active = true` ve `is_available = true` olması.
- Seçilen `shop_product` kaydının seçilen `shop_id` ile uyumlu olması.
- Kullanıcı için daha önce `status = 'active'` cart olup olmadığı.

## 4. Migration / tablo ön kontrolleri

Kontrol edilmesi gerekenler:

- `public.carts` var mı?
- `public.cart_items_v2` var mı?
- `public.shops` count değeri nedir?
- `public.shop_products` count değeri nedir?
- Eski `public.cart_items` count değeri nedir?
- Test kullanıcı id'si doğru mu?

Örnek kontrol şablonları:

```sql
select to_regclass('public.carts') as carts_table;
select to_regclass('public.cart_items_v2') as cart_items_v2_table;
select count(*) as shops_count from public.shops;
select count(*) as shop_products_count from public.shop_products;
select count(*) as old_cart_items_count from public.cart_items;
select id, email from auth.users where id = '<TEST_USER_ID>';
```

## 5. Active cart unique constraint notu

- `public.carts` tablosunda kullanıcı başına `status = 'active'` için partial unique index vardır.
- Bu yüzden aynı `user_id` için ikinci bir active cart insert etmeye çalışmak hata verir.
- Testten önce kullanıcı için active cart var mı kontrol edilmelidir.

## 6. Güvenli manuel test akışı

Aşama 1:

- Test `user_id` değerini belirle.

Aşama 2:

- Kullanılacak `shop_product` kaydını seç.
- `shop_product_id`, `shop_id` ve product bilgilerini kontrol et.

Aşama 3:

- Kullanıcının active cart'ı var mı kontrol et.

Aşama 4:

- Active cart yoksa `public.carts` içine `user_id`, `shop_id`, `status = 'active'` test kaydı oluşturulabilir.

Aşama 5:

- `public.cart_items_v2` içine `cart_id`, `shop_product_id`, `quantity` test kaydı oluşturulabilir.

Aşama 6:

- `CartV2View` erişim stratejisi ayrıca hazır olduğunda read-only dolu state test edilir.

## 7. Örnek SQL şablonları

Bu SQL'ler şablondur. Değerler manuel kontrol edilmeden doğrudan çalıştırılmamalıdır.

Active cart kontrol sorgusu:

```sql
select *
from public.carts
where user_id = '<TEST_USER_ID>'
  and status = 'active';
```

`shop_product` kontrol sorgusu:

```sql
select
  sp.id as shop_product_id,
  sp.shop_id,
  sp.product_id,
  sp.price,
  sp.is_active,
  sp.is_available,
  s.name as shop_name,
  p.name as product_name
from public.shop_products sp
join public.shops s on s.id = sp.shop_id
join public.products p on p.id = sp.product_id
where sp.id = '<SHOP_PRODUCT_ID>';
```

`carts` insert şablonu:

```sql
insert into public.carts (
  user_id,
  shop_id,
  status
)
values (
  '<TEST_USER_ID>',
  '<SHOP_ID>',
  'active'
)
returning id;
```

`cart_items_v2` insert şablonu:

```sql
insert into public.cart_items_v2 (
  cart_id,
  shop_product_id,
  quantity
)
values (
  '<CART_ID>',
  '<SHOP_PRODUCT_ID>',
  1
)
returning *;
```

Test kayıtlarını okuma sorgusu:

```sql
select
  c.id as cart_id,
  c.user_id,
  c.shop_id as cart_shop_id,
  c.status,
  ci.id as cart_item_id,
  ci.shop_product_id,
  ci.quantity,
  sp.price,
  s.name as shop_name,
  p.name as product_name
from public.carts c
join public.cart_items_v2 ci on ci.cart_id = c.id
join public.shop_products sp on sp.id = ci.shop_product_id
join public.shops s on s.id = sp.shop_id
join public.products p on p.id = sp.product_id
where c.user_id = '<TEST_USER_ID>'
  and c.status = 'active';
```

## 8. Dikkat edilmesi gerekenler

- Eski `public.cart_items` tablosuna dokunma.
- Eski `cart_items` verisini silme.
- Gerçek kullanıcı verisiyle test yapma; mümkünse test kullanıcısı kullan.
- Aynı `user_id` için duplicate active cart oluşturmaya çalışma.
- Farklı `shop_id` ile item ekleme durumunda tek esnaf kuralı ileride repository tarafından yönetilecek; manuel testte `shop_id` uyumuna dikkat et.
- QR, checkout, ödeme veya kargo akışı ekleme.

## 9. Temizlik / geri alma notu

- Test verisi oluşturulursa sadece test `user_id` değerine ait `carts` ve `cart_items_v2` kayıtları temizlenmelidir.
- Eski `public.cart_items` tablosuna dokunulmamalıdır.
- DELETE şablonları çok dikkatli kullanılmalı ve `user_id` / `cart_id` filtreli olmalıdır.
- Toplu delete, drop veya truncate kullanılmamalıdır.

Filtreli temizlik şablonu:

```sql
delete from public.cart_items_v2
where cart_id in (
  select id
  from public.carts
  where user_id = '<TEST_USER_ID>'
);

delete from public.carts
where user_id = '<TEST_USER_ID>';
```

## 10. CartV2View testinden önce

- `CartV2View` henüz navigation'a bağlı değildir.
- Önce debug-only erişim stratejisi ayrıca analiz edilmelidir.
- Kullanıcı-facing sepet ikonuna bağlama yapılmamalıdır.

## 11. Riskler

- Yanlış `user_id` ile veri eklemek.
- Aynı kullanıcıya ikinci active cart eklemeye çalışmak.
- `shop_product` / `shop` uyumsuzluğu.
- Eski `cart_items` tablosuna yanlışlıkla müdahale etmek.
- Test verisini production gerçek kullanıcıda bırakmak.
- Debug erişimi kullanıcı-facing hale getirmek.

## 12. Sonuç

- Bu runbook sadece CartV2 dolu state testine hazırlıktır.
- `ProductSellersSection` v2 add button, badge geçişi ve ana `CartView` geçişi ayrı çalışmalardır.
