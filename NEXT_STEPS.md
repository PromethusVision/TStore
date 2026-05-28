# NEXT_STEPS

## Son Guncel Sonraki Teknik Calisma

- Calisma 20: shops + shop_products SQL migration taslagi hazirlama.
- Bu calisma dogrudan SQL calistirmakla baslamayacak.
- Once sadece migration SQL taslagi uretilecek.
- Ilk migration yalnizca shops ve shop_products tablolarini eklemeli.
- Mevcut products, cart_items, add-to-cart ve CartView akisi bozulmamali.
- qr_sessions, carts ve yeni cart_items donusumu sonraki asamalara birakilmali.
- Supabase'e SQL uygulanmadan once kullanicidan acik onay alinmali.
- SQL calistirmadan once GitHub Desktop Changes temiz olmali.
- Her SQL adimindan sonra uygulama smoke test yapilmali.

## Son Guncel Yeni Sohbet Hatirlatmasi

- Yeni pencere acilirsa once PROJECT_BRIEF.md, DEV_LOG.md, NEXT_STEPS.md, KNOWN_ISSUES.md, DESIGN_CART_QR_MODEL.md ve MIGRATION_PLAN_CART_QR.md okunmali.
- Kod veya SQL yazmadan once aktif branch, son commit ve GitHub Desktop Changes durumu sorulmali.
- Her iste once analiz, sonra minimum degisiklik, sonra test, sonra commit, sonra push yapilmali.

## Guncel Sonraki Teknik Calisma

- Calisma 19: SQL migration plani hazirlama.
- Amac: DESIGN_CART_QR_MODEL.md icindeki shops, shop_products, carts, cart_items ve qr_sessions modelini mevcut calisan sistemi bozmadan kucuk migration adimlarina bolmek.
- Ilk adimda dogrudan SQL calistirilmayacak.
- Once migration plani analiz edilecek.
- Mevcut calisan cart_items yapisi hemen bozulmayacak.
- Prototip verisi korunacak.
- shops ve shop_products icin seed/demo data plani cikarilacak.
- cart_items eski modelden yeni carts/cart_items modeline nasil gececek analiz edilecek.
- QR sessions tablosu en son asamada ele alinacak.

## Yeni Sohbet Hatirlatmasi

- Yeni sohbet penceresinde once PROJECT_BRIEF.md, DEV_LOG.md, NEXT_STEPS.md, KNOWN_ISSUES.md ve DESIGN_CART_QR_MODEL.md okunmali.
- Kod yazmadan once aktif branch, GitHub Desktop Changes durumu ve son commit sorulmali.
- Her iste once analiz, sonra minimum degisiklik, sonra test, sonra commit, sonra push yapilmali.

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
