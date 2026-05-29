# Shops Migration Runbook

## 1. Amac

- `shops` ve `shop_products` tablolarini mevcut calisan sistemi bozmadan Supabase'e eklemek.
- Mevcut `products` / `cart_items` / add-to-cart / cart view akisina dokunmamak.

## 2. Calistirilacak Dosya Sirasi

1. `supabase_migration_shops_shop_products.sql`
2. `supabase_seed_shops_shop_products.sql`

## 3. Calistirmadan Once Kontrol Listesi

- GitHub Desktop Changes temiz mi?
- Son commit push edildi mi?
- Supabase projesi dogru proje mi?
- `products` tablosunda 29 urun var mi?
- `categories` ve `brands` calisiyor mu?
- `cart_items` mevcut sepet akisinda calisiyor mu?

## 4. Migration Sonrasi Kontrol SQL'leri

```sql
-- shops tablosu olustu mu?
select to_regclass('public.shops') as shops_table;

-- shop_products tablosu olustu mu?
select to_regclass('public.shop_products') as shop_products_table;

-- shop count kac?
select count(*) as shop_count
from public.shops;

-- shop_products count kac?
select count(*) as shop_products_count
from public.shop_products;

-- her product en az bir shop'a baglanmis mi?
select p.id, p.name
from public.products p
left join public.shop_products sp on sp.product_id = p.id
where sp.id is null;

-- duplicate shop/product var mi?
select shop_id, product_id, count(*) as duplicate_count
from public.shop_products
group by shop_id, product_id
having count(*) > 1;
```

## 5. Seed Sonrasi Beklenen Sonuclar

- `shops` count = 3
- `shop_products` count = 34 beklenir.
- Bunun nedeni: 29 urun + 5 duplicate listing.

## 6. Uygulama Smoke Test

- Ana sayfa aciliyor mu?
- Kategoriler geliyor mu?
- Urun detay aciliyor mu?
- Sepete ekle calisiyor mu?
- Sepet gercek urunleri gosteriyor mu?
- Silme calisiyor mu?
- Quantity + / - calisiyor mu?

## 7. Riskler

- SQL yanlis projede calistirilmamali.
- `supabase_schema.sql` calistirilmamali.
- DROP TABLE iceren dosyalar kullanilmamali.
- Mevcut `cart_items` akisina dokunulmadigi dogrulanmali.

## 8. Geri Donus Plani

- Bu migration mevcut `products` / `cart_items` tablolarini degistirmedigi icin uygulama bozulmamali.
- Sorun olursa yeni eklenen `shops` / `shop_products` tablolari kullanilmadan birakilabilir.
- Daha agresif temizlik veya silme islemleri yapilmadan once ayrica karar alinmali.

## 9. Sonraki Adim

- Eger migration ve seed basarili olursa Calisma 21: `ShopEntity` / `ShopProductEntity` model analizi.
- Kod gecisi hemen yapilmayacak; once entity / repository plani cikarilacak.
