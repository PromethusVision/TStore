# carts + cart_items_v2 Migration Runbook

## 1. Amac

- Mevcut `product_id` tabanli `cart_items` akisini bozmadan `carts` + `cart_items_v2` tablolarini Supabase'e eklemek.
- Bu migration mevcut sepet sistemini degistirmeyecek.
- Bu migration sadece gelecekteki `shop_product_id` tabanli sepet icin paralel altyapi hazirlayacak.

## 2. Calistirilacak Dosya

- `supabase_migration_carts_v2.sql`

## 3. Calistirmadan Once Kontrol Listesi

- GitHub Desktop Changes temiz mi?
- Son commit push edildi mi?
- Dogru Supabase projesinde miyiz?
- `public.shops` var mi?
- `public.shop_products` var mi?
- `public.cart_items` eski sistemde calisiyor mu?
- Uygulamada add-to-cart / cart / quantity / delete / badge akisi calisiyor mu?

## 4. Migration Oncesi SQL Kontrolleri

```sql
select count(*) as shops_count from public.shops;

select count(*) as shop_products_count from public.shop_products;

select count(*) as old_cart_items_count from public.cart_items;

select to_regclass('public.carts') as carts_table;

select to_regclass('public.cart_items_v2') as cart_items_v2_table;
```

## 5. Migration Sonrasi Beklenen Sonuclar

- `public.carts` tablosu olusmali.
- `public.cart_items_v2` tablosu olusmali.
- Eski `public.cart_items` tablosu degismemeli.
- Eski `cart_items` kayitlari silinmemeli.
- `carts` count baslangicta `0` olabilir.
- `cart_items_v2` count baslangicta `0` olabilir.

## 6. Migration Sonrasi SQL Kontrolleri

```sql
select to_regclass('public.carts') as carts_table;

select to_regclass('public.cart_items_v2') as cart_items_v2_table;

select count(*) as carts_count from public.carts;

select count(*) as cart_items_v2_count from public.cart_items_v2;

select count(*) as old_cart_items_count from public.cart_items;

select relrowsecurity as carts_rls_enabled
from pg_class
where oid = 'public.carts'::regclass;

select relrowsecurity as cart_items_v2_rls_enabled
from pg_class
where oid = 'public.cart_items_v2'::regclass;
```

## 7. Uygulama Smoke Test

- Ana sayfa aciliyor mu?
- Kategoriler geliyor mu?
- Urun detay aciliyor mu?
- `ProductSellersSection` calisiyor mu?
- Sepete Ekle calisiyor mu?
- Sepet urunleri gosteriyor mu?
- Quantity + / - calisiyor mu?
- Urun silme calisiyor mu?
- Badge calisiyor mu?

## 8. Riskler

- Yanlislikla `supabase_schema.sql` calistirilmamali.
- Eski `cart_items` tablosuna dokunulmamali.
- Migration sadece paralel tablo eklemeli.
- Bu migration tek esnaf sepet kuralini henuz uygulamaz.
- Bu migration UI / repository akisini henuz degistirmez.

## 9. Geri Donus Notu

- Bu tablolar henuz uygulama tarafindan kullanilmadigi icin migration sonrasi uygulama bozulmamali.
- Sorun olursa yeni tablolar kullanilmadan birakilabilir.
- Drop / delete gibi islemler ayri karar ve backup olmadan yapilmamali.

## 10. Sonraki Adim

- Migration basariyla calistirilirsa Calisma 30: CartV2 entity / model / repository analizine gecilebilir.
- UI'ya "Bu esnaftan sepete ekle" butonu eklemek daha sonraki asamadir.
