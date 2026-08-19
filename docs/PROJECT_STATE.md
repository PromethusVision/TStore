# EsnaftaVar Project State

## Snapshot Bilgisi

- Son güncelleme: 2026-08-19
- Son doğrulanan teslim: Wave 11 Phase B2R POCO X7 Pro fiziksel input/location retest
- Doğrulanan branch/base: `agent1/w11-b2-physical-retest` /
  `origin/main@4d3542903ef6e6cb861723100ce69113b19c28cc`
- Entegrasyon durumu: **WAVE 11 PHASE B2 CODE FIX PASS / PHYSICAL INPUT+LOCATION PASS / CONFIRMATION PHYSICAL BLOCKED**
- Snapshot oluşturulurken çalışma ağacı: Agent 1 B2R task worktree. Current main'den
  canonical keystore ile signed Production APK üretildi, mevcut uygulamanın üzerine
  data silmeden kuruldu ve input/location fiziksel retest tamamlandı. Production veya
  Development backend write, Auth signup/e-posta, QR, Storage, config veya migration
  işlemi yapılmadı.
- Doğrulama türü: input/theme/widget, callback/confirmation, PKCE, konum
  servis/izin/settings ve Android platform/signing hedefli matrisi; tam Flutter suite,
  analyzer, diff ve secret/private-key/tracked signing artifact kontrolleri.
- Çalıştırılmayan/BLOCKED kontroller: yeni Production signup/e-posta üretilmediği için
  confirmation success/app opening fiziksel UI kabulü; physical deniedForever/
  Settings-return negatif turu; full mobile recovery PKCE lifecycle; legacy Production
  allowlist removal; deliverability tuning; broader Production smoke; fiziksel iki-cihaz
  QR ve iOS archive/signing (Windows).

`FINAL_APP_IDENTIFIER: com.esnaftavar.app — OWNER FINAL / ANDROID-IOS WIRING COMPLETE`

`PRODUCTION_CLIENT_WIRED: YES`

`FINAL_APP_IDENTITY_WIRED: YES`

`FINAL_AUTH_CALLBACK_IMPLEMENTATION: PASS`

`PHASE_F_CALLBACK_INTEGRATED: YES`

`SMTP_CONFIGURATION_PRESENT: YES`

`PRODUCTION_SITE_URL_FINAL_CALLBACK: PASS`

`PHASE_F3_PREWRITE_GATE: PASS — EXACT AUTH/IDENTITY/SESSION 0/0/0`

`AUTH_USER_BASELINE_EXPLAINED: YES`

`REAL_SMTP_DELIVERY: PASS`

`SERVER_SIDE_EMAIL_CONFIRMATION: PASS`

`FINAL_CALLBACK_EMAIL_CONTRACT: PASS`

`FINAL_CALLBACK_APP_OPENING: BLOCKED`

`PRODUCTION_PASSWORD_RECOVERY: BLOCKED`

`AUTHORIZED_TEST_USER_CLEANUP: PASS`

`PRODUCTION_ZERO_AUTH_BASELINE_RESTORED: YES`

`TEST_FIXTURE_CLEANUP: PASS`

`PRODUCTION_ZERO_TEST_RESIDUAL: YES`

`PRODUCTION_EMAIL_INFRASTRUCTURE: READY`

`F2_PRODUCTION_SMTP_PRECHECK: FAIL — HISTORICAL PRE-LIVE CHECK`

`EMAIL_TEMPLATE_PRECHECK: PASS`

`PHASE_F_LIVE_EMAIL_ACCEPTANCE: PARTIAL — MOBILE APP OPENING/RECOVERY BLOCKED`

`MOBILE_AUTH_CALLBACK_ACCEPTANCE: BLOCKED`

`PASSWORD_RECOVERY_MOBILE_ACCEPTANCE: BLOCKED`

`LEGACY_PRODUCTION_CALLBACK_REMOVAL: OPEN`

`EMAIL_DELIVERABILITY_TUNING: OPEN — CONFIRMATION EMAIL REACHED SPAM`

`LEGACY_PRODUCTION_ALLOWLIST_REMOVAL_REQUIRED: YES`

`ANDROID_SIGNING_READY: YES`

`IOS_SIGNING_READY: NO`

`SIGNED_PRODUCTION_APK: PASS`

`SIGNED_PRODUCTION_AAB: PASS`

`SIGNED_ANDROID_ARTIFACT_EVIDENCE: PASS`

`KEYSTORE_PRIMARY_BACKUP: COMPLETED`

`KEYSTORE_SECOND_OFFLINE_BACKUP: RECOMMENDED / OPEN`

`READY_FOR_PHYSICAL_ANDROID_ACCEPTANCE: YES`

`ANDROID_PHYSICAL_ACCEPTANCE: OPEN`

`WAVE_11_B2_AUTOMATED_REGRESSION: PASS`

`INPUT_VISIBILITY_BUG: FIXED`

`EMAIL_CONFIRMATION_UI_BUG: FIXED`

`LOCATION_PERMISSION_BUG: FIXED`

`INPUT_PHYSICAL_VISIBILITY: PASS`

`LOCATION_PHYSICAL_ACCEPTANCE: PASS`

`CONFIRMATION_UI_PHYSICAL_ACCEPTANCE: BLOCKED — NO AUTH/EMAIL FIXTURE CREATED`

`PHYSICAL_DEVICE_REGRESSION: PASS — B2R INPUT/LOCATION`

