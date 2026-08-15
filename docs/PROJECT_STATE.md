# EsnaftaVar Project State

## Snapshot Bilgisi

- Son güncelleme: 2026-08-15
- Son doğrulanan uygulama commit'i: `781630a46d4dff3059af5902abfbf44c89ae0276`
- Doğrulanan branch/upstream: `integration/wave-6-final-20260815` / `origin/main`
- Entegrasyon durumu: **WAVE 6 COMPLETE**
- Snapshot oluşturulurken çalışma ağacı: entegrasyon commit'i sonrasında temiz (`+0/-0`)
- Doğrulama türü: Wave 6 Agent 1 backend/migration, Agent 2 review client ve Agent 3 Storage client dallarının sıralı entegrasyonu; frozen RPC ve controlled-path sözleşme incelemesi; Development `0009` remote migration kaydı; normal Auth istemcileriyle canlı review lifecycle; residual `0` fixture cleanup; hedefli 189/189, tam 1106/1106 test; analyzer, diff ve güvenlik taraması
- Çalıştırılmayan kontroller: fiziksel iki cihaz QR kabulü; Production smoke; production-like e-posta doğrulama/SMTP kabulü; deferred `brand-logos`, `avatars` ve `review-images` implementasyonu; legacy order final drop

Bu dosya mevcut kod durumunun source-of-truth özetidir. Gelecek ürün fikirleri burada implemented gibi gösterilmez. Kod gerçeği ile ürün backlog'u ayrıdır; tamamlanmamış ürün işleri için `PRODUCT_BACKLOG.md` kullanılır.

## Mimari Özet

- Flutter/Dart istemcisi ve Supabase backend kullanılıyor.
- State yönetimi BLoC/Cubit, bağımlılık yönetimi GetIt ile yapılıyor.
- Feature'lar genel olarak `data/domain/presentation` katmanlarına ve repository/use-case yaklaşımına ayrılmış.
- Hata sonuçlarında çoğunlukla `dartz Either`, state karşılaştırmalarında `Equatable` kullanılıyor.
- Navigation, merkezi bir router paketi yerine `MaterialApp`, global navigator key ve doğrudan `Navigator/MaterialPageRoute` çağrılarıyla yürütülüyor.
- Beş ana müşteri sekmesi: Ana Sayfa, Yakındakiler, Sepet, Favoriler ve Profil.
- Auth, tablo CRUD, Storage ve Realtime için ortak `SupabaseService`; feature repository'lerinde doğrudan Supabase sorguları ve güvenli RPC çağrıları bulunuyor.
- Fresh Supabase bootstrap için resmi kaynak, `supabase/migrations/` altındaki sıralı `0001`–`0009` canonical zinciridir; kökteki eski schema/migration dosyaları yalnız tarihsel referanstır.
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
| Puanlama / yorum | COMPLETE | FINAL Option A backend ve istemcide uygulandı: ürün yorumu yalnız merchant tarafından doğrulanmış server-authoritative QR işlemindeki durable ürün satırıyla açılır. Eligibility/read/create/idempotent duplicate/update/delete/recreate akışı RPC-only çalışır; verified bilgisi server-derived ve evidence immutable'dır. Development normal Auth canlı lifecycle testi geçti; legacy yorumlar korunur ancak verified aggregate'lere katılmaz. QR-doğrulanmış mağaza puanı da korunur. |
| Merchant altyapısı | PARTIAL | Rol kapısı, merchant login, mağaza oluşturma/düzenleme ve QR scanner var; merchant ürün/stok/fiyat/istatistik yönetimi yok. |
| Reklam / sponsored / campaign | SKELETON | Supabase banner gösterimi ve promotion bildirim tipi var; reklam/campaign motoru yok. |
| Kuponlar | SKELETON | Müşteri ekranı statik boş state gösteriyor; repository/Cubit/backend bağlantısı yok. |
| Ödül Çubuğu / gamification | NOT FOUND | Uygulama kodunda reward/task/badge domain'i bulunmuyor. |
| Analytics / event ölçümü | NOT FOUND | Event tracking veya analytics entegrasyonu bulunmuyor. |
| Permissions / privacy | PARTIAL | Legal belgeler/consent, hesap silme, konum izin durumu ve notification permission SQL'i var; merkezi preference/consent modeli yok. |
| Supabase / RLS | COMPLETE | Development projesinde canonical `0001`–`0009` zinciri kayıtlıdır. Önceki postflight 23 public tablo, 23/23 RLS, 55 policy ve canonical grant matrisini doğruladı; `0008` role guard ile Wave 4 Auth/Profile/RLS, Realtime ve QR canlı testleri geçti. `0009`, durable product evidence + review RPC/RLS sözleşmesini ve public-read `product-images`, `category-images`, `banner-images` bucket'larını uygular; client list/write/update/delete policy'si açmaz. Wave 6 review lifecycle normal Auth istemcileriyle canlı doğrulandı. |
| Automotive / Services | NOT FOUND | Yalnız generic `vehicle` ve `motorcycle` kategori metni/asset'i var; özel domain veya servis akışı yok. |
| Legacy order / checkout | SKELETON | Order repository/Cubit, testler ve shipping/payment alanları repoda duruyor; aktif müşteri navigation'ına ve GetIt DI grafiğine bağlı değil, hedef ürün akışı değil. |

