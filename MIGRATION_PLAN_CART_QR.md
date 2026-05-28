# Cart / Shop / QR Migration Plani

## 1. Amac

- Mevcut calisan `products` / `cart_items` / add-to-cart / cart view akisini bozmadan Esnafta Var'in `shops` + `shop_products` + `carts` + `cart_items` + `qr_sessions` modeline gecis planini tanimlamak.
- Bu belge SQL migration dosyasi degildir; uygulama sirasi ve risk planidir.

## 2. Mevcut Calisan Durum

- `products` tablosu calisiyor.
- `categories` ve `brands` calisiyor.
- `cart_items` mevcut yapida `user_id` + `product_id` + `quantity` ile calisiyor.
- `ProductDetailsView` gercek urun verisiyle calisiyor.
- Add to cart calisiyor.
- `CartView` gercek `cart_items` verisini gosteriyor.
- Urun silme ve quantity + / - calisiyor.

## 3. Kritik Uyarilar

- `supabase_schema.sql` reset/drop iceren bir dosya oldugu icin dogrudan calistirilmamali.
- Mevcut `cart_items` yapisi hemen bozulmamali.
- `brandId` asla esnaf veya magaza yerine kullanilmamali.
- QR checkout degildir; magazada alisveris dogrulama oturumudur.

## 4. Asama 1: shops ve shop_products Tablolarini Paralel Ekleme

- Mevcut `products` ve `cart_items` akisina dokunma.
- `shops` tablosu eklenir.
- `shop_products` tablosu eklenir.
- RLS / policy / grant plani ayrica hazirlanir.
- Bu asamada uygulama kodu hala eski `products` akisini kullanir.

## 5. Asama 2: Demo shops ve shop_products Seed Plani

- 3 demo shop onerilir:
  - elektronik agirlikli
  - giyim / ayakkabi agirlikli
  - ev / aksesuar agirlikli
- Mevcut 29 urun en az bir shop'a baglanir.
- Bazi urunler birden fazla shop'a baglanir.
- Ayni `product_id`, farkli `shop_id` ile farkli `price` / `is_available` verisi tasiyabilir.

## 6. Asama 3: Product / ShopProduct Model Ayrimi

- `products` canonical urun profili olarak kalir.
- `shop_products` esnaf listing kaydi olur.
- `ProductEntity` hemen bozulmaz.
- Yeni `ShopProductEntity` / `ShopEntity` plani ayrica cikarilir.

## 7. Asama 4: Urun Listeleme Akisini shop_products Modeline Hazirlama

- Ilk etapta mevcut urun listeleme calismaya devam eder.
- Sonra urun detayinda "bu urunu satan esnaflar" mantigina gecis planlanir.
- Nearby / sorting / location calismalari daha sonraya birakilir.

## 8. Asama 5: carts Ust Tablosunu Ekleme

- `carts` tablosu paralel eklenir.
- Mevcut `cart_items` hemen degistirilmez.
- `carts.user_id` + `carts.shop_id` + `status` mantigi planlanir.

## 9. Asama 6: Yeni cart_items Modeline Gecis

- Yeni modelde `cart_items`, `cart_id` + `shop_product_id` + `quantity` tutar.
- Eski `cart_items.product_id` bagimliligi hemen kaldirilmaz.
- Gecis icin ayri branch ve test plani gerekir.

## 10. Asama 7: Tek Esnaf Sepet Kurali

- Sepet yoksa yeni cart olustur.
- Ayni `shop_id` ise urunu ekle veya guncelle.
- Farkli `shop_id` ise kullaniciya dialog goster.
- Onaylanirsa sepet temizlenir ve yeni shop ile devam edilir.
- Vazgecerse hicbir sey degismez.

## 11. Asama 8: qr_sessions Tablosu

- QR modeli en son eklenir.
- `qr_sessions` gecici dogrulama oturumu tutar.
- `cart_snapshot` ve `total_amount` onemlidir.
- `status`: `pending`, `verified`, `expired`, `cancelled`.
- QR rezervasyon degildir.

## 12. Test Plani

Her asamada su kontroller yapilmali:

- Ana sayfa aciliyor mu?
- Kategoriler calisiyor mu?
- Urun detay aciliyor mu?
- Add to cart calisiyor mu?
- `CartView` urun gosteriyor mu?
- Urun silme calisiyor mu?
- Quantity + / - calisiyor mu?
- Eski davranis bozuldu mu?

## 13. Geri Donus Plani

- Her migration ayri branch'te yapilmali.
- Her asama kucuk commit ile ilerlemeli.
- Mevcut calisan sepet bozulursa son saglam commit'e donulebilmeli.
- SQL uygulanmadan once Supabase backup / export dusunulmeli.

## 14. Sonuc

- Ilk gercek migration sadece `shops` + `shop_products` eklemeli.
- `carts` / `cart_items` donusumu daha sonra yapilmali.
- `qr_sessions` en son asamada eklenmeli.