`COMMERCIAL_RELEASE_READY: NO`

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
- Wave 9 Production preflight yalnız exact `main_production.dart`, ref-host uyumu,
  client-safe key ve canonical Auth redirect kararlarını kabul eder; sentetik
  compile-contract release config olarak kullanılamaz.
- Wave 10'da canonical Production `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` /
  `https://mefhfvrgkwciubeajjeb.supabase.co` / Frankfurt olarak doğrulandı.
  Production canonical `0001→0009` schema/RLS/RPC/Storage contract'ına bootstrap
  edilmiştir ve business data halen sıfırdır. Development `tnipyxnvhgelwdpykyez`
  ayrı projedir ve Production değildir.
- Wave 10 Phase E1'de gerçek client-safe Production runtime config ile anonymous
  categories/products/shops/banners empty-state bağlantısı ve transient standart Web
  release build PASS; publishable key source, belge veya loga yazılmadı.
- Product owner final Android/iOS application/bundle identifier'ını
  `com.esnaftavar.app` olarak kesinleştirdi. Phase E2'de Android namespace,
  applicationId, MainActivity/Fastlane ve iOS Runner/RunnerTests build
  configuration'ları bu kimliğe bağlandı. Phase F1'de Production istemci/platform
  callback'i `com.esnaftavar.app://login-callback/` değerine taşındı; Development
  mevcut `io.supabase.tstore://login-callback/` sözleşmesini ayrı tutar. Phase F
  intermediate integration bu kaynak cutover'ını Auth/SMTP read-only precheck ile
  birleştirdi. Production Custom SMTP açıktır ve görünür host/port/name wiring'i
  mevcuttur; Site URL exact final mobile callback'tir. F3B gerçek SMTP teslimatı,
  server-side confirmation ve final callback email URL contract'ını doğruladı. F3D
  exact disposable fixture'ı temizledi ve Auth/business/Storage zero baseline'ını
  yeniden kurdu. Wave 11'de repo-dışı upload key ile ilk signed Android Production
  APK/AAB üretildi; exact Production application ID, version, manifest, callback,
  signature, hash ve artifact secret scan PASS. Signed Production mobil uygulamada
  fiziksel install/startup, app opening, full recovery PKCE, Resend link-tracking ve
  kabul sonrasındaki legacy allowlist removal açıktır.
- Feature flag, remote config, analytics/event tracking veya crash reporting altyapısı bulunamadı.

## Modül Durumları

`COMPLETE`, bu snapshot'ta görülen prototip kapsamındaki yapısal kod bütünlüğünü belirtir; canlı kabul veya bu snapshot sırasında testlerin geçtiği anlamına gelmez.

| Modül | Durum | Koddan doğrulanan durum |
|---|---|---|
| Authentication / login / signup | PARTIAL | E-posta/parola, kayıt, doğrulama, parola kurtarma, session listener ve legal consent var. Wave 10 Phase F'te Production final callback'i environment-specific merkezi sözleşmeyle entegre edildi; signup/resend/recovery explicit redirect kullanır ve PKCE yalnız exact scheme/host/path sonrası işlenir. Development callback'i korunur. Wave 11 B2'de confirmation callback sonucu Auth/profile yeniden değerlendirmesi, waiting-state kapatma, authenticated shell veya güvenli login hedefi, tekil başarı mesajı ve duplicate/invalid callback koruması eklendi. Production Custom SMTP mevcut, template precheck PASS; F3B gerçek SMTP teslimatı, server-side confirmation ve final callback email URL contract'ı PASS. F3D authorized fixture cleanup sonrası Auth/profile/consent/business/Storage zero baseline restore PASS. Signed Production mobil app opening, full recovery PKCE ve sender/link-tracking final doğrulaması BLOCKED. Wave 8'de işlevsiz sosyal giriş düğmeleri/ayırıcı aktif UI'dan kaldırıldı; provider abstraction gelecekteki optional özellik için korundu. Merchant kayıt akışı açık değil. |
| Ana sayfa | COMPLETE | Supabase ürünleri, kategoriler, banner'lar, yakındaki mağazalar, konum, arama ve temel state'ler bağlı; banner sıralama/tarih/bozuk veri/stale response/fallback ile async session ve duplicate navigation korumaları var. |
| Arama | COMPLETE | Ürün/kategori/mağaza birleşik araması, istek yarışı ve stale history snapshot koruması, cache, kısmi hata ve son aramalar var. |
| Kategoriler | COMPLETE | Repository, Cubit/use-case, kategori/alt kategori ekranları, satıcı fiyatları ve testler var. |
| Yakındakiler / location | COMPLETE | GPS, cihaz servis kontrolü, runtime izin isteği, kalıcı ret/app settings, location settings, ayar dönüşünde lifecycle refresh, last-known fallback, kayıtlı/manuel konum, mesafe sıralaması, hata/fallback, dispose sonrası async completion ve duplicate dialog/navigation korumaları var. |
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
| Supabase / RLS | COMPLETE | Development ve Production projelerinde canonical `0001`–`0009` zinciri kayıtlıdır. Production D1 metadata postflight 23 public tablo, 23/23 RLS, final 52 policy, canonical grant/RPC/trigger seti ve exact üç active Storage bucket'ı doğruladı; Auth/business data sıfırdır. Development'ta `0008` role guard ile Wave 4 Auth/Profile/RLS, Realtime ve QR; `0009` review lifecycle normal Auth istemcileriyle canlı doğrulandı. |
| Automotive / Services | NOT FOUND | Yalnız generic `vehicle` ve `motorcycle` kategori metni/asset'i var; özel domain veya servis akışı yok. |
| Legacy order / checkout | SKELETON | Order repository/Cubit, testler ve shipping/payment alanları repoda duruyor; aktif müşteri navigation'ına ve GetIt DI grafiğine bağlı değil, hedef ürün akışı değil. |