## Önemli Teknik Borçlar

- Ürün yorumu için FINAL Option A uygulandı: yalnız merchant tarafından doğrulanmış server-authoritative fiziksel QR alışverişi ve ilgili durable ürün satırı eligibility verir; aktif yol legacy `orders/order_items` verisini kanıt kabul etmez. Korunan legacy yorumlar doğrulanmamış kalır ve verified aggregate'lere katılmaz.
- Sosyal giriş düğmeleri görünür fakat callback'leri boş.
- Kupon ekranı gerçek veriye bağlı değil.
- Merchant ürün/stok/fiyat yönetimi bulunmuyor; mevcut merchant altyapısı yalnız mağaza profili ve QR doğrulama seviyesinde.
- Legacy order/shipping/payment kodu hedef ürün modelinin dışında ve aktif DI grafiğinden çıkarılmış olduğu halde repoda tutuluyor.
- Development/production config sözleşmesi ayrıldı; Agent 1 gerçek client-safe Development değerleriyle web release build/startup/Auth/Profile/customer shell/empty backend UX/config failure sözleşmelerini PASS olarak doğruladı. Production smoke ayrı release gate olarak açık.
- `use_build_context_synchronously` global ignore'u kaldırıldı; Wave 3 birleşik durumda lint repo genelinde etkin ve analyzer temiz.
- Wave 6'da aktif `product-images`, `category-images` ve `banner-images` sözleşmesi kapatıldı: public object read, trusted operations write, exact versioned controlled path, bucket-side MIME/size limiti ve en az yedi günlük orphan retention uygulanır; Flutter istemcisine Storage mutation veya server credential verilmez. `brand-logos`, `avatars` ve `review-images` deferred kalır.
- Feature flag, analytics/event ve crash reporting altyapısı yok.
- Bazı merkezi view dosyaları çok büyük: `all_products_view.dart`, `cart_v2_view.dart`, `nearby_view.dart`, `chat_view.dart` ve `conversations_view.dart`.

## Kritik Integration Eksikleri

- QR müşteri → merchant scanner → onay → müşteri tamamlanma akışı iki gerçek cihazla kabul edilmedi.
- Wave 4 Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime Development integration testleri tamamlandı; fiziksel cihaz ve sonraki implementation gerektiren kapılar aşağıda açık tutuluyor.
- Ürün yorumu Option A server-authoritative doğrulanmış QR alışverişi/durable ürün satırı üzerinden backend ve istemcide uygulandı; frozen RPC sözleşmesiyle canlı Development lifecycle testi geçti.
- Development Supabase schema/RLS/RPC nesne sözleşmesi repo dosyalarından bağımsız remote audit ile doğrulandı; `0008` sonrası tam Wave 4 Auth/Profile/RLS canlı harness'i geçti.
- Gerçek client-safe Development değerleriyle web release build ve istemci smoke PASS; Production smoke yapılmadı.
- Canonical `0001`–`0009` zinciri Development Supabase'e uygulandı; remote migration kaydı `20260815000900 0009_verified_product_reviews_storage` olarak doğrulandı ve entegrasyonda yeniden uygulanmadı.
- Aktif üç Storage bucket ve least-privilege read sözleşmesi `0009` ile uygulandı; client write/update/delete/list kapalıdır. `brand-logos`, `avatars` ve `review-images` bilinçli olarak provision edilmedi.
- Merchant ürün yönetimi müşteri keşif ve ShopProduct modeliyle bütünleşmiş değil.

## Test Durumu

