# EsnaftaVar Project State

## Snapshot Bilgisi

- Son güncelleme: 2026-08-11
- Son doğrulanan uygulama commit'i: `ddbabc0fcd3d8f9ffd5406611e12a85cca297d57`
- Doğrulanan branch/upstream: `main` / `origin/main`
- Snapshot oluşturulurken çalışma ağacı: temiz (`+0/-0`)
- Doğrulama türü: repo, kod, test yapısı, SQL ve Git geçmişi üzerinde salt okunur baseline analizi
- Çalıştırılmayan kontroller: Flutter test suite, analyzer, uygulama, gerçek cihaz ve canlı Supabase doğrulaması

Bu dosya mevcut kod durumunun source-of-truth özetidir. Gelecek ürün fikirleri burada implemented gibi gösterilmez. Kod gerçeği ile ürün backlog'u ayrıdır; tamamlanmamış ürün işleri için `PRODUCT_BACKLOG.md` kullanılır.

## Mimari Özet

- Flutter/Dart istemcisi ve Supabase backend kullanılıyor.
- State yönetimi BLoC/Cubit, bağımlılık yönetimi GetIt ile yapılıyor.
- Feature'lar genel olarak `data/domain/presentation` katmanlarına ve repository/use-case yaklaşımına ayrılmış.
- Hata sonuçlarında çoğunlukla `dartz Either`, state karşılaştırmalarında `Equatable` kullanılıyor.
- Navigation, merkezi bir router paketi yerine `MaterialApp`, global navigator key ve doğrudan `Navigator/MaterialPageRoute` çağrılarıyla yürütülüyor.
- Beş ana müşteri sekmesi: Ana Sayfa, Yakındakiler, Sepet, Favoriler ve Profil.
- Auth, tablo CRUD, Storage ve Realtime için ortak `SupabaseService`; feature repository'lerinde doğrudan Supabase sorguları ve güvenli RPC çağrıları bulunuyor.
- RLS, trigger ve RPC altyapısı kökteki schema ve migration SQL dosyalarında tutuluyor.
- Son aramalar, son görüntülenen ürünler ve bekleyen ürün sohbeti için SharedPreferences; konum için Geolocator kullanılıyor.
- Ortak tasarım altyapısı `TAppTheme`, widget theme dosyaları ve `customer_home_v1_tokens.dart` üzerinden ilerliyor. Eski ve yeni tasarım sabitleri birlikte bulunuyor.
- `main_development.dart` ve `main_production.dart` içerik olarak aynı; gerçek ortam ayrımı yok.
- Feature flag, remote config, analytics/event tracking veya crash reporting altyapısı bulunamadı.

## Modül Durumları

`COMPLETE`, bu snapshot'ta görülen prototip kapsamındaki yapısal kod bütünlüğünü belirtir; canlı kabul veya bu snapshot sırasında testlerin geçtiği anlamına gelmez.

