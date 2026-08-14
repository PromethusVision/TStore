# EsnaftaVar Project State

## Snapshot Bilgisi

- Son güncelleme: 2026-08-15
- Son doğrulanan uygulama commit'i: `ce275b3bc8f1e3dc75620cd64992ad7e31f02c98`
- Doğrulanan branch/upstream: `integration/wave-4-final` / `origin/main`
- Entegrasyon durumu: **WAVE 4 COMPLETE**
- Snapshot oluşturulurken çalışma ağacı: temiz (`+0/-0`)
- Doğrulama türü: Wave 4 Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime live sonuçlarının entegrasyonu; Development MCP read-only kontrolü; 23 public tablo, 8 migration ve 23/23 RLS doğrulaması; hedefli 998/998, tam 1069/1069 test; analyzer ve güvenlik taraması
- Çalıştırılmayan kontroller: Integration ortamında client-safe Development Dart-define değerleri bulunmadığı için üç live harness rerun'u; fiziksel iki cihaz QR kabulü; Storage bucket/policy kabulü; gerçek client-safe Development/Production smoke build'i; production-like e-posta doğrulama/SMTP kabulü

Bu dosya mevcut kod durumunun source-of-truth özetidir. Gelecek ürün fikirleri burada implemented gibi gösterilmez. Kod gerçeği ile ürün backlog'u ayrıdır; tamamlanmamış ürün işleri için `PRODUCT_BACKLOG.md` kullanılır.

## Mimari Özet

- Flutter/Dart istemcisi ve Supabase backend kullanılıyor.
- State yönetimi BLoC/Cubit, bağımlılık yönetimi GetIt ile yapılıyor.
- Feature'lar genel olarak `data/domain/presentation` katmanlarına ve repository/use-case yaklaşımına ayrılmış.
- Hata sonuçlarında çoğunlukla `dartz Either`, state karşılaştırmalarında `Equatable` kullanılıyor.
- Navigation, merkezi bir router paketi yerine `MaterialApp`, global navigator key ve doğrudan `Navigator/MaterialPageRoute` çağrılarıyla yürütülüyor.
- Beş ana müşteri sekmesi: Ana Sayfa, Yakındakiler, Sepet, Favoriler ve Profil.
- Auth, tablo CRUD, Storage ve Realtime için ortak `SupabaseService`; feature repository'lerinde doğrudan Supabase sorguları ve güvenli RPC çağrıları bulunuyor.
- Fresh Supabase bootstrap için resmi kaynak, `supabase/migrations/` altındaki sıralı `0001`–`0008` canonical zinciridir; kökteki eski schema/migration dosyaları yalnız tarihsel referanstır.
- Son aramalar, son görüntülenen ürünler ve bekleyen ürün sohbeti için SharedPreferences; konum için Geolocator kullanılıyor.
- Ortak tasarım altyapısı `TAppTheme`, widget theme dosyaları ve `customer_home_v1_tokens.dart` üzerinden ilerliyor. Eski ve yeni tasarım sabitleri birlikte bulunuyor.
- `main_development.dart` ve `main_production.dart` ayrı Dart-define ad alanlarını seçiyor; eksik, placeholder, güvensiz veya server-only config güvenli biçimde startup'ta reddediliyor ve ortamlar arasında fallback yapılmıyor.
- Feature flag, remote config, analytics/event tracking veya crash reporting altyapısı bulunamadı.

## Modül Durumları

`COMPLETE`, bu snapshot'ta görülen prototip kapsamındaki yapısal kod bütünlüğünü belirtir; canlı kabul veya bu snapshot sırasında testlerin geçtiği anlamına gelmez.

