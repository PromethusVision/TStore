# CartV2View Stratejisi

## 1. Amaç

- V2 sepetin kullanıcıya nasıl gösterileceğini planlamak.
- Eski `CartView` ve badge akışını bozmadan ilerlemek.
- `ProductSellersSection` içine "Bu esnaftan sepete ekle" aksiyonu eklenmeden önce kullanıcıya görünecek sepet ekranını netleştirmek.
- Sepet toplamı bölümünü hem eski hem v2 sepet stratejisinde dikkate almak.

## 2. Mevcut Durum

- Eski `CartView`, `CartCubit` ve `public.cart_items` ile çalışıyor.
- Eski badge, `CartCubit` / `CartLoaded.itemCount` üzerinden çalışıyor.
- Eski `BottomAddToCart`, `product.id` ile eski sepete ekliyor.
- `ProductSellersSection`, `shop_products` listesini read-only gösteriyor.
- `CartV2Repository` / usecase / `CartV2Cubit` altyapısı hazır ama UI'ya bağlı değil.
- V2'ye eklenen ürün şu an eski `CartView` içinde görünmez.

## 3. Temel Risk

- `ProductSellersSection` içine v2 sepete ekle butonu erken eklenirse kullanıcı ürünü sepete eklediğini sanır ama eski `CartView` içinde göremez.
- Badge eski sepeti dinlediği için sayı değişmez.
- Kullanıcı açısından "sepete ekledim ama sepet boş" güven sorunu oluşur.

## 4. V2 CartView'de Gösterilecek Bilgiler

- Esnaf adı
- Esnaf adresi
- Ürün adı
- Mağaza fiyatı
- Adet
- Satır toplamı
- Genel sepet toplamı
- QR doğrulama hazırlık alanı
- "Bu sepet mağazada doğrulama için hazırlanır" benzeri kısa açıklama

## 5. Sepet Toplamı Kuralı

- Eski cart toplamı: `CartLoaded.totalPrice`
- V2 cart toplamı: `CartV2Loaded.totalAmount`
- Eski cart `product.effectivePrice` üzerinden hesaplanır.
- V2 cart `shopProduct.price` üzerinden hesaplanır.
- Kullanıcı ekranında genel toplam mutlaka görünür olmalı.
- Satır toplamı ve genel toplam ayrı gösterilmeli.

## 6. Eski CartView'e Toplam Tutar Ekleme Notu

- Eski `CartView` içine toplam tutar eklemek düşük riskli kısa vadeli UX iyileştirmesidir.
- Ancak v2'ye geçişte bu alan yeniden tasarlanabilir.
- Bu nedenle eski `CartView` toplamı ayrı küçük çalışma olarak yapılabilir.

## 7. V2 Geçiş Stratejisi

### Aşama 1

- `CartV2View` tasarımı ve state ihtiyaçları netleştirilir.

### Aşama 2

- `CartV2View` skeleton hazırlanır ama kullanıcı-facing ana sepet akışına hemen bağlanmaz.

### Aşama 3

- `CartV2View`, `CartV2Cubit.getActiveCartItems` ile read-only veri gösterebilir.

### Aşama 4

- `ProductSellersSection` içine "Bu esnaftan sepete ekle" aksiyonu eklenir.

### Aşama 5

- Conflict durumunda dialog akışı eklenir.

### Aşama 6

- Badge eski `CartCubit`ten `CartV2Cubit`e geçiş için ayrıca planlanır.

### Aşama 7

- Eski `BottomAddToCart` rolü yeniden değerlendirilir:
  - kaldırılabilir,
  - sadece quantity selector'a dönüşebilir,
  - veya v2 geçiş tamamlanana kadar eski akışta kalabilir.

## 8. BottomAddToCart Rol Kararı

- Şimdilik eski Sepete Ekle olarak kalabilir.
- V2 kullanıcıya açıldığında esnaf seçimi olmadan sepete ekleme belirsizleşir.
- Uzun vadede asıl ekleme aksiyonu esnaf kartından gelmelidir.
- `BottomAddToCart` quantity seçiciye dönüşebilir.

## 9. Badge Geçiş Kararı

- Badge şu an eski `CartCubit`i dinliyor.
- V2 kullanıcıya açılmadan badge `CartV2Cubit`e taşınmamalı.
- V2 `CartView` ve v2 add-to-cart kullanıcıya açıldığında badge geçişi ayrıca yapılmalı.

## 10. QR Hazırlığı

- V2 `CartView` ileride QR doğrulama ekranına geçiş noktası olacak.
- QR oluşturulurken `cart_snapshot` ve `total_amount` alınmalı.
- QR butonu hemen eklenmemeli; önce sepet ekranı ve toplam mantığı oturmalı.

## 11. Önerilen Sıradaki Küçük Teknik Adımlar

- Önce eski `CartView` içine genel sepet toplamı eklemek düşük riskli olabilir.
- Ardından `CartV2View` skeleton analizi yapılabilir.
- Daha sonra `CartV2View` read-only skeleton eklenebilir.
- `ProductSellersSection` içine v2 add butonu en son eklenmelidir.

## 12. Riskler

- İki sepet modelinin aynı anda kullanıcıya açık olması.
- Badge'in yanlış modeli göstermesi.
- V2'ye eklenen ürünün eski `CartView` içinde görünmemesi.
- Eski `BottomAddToCart` ile v2 esnaf bazlı ekleme akışının çakışması.
- QR butonunun erken eklenmesi.
- Sepet toplamı gösterilmezse kullanıcı tutar güveni oluşmaz.

## 13. Sonuç

- V2 add-to-cart UI'ya açılmadan önce `CartV2View` stratejisi netleşmelidir.
- Mevcut kullanıcı akışı bozulmamalıdır.
- Sepet toplamı hem eski `CartView` hem v2 `CartView` için temel UX gereksinimidir.
- En güvenli yakın adım: eski `CartView` içine genel sepet toplamı eklemek veya `CartV2View` skeleton analizine geçmektir.
