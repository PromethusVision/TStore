# NEXT_STEPS

## Guncel Sonraki Adimlar

- Bir sonraki oturumda ilk yapilacaklar:
  1. GitHub Desktop current branch kontrol edilecek.
  2. Changes temiz mi kontrol edilecek.
  3. Uygulama calistirilip kisa smoke test yapilacak:
     - Ana sayfa aciliyor mu?
     - Kategoriler gercek kategoriler olarak geliyor mu?
     - Kategoriye basinca ilgili urunler geliyor mu?
     - Urun detayinda gercek gorsel/fiyat/rating gorunuyor mu?
     - Sepet bossa "Sepetiniz bos" yaziyor mu?
  4. Sonraki teknik hedef:
     - Calisma 15.2: BottomAddToCart butonunu gercek sepete baglamak.
     - ProductDetailsView -> BottomAddToCart(product: product)
     - BottomAddToCart StatefulWidget olacak.
     - Quantity + / - local state ile calisacak.
     - Guest kullanici Add To Cart'a basarsa LoginView'e yonlenecek.
     - Login olmus kullanicida CartCubit.addToCart(productId: product.id, quantity: quantity) cagrilacak.
     - Basarili olursa "Sepete eklendi" snackbar gosterilecek.
     - Otomatik CartView acilmayacak.
     - QR / checkout / odeme / kargo akisina dokunulmayacak.

- Yeni sohbet penceresine gecildiginde once PROJECT_BRIEF.md, DEV_LOG.md, NEXT_STEPS.md ve KNOWN_ISSUES.md okunmali.
- Kod degistirmeden once aktif branch ve GitHub Desktop Changes durumu kullanicidan istenmeli.
- Her yeni iste once analiz, sonra minimum degisiklik, sonra test, sonra commit, sonra push yapilmali.

- Bir sonraki oturumda önce kontrol edilecekler:
  1. GitHub Desktop current branch kontrol edilecek.
  2. GitHub Desktop Changes alanı temiz mi kontrol edilecek.
  3. Uygulama Chrome’da çalıştırılacak.
  4. Guest home, logout, cart icon guard kısa test edilecek.
- Sıradaki geliştirme konuları:
  1. NavigationMenu içindeki Favoriler ve Profil guest guard’ın aktif branch’te gerçekten durup durmadığını kontrol et.
  2. Eksikse Favoriler/Profil guest guard’ı tekrar ekle.
  3. Add to Cart butonlarının gerçekten CartCubit’e bağlı olup olmadığını incele.
  4. Ürün detay sayfasındaki Add to Cart davranışını analiz et.
  5. Sepeti Esnafta Var modelindeki QR doğrulama sepetine dönüştürme planı çıkar.
  6. Tek esnaf sepet kuralı için veri/model analizi yap.
- Her yeni iş için kural:
  - Önce analiz.
  - Sonra minimum değişiklik.
  - Sonra test.
  - Sonra commit.
  - Sonra push.
