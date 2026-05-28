# Esnafta Var Cart / QR Model Tasarimi

## 1. Amac

- Esnafta Var klasik e-commerce degildir.
- Sepet online odeme veya kargo icin degil, magazada QR dogrulama icin kullanilacaktir.
- Sepet tek esnafa ait urunleri icermelidir.

## 2. Temel Kararlar

- `brandId` esnaf veya magaza yerine kullanilmayacak.
- `products` merkezi/canonical urun profili olacak.
- `shop_products` esnafin urun listing kaydi olacak.
- `carts` kullaniciya ait aktif sepeti ve `shop_id` bilgisini tutacak.
- `cart_items` sepetteki urunleri `shop_product_id` uzerinden tutacak.
- `qr_sessions` gecici QR dogrulama oturumlarini tutacak.

## 3. Onerilen Tablolar

- `shops`
- `shop_products`
- `carts`
- `cart_items`
- `qr_sessions`

## 4. shops Tablosu Minimum Alanlari

- `id`
- `owner_user_id`
- `name`
- `description`
- `address`
- `latitude`
- `longitude`
- `phone`
- `opening_hours`
- `is_active`
- `rating`
- `created_at`
- `updated_at`

## 5. shop_products Tablosu Minimum Alanlari

- `id`
- `shop_id`
- `product_id`
- `price`
- `is_available`
- `description`
- `images`
- `is_active`
- `created_at`
- `updated_at`

## 6. carts Tablosu Minimum Alanlari

- `id`
- `user_id`
- `shop_id`
- `status`
- `created_at`
- `updated_at`

## 7. cart_items Tablosu Yeni Modelde Minimum Alanlari

- `id`
- `cart_id`
- `shop_product_id`
- `quantity`
- `created_at`
- `updated_at`

## 8. qr_sessions Tablosu Minimum Alanlari

- `id`
- `user_id`
- `shop_id`
- `cart_id`
- `cart_snapshot`
- `total_amount`
- `status`
- `expires_at`
- `verified_at`
- `created_at`
- `updated_at`

## 9. Tek Esnaf Sepet Algoritmasi

- Sepet yoksa yeni `cart` olustur.
- Sepet varsa ve ayni `shop_id` ise urunu ekle veya guncelle.
- Sepet varsa ve farkli `shop_id` ise kullaniciya dialog goster.
- Kullanici onaylarsa eski sepet temizlenir ve yeni `shop_id` ile devam edilir.
- Kullanici vazgecerse hicbir sey degismez.

## 10. QR Dogrulama Akisi

- Kullanici sepette QR olusturur.
- `qr_sessions` kaydi olusturulur.
- `cart_snapshot` alinir.
- QR belirli sure gecerli olur.
- Esnaf QR'i okur.
- `status` `verified` olur.
- Odeme uygulama icinde degil, fiziksel kasada gerceklesir.

## 11. Prototip Icin Uygulanacak Sira

- Once tasarim dokumani.
- Sonra SQL migration plani.
- Sonra `shops` ve `shop_products` seed data.
- Sonra urun listeleme akisinin `shop_products` modeline tasinmasi.
- Sonra `carts` / `cart_items` yeni modele tasinmasi.
- Sonra single-shop cart rule.
- En son `qr_sessions` prototipi.

## 12. Riskler ve Dikkat Notlari

- Mevcut calisan `cart_items` yapisi hemen bozulmamali.
- Migration kucuk adimlarla yapilmali.
- Demo/prototip verisi korunmali.
- QR rezervasyon degildir; sadece magazada alisveris dogrulamasidir.
- Price snapshot onemlidir.