| Modül | Durum | Koddan doğrulanan durum |
|---|---|---|
| Authentication / login / signup | PARTIAL | E-posta/parola, kayıt, doğrulama, parola kurtarma, session listener ve legal consent var. Sosyal giriş düğmeleri backend metotlarına bağlı değil; merchant kayıt akışı açık değil. |
| Ana sayfa | COMPLETE | Supabase ürünleri, kategoriler, banner'lar, yakındaki mağazalar, konum, arama ve temel state'ler bağlı; banner sıralama/tarih/bozuk veri/stale response/fallback ile async session ve duplicate navigation korumaları var. |
| Arama | COMPLETE | Ürün/kategori/mağaza birleşik araması, istek yarışı ve stale history snapshot koruması, cache, kısmi hata ve son aramalar var. |
| Kategoriler | COMPLETE | Repository, Cubit/use-case, kategori/alt kategori ekranları, satıcı fiyatları ve testler var. |
| Yakındakiler / location | COMPLETE | GPS, izin durumları, kayıtlı/manuel konum, mesafe sıralaması, hata/fallback, dispose sonrası async completion ve duplicate dialog/navigation korumaları var. |
| Mağaza profili | PARTIAL | Müşteri mağaza profili ve mesaj başlatma var; merchant ürün/stok yönetimi yok. |
| Ürün listeleme | COMPLETE | Liste, kategori, arama, sıralama, gerçek satıcı fiyatları, fallback ve state'ler var. |
| Ürün detay | COMPLETE | Satıcılar, stok/fiyat, favori, sepet, ürün bağlantılı chat ve yorum ekranı bağlı. |
| Sepet V2 | PARTIAL | Tek-mağaza sepeti, miktar/silme, fiyat-stok kontrolü, işlem kilitleri ve QR üretimi var; fiziksel uçtan uca kabul tamamlanmadı. |
| Favoriler | COMPLETE | Supabase repository, Cubit, guest-login devam akışı, kart entegrasyonu ve testler var. |
| Profil / hesap | COMPLETE | Profil düzenleme, avatar, hesap silme, kayıtlı konumlar, yardım/gizlilik ve testler var. |
| Doğrulanmış alışveriş geçmişi | COMPLETE | `verified_transactions` snapshot verileri, repository, Cubit, detay ekranı ve testler var. |
| Mesajlaşma / chat | COMPLETE | Ürün bağlantılı mesaj, konuşma listesi, pagination, Realtime lifecycle/reconnect/dedup, unread ve delivery/read state'leri var; Development üzerinde chat event delivery, RLS isolation, reconnect, dedup, unsubscribe ve summary RPC canlı doğrulandı. |
| QR / mağaza içi doğrulama | PARTIAL | Müşteri QR, merchant scanner, polling, tek kullanımlı onay, immutable snapshot revalidation, stale/duplicate/timeout korumaları ve güvenli RPC/RLS var; Development canlı testinde create/confirm, negative state'ler ve gerçek concurrent confirm geçti. Fiziksel iki cihaz kabulü bekliyor. |
| Bildirimler | PARTIAL | Supabase içi liste, pagination/refresh yarış koruması, session izolasyonu, Realtime lifecycle/dedup ve güvenli okundu/silme işlemleri var; Development canlı event/recipient isolation/mark-read doğrulandı. Geçici `channelError`/`timedOut` artık stream'i sonlandırmıyor; yalnız terminal `closed` kapatıyor. Push notification yok. |
| Puanlama / yorum | PARTIAL | Ürün yorumları ve QR-doğrulanmış mağaza puanı var. Ürün yorumu yetkisi halen legacy `orders/order_items` modeline bakıyor. |
| Merchant altyapısı | PARTIAL | Rol kapısı, merchant login, mağaza oluşturma/düzenleme ve QR scanner var; merchant ürün/stok/fiyat/istatistik yönetimi yok. |
| Reklam / sponsored / campaign | SKELETON | Supabase banner gösterimi ve promotion bildirim tipi var; reklam/campaign motoru yok. |
| Kuponlar | SKELETON | Müşteri ekranı statik boş state gösteriyor; repository/Cubit/backend bağlantısı yok. |
| Ödül Çubuğu / gamification | NOT FOUND | Uygulama kodunda reward/task/badge domain'i bulunmuyor. |
| Analytics / event ölçümü | NOT FOUND | Event tracking veya analytics entegrasyonu bulunmuyor. |
| Permissions / privacy | PARTIAL | Legal belgeler/consent, hesap silme, konum izin durumu ve notification permission SQL'i var; merkezi preference/consent modeli yok. |
| Supabase / RLS | COMPLETE | Development projesinde 8 dosyalı canonical zincir uygulandı: 23 public tablo, 23/23 RLS, 55 policy, birebir canonical anon/auth grant matrisi ve 19 app fonksiyonu doğrulandı. `0008` profile role guard düzeltmesi uygulandı; tam Wave 4 Auth/Profile/RLS canlı harness'i geçti, merchant/admin escalation `42501` ile reddedildi ve PostgreSQL 42883 görülmedi. Chat/notifications Realtime ile QR/verified purchase canlı doğrulandı. Storage bucket/policy kararları ayrı ürün blocker'ı olarak açık. |
| Automotive / Services | NOT FOUND | Yalnız generic `vehicle` ve `motorcycle` kategori metni/asset'i var; özel domain veya servis akışı yok. |
| Legacy order / checkout | SKELETON | Order repository/Cubit, testler ve shipping/payment alanları repoda duruyor; aktif müşteri navigation'ına ve GetIt DI grafiğine bağlı değil, hedef ürün akışı değil. |