| Modül | Durum | Koddan doğrulanan durum |
|---|---|---|
| Authentication / login / signup | PARTIAL | E-posta/parola, kayıt, doğrulama, parola kurtarma, session listener ve legal consent var. Sosyal giriş düğmeleri backend metotlarına bağlı değil; merchant kayıt akışı açık değil. |
| Ana sayfa | COMPLETE | Supabase ürünleri, kategoriler, banner'lar, yakındaki mağazalar, konum, arama ve temel state'ler bağlı. |
| Arama | COMPLETE | Ürün/kategori/mağaza birleşik araması, istek yarışı koruması, cache, kısmi hata ve son aramalar var. |
| Kategoriler | COMPLETE | Repository, Cubit/use-case, kategori/alt kategori ekranları, satıcı fiyatları ve testler var. |
| Yakındakiler / location | COMPLETE | GPS, izin durumları, kayıtlı/manuel konum, mesafe sıralaması, hata/fallback ve testler var. |
| Mağaza profili | PARTIAL | Müşteri mağaza profili ve mesaj başlatma var; merchant ürün/stok yönetimi yok. |
| Ürün listeleme | COMPLETE | Liste, kategori, arama, sıralama, gerçek satıcı fiyatları, fallback ve state'ler var. |
| Ürün detay | COMPLETE | Satıcılar, stok/fiyat, favori, sepet, ürün bağlantılı chat ve yorum ekranı bağlı. |
| Sepet V2 | PARTIAL | Tek-mağaza sepeti, miktar/silme, fiyat-stok kontrolü, işlem kilitleri ve QR üretimi var; fiziksel uçtan uca kabul tamamlanmadı. |
| Favoriler | COMPLETE | Supabase repository, Cubit, guest-login devam akışı, kart entegrasyonu ve testler var. |
| Profil / hesap | COMPLETE | Profil düzenleme, avatar, hesap silme, kayıtlı konumlar, yardım/gizlilik ve testler var. |
| Doğrulanmış alışveriş geçmişi | COMPLETE | `verified_transactions` snapshot verileri, repository, Cubit, detay ekranı ve testler var. |
| Mesajlaşma / chat | COMPLETE | Ürün bağlantılı mesaj, konuşma listesi, pagination, Realtime, unread, delivery/read state'leri ve testler var. |
| QR / mağaza içi doğrulama | PARTIAL | Müşteri QR, merchant scanner, polling, tek kullanımlı onay, snapshot ve güvenli RPC/RLS var; iki gerçek cihaz kabulü bekliyor. |
| Bildirimler | PARTIAL | Supabase içi liste, pagination, unread, okundu/silme, Realtime ve testler var; push notification yok. |
| Puanlama / yorum | PARTIAL | Ürün yorumları ve QR-doğrulanmış mağaza puanı var. Ürün yorumu yetkisi halen legacy `orders/order_items` modeline bakıyor. |
| Merchant altyapısı | PARTIAL | Rol kapısı, merchant login, mağaza oluşturma/düzenleme ve QR scanner var; merchant ürün/stok/fiyat/istatistik yönetimi yok. |
| Reklam / sponsored / campaign | SKELETON | Supabase banner gösterimi ve promotion bildirim tipi var; reklam/campaign motoru yok. |
| Kuponlar | SKELETON | Müşteri ekranı statik boş state gösteriyor; repository/Cubit/backend bağlantısı yok. |
| Ödül Çubuğu / gamification | NOT FOUND | Uygulama kodunda reward/task/badge domain'i bulunmuyor. |
| Analytics / event ölçümü | NOT FOUND | Event tracking veya analytics entegrasyonu bulunmuyor. |
| Permissions / privacy | PARTIAL | Legal belgeler/consent, hesap silme, konum izin durumu ve notification permission SQL'i var; merkezi preference/consent modeli yok. |
| Supabase / RLS | PARTIAL | Geniş RLS, trigger, permission ve `SECURITY DEFINER` RPC altyapısı var; canlı şema bu snapshot'ta doğrulanmadı ve migration'lar tek sıralı klasörde değil. |
| Automotive / Services | NOT FOUND | Yalnız generic `vehicle` ve `motorcycle` kategori metni/asset'i var; özel domain veya servis akışı yok. |
| Legacy order / checkout | SKELETON | Order repository/Cubit ve shipping/payment alanları repoda duruyor; ana müşteri navigation'ına bağlı değil ve hedef ürün akışı değil. |

## Önemli Teknik Borçlar

- Ürün yorumu uygunluğu legacy `delivered orders/order_items`, mağaza puanı ise QR-doğrulanmış alışveriş modelini kullanıyor.
- Sosyal giriş düğmeleri görünür fakat callback'leri boş.
- Kupon ekranı gerçek veriye bağlı değil.
- Merchant ürün/stok/fiyat yönetimi bulunmuyor; mevcut merchant altyapısı yalnız mağaza profili ve QR doğrulama seviyesinde.
- Legacy order/shipping/payment kodu hedef ürün modelinin dışında kaldığı halde repoda tutuluyor.
- Development ve production entrypoint'leri aynı; ortam davranışı ayrışmıyor.
- `use_build_context_synchronously` lint'i analyzer seviyesinde global olarak ignore ediliyor.
- README, `NEXT_STEPS.md` ve `KNOWN_ISSUES.md` güncel kod durumunun gerisinde.
- Feature flag, analytics/event ve crash reporting altyapısı yok.
- Bazı merkezi view dosyaları çok büyük: `all_products_view.dart`, `cart_v2_view.dart`, `nearby_view.dart`, `chat_view.dart` ve `conversations_view.dart`.