## Önemli Teknik Borçlar

- Ürün yorumu için FINAL Option A uygulandı: yalnız merchant tarafından doğrulanmış server-authoritative fiziksel QR alışverişi ve ilgili durable ürün satırı eligibility verir; aktif yol legacy `orders/order_items` verisini kanıt kabul etmez. Korunan legacy yorumlar doğrulanmamış kalır ve verified aggregate'lere katılmaz.
- İşlevsiz sosyal giriş düğmeleri aktif Login/Signup UI'dan kaldırıldı; gelecekte OAuth açılması optional ürün/backlog işidir ve mevcut release'i bloke etmez.
- Kupon ekranı gerçek veriye bağlı değil.
- Merchant ürün/stok/fiyat yönetimi bulunmuyor; mevcut merchant altyapısı yalnız mağaza profili ve QR doğrulama seviyesinde.
- Legacy order/shipping/payment kodu hedef ürün modelinin dışında ve aktif DI grafiğinden çıkarılmış olduğu halde repoda tutuluyor.
- Development/production config sözleşmesi ayrıldı; Agent 1 gerçek client-safe Development değerleriyle web release build/startup/Auth/Profile/customer shell/empty backend UX/config failure sözleşmelerini PASS olarak doğruladı. Production smoke ayrı release gate olarak açık.
- Iconsax release build blocker'ı kapandı: `iconsax 0.0.8` kaldırıldı, `iconsax_flutter 1.0.1` repo-local sınırlı compatibility katmanıyla kullanılıyor ve standart Web release build ek icon workaround'u olmadan PASS.
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
- Production kimliği exact ref/name/URL/region ile doğrulandı. D1 öncesi fresh baseline ve zero-state JIT PASS; canonical 0001→0009 apply ve metadata/security postflight tamamlandı.
- Production current schema state: ledger 9/9, 23 public tablo, 23/23 RLS, final 52 policy, 28 app function, 25 trigger ve exact üç active bucket. Phase F3A exact SQL Auth user/identity/session `0/0/0`, profiles/consents `0/0` ve bütün user-linked business relations `0` doğruladı. F3 Dashboard `10 users (estimated)` göstergesi actual relation count değildi; D1 zero baseline geçerlidir. F3B tek disposable customer ile live email/server confirmation acceptance yaptı. F3D'de trusted Auth Admin cleanup sonrası Auth user/identity/session/profile/consent, business residual ve Storage object tekrar exact `0/0/0/0/0/0/0` doğrulandı. Owner'ın empty-first-bootstrap no-backup istisnası kullanıldı ve gelecekteki migration'lara emsal değildir.
- Canonical `0001`–`0009` zinciri Development Supabase'e uygulandı; remote migration kaydı `20260815000900 0009_verified_product_reviews_storage` olarak doğrulandı ve entegrasyonda yeniden uygulanmadı.
- Aktif üç Storage bucket ve least-privilege read sözleşmesi `0009` ile uygulandı; client write/update/delete/list kapalıdır. `brand-logos`, `avatars` ve `review-images` bilinçli olarak provision edilmedi.
- Merchant ürün yönetimi müşteri keşif ve ShopProduct modeliyle bütünleşmiş değil.

## Test Durumu

