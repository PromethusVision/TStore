# DEV_LOG

## Guncel Oturum Ilerlemesi

- Supabase categories/products/brands izinleri ve veri sorunlari cozuldu.
- categories tablosu bos oldugu icin kategori akisi fallback listeye dusuyordu; sample categories eklendi.
- brands tablosu icin anon/authenticated select izni verildi.
- products tablosu bos oldugu icin sample brands/products verileri yuklendi.
- product_count = 29 ve active_product_count = 29 dogrulandi.
- Ana sayfa kategorileri gercek categoryId ile calisir hale geldi.
- SubCategoryView secilen kategoriye gore gercek urunleri gostermeye basladi.
- ProductDetailsView gercek product verisiyle aciliyor.
- Urun detay sayfasindaki dummy ProductAttributes bolumu kaldirildi.
- Urun detay sayfasindaki dummy aciklama / Reviews(199) bolumu kaldirildi.
- ProductImageSlider gercek product.images / thumbnail verisiyle calisir hale geldi.
- RatingAndShare dummy 5.0 / (23) yerine product.rating / product.reviewsCount kullanacak hale getirildi.
- CartView gercek CartCubit state'e baglandi.
- cart_items tablosu icin authenticated role yetkileri ve RLS policy'leri duzeltildi.
- Sepet bosken "Sepetiniz bos" mesaji gosteriliyor.
- Dummy Nike sepet urunleri kaldirildi.
- Dummy "Checkout $175" butonu kaldirildi.
- BottomAddToCart analizi yapildi; henuz gercek CartCubit.addToCart baglantisi yapilmadi.

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