## Önemli Teknik Borçlar

- Ürün yorumu uygunluğu legacy `delivered orders/order_items`, mağaza puanı ise QR-doğrulanmış alışveriş modelini kullanıyor.
- Sosyal giriş düğmeleri görünür fakat callback'leri boş.
- Kupon ekranı gerçek veriye bağlı değil.
- Merchant ürün/stok/fiyat yönetimi bulunmuyor; mevcut merchant altyapısı yalnız mağaza profili ve QR doğrulama seviyesinde.
- Legacy order/shipping/payment kodu hedef ürün modelinin dışında ve aktif DI grafiğinden çıkarılmış olduğu halde repoda tutuluyor.
- Development/production config sözleşmesi ayrıldı; gerçek client-safe ortam değerleriyle iki entrypoint smoke build'i release gate olarak açık.
- `use_build_context_synchronously` global ignore'u kaldırıldı; Wave 3 birleşik durumda lint repo genelinde etkin ve analyzer temiz.
- Storage bucket görünürlüğü, yazan roller, object path sahipliği, MIME/size ve silme kuralları ürün kararı bekliyor.
- Feature flag, analytics/event ve crash reporting altyapısı yok.
- Bazı merkezi view dosyaları çok büyük: `all_products_view.dart`, `cart_v2_view.dart`, `nearby_view.dart`, `chat_view.dart` ve `conversations_view.dart`.

## Kritik Integration Eksikleri

- QR müşteri → merchant scanner → onay → müşteri tamamlanma akışı iki gerçek cihazla kabul edilmedi.
- Wave 4 Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime Development integration testleri tamamlandı; fiziksel cihaz ve ürün-kararı gerektiren kapılar aşağıda açık tutuluyor.
- Ürün yorumu yetkisi yeni doğrulanmış alışveriş modeliyle bütünleştirilmedi.
- Development Supabase schema/RLS/RPC nesne sözleşmesi repo dosyalarından bağımsız remote audit ile doğrulandı; `0008` sonrası tam Wave 4 Auth/Profile/RLS canlı harness'i geçti.
- Gerçek client-safe development ve production değerleriyle ayrı smoke build alınmadı.
- Canonical `0001`–`0008` zinciri Development Supabase'e uygulandı; gerçek PostgreSQL parse/apply, statik remote RLS/RPC/grant audit'i ve tam Wave 4 Auth/Profile/RLS davranış testi geçti.
- Beklenen altı Storage bucket için visibility/write/ownership/MIME/size/delete kararları verilmedi; bucket veya policy oluşturulmadı.
- Merchant ürün yönetimi müşteri keşif ve ShopProduct modeliyle bütünleşmiş değil.

## Test Durumu

- `test/` altında 110 Dart test dosyası ve ayrıca gated QR live harness'i bulunuyor.
- Güçlü alanlar: Shop, Auth, Personalization, Chat ve Cart.
- Açık doğrulama alanları: fiziksel cihaz/kamera kabulü, Storage policy uygulaması, merchant ekranları, kupon backend'i ve review eligibility geçişi.
- Auth/RLS, QR ve Realtime için Development ref'ine kilitli, açık opt-in gerektiren live harness'lar bulunuyor; normal `flutter test` remote istek yapmadan bunları skip ediyor.
- Wave 1 birleşik durumda tam Flutter test suite geçti; `flutter analyze --no-pub` sonucu temizdi. Hedefli sonuçlar: chat 97/97, notifications 53/53, cart/QR/purchases 138/138 ve settings/navigation 34/34.
- Wave 2 birleşik durumda tam Flutter test suite ve `flutter analyze --no-pub` geçti. Hedefli sonuçlar: environment/config 11/11, discovery/shop 344/344, legacy mimari + unit 22/22 ve Cart V2/QR 94/94.
- Wave 3 birleşik durumda tam Flutter test suite ve `flutter analyze --no-pub` geçti. Hedefli sonuçlar: canonical migration 13/13, QR release contract 3/3, banner 22/22, async-context 32/32, chat 97/97, notifications 53/53, cart/QR/purchases 157/157 ve discovery/navigation 412/412.
- Wave 3.1 hotfix ve Development bootstrap öncesi/sonrası canonical migration 14/14, QR concurrency contract 3/3 ve `flutter analyze --no-pub` geçti; gerçek PostgreSQL parse/apply 0004–0007 için başarılı oldu.
- Wave 4.1 Development `0008_fix_profile_role_guard` apply/postflight geçti; normal profile update başarılı, merchant/admin escalation `42501` ile reddedildi, final rol `customer` kaldı ve smoke sırasında `42883` görülmedi.
- Wave 4 final birleşik durumda hedefli matris 998/998 (4 gated live skip), tam Flutter suite 1069/1069 (3 gated live skip) ve `flutter analyze --no-pub` geçti; global `use_build_context_synchronously` etkin ve temiz kaldı.
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