- `test/` altında 116 Dart test dosyası; QR, Realtime, Auth/RLS ve Wave 6 ürün yorumu için Development ref'ine kilitli gated live harness'lar bulunuyor.
- Güçlü alanlar: Shop, Auth, Personalization, Chat ve Cart.
- Açık doğrulama alanları: fiziksel cihaz/kamera kabulü, deferred Storage özellikleri, merchant ekranları, kupon backend'i, Production smoke ve production-like e-posta/SMTP kabulü.
- Auth/RLS, QR ve Realtime için Development ref'ine kilitli, açık opt-in gerektiren live harness'lar bulunuyor; normal `flutter test` remote istek yapmadan bunları skip ediyor.
- Wave 1 birleşik durumda tam Flutter test suite geçti; `flutter analyze --no-pub` sonucu temizdi. Hedefli sonuçlar: chat 97/97, notifications 53/53, cart/QR/purchases 138/138 ve settings/navigation 34/34.
- Wave 2 birleşik durumda tam Flutter test suite ve `flutter analyze --no-pub` geçti. Hedefli sonuçlar: environment/config 11/11, discovery/shop 344/344, legacy mimari + unit 22/22 ve Cart V2/QR 94/94.
- Wave 3 birleşik durumda tam Flutter test suite ve `flutter analyze --no-pub` geçti. Hedefli sonuçlar: canonical migration 13/13, QR release contract 3/3, banner 22/22, async-context 32/32, chat 97/97, notifications 53/53, cart/QR/purchases 157/157 ve discovery/navigation 412/412.
- Wave 3.1 hotfix ve Development bootstrap öncesi/sonrası canonical migration 14/14, QR concurrency contract 3/3 ve `flutter analyze --no-pub` geçti; gerçek PostgreSQL parse/apply 0004–0007 için başarılı oldu.
- Wave 4.1 Development `0008_fix_profile_role_guard` apply/postflight geçti; normal profile update başarılı, merchant/admin escalation `42501` ile reddedildi, final rol `customer` kaldı ve smoke sırasında `42883` görülmedi.
- Wave 4 final birleşik durumda hedefli matris 998/998 (4 gated live skip), tam Flutter suite 1069/1069 (3 gated live skip) ve `flutter analyze --no-pub` geçti; global `use_build_context_synchronously` etkin ve temiz kaldı.
- Wave 5 final birleşik durumda review/QR/shop rating/Storage contract/legacy architecture hedefli matrisi 169/169, tam Flutter suite 1069/1069 (3 güvenlik-gated live skip) ve `flutter analyze --no-pub` geçti; Agent 1 Development istemci smoke sonucu bağımsız olarak PASS.
- Wave 6 final birleşik durumda review RPC/client, cart/QR/purchases, Storage resolver/model ve canonical migration sözleşmesi hedefli matrisi 189/189; tam Flutter suite 1106/1106 (yaklaşık 4 opt-in live skip) ve `flutter analyze --no-pub` geçti. Ayrı Development live review harness'i 3/3 geçti.
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

- Development canonical bootstrap `0001`–`0009` tamamlandı; `20260815000900 0009_verified_product_reviews_storage` remote migration kaydı ve doğru Development project ref'i doğrulandı. Önceki postflight 23 tablo, 23/23 RLS, 55 policy, canonical grant matrisi ve Realtime üyeliğini doğrulamıştı; Production'a dokunulmadı.
- Production-like e-posta doğrulama/SMTP kabulü, Development'taki Confirm Email kapalı live testlerinden ayrı tutulur.
- QR doğrulamasının iki gerçek hesap ve iki fiziksel cihazla kamera dahil uçtan uca davranışı.
- Gerçek client-safe Development Dart-define değerleriyle web release build/startup/Auth/Profile/customer shell/empty backend UX/config failure smoke PASS; Production smoke yalnız güvenli Production değerleri sağlandığında ayrıca yapılır.
- Aktif üç public-read Storage bucket uygulandı; `brand-logos`, `avatars` ve `review-images` ürün özelliği ve sözleşmeleri deferred kalır.
- Wave 6 Development review lifecycle fixture'ları tamamen temizlendi; review, verified transaction/item, listing, shop, product ve Auth test hesaplarında residual değer `0` doğrulandı.

## Son Geliştirme Odağı

- 2026-08-15: **WAVE 6 COMPLETE** — Agent 1 verified review/Storage backend, Agent 2 review client ve Agent 3 Storage client dalları zorunlu sırayla, çatışmasız entegre edildi. RPC sözleşmesi ve exact versioned Storage path'leri hizalandı. Development `0009` kaydı doğrulandı; normal Auth client review lifecycle 3/3 geçti ve yalnız Wave 6 fixture'ları residual `0` ile temizlendi. Hedefli 189/189, tam 1106/1106 test, analyzer, diff ve güvenlik kapıları geçti; Production'a dokunulmadı.
- 2026-08-15: **WAVE 5 COMPLETE** — Agent 1 Development web release build ve istemci smoke sonucunu PASS teslim etti; kod/merge üretmedi. Agent 2 Storage contract auditi ile Agent 3 review eligibility/legacy order auditi sıralı ve çatışmasız entegre edildi. Ürün yorumu için Option A FINAL olarak kanonikleştirildi ancak uygulanmış sayılmadı; Storage owner kararları gerçek `TBD` olarak korundu. Hedefli 169/169, tam 1069/1069 test, analyzer ve güvenlik/diff kapıları geçti.
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