- `test/` altında 124 Dart test dosyası; QR, Realtime, Auth/RLS ve Wave 6 ürün yorumu için Development ref'ine kilitli gated live harness'lar bulunuyor.
- Güçlü alanlar: Shop, Auth, Personalization, Chat ve Cart.
- Açık doğrulama alanları: fiziksel cihaz/kamera kabulü, deferred Storage özellikleri, merchant ekranları, kupon backend'i, Production smoke, signed Production mobil callback opening ve full recovery PKCE kabulü.
- Auth/RLS, QR ve Realtime için Development ref'ine kilitli, açık opt-in gerektiren live harness'lar bulunuyor; normal `flutter test` remote istek yapmadan bunları skip ediyor.
- Wave 1 birleşik durumda tam Flutter test suite geçti; `flutter analyze --no-pub` sonucu temizdi. Hedefli sonuçlar: chat 97/97, notifications 53/53, cart/QR/purchases 138/138 ve settings/navigation 34/34.
- Wave 2 birleşik durumda tam Flutter test suite ve `flutter analyze --no-pub` geçti. Hedefli sonuçlar: environment/config 11/11, discovery/shop 344/344, legacy mimari + unit 22/22 ve Cart V2/QR 94/94.
- Wave 3 birleşik durumda tam Flutter test suite ve `flutter analyze --no-pub` geçti. Hedefli sonuçlar: canonical migration 13/13, QR release contract 3/3, banner 22/22, async-context 32/32, chat 97/97, notifications 53/53, cart/QR/purchases 157/157 ve discovery/navigation 412/412.
- Wave 3.1 hotfix ve Development bootstrap öncesi/sonrası canonical migration 14/14, QR concurrency contract 3/3 ve `flutter analyze --no-pub` geçti; gerçek PostgreSQL parse/apply 0004–0007 için başarılı oldu.
- Wave 4.1 Development `0008_fix_profile_role_guard` apply/postflight geçti; normal profile update başarılı, merchant/admin escalation `42501` ile reddedildi, final rol `customer` kaldı ve smoke sırasında `42883` görülmedi.
- Wave 4 final birleşik durumda hedefli matris 998/998 (4 gated live skip), tam Flutter suite 1069/1069 (3 gated live skip) ve `flutter analyze --no-pub` geçti; global `use_build_context_synchronously` etkin ve temiz kaldı.
- Wave 5 final birleşik durumda review/QR/shop rating/Storage contract/legacy architecture hedefli matrisi 169/169, tam Flutter suite 1069/1069 (3 güvenlik-gated live skip) ve `flutter analyze --no-pub` geçti; Agent 1 Development istemci smoke sonucu bağımsız olarak PASS.
- Wave 6 final birleşik durumda review RPC/client, cart/QR/purchases, Storage resolver/model ve canonical migration sözleşmesi hedefli matrisi 189/189; tam Flutter suite 1106/1106 (yaklaşık 4 opt-in live skip) ve `flutter analyze --no-pub` geçti. Ayrı Development live review harness'i 3/3 geçti.
- Wave 7 final birleşik durumda Auth/callback/config/platform/non-live integration hedefli matrisi 186/186, environment/platform/migration/Storage/review/Auth release-readiness matrisi 67/67; tam Flutter suite 1113/1113 (4 opt-in Development live skip) ve `flutter analyze --no-pub` geçti. Dönemin sentetik compile contract'ı workaround ile geçmişti; bu eski build engeli Wave 8'de kapatıldı.
- Wave 8 final birleşik durumda Iconsax/Auth/callback/config/platform/migration hedefli matrisi 56/56, cutover doküman/hash kontrolü 20/20, tam Flutter suite 1116/1116 (4 opt-in Development live skip) ve `flutter analyze --no-pub` geçti. Sentetik client-safe değerlerle `main_production.dart` standart Web release build'i ek icon workaround'u olmadan PASS; Production backend'e bağlanılmadı.
- Wave 9 final birleşik durumda migration/config/signing/platform/Auth hedefli matrisi 62/62, canonical LF migration manifesti 9/9 ve tam Flutter suite 1136/1136 (4 opt-in Development live skip) PASS. Standart Web Production ve Android production-release compile-only contract, Android development debug build ve analyzer PASS; Android release packaging eksik signing materyalinde beklenen fail-closed sonucu verdi.
- Wave 10 pre-migration belge entegrasyonunda canonical Git/LF migration manifesti 9/9 ve canonical migration contract testi 18/18 PASS. Agent teslimindeki local safe-equivalent clean-room replay 9/9 PASS olarak korundu; yalnız doküman değiştiği için full Flutter suite ve analyzer yeniden çalıştırılmadı.
- Wave 10 D0 entegrasyonunda linked CLI dry-run yalnız exact canonical `0001→0009` pending sırasını gösterdi; remote before/after state aynı ve write `0`. Integration canonical migration contract testi 18/18, manifest 9/9, docs/diff/security kontrolleri PASS; yalnız doküman değiştiği için full Flutter suite ve analyzer yeniden çalıştırılmadı.
- Wave 10 D1'de Production canonical `0001→0009` official linked CLI ile uygulandı. Final remote metadata postflight ledger 9/9, table/RLS 23/23, policy 52/52, app function 28/28, trigger 25/25, critical RPC 15/15 ve exact Storage/Realtime contract PASS; Auth ve business data `0`. Local canonical/review-Storage contract matrisi 28/28, QR release contract 3/3, PGlite SQL behavioral replay 9/9 ve migration manifesti 9/9 PASS.
- Wave 10 Phase E2'de final mobile identity/signing/Auth callback hedefli matrisi
  35/35, tam Flutter suite 1138/1138 (4 opt-in Development live skip), Android
  development debug build, production release compile-only contract, eksik signing
  materyalinde release fail-closed kontrolü ve analyzer PASS. iOS 3+3 bundle-ID
  configuration/plist/scheme statik doğrulaması PASS; Windows'ta signed archive
  çalıştırılmadı.
- Wave 10 Phase E final birleşik durumda config/Auth/platform/harness hedefli matrisi
  61 PASS (1 Production live güvenli skip), tam Flutter suite 1142 PASS (5 opt-in
  live skip) ve analyzer temizdir. Gerçek Production Web runtime build, Android
  Development debug ve Production release compile-only PASS; Production packaging
  eksik signing materyalinde beklenen fail-closed sonucu verdi ve artifact üretmedi.
- Wave 10 Phase F1 Agent 1 task branch'inde callback/email/platform hedefli matris
  40/40, tam Flutter suite 1154 PASS (5 explicit opt-in live skip), analyzer temiz,
  Android Development debug APK ve Production release compile-only PASS. Production
  ve Development merged manifest callback/package ayrımı exact doğrulandı; iOS
  Windows ortamında statik doğrulandı, signed archive üretilmedi.
- Wave 10 Phase F intermediate integration'da Auth callback/PKCE/signup-resend-
  recovery/platform/preflight hedefli matrisi 118/118, tam Flutter suite 1154 PASS
  (5 explicit opt-in live skip), sentetik Production config contract preflight,
  analyzer, docs/diff ve security/secret scan PASS geçti. Integration remote backend
  erişimi, e-posta gönderimi veya signed artifact üretmedi.
