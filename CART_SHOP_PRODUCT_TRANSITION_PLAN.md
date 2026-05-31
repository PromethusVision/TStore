# Cart shop_product_id Gecis Plani

## 1. Amac

- Mevcut `product_id` tabanli sepetten `shop_product_id` tabanli sepete gecisi planlamak.
- Mevcut calisan add-to-cart / cart / quantity / delete akisini bozmadan ilerlemek.
- Tek esnaf sepet kurali ve QR dogrulama sepetine zemin hazirlamak.

## 2. Mevcut Durum

- `cart_items` su an `user_id` + `product_id` + `quantity` + `selected_attributes` kullaniyor.
- `CartItemEntity`, `productId` ve `ProductEntity` tasiyor.
- `CartRepositoryImpl.addToCart`, `user_id` + `product_id` ile calisiyor.
- `ProductSellersSection`, `shop_products` listesini read-only gosteriyor.
- `BottomAddToCart`, `product.id` ile calisiyor.

## 3. Hedef Model

- `carts` tablosu: `user_id`, `shop_id`, `status`.
- Yeni `cart_items` modeli: `cart_id`, `shop_product_id`, `quantity`.
- `shop_product_id` uzerinden product ve shop bilgisi join edilecek.
- QR icin ileride `cart_snapshot` uretilecek.

## 4. Neden Dogrudan UI Butonu Eklenmemeli?

- "Bu esnaftan sepete ekle" butonu icin DB ve repository altyapisi yok.
- Shop secimi olmadan `shop_product_id` belirlenemez.
- Tek esnaf kurali olmadan farkli esnaflar ayni sepete karisabilir.

## 5. Gecis Secenekleri

### A) Ara Gecis

- Mevcut `cart_items` icine nullable `shop_product_id` eklemek.
- Eski `product_id` akisini bir sure korumak.
- Daha hizli ama model karmasasi riski var.

### B) Dogru Hedef Model

- `carts` ust tablosu eklemek.
- `cart_items` yeni modelini `cart_id` + `shop_product_id` uzerine kurmak.
- Daha temiz ama daha buyuk gecis.

## 6. Onerilen Strateji

- Hedef model `carts` + `cart_items` olmali.
- Ancak migration parca parca yapilmali.
- Mevcut `cart_items` hemen bozulmamali.
- Yeni model paralel hazirlanmali.
- UI en son yeni modele baglanmali.

## 7. Asamali Gecis Plani

### Asama 1

- Yeni `carts` tablosu icin migration taslagi.
- Mevcut `cart_items` degistirilmez.

### Asama 2

- Yeni `cart_items_v2` veya yeni isimli gecici tablo tasarimi degerlendirilir.
- Mevcut `cart_items` ile isim cakismasi riski analiz edilir.

### Asama 3

- Repository'ye paralel method eklenir:
  - `addShopProductToCart(shopProductId, quantity)`

### Asama 4

- Tek esnaf sepet kurali repository / usecase seviyesinde tasarlanir.
- Farkli shop durumunda UI'ya ozel sonuc dondurulur.

### Asama 5

- `ProductSellersSection` icine "Bu esnaftan sepete ekle" aksiyonu eklenir.
- `BottomAddToCart` rolu yeniden degerlendirilir.

### Asama 6

- `CartView` yeni modelde shop / listing fiyatini ve shop bilgisini gosterir.

### Asama 7

- QR session / `cart_snapshot` akisi baslatilir.

## 8. Tek Esnaf Sepet Algoritmasi

- Aktif cart yoksa `shop_id` ile cart olustur.
- Aktif cart ayni `shop_id` ise item ekle veya guncelle.
- Aktif cart farkli `shop_id` ise ozel conflict sonucu dondur.
- UI dialog gosterir:
  - "Sepetinizde baska bir esnafa ait urunler var. Sepeti temizleyip bu esnafla devam etmek ister misiniz?"
- Onaylanirsa eski aktif sepet kapatilir / temizlenir ve yeni shop ile devam edilir.
- Vazgecilirse hicbir sey degismez.

## 9. Fiyat Kurallari

- Mevcut `product.price` canonical / referans fiyat olarak kalir.
- Cart ve QR icin `shop_products.price` esas alinir.
- QR olusturulurken `cart_snapshot` ve `total_amount` alinir.
- Sonradan fiyat degisse bile QR snapshot bozulmaz.

## 10. UI Karar Notlari

- Bu asamada `ProductSellersSection` read-only kalabilir.
- "Mesaj" ve "Yol Tarifi" placeholder butonlari erken.
- Ilk gercek aksiyon "Bu esnaftan sepete ekle" olmali ama altyapi tamamlandiktan sonra.
- `BottomAddToCart` ileride kaldirilabilir veya sadece quantity seciciye donusebilir.

## 11. Riskler

- Mevcut calisan sepet bozulabilir.
- Eski `cart_items` migration'i kullanici sepetlerini etkileyebilir.
- `product.price` ve `shop_products.price` karisabilir.
- Tek esnaf kurali sadece UI'da kalirsa veri butunlugu zayif olur.
- QR snapshot alinmazsa kasada fiyat / dogrulama tutarsizligi olusur.

## 12. Sonuc

- Bir sonraki teknik adim dogrudan UI degil.
- Once `carts` / `cart_items` yeni model migration plani hazirlanmali.
- Mevcut `product_id` sepet akisi gecis tamamlanana kadar korunmali.
