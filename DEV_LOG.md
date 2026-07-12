# DEV_LOG

## 2026-07-12 - Kasada QR Doğrulama (Yerel Uygulama Hazır)

- Müşterinin mağaza sepetinden oluşturduğu QR için ürün, adet ve fiyatların değişmez kopyasını hazırlayan güvenli migration yazıldı.
- Esnafın yalnız kendi aktif mağazasına ait QR'ı okutması, ürünleri ve toplamı görmesi ve alışverişi tek seferlik doğrulaması uygulamaya eklendi.
- Doğrulama sonrasında müşteri QR ekranında "Alışveriş tamamlandı" sonucu gösteriliyor.
- Süresi dolmuş, iptal edilmiş, kullanılmış veya başka mağazaya ait QR güvenli biçimde reddediliyor.
- Doğrulanmış alışveriş kanıtı, mağaza/sepet kayıtları daha sonra değişse bile korunacak bağımsız bir kayda dönüştürüldü.
- Kamera izni ve QR okuyucu Android, iOS, macOS ve web için projeye bağlandı.
- 23 yeni QR testi ile birlikte toplam 218 birim ve giriş akışı testi geçti.
- Web derlemesi `--no-tree-shake-icons` ile geçti. Normal web paketlemesinde QR değişikliğinden bağımsız eski bir ikon değeri sorunu sürüyor.
- Android APK doğrulaması, bilgisayarda geçerli JDK/Android Studio Java yolu bulunmadığı için tamamlanamadı.
- `supabase_migration_qr_verification.sql` henüz canlı Supabase projesinde çalıştırılmadı.
- Değişiklikler henüz commit veya push edilmedi.

## Son Guncel Hafiza Notu

- Cart item management tamamlandi.
- Sepette tek urun silme calisiyor.
- Sepet quantity + / - calisiyor.
- Quantity 1 iken - urunu silmiyor; silme isi cop kutusunda kaliyor.
- Tek esnaf sepet kurali analiz edildi.
- Mevcut products/cart_items yapisinda shopId/merchantId/storeId olmadigi goruldu.
- brandId'nin esnaf/magaza yerine kullanilmamasi karari netlestirildi.
- Gelecek model icin shops + shop_products + carts + cart_items + qr_sessions mimarisi belgelendi.
- DESIGN_CART_QR_MODEL.md olusturuldu.
- SQL migration'a hemen gecilmemesi kararlastirildi.
- MIGRATION_PLAN_CART_QR.md olusturuldu.
- Ilk gercek migration'in sadece shops + shop_products eklemesi gerektigi, mevcut cart_items sisteminin hemen bozulmamasi gerektigi not edildi.

## Guncel Mimari ve Sepet Ilerlemesi

- Cart item management tamamlandi.
- Sepette tek urun silme butonu eklendi.
- CartItem icindeki cop kutusu butonu CartCubit.removeFromCart(item.id) cagiriyor.
- Son urun silinince CartView "Sepetiniz bos" mesaji gosteriyor.
- Sepet quantity management tamamlandi.
- CartItem icinde inline - / quantity / + kontrolu eklendi.
- + butonu CartCubit.incrementQuantity(item.id) cagiriyor.
- - butonu sadece quantity > 1 ise CartCubit.decrementQuantity(item.id) cagiriyor.
- Quantity 1 iken - urunu silmiyor; silme isi cop kutusu butonunda kaliyor.
- Tek esnaf sepet kurali analiz edildi.
- Mevcut ProductEntity/products/cart_items yapisinda shopId/merchantId/storeId olmadigi goruldu.
- brandId'nin esnaf yerine kullanilmamasi karari netlestirildi.
- Gelecek model icin shops + shop_products + carts + cart_items + qr_sessions mimarisi onerildi.
- DESIGN_CART_QR_MODEL.md dosyasi olusturuldu ve repo icine eklendi.
- QR dogrulama sepetinin klasik checkout/online odeme olmadigi belgeye islendi.

- Proje adı: Esnafta Var
- Kod tabanı: TStore Flutter e-commerce app fork’u
- Backend: Supabase
- Geliştirme yöntemi: Küçük adımlar, ayrı branch, test, commit, push
- Bugüne kadar yapılan teknik ilerlemeler:
  - TStore klonlandı.
  - Flutter pub get çalıştı.
  - Chrome üzerinde uygulama çalıştırıldı.
  - Supabase projesi kuruldu.
  - supabase_schema.sql çalıştırıldı.
  - supabase_sample_data.sql çalıştırıldı.
  - Auth kullanıcı oluşturma trigger problemi düzeltildi.
  - SUPABASE_URL format hatası düzeltildi.
  - profiles tablosu için authenticated select/update izinleri verildi.
  - Login başarılı hale getirildi.
  - Ana sayfaya erişildi.
  - PROJECT_BRIEF.md eklendi.
  - Temel marka/metin dönüşümleri yapıldı.
  - Uygulama açılışı OnBoarding/Login bariyerinden çıkarılıp NavigationMenu/Home başlangıcına alındı.
  - Logout gerçek signOut yapacak ve guest home’a dönecek şekilde düzeltildi.
  - Favoriler/Profil gibi kişisel alanlar için guest guard çalışması başlatıldı.
  - Sepet ikonları için guest guard eklendi.
- Son bilinen sağlam davranış:
  - Uygulama misafir olarak ana sayfadan açılıyor.
  - Ana sayfa ve Esnaf/Store keşfi misafire açık.
  - Sepet ikonuna basan misafir LoginView’e yönleniyor.
  - Logout sonrası kullanıcı LoginView’de kilitlenmeden misafir ana sayfaya dönüyor.