- Wave 10 Phase F3'te exact Production identity, Custom SMTP, Confirm Email, final
  remote Site URL ve final+legacy callback allowlist salt-okunur PASS oldu. Auth Users
  baseline'ı refresh sonrasında beklenen `0` yerine `10 (estimated)` gösterdiği için
  signup öncesi safety gate FAIL oldu; Production write/e-posta/user/fixture `0` kaldı.
  Callback/Auth/preflight/profile hedefli yerel matris 129 PASS, 1 gated Development
  live test skip; docs/diff ve secret scan PASS oldu.
- Wave 10 Phase F3A `2026-08-17 00:59:49 UTC` exact salt-okunur SQL snapshot'ı
  Auth user/identity/session `0/0/0`, profiles/consents `0/0`, user-linked business
  relation'ları `0` ve ledger 9/9 doğruladı. D1 zero-state current state ile
  tutarlıdır; Dashboard estimated user göstergesi actual count değildir. Production
  write/user/email `0`, Development erişimi `0` kaldı.
- Wave 10 Phase F3B/F3D'de tek disposable customer için gerçek SMTP inbox teslimatı,
  gözlenen sender adı/domain, server-side confirmation ve final callback email URL
  contract'ı PASS oldu. Confirmation e-postası Spam klasörüne düştü. Actual mobile app
  opening ve full recovery PKCE lifecycle BLOCKED kaldı. Fresh F3D gate exact tek
  fixture'ı doğruladı; owner-authorized Supabase Dashboard Auth Admin delete sonrasında
  Auth user/identity/session/profile/consent, bütün linked business residual ve Storage
  object count'ları `0/0/0/0/0/0/0` oldu. Başka user veya Production write yoktu;
  Auth config/schema/migration ve Development değiştirilmedi. Account-deletion,
  Auth/profile ve canonical RLS contract hedefli matrisi 90 PASS; Development live RLS
  harness'i opt-in kapalı olduğu için beklenen 1 skip verdi.
- Wave 10 Phase F final integration'da callback/PKCE/signup-recovery/account-deletion/
  profile/canonical RLS hedefli yerel matris 151/151, docs consistency, diff ve
  secret/PII scan PASS. Kod değişmediği için full Flutter suite ve analyzer formalite
  amacıyla yeniden çalıştırılmadı; Development live harness'i çağrılmadı ve remote
  erişim yapılmadı.
- Wave 11 Phase A'da hedefli signing/callback/config/Auth matrisi 67/67, tam Flutter
  suite 1154 PASS (5 opt-in live skip) ve `flutter analyze --no-pub` PASS. Standard
  Production APK/AAB release build'i gerçek client-safe runtime injection ile ek icon
  workaround'u olmadan PASS; package `com.esnaftavar.app`, version `1.0.0+1`, signer
  certificate ve artifact hash'leri doğrulandı. Secret scan server-only/signing secret
  bulmadı. Bağlı Android cihazı olmadığından fiziksel install/startup çalıştırılmadı.
- Wave 11 Phase A final integration'da identity/signing/callback/preflight/Auth
  hedefli matrisi 62/62, tam Flutter suite 1154 PASS (5 opt-in live skip) ve
  `flutter analyze --no-pub` PASS. Diff, conflict marker, private-key/secret ve
  tracked keystore/key.properties/APK/AAB scan'leri temizdir; remote harness
  çağrılmadı.
- Wave 11 Phase B2 task branch'inde açık yüzeylerdeki müşteri input'ları için koyu
  sistem temasından bağımsız yerel değer/cursor/selection teması; confirmation callback
  sonrası Auth/profile refresh, tekil feedback ve güvenli route replacement; Geolocator
  servis/izin/request/denied-forever/settings-resume/last-known akışı doğrulandı.
  Hedefli matris 88/88, kayıtlı konum regresyonu 13/13, tam Flutter suite 1177 PASS
  (5 opt-in live skip), analyzer ve Development debug Android build PASS. Production ve
  Development remote yazması, Auth user/e-posta oluşturma yoktur. Sonraki B2R turunda
  POCO X7 Pro / Android 16 cihaz algılama, signed Production APK rebuild, data koruyan
  normal upgrade ve startup PASS oldu. Home arama input'unda değer/hint/cursor fiziksel
  görünürlüğü; Android runtime location dialog'u, izin sonrası location access ve
  product-owner'ın konum sonucu/hata yok gözlemi PASS. Login/signup oturum korunarak
  açılmadı; parola maskelemesi otomatik testle PASS. Confirmation UI için yeni Auth/
  e-posta fixture üretilmediğinden fiziksel kabul BLOCKED kaldı.
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