## Kritik Integration Eksikleri

- QR müşteri → merchant scanner → onay → müşteri tamamlanma akışı iki gerçek cihazla kabul edilmedi.
- QR, chat, merchant ve RLS için gerçek Supabase integration testi yok.
- Ürün yorumu yetkisi yeni doğrulanmış alışveriş modeliyle bütünleştirilmedi.
- Canlı Supabase schema/RLS durumu repo dosyalarından bağımsız doğrulanmadı.
- Merchant ürün yönetimi müşteri keşif ve ShopProduct modeliyle bütünleşmiş değil.

## Test Durumu

- 98 test dosyası: 40 unit, 56 widget, 1 integration ve 1 kök smoke/widget testi.
- Baseline taramasında 817 `test/testWidgets` bloğu bulundu.
- Güçlü alanlar: Shop, Auth, Personalization, Chat ve Cart.
- Zayıf alanlar: gerçek backend integration, RLS, merchant ekranları, kupon backend'i ve review repository geçişi.
- Mevcut tek integration dosyası auth akışına odaklanıyor.
- Bu snapshot hazırlanırken test suite ve analyzer çalıştırılmadı; güncel geçiş durumu bilinmiyor.
- Açık `TODO`, `FIXME` veya `UnimplementedError` işareti bulunmadı; boş callback ve statik ekran gibi örtük skeleton'lar mevcut.

## Hot-Spot / Shared Alanlar

- `lib/core/dependency_injection/service_locator.dart`: bütün repository/use-case/Cubit kayıtları.
- `lib/t_store.dart`: bootstrap, global provider'lar, session listener ve navigator key.
- `lib/core/common/widgets/navigation_menu.dart`, navigation Cubit ve bottom navigation: beş sekme, guest guard, cart ve unread badge.
- `lib/features/personalization/presentation/views/settings_view.dart`: chat, purchases, coupons, ratings, notifications, locations, profile ve privacy hub'ı.
- Shop repository/entity/model alanları: discovery, nearby, merchant, cart ve ShopProduct bağımlılıkları.
- `supabase_tables.dart`, `supabase_schema.sql` ve bütün migration SQL'leri.
- `customer_home_v1_tokens.dart`, theme dosyaları, `pubspec.yaml` ve lockfile.
- Büyük Shop/Cart/Chat view dosyaları aynı dosyada paralel çalışma için yüksek conflict riski taşır.

## Canlı Backend ile Doğrulanmamış Alanlar

- Repo içindeki 18 migration'ın canlı ortamda tam ve doğru sırayla uygulanmış güncel durumu.
- Canlı RLS, grant, trigger ve `SECURITY DEFINER` RPC izinlerinin repo ile bire bir eşleşmesi.
- Chat conversation summary RPC'lerinin canlı performans ve fallback davranışı.
- Notification ve saved-location permission migration'larının canlı durumu.
- QR doğrulamasının iki gerçek hesap ve iki fiziksel cihazla kamera dahil uçtan uca davranışı.
- Supabase içindeki veri bütünlüğünün mevcut schema dosyalarıyla tam uyumu.

## Son Geliştirme Odağı

- 2026-08-10: chat güvenilirliği, delivery/read state'leri, konuşma özetleri ve hata ayrımı.
- 2026-08-09: double-submit, double-navigation ve kritik kullanıcı aksiyonu korumaları.
- 2026-08-08: guest-login sonrası hedef işleme devam etme, auth ve onboarding.
- Önceki yoğun alanlar: müşteri ekranlarının yenilenmesi, arama/satıcı fiyatları, QR güvenliği, alışveriş geçmişi, mağaza puanı, profil ve bildirimler.

## Güncelleme Kuralı

- Bu dosya yalnız kod, test, Git ve doğrulanmış backend gerçeği değiştiğinde güncellenir.
- Üretim agentları geniş kapsamlı yeniden yazma yapmaz; merkezi güncelleme analiz/koordinasyon veya integration/release agentı tarafından yapılır.
- Bir modül ancak UI, state/business logic, backend/repository, hata davranışı ve gerekli test kanıtları birlikte yeterliyse `COMPLETE` işaretlenir.