## Canlı Backend ile Kalan Doğrulamalar

- Development canonical bootstrap ve `0008` apply tamamlandı: 23 tablo, 8 migration, 23/23 RLS, 55 policy, canonical grant matrisi, trigger/RPC envanteri ve Realtime publication üyeliği remote olarak doğrulandı; production'a dokunulmadı.
- Production-like e-posta doğrulama/SMTP kabulü, Development'taki Confirm Email kapalı live testlerinden ayrı tutulur.
- QR doğrulamasının iki gerçek hesap ve iki fiziksel cihazla kamera dahil uçtan uca davranışı.
- Gerçek client-safe Development Dart-define değerleriyle uygulama build/smoke doğrulaması; Production smoke yalnız güvenli Production değerleri sağlandığında ayrıca yapılır.
- Altı beklenen Storage bucket ve bunların least-privilege policy sözleşmesi.

## Son Geliştirme Odağı

- 2026-08-15: **WAVE 4 COMPLETE** — Live Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime sonuçları entegre edildi. Development read-only kontrolde 23 tablo, 8 migration ve 23/23 RLS doğrulandı; test verisi temiz. Bildirim stream'i geçici Realtime kanal hatalarında açık kalacak şekilde düzeltildi; birleşik hedefli/tam test ve analyzer kapıları geçti.
- 2026-08-14: Wave 4.1 `0008_fix_profile_role_guard` Development'a uygulandı; normal profil update smoke geçti, merchant/admin escalation reddedildi, PostgreSQL 42883 giderildi ve disposable müşteri güvenli RPC ile temizlendi.
- 2026-08-12: Wave 3.1 PostgreSQL özel identifier hotfix'i `origin/main`e entegre edildi; Development canonical DB bootstrap 23 tablo/7 migration ile tamamlandı, RLS/grant/RPC ve Realtime audit'i geçti, seed ve Storage bucket/policy uygulanmadı.
- 2026-08-12: canonical Supabase migration normalization, 25/23 tablo reconciliation, promotion banner read-path hardening ve kalan 9 async-context ihlalinin temizlenmesi Wave 3 entegrasyonu; analyzer ve tam test suite temiz.
- 2026-08-11: development/production config ayrımı, discovery async lifecycle hardening ve legacy order aktif navigation + DI izolasyonu Wave 2 entegrasyonu; analyzer ve tam test suite temiz.
- 2026-08-11: chat, in-app notifications ve QR/verified purchase release-hardening Wave 1 entegrasyonu; analyzer ve tam test suite temiz.
- 2026-08-10: chat güvenilirliği, delivery/read state'leri, konuşma özetleri ve hata ayrımı.
- 2026-08-09: double-submit, double-navigation ve kritik kullanıcı aksiyonu korumaları.
- 2026-08-08: guest-login sonrası hedef işleme devam etme, auth ve onboarding.
- Önceki yoğun alanlar: müşteri ekranlarının yenilenmesi, arama/satıcı fiyatları, QR güvenliği, alışveriş geçmişi, mağaza puanı, profil ve bildirimler.

## Güncelleme Kuralı

- Bu dosya yalnız kod, test, Git ve doğrulanmış backend gerçeği değiştiğinde güncellenir.
- Üretim agentları geniş kapsamlı yeniden yazma yapmaz; merkezi güncelleme analiz/koordinasyon veya integration/release agentı tarafından yapılır.
- Bir modül ancak UI, state/business logic, backend/repository, hata davranışı ve gerekli test kanıtları birlikte yeterliyse `COMPLETE` işaretlenir.