- Development canonical bootstrap `0001`–`0009` tamamlandı; `20260815000900 0009_verified_product_reviews_storage` remote migration kaydı ve doğru Development project ref'i doğrulandı. Önceki postflight 23 tablo, 23/23 RLS, 55 policy, canonical grant matrisi ve Realtime üyeliğini doğrulamıştı.
- Production Phase A inventory, D0 linked dry-run, D1 canonical migration apply/metadata postflight, Phase E client wiring ve Phase F final callback integration + Auth/SMTP/template precheck tamamlandı. Exact ref'te ledger 9/9, 23/23 table/RLS ve final policy/RPC/trigger/Storage/Realtime contract doğrulandı. Phase F3B gerçek SMTP teslimatı, server-side confirmation ve final callback email URL contract'ı PASS; F3D cleanup sonrası Auth/business/Storage zero baseline restore PASS. Wave 11 Android upload signing ve ilk signed APK/AAB PASS. Physical Android app opening, full recovery PKCE, resend/link-tracking final verification, legacy allowlist removal, iOS signing ve controlled smoke ayrı gate'lerdir.
- Production-like e-posta doğrulama/SMTP kabulü, Development'taki Confirm Email kapalı live testlerinden ayrı tutulur.
- Development Auth remote config bu entegrasyonda değiştirilmedi: Confirm Email OFF, Custom SMTP OFF, gerçek SMTP credential yok ve Site URL/redirect allowlist production-like değil. Production F3B kanıtı Development'a genellenmez.
- QR doğrulamasının iki gerçek hesap ve iki fiziksel cihazla kamera dahil uçtan uca davranışı.
- Gerçek client-safe Development Dart-define değerleriyle web release build/startup/Auth/Profile/customer shell/empty backend UX/config failure smoke PASS; Production smoke yalnız güvenli Production değerleri sağlandığında ayrıca yapılır.
- Aktif üç public-read Storage bucket uygulandı; `brand-logos`, `avatars` ve `review-images` ürün özelliği ve sözleşmeleri deferred kalır.
- Wave 6 Development review lifecycle fixture'ları tamamen temizlendi; review, verified transaction/item, listing, shop, product ve Auth test hesaplarında residual değer `0` doğrulandı.

## Son Geliştirme Odağı

- 2026-08-19: **WAVE 11 PHASE B2R PHYSICAL INPUT/LOCATION PASS / CONFIRMATION UI PHYSICAL BLOCKED** — POCO X7 Pro / Android 16 hem ADB hem Flutter ile fiziksel cihaz olarak doğrulandı. Current main'den canonical repo-dışı keystore ve client-safe Production runtime config ile signed APK üretildi; signature, `com.esnaftavar.app`, final callback ve artifact secret scan PASS. Geçici signing/runtime dosyaları silindi, kalıcı keystore korundu. Mevcut uygulamaya uninstall/clear-data olmadan upgrade yapıldı; startup/process ve crash kontrolü PASS. Home arama input'unda değer/hint/cursor görünürlük checklist'i product-owner tarafından PASS edildi. Konum dialog'u açıldı, izin verildi; sistem servisi, permission, location access ve crash-free process ADB'de, başarı sonucu/hata yok durumu product-owner tarafından doğrulandı. Hedefli paket 114 PASS, tam suite 1177 PASS (5 opt-in live skip), analyzer PASS. Yeni signup/e-posta/confirmation veya remote backend write yapılmadı; confirmation UI fiziksel kabulü bu nedenle BLOCKED.
- 2026-08-19: **WAVE 11 PHASE B2 INPUT/AUTH CALLBACK/LOCATION AUTOMATED FIX PASS / PHYSICAL REGRESSION BLOCKED** — Açık müşteri form yüzeylerinde değer/hint/error/cursor/selection görünürlüğü merkezi yerel theme ile sabitlendi. Confirmation callback Auth/profile state'ini yeniden değerlendirir, waiting route'u kapatır, session durumuna göre shell/login hedefini seçer ve tek başarı mesajı gösterir; malformed/duplicate ve environment isolation korunur. Konum akışı cihaz servisi → runtime permission request → current/last-known position sırasına, denied-forever settings aksiyonuna ve resume refresh'e bağlandı. Remote backend yazması, signup veya e-posta yoktur. ADB cihazı olmadığından signed Production rebuild/install ve POCO X7 Pro fiziksel doğrulama yapılmadı.
- 2026-08-18: **WAVE 11 PHASE A FINAL INTEGRATION / ANDROID SIGNING READY / FIRST SIGNED APK+AAB PASS / PHYSICAL ACCEPTANCE OPEN** — Agent 1 `b56b9fe` teslimi `18f7e03` ile `--no-ff` ve çatışmasız entegre edildi. Repo-dışı kalıcı RSA-4096 upload key ve `esnaftavar-upload` alias'ıyla `com.esnaftavar.app` / `EsnaftaVar` / `1.0.0+1` signed Production APK ve AAB üretildi. APK signer v2, AAB signature, package/manifest/final callback, artifact hash ve secret scan PASS; legacy callback ve server-only/signing secret yok. Geçici credential/config dosyaları silindi; keystore, `key.properties` ve APK/AAB Git dışında kaldı. Owner birincil keystore yedeği ile parola yöneticisi kaydını tamamladı; ikinci offline yedek öneri/açık olarak korunur. Fiziksel Android install/startup/callback acceptance, Play Console/Play App Signing, iOS signing ve commercial GO açıktır. Integration Production/Development remote erişimi veya write yapmadı.
- 2026-08-18: **WAVE 10 PHASE F FINAL INTEGRATION / EMAIL INFRASTRUCTURE READY / ZERO TEST RESIDUAL** — Agent 1 final F3/F3A/F3B/F3D evidence HEAD'i `--no-ff` ve çatışmasız entegre edildi. Gerçek inbox teslimatı, server-side confirmation, final callback email contract'ı ve customer role/profile davranışı PASS; authorized disposable fixture cleanup sonrası Auth user/identity/session/profile/consent, linked business ve Storage residual exact `0`. Spam teslimatı Auth failure değildir ve deliverability tuning açık follow-up'tır. Actual mobile app opening, full recovery lifecycle, legacy callback removal, signing ve broader Production smoke açık kalır. Integration remote backend işlemi yapmadı.
- 2026-08-18: **WAVE 10 PHASE F3D AUTHORIZED ADMIN CLEANUP PASS / ZERO AUTH BASELINE RESTORED** — Fresh exact gate yalnız masked F3 disposable customer'ı doğruladı: Auth user/identity/profile `1/1/1`, customer `1`, merchant/admin `0`, legal consent `2`, session `2`, linked business ve Storage `0`. Owner'ın exact-account yetkisiyle Supabase Dashboard Auth Admin delete uygulandı. Authoritative post-delete state Auth user/identity/session/profile/consent/business/Storage `0/0/0/0/0/0/0`; başka user/veri yok. F3D'de email/config/schema/migration/Storage/Development write yapılmadı.
- 2026-08-18: **WAVE 10 PHASE F3B REAL SMTP + SERVER CONFIRMATION PASS / MOBILE LIFECYCLE BLOCKED** — Tek disposable normal-client customer için confirmation e-postası gerçek inbox'a ulaştı (Spam); sender adı/domain beklenen contract ile uyumluydu. Link server-side confirmation'ı tamamladı ve final callback URL contract'ını taşıdı. Windows'ta Production mobile scheme handler bulunmadığı için actual app opening; kullanılmayan recovery linki nedeniyle full mobile PKCE recovery BLOCKED kaldı. Bu durum Auth delivery/confirmation failure değildir.
- 2026-08-17: **WAVE 10 PHASE F3A AUTH BASELINE EXPLAINED / LIVE EMAIL CAN RESUME** — Authoritative salt-okunur SQL `auth.users/identities/sessions = 0/0/0`, profiles/consents ve tüm user-linked business relation'ları `0` doğruladı. D1 zero-state current state ile tutarlı; Dashboard `10 users (estimated)` actual relation count değildi. User inventory boştur, cleanup adayı yoktur. Production/Development write, user mutation veya e-posta gönderimi yapılmadı.
- 2026-08-17: **WAVE 10 PHASE F3 PRE-WRITE GATE BLOCKED / NO PRODUCTION WRITE — F3A İLE ÇÖZÜLDÜ** — Exact Production name/ref, Development exclusion, Custom SMTP, Confirm Email, final Site URL ve final+legacy allowlist salt-okunur PASS oldu. Auth Users ekranı refresh sonrasında beklenen `0` yerine `10 users (estimated)` gösterdiği için güvenli stop uygulandı; disposable signup, inbox gönderimi, resend, recovery veya cleanup başlatılmadı. Sonraki F3A exact SQL bu UI sinyalinin gerçek user count olmadığını doğruladı.
- 2026-08-17: **WAVE 10 PHASE F INTERMEDIATE INTEGRATION / CALLBACK INTEGRATED / LIVE EMAIL NOT READY** — Agent 1 final callback cutover ve Agent 2 Production Auth/SMTP read-only precheck branch'leri zorunlu sırayla `--no-ff` entegre edildi; tek doküman çakışması final callback kaynak gerçeği ile SMTP precheck FAIL sonucunu birlikte koruyacak şekilde çözüldü. Production signup/resend/recovery ve PKCE final callback'e bağlı, Development legacy callback'i izoledir. Custom SMTP ve email template precheck kanıtı mevcut; Site URL localhost, HTTPS web recovery, gerçek inbox kabulü, legacy allowlist removal ve signing açık kaldı. Integration sırasında Production/Development remote erişimi veya write yapılmadı.
- 2026-08-17: **WAVE 10 PHASE F1 FINAL AUTH CALLBACK SOURCE CUTOVER PASS / INTEGRATION REQUIRED** — Production callback `com.esnaftavar.app://login-callback/` istemci, Android production flavor, iOS Profile/Release ve release preflight'ta tek merkezi environment sözleşmesine bağlandı. Development mevcut legacy callback'ini ayrı ve fallback'siz korur. Signup, resend, recovery ve mevcut OAuth redirect'leri explicit; broad Supabase URI detector kapalı ve PKCE exact scheme/host/path/code filtresinden sonra exchange edilir. Remote Production/Development Auth yazması yapılmadı. Integration ve signed-artifact kabulü sonrasında legacy Production allowlist kaydı yetkili owner tarafından kaldırılmalıdır.
- 2026-08-16: **WAVE 10 PHASE E CLIENT + FINAL MOBILE IDENTITY WIRED / PHASE F READY / COMMERCIAL RELEASE NOT READY** — Agent 1 gerçek Production runtime config, anonymous read-only empty-state bağlantısı ve transient Web release build kanıtını; Agent 2 final mobil kimlik ve fail-closed signing sözleşmesini teslim etti. İki branch sırasıyla ve çatışmasız entegre edildi. Production/Development write veya migration apply yapılmadı. Final `com.esnaftavar.app` kimliği wired, callback ve signing kapıları açık kaldı.
- 2026-08-16: **WAVE 10 PHASE E2 FINAL MOBILE IDENTITY WIRED / SIGNING OPEN** —
  Owner-final `com.esnaftavar.app`, Android namespace/applicationId/MainActivity ve
  iOS Runner/RunnerTests Debug/Profile/Release configuration'larına bağlandı.
  Android release fail-closed signing ve iOS Apple Distribution/manual signing
  korundu. `io.supabase.tstore://login-callback/` remote allowlist değiştirilmeden
  legacy sözleşme olarak bırakıldı; final scheme + Production Auth allowlist Phase F
  atomik cutover işidir. Gerçek keystore/Apple signing materyali ve signed artifact
  bulunmadığından commercial release hazır değildir.
- 2026-08-16: **WAVE 10 D1 PRODUCTION CANONICAL MIGRATION PASS / SCHEMA READY** — Product owner'ın yalnız boş ilk bootstrap için verdiği no-backup istisnası kullanıldı. Exact Production identity, JIT zero-state, manifest 9/9 ve final linked dry-run PASS sonrasında official CLI canonical 0001→0009'u sırasıyla uyguladı. Ledger 9/9; table/RLS 23/23; policy 52/52; app function 28/28; trigger 25/25; critical RPC 15/15; Storage/Realtime/grant/search-path ve zero-data postflight PASS. Manual SQL, fixture, Auth config veya Development write yapılmadı. Final app identifier `com.esnaftavar.app` owner tarafından kesinleştirildi; platform wiring bu görevde yapılmadı. Phase E Production client wiring başlayabilir; Site URL/SMTP, signing, controlled smoke ve fiziksel QR açık olduğundan commercial release hazır değildir.
- 2026-08-16: **WAVE 10 D0 INTEGRATION COMPLETE / FIRST EMPTY BOOTSTRAP APPLY READY, NOT APPLIED** — Agent 1 linked Production CLI dry-run commit'i `--no-ff` ve çatışmasız entegre edildi. CLI exact `mefhfvrgkwciubeajjeb` ref'inde yalnız canonical `0001→0009` pending sırasını gösterdi; before/after Production state değişmedi, remote write `0`. Product owner yalnız tamamen boş ilk bootstrap için native backup/PITR olmadan ilerleme riskini ve güvenli forward-fix yoksa empty-project recreation yolunu kabul etti. Bu istisna gerçek veri geldikten sonraki migration'lara emsal değildir. Apply ayrı görev/change window'u ve just-in-time zero-state recheck ister; bu entegrasyonda migration uygulanmadı.
- 2026-08-16: **WAVE 10 PRE-MIGRATION INTEGRATION COMPLETE / MIGRATION APPLY NOT READY** — Agent 1'in Phase A ve Phase B/C belge commit'leri final branch HEAD üzerinden `--no-ff` ve çatışmasız entegre edildi. Canonical Production kimliği ve fresh/empty baseline doğrulandı; migration ledger, public uygulama tablosu, Auth user, Storage bucket/object ve Realtime uygulama üyeliği sıfırdır. Migration manifesti 9/9, clean-room replay 9/9 ve integration canonical contract testi 18/18 PASS. Free plan backup/PITR/restorable point sağlamadığından accepted RPO/RTO, restore/incident owner/drill ve enforced change window açık; linked CLI dry-run PENDING, Production migration apply/postflight yapılmadı. SMTP/e-posta, fiziksel iki-cihaz QR, final app identifiers/signing ve Production smoke da açık kaldı.
- 2026-08-16: **WAVE 9 INTEGRATION COMPLETE / COMMERCIAL RELEASE NOT READY** — Üç agent dalı zorunlu sırayla ve çatışmasız entegre edildi. Production kimliği doğrulanamadığı için Development kesin dışlandı ve belirsiz proje envanterlenmedi. Migration hash farkı Windows CRLF checkout kök nedenine indirildi; Development apply sonrası tracked SQL mutation olmadığı kanıtlandı ve canonical Git/LF manifesti 9/9 PASS oldu. Mobile signing debug fallback'siz fail-closed, Production config/Auth redirect preflight fail-closed durumdadır. Final identifier/signing, exact Production identity/config/inventory/apply/postflight/smoke, SMTP/email ve fiziksel QR açık gate'tir; remote backend yazması yapılmadı.
- 2026-08-16: **WAVE 8 INTEGRATION COMPLETE / COMMERCIAL RELEASE NOT READY** — Agent 1 release/icons fix, Agent 2 sosyal login UI cleanup ve Agent 3 Production Supabase cutover belgeleri zorunlu sırayla, çatışmasız entegre edildi. `iconsax_flutter 1.0.1` + sınırlı repo compatibility katmanı ile standart Web release build ek workaround olmadan PASS; işlevsiz sosyal UI blocker'ı kapandı, e-posta/parola/PKCE/recovery korundu. Cutover planı ile GO/NO-GO checklist'i hazırlandı ve hatalı `0001` manifest hash'i canonical dosyayla hizalandı. Hedefli 56/56, cutover 20/20 ve tam 1116/1116 test (4 gated live skip) geçti; Production/Development remote yazması yapılmadı.
- 2026-08-16: **WAVE 7 INTEGRATION COMPLETE / COMMERCIAL RELEASE NOT READY** — Agent 2 Auth callback/PKCE/enumeration hardening branch'i ve Agent 3 Production readiness audit branch'i sıralı entegre edildi; Agent 1 diff üretmediği için merge edilmedi ve fiziksel iki-cihaz gate'i BLOCKED kaldı. Android manifest conflict'i tüm gerekli izinleri ve tek callback kaydını koruyarak çözüldü; iOS duplicate callback kaydı tekilleştirildi. Auth hedefli 186/186, release-readiness 67/67, tam 1113/1113 test, analyzer, diff/security ve sentetik `--no-tree-shake-icons` compile contract'ı geçti. Production/Development remote config yazması yapılmadı.
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
