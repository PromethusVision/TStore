# EsnaftaVar Product Backlog

## Kaynak ve Kullanım Kuralı

Bu dosya henüz tamamlanmamış ürün ve release işlerinin source-of-truth listesidir.

- `PROJECT_STATE.md` mevcut kod gerçeğini, bu dosya ise tamamlanmamış işleri ve ürün kararlarını taşır.
- Koddan doğrulanmayan bir özellik implemented olarak işaretlenmez.
- Ürün sahibinin kesinleştirmediği business rule uydurulmaz; açık noktalar `TBD` olarak tutulur.
- Eski README ve `NEXT_STEPS` belgeleri tek başına gerçek kaynak kabul edilmez; güncel kod ve bu koordinasyon belgeleri esas alınır.
- Mevcut ürün önceliği müşteri uygulamasıdır.
- Merchant tarafındaki mevcut altyapı korunur; merchant ürün/stok yönetimini genişletmek şu aşamada ana geliştirme önceliği değildir.
- Online ödeme, kargo, klasik checkout ve klasik sipariş akışı hedef EsnaftaVar ürün modeli değildir.
- UI Kit ve kapsamlı görsel yeniden tasarım, temel iş motorları olgunlaştıktan sonra ele alınacaktır.
- Automotive/Services ilk paralel geliştirme dalgasının kapsamında değildir.

## A. CONFIRMED PRODUCT WORK

### A1. Mevcut Müşteri Uygulamasının Ticari Hazırlığı

- Durum: Açık
- Öncelik: Mevcut ana ürün önceliği
- Hedef: Çalışan müşteri discovery, sepet, QR, alışveriş geçmişi, chat, profil ve destek akışlarını ticari kullanıma güvenilir hâle getirmek.
- Kapsam ilkeleri:
  - Loading, empty, error ve success davranışlarını korumak.
  - Duplicate-submit/double-navigation korumalarını sürdürmek.
  - Canlı backend/RLS bütünlüğünü ve kritik entegrasyonları doğrulamak.
  - Klasik online ödeme, kargo veya checkout akışı eklememek.
- 2026-08-11 Wave 1 teknik ilerleme: chat Realtime/reconnect/dedup ve async lifecycle hardening, in-app notification Realtime/pagination/session/mutation hardening ve QR/verified purchase client + RPC contract hardening tamamlandı; birleşik analyzer ve tam test suite geçti.
- 2026-08-11 Wave 2 teknik ilerleme: development/production config sözleşmesi ayrıldı, discovery ekranlarındaki 5 lifecycle/race problemi giderildi ve legacy order aktif müşteri navigation'ı ile DI grafiğinden izole edildi; birleşik analyzer ve tam test suite geçti.
- 2026-08-12 Wave 3 teknik ilerleme: 7 dosyalı canonical Supabase migration zinciri ve 23 tabloluk fresh bootstrap sözleşmesi hazırlandı, banner okuma yolu sertleştirildi, kalan 9 async-context ihlali temizlendi ve global lint etkinleştirildi; birleşik analyzer ve tam test suite geçti. Remote Supabase'e migration uygulanmadı.
- 2026-08-15 Wave 4 teknik ilerleme: Development üzerinde Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime live doğrulamaları geçti; `0008` profile role guard 42883 regresyonunu giderdi; bildirim stream'i geçici kanal hatalarında açık kalacak şekilde düzeltildi. Final entegrasyon hedefli/tam test ve analyzer kapılarını geçti.
- 2026-08-15 Wave 5 teknik ilerleme: gerçek client-safe Development değerleriyle web release build/startup/Auth/Profile/customer shell/empty backend UX/config failure smoke PASS; Storage contract ve review eligibility/legacy order auditleri entegre edildi. Review için Option A FINAL kaydedildi; uygulama yapılmadı. Hedefli 169/169, tam 1069/1069 test ve analyzer geçti.
- 2026-08-15 Wave 6 teknik ilerleme: FINAL Option A canonical `0009` backend ve RPC-only istemciyle uygulandı; aktif üç public-read Storage bucket ve exact versioned controlled-path istemci çözümlemesi tamamlandı. Development live review lifecycle 3/3, fixture cleanup residual `0`, hedefli 189/189, tam 1106/1106 test ve analyzer PASS oldu.
- 2026-08-16 Wave 7 teknik ilerleme: Android/iOS Auth callback kaydı, PKCE recovery fix, enumeration-safe signup ve Android release internet izni entegre edildi; Production readiness audit ve smoke checklist eklendi. Auth hedefli 186/186, release-readiness 67/67, tam 1113/1113 test, analyzer ve sentetik `--no-tree-shake-icons` compile contract PASS; fiziksel QR, SMTP/e-posta ve Production release gate'leri BLOCKED/açık kaldı.
- 2026-08-16 Wave 8 teknik ilerleme: `iconsax_flutter 1.0.1` ve sınırlı repo-local compatibility katmanı ile standart Web release build ek workaround olmadan PASS; işlevsiz sosyal login UI release blocker'ı kapandı. Production Supabase cutover planı ile GO/NO-GO checklist'i hazırlandı. Hedefli 56/56, cutover belge/hash 20/20 ve tam 1116/1116 test (4 gated live skip) geçti; Production/Development remote yazması yapılmadı.
- 2026-08-16 Wave 9 teknik ilerleme: Production read-only discovery protokolü, mobile signing fail-safe/secret hygiene ve Production config/Auth redirect preflight entegre edildi. Migration manifesti CRLF kaynaklı platform bağımlılığından canonical Git/LF sözleşmesine geçirildi ve 9/9 PASS; Development apply sonrası tracked SQL mutation yok. Exact Production identity, final mobile identifier/signing ve bütün gerçek Production/SMTP/QR kabul kapıları açık kaldı.
- 2026-08-16 Wave 10 pre-migration ilerlemesi: Canonical Production kimliği ve fresh/empty baseline doğrulandı; migration ledger, public application table, Auth user, Storage bucket/object ve Realtime application membership sayıları sıfır. Canonical hash ve local clean-room replay 9/9 PASS; pre-migration baseline/current-state belgeleri entegre edildi. Free plan backup/PITR/restorable point sağlamadığından rollback/RPO/RTO, linked CLI dry-run, migration apply/postflight, SMTP/e-posta, fiziksel QR, final identifier/signing ve Production smoke açık kaldı.
- 2026-08-16 Wave 10 D0 ilerlemesi: Exact Production ref'inde linked CLI dry-run yalnız canonical `0001→0009` pending sırasını gösterdi; remote state değişmedi ve write `0`. Owner, yalnız boş ilk bootstrap için no-backup riskini ve gerektiğinde empty-project recreation yolunu kabul etti. Apply ayrı görev/zero-state recheck ile hazırdır; migration uygulanmadı ve bu istisna gerçek veri sonrası değişikliklere taşınmaz.
- 2026-08-16 Wave 10 D1 ilerlemesi: Owner'ın boş ilk bootstrap istisnası altında canonical Production migration `0001→0009` uygulandı. Ledger 9/9; 23/23 tablo/RLS, 52/52 policy, 28/28 app function, 25/25 trigger, 15/15 kritik RPC ve exact Storage/Realtime metadata postflight PASS; Auth/business data `0`. Final app identifier `com.esnaftavar.app` owner tarafından kesinleştirildi, ancak platform wiring Phase E'ye bırakıldı.
- 2026-08-16 Wave 10 Phase E ilerlemesi: Gerçek client-safe Production config ile
  anonymous read-only empty-state bağlantısı ve transient standart Web release build
  PASS. Final Android/iOS kimliği `com.esnaftavar.app` olarak wired; Development
  `com.esnaftavar.app.dev`. Callback bilinçli olarak korunup Phase F atomik cutover'a,
  mobil signing ve signed artifact'lar release sahibine açık bırakıldı. Remote write,
  migration apply, Auth/Storage config veya fixture işlemi yapılmadı.
- 2026-08-18 Wave 10 Phase F final ilerlemesi: Final callback code/remote Site URL
  wiring, Custom SMTP/Resend, gerçek inbox delivery, server-side confirmation ve
  customer role/profile acceptance PASS. Dashboard `10 users (estimated)` göstergesi
  authoritative SQL `auth.users = 0` ile açıklandı. Tek owner-authorized disposable
  fixture cleanup sonrası Auth/profile/consent, linked business ve Storage residual
  exact `0`; Production zero-auth baseline restore PASS. Actual mobile callback app
  opening, full recovery lifecycle, legacy callback removal, deliverability tuning,
  signing, fiziksel QR ve broader Production smoke açık kaldı.

### A2. QR Fiziksel Doğrulama Kabulünün Tamamlanması

- Durum: Kod hardening, Development PostgreSQL uygulaması ve gerçek backend concurrent confirm doğrulaması tamamlandı; iki kamera-capable cihaz bulunmadığı için `PHYSICAL_TWO_DEVICE_ACCEPTANCE: BLOCKED`.
- Hedef: Müşteri QR oluşturma → merchant QR okutma → merchant onayı → müşteride tamamlanma akışını gerçek hesaplar ve iki fiziksel cihazla doğrulamak.
- Kabul kapsamında kamera izni, yanlış mağaza, süresi dolmuş/iptal edilmiş/kullanılmış QR ve bağlantı gecikmesi davranışları bulunur.

### A3. Reklam Motoru

- Durum: Planlanan gerçek ürün modülü; implementation bulunmuyor
- Bilinen: Mevcut banner gösterimi tam reklam motoru değildir.
- Business rules: **TBD**
- Açık konular: campaign modeli, sponsorlu yerleşimler, hedefleme, bütçe/faturalama, ölçüm, merchant erişimi ve müşteri şeffaflığı.
- Bu ayrıntılar ürün kararı verilmeden uygulanmış varsayılmaz.

### A4. Ödül Çubuğu / Gamification

- Durum: Planlanan gerçek ürün modülü; implementation bulunmuyor
- Bilinen ana model:
  - Kullanıcıya 5 işletmeden alışveriş görevi verilir.
  - İlerleme yalnız doğrulanmış fiziksel alışverişlerle gerçekleşir.
  - Görev zinciri tamamlandığında ödül/alışveriş kuponu kazanılır.
- Ayrıntılı business rules: **TBD**
- TBD alanları: işletme seçimi, tekrar eden işletme kuralı, süre, ilerleme sıfırlama, ödül değeri, kupon geçerliliği, kötüye kullanım önleme ve kampanya finansmanı.
- TBD alanları ürün sahibi tarafından kesinleştirilmeden uygulama davranışı uydurulmaz.

### A5. Ürün Yorumu Uygunluğu — FINAL Option A

- Durum: Ürün kararı **FINAL**; backend/client implementasyonu ve Development canlı doğrulaması tamamlandı.
- Yalnız merchant tarafından doğrulanmış, server-authoritative fiziksel QR alışverişi ve o işlemdeki ilgili ürün satırı review/rating eligibility verir.
- Ürün görüntüleme, sepete ekleme ve yalnız QR oluşturma eligibility vermez.
- Canonical `0009`, verified transaction item üzerinde durable `product_id` ile immutable purchase snapshot/evidence sözleşmesini kurar. Eligibility legacy `orders/order_items` verisini veya client-provided verified flag'i kabul etmez.
- Müşteri/canonical ürün başına bir aktif yorum vardır; duplicate/concurrent submit mevcut satırı değiştirmeden `created: false` döndürür. Owner rating/title/comment alanlarını güncelleyebilir, yorumu silebilir ve durable evidence kaldığı sürece yeniden oluşturabilir; expiry yoktur.
- Korunan legacy yorumlar otomatik backfill edilmez, doğrulanmamış kalır ve verified aggregate'lere katılmaz. UI'daki verified bilgi yalnız server response'undan gelir. Mağaza puanı mevcut doğrulanmış QR akışında server-authoritative çalışmayı sürdürür.

## B. PRODUCT DECISION NEEDED

### B1. Sosyal Login — OPTIONAL / NON-BLOCKING

- Soru: Sosyal login ilk ticari lansmanda gerekli mi?
- Karar verilirse ayrıca hangi sağlayıcıların destekleneceği belirlenmeli.
- Mevcut gerçeklik: Supabase servis/repository abstraction'ı korunuyor; Google/Facebook düğmeleri ve ayırıcı aktif Login/Signup UI'dan kaldırıldı.
- Release durumu: İşlevsiz sosyal UI blocker'ı **CLOSED**. OAuth sağlayıcılarının gelecekte açılması ayrı optional ürün işidir; ilk release'i tek başına bloke etmez.

### B2. Push Notification

- Soru: Push notification ilk ticari lansmanda gerekli mi?
- Mevcut gerçeklik: Supabase tabanlı in-app bildirim sistemi var; FCM/push delivery yok.

### B3. Kupon ve Ödül Business Rules

- Kuponun kim tarafından üretileceği ve finanse edileceği: **TBD**
- Hak kazanma, kullanım, süre, minimum koşul ve kötüye kullanım kuralları: **TBD**
- Ödül Çubuğu tamamlanma ödülünün kupon sistemiyle ilişkisi: **TBD**
- Mevcut müşteri kupon ekranı gerçek backend verisine bağlı değil.

### B4. Reklam Motoru Business Rules

- Sponsorlu içerik türleri ve gösterim alanları: **TBD**
- Merchant campaign oluşturma ve onay süreci: **TBD**
- Fiyatlandırma/faturalama modeli: **TBD**
- Hedefleme, sıralama, raporlama ve müşteri şeffaflığı: **TBD**

## C. TECHNICAL / RELEASE WORK

### C1. Gerçek İki Cihaz QR Kabul Testi

- Öncelik: Kritik release doğrulaması
- Durum: **BLOCKED** — entegrasyon ortamında iki fiziksel kamera-capable cihaz yoktur; otomatik QR/backend testleri bu kabulün yerine geçmez.
- Müşteri ve merchant için iki ayrı gerçek hesap kullanılmalı.
- Kamera, izin, QR üretme, okutma, onay, polling ve tamamlanma birlikte doğrulanmalı.
- Canlı veri silinmemeli; güvenli ve geri alınabilir test verisi kullanılmalı.

### C2. Backend Integration Test Eksikleri

- Wave 4 tamamlanan Development doğrulamaları: Auth signup/session, otomatik profil/legal consent, own/cross-user/anon RLS, saved locations/addresses/wishlist, merchant/admin escalation reddi; QR create/confirm/negative state'ler/immutable snapshot/gerçek concurrency; Chat ve Notifications Realtime delivery/isolation/reconnect/dedup/lifecycle.
- Fiziksel kamera ve iki cihaz QR kabulü C1 altında açık kalır.
- Ürün yorumu Option A backend/client implementasyonu ve normal Auth Development live lifecycle doğrulaması tamamlandı; unverified submit `42501 [REVIEW_NOT_VERIFIED]` ile reddedildi ve create/duplicate/update/delete/recreate aggregate yenilemesi geçti.
- Production Phase F gerçek SMTP delivery, server-side signup confirmation ve final
  callback email contract'ı PASS'tir. Confirm Email'in kapalı olduğu Development live
  testleri bu kanıtın yerine geçmez ve Phase F Production sonucu Development'a
  genellenmez.
- PKCE recovery callback, Android/iOS callback registration, enumeration-safe signup
  ve Android internet izni kodda tamamdır. Actual Production mobile app opening ve
  full recovery link/PKCE/password-change lifecycle `BLOCKED`; resend duplicate/expiry
  ve spam/deliverability tuning broader acceptance kapsamında açıktır.

### C3. RLS ve Canlı Schema Doğrulaması

- Fresh bootstrap için resmi kaynak `supabase/migrations/` altındaki `0001`–`0009` canonical zinciridir; kökteki eski schema ve migration dosyaları tarihsel referans olarak kalır.
- Eski audit modelindeki 25 tablo ile canonical 23 tablo farkı kapatıldı: aktif repository kullanımı olmayan legacy `cart_items` ve backend'e bağlanmamış `coupons` canonical zincire alınmadı. `orders/order_items`, kalan hesap silme/referans ve tarihsel veri bağımlılıkları çözülene kadar korunur.
- Canonical `0001`–`0009` zinciri doğrulanmış Development Supabase'e uygulandı; `20260815000900 0009_verified_product_reviews_storage` exact remote migration kaydı doğrulandı. Önceki postflight 23 public tablo, 23/23 RLS, 55 policy ve grant/trigger/RPC envanterini audit etmişti.
- Canonical QR RPC'leri gerçek Development PostgreSQL üzerinde state geçişi ve concurrent confirm ile doğrulandı; Production'a migration uygulanmadı ve Wave 4 final entegrasyonu remote yazma yapmadı.
- `0009`, aktif `product-images`, `category-images` ve `banner-images` bucket'larını public object read, trusted-operations-only write, exact versioned controlled path, MIME/size allowlist ve en az yedi günlük orphan retention sözleşmesiyle provision eder. Client list/write/update/delete policy'si yoktur; Flutter yalnız controlled path/legacy HTTPS okur.
- `brand-logos`, `avatars` ve `review-images` deferred ve provision edilmemiştir; ancak ilgili ürün özelliği aktive edilip owner sözleşmesi kesinleştiğinde ayrı least-privilege iş olarak ele alınır.
- Production üzerinde destructive işlem kullanıcı onayı olmadan yapılmaz.

### C4. Legacy Order / Shipping / Payment Teknik Borcu

- Legacy order repository/Cubit ve shipping/payment alanları aktif müşteri navigation'ından ve GetIt DI grafiğinden izole edildi.
- Legacy dosyalar, tablolar, veriler ve testler kaldırılmadı; tam kaldırma tamamlanmış sayılmaz.
- Option A'nın aktif ürün yorumu yolu artık legacy `orders/order_items` bağı taşımaz; kanıt yalnız verified transaction item durable `product_id` alanından gelir. Korunan legacy yorumlar otomatik yükseltilmez.
- `orders/order_items` hâlen hesap silme, migration sözleşmeleri ve tarihsel veri alanlarında referanslıdır. Gelecekte kaldırma veya arşivleme ancak bu kalan bağımlılıklar ve güvenli migration planı çözüldükten sonra ayrı ve açık yetkili görev olarak ele alınır.

### C5. Environment Ayrımı

- Development/production Dart-define ad alanları ayrıldı; sessiz fallback kaldırıldı ve eksik/placeholder/güvensiz/server-only config startup'ta güvenli biçimde reddediliyor.
- `.env` Flutter asset paketinden çıkarıldı; aktif uygulama source taramasında hardcoded Supabase URL/JWT ve çalışma alanında geçici `.env` placeholder bulunmadı.
- Agent 1 gerçek client-safe Development değerleriyle web release build, Supabase Development startup, Auth/Profile, customer shell, empty backend UX ve config failure sözleşmelerini PASS doğruladı; kod/commit üretmedi.
- Kalan release gate: gerçek client-safe Production değerleriyle ayrı Production smoke; production backend'e güvenli değer olmadan bağlanılmamalı.
- Wave 8 standart Web release build'i sentetik client-safe URL/key ile, ek icon workaround'u olmadan PASS oldu. Bu yalnız compile/config contract kanıtıdır; startup/Auth/Production smoke değildir ve gerçek Production config hâlâ açık gate'tir.

### C6. Lint ve Navigation Lifecycle Borcu

- Discovery ekranlarındaki Wave 2 kapsamlı lifecycle/race düzeltmeleri tamamlandı.
- Wave 3'te `helper_functions.dart`, `location_helper.dart` ve `product_sellers_section.dart` içindeki kalan 9 ihlal lifecycle/dispose ve duplicate-navigation korumalarıyla düzeltildi.
- `use_build_context_synchronously` global ignore'u kaldırıldı; lint repo genelinde etkin ve analyzer temiz.
- Mevcut duplicate-submit/double-navigation korumaları korunmalı.

### C7. Eski Dokümantasyonun Güncellenmesi

- Wave 2'de README, `NEXT_STEPS.md`, `KNOWN_ISSUES.md` ve yeni `docs/LEGACY_ORDER_ISOLATION.md` legacy order sınırını güncel kod gerçeğine göre belgeledi.
- Diğer eski planların güncel kodla çelişen bölümleri ortaya çıktıkça belirlenmeli.
- Bu üç koordinasyon belgesi source-of-truth olarak korunmalı.
- Eski belgeler gerçek kod durumu doğrulanmadan otomatik kopyalanmamalı.

### C8. Test ve Release Sağlığı

- 2026-08-11 Wave 1 birleşik sonucu: `flutter analyze --no-pub` temiz ve tam Flutter test suite başarılı. Hedefli kanıtlar: chat 97/97, notifications 53/53, cart/QR/purchases 138/138, settings/navigation 34/34.
- 2026-08-11 Wave 2 birleşik sonucu: `flutter analyze --no-pub` temiz ve tam Flutter test suite başarılı. Hedefli kanıtlar: environment/config 11/11, discovery/shop 344/344, legacy mimari + unit 22/22, Cart V2/QR 94/94.
- 2026-08-12 Wave 3 birleşik sonucu: `flutter analyze --no-pub` temiz ve 108 dosyalık tam Flutter test suite başarılı. Hedefli kanıtlar: canonical migration 13/13, QR release contract 3/3, banner 22/22, async-context 32/32, chat 97/97, notifications 53/53, cart/QR/purchases 157/157 ve discovery/navigation 412/412.
- 2026-08-15 Wave 4 final sonucu: Auth/Profile/RLS, QR/verified purchase ve Chat/Notifications Realtime gated live harness'ları entegre edildi; hedefli 998/998, tam Flutter suite 1069/1069 ve analyzer geçti. Integration live rerun'u client-safe değer bulunmadığı için yapılmadı; bağımsız üç live sonuç PASS.
- 2026-08-15 Wave 5 final sonucu: Agent 1 Development istemci smoke PASS; Agent 2 Storage contract ve Agent 3 review eligibility/legacy order auditleri entegre edildi. Review/QR/shop rating/Storage contract/legacy architecture hedefli matris 169/169, tam Flutter suite 1069/1069 (3 güvenlik-gated live skip) ve `flutter analyze --no-pub` temiz geçti.
- 2026-08-15 Wave 6 final sonucu: üç production dalı zorunlu sırayla çatışmasız entegre edildi. Review RPC/client + cart/QR/purchases + Storage resolver/model + canonical migration hedefli matrisi 189/189, tam Flutter suite 1106/1106, ayrı Development live review harness'i 3/3 ve `flutter analyze --no-pub` geçti; fixture cleanup residual `0`, Production erişimi `NO`.
- 2026-08-16 Wave 7 final sonucu: Agent 2 Auth hardening ve Agent 3 Production readiness çıktıları entegre edildi; Agent 1 diff olmadığı için merge edilmedi. Auth/platform/config matrisi 186/186, release-readiness matrisi 67/67, tam Flutter suite 1113/1113 (4 gated live skip), analyzer, diff/security ve sentetik Production entrypoint compile contract PASS; gerçek Production/Development remote yazması yapılmadı.
- 2026-08-16 Wave 8 final sonucu: Üç teslim dalı zorunlu sırayla çatışmasız entegre edildi. Iconsax/Auth/callback/config/platform/migration matrisi 56/56, cutover belge/hash kontrolü 20/20, tam Flutter suite 1116/1116 (4 gated live skip) ve standart sentetik Production entrypoint Web release build'i ek icon workaround'u olmadan PASS; gerçek Production/Development remote yazması yapılmadı.
- 2026-08-16 Wave 9 final sonucu: Üç teslim dalı zorunlu sırayla çatışmasız entegre edildi. Migration/config/signing/platform/Auth hedefli matrisi 62/62, migration artifact manifesti 9/9, tam Flutter suite 1136/1136 (4 opt-in Development live skip), analyzer, standart Web ve Android production-release compile-only contract ile Android development debug build PASS. Android release packaging eksik signing materyalinde beklenen fail-closed sonucu verdi; remote backend yazması yapılmadı.
- 2026-08-16 Wave 10 pre-migration sonucu: Agent 1 Phase A + Phase B/C dokümantasyonu çatışmasız entegre edildi. Migration artifact manifesti 9/9 ve canonical migration contract testi 18/18 PASS; Agent clean-room replay kanıtı 9/9 PASS olarak korundu. Kod değişmediğinden full Flutter suite ve analyzer yeniden çalıştırılmadı; integration sırasında remote backend erişimi/yazması veya migration apply yapılmadı.
- 2026-08-16 Wave 10 D0 sonucu: Linked Production CLI dry-run kanıtı çatışmasız entegre edildi; pending sıra exact `0001→0009`, Production before/after state aynı ve remote write `0`. Owner'ın empty-first-bootstrap risk istisnası canonical belgelere kaydedildi. Manifest 9/9, canonical contract 18/18, docs/diff/security PASS; migration uygulanmadı.
- 2026-08-16 Wave 10 D1 sonucu: Production canonical migration apply ve metadata/security postflight kanıtı çatışmasız entegre edildi. Integration migration'ı yeniden uygulamadı ve remote erişim/yazma yapmadı. Manifest 9/9, canonical contract ve belge/güvenlik kontrolleri PASS sonrasında Phase E Production client wiring kapısı açıldı; full Flutter suite kod değişmediği için yeniden çalıştırılmadı.
- 2026-08-16 Wave 10 Phase E sonucu: Agent 1 Production client wiring ve Agent 2
  final mobile identity branch'leri zorunlu sırayla çatışmasız entegre edildi.
  Production client ve final app identity wired; Auth/email callback cutover, signing,
  controlled Production smoke ve commercial GO açık kaldı. Hedefli matris 61 PASS +
  1 güvenli live skip, tam suite 1142 PASS + 5 opt-in live skip, analyzer, gerçek
  Production Web build, Android Development debug ve Production compile-only PASS;
  eksik signing materyalinde release packaging fail-closed PASS.
- 2026-08-17 Wave 10 Phase F intermediate sonucu: Agent 1 final callback cutover ve
  Agent 2 Production Auth/SMTP read-only precheck branch'leri zorunlu sırayla
  entegre edildi. Production callback `com.esnaftavar.app://login-callback/`,
  Development callback `io.supabase.tstore://login-callback/` olarak izole; explicit
  signup/resend/recovery redirect ve exact PKCE filtresi kaynakta tamamlandı. Custom
  SMTP config mevcut ve template precheck PASS; ancak Site URL localhost, web recovery
  HTTPS route/allowlist, canlı inbox acceptance, sender/link-tracking final kanıtı ve
  legacy allowlist removal açık olduğundan SMTP precheck FAIL ve live email readiness
  NO kaldı. Hedefli Auth/platform/preflight matrisi 118/118, tam Flutter suite 1154
  PASS (5 opt-in live skip), sentetik Production config preflight, analyzer,
  docs/diff ve security/secret scan temizdir. Integration remote backend
  erişimi/yazması veya e-posta göndermedi.
- 2026-08-18 Wave 10 Phase F final sonucu: Agent 1 final live email/cleanup evidence
  HEAD'i `--no-ff` ve çatışmasız entegre edildi. Real SMTP delivery, server-side
  confirmation, final callback email URL contract'ı ve customer role/profile PASS;
  exact cleanup sonrası Production Auth/business/Storage test residual `0`. Mobile
  app opening ve full recovery BLOCKED; legacy callback removal ve spam tuning OPEN.
  Callback/PKCE/signup-recovery/account-deletion/profile/canonical RLS hedefli yerel
  matris 151/151, docs/diff ve secret/PII scan PASS; integration remote backend işlemi
  yapmadı.
- Büyük view dosyalarının conflict/testability riskini görev bazında azaltmak; geniş refactor'ı ayrı ve kontrollü yürütmek.
- Release öncesinde working tree, migration durumu ve canlı kabul sonuçlarını birlikte raporlamak.

### C9. Production Release Readiness — BLOCKED

- Canonical operasyon kaynakları: `docs/PRODUCTION_READINESS_AUDIT.md`, `docs/PRODUCTION_SMOKE_CHECKLIST.md`, `docs/PRODUCTION_PRE_MIGRATION_BASELINE.md`, `docs/PRODUCTION_CURRENT_STATE_INVENTORY.md`, `docs/PRODUCTION_SUPABASE_CUTOVER_PLAN.md` ve `docs/PRODUCTION_GO_NO_GO_CHECKLIST.md`.
- Canonical Production `EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` / `https://mefhfvrgkwciubeajjeb.supabase.co` / Frankfurt olarak doğrulandı; Development ref'i `tnipyxnvhgelwdpykyez` Production değildir.
- Production canonical `0001→0009` schema durumundadır: ledger 9/9, 23 public tablo, 23/23 RLS, final 52 policy, 28 app function, 25 trigger, exact üç active bucket ve iki Realtime member doğrulandı; Auth user/identity/session, Storage object ve business row sayıları sıfırdır.
- Free plan scheduled backup/PITR/restorable point sağlamaz. Owner'ın yalnız tamamen boş ilk bootstrap için verdiği no-backup/recreate istisnası D1'de kullanıldı; gerçek veri sonrası veya gelecekteki Production migration'ları için yetki ya da emsal değildir.
- Final application/bundle identifier `com.esnaftavar.app` owner kararıyla kapanmış ve Android/iOS platform wiring tamamlanmıştır. Android upload signing, Apple Team/certificate/profile ve signed AAB/APK/IPA hâlâ açık blocker'dır.
- Gerçek client-safe Production config/read-only bağlantı PASS'tir. Production final
  callback code/platform wiring tamamlanmıştır ve Development callback'i izoledir.
  Mobile Site URL exact final callback'e geçirilmiştir; real SMTP delivery ve
  server-side confirmation PASS'tir. Actual mobile app opening, full recovery
  lifecycle, legacy callback allowlist removal, deliverability/spam tuning,
  fiziksel iki-cihaz QR, fixture tabanlı Storage negative listing ve controlled
  broader Production smoke açık blocker'dır.
- Local migration artifact integrity, safe-equivalent clean-room replay ve linked CLI kontrolleri 9/9 PASS; gerçek apply ve metadata/security postflight D1'de PASS olmuştur.
- `PRODUCTION_CLIENT_WIRED: YES`, `FINAL_APP_IDENTITY_WIRED: YES`,
  `PHASE_F_CALLBACK_INTEGRATED: YES`, `SMTP_CONFIGURATION_PRESENT: YES`,
  `PRODUCTION_EMAIL_INFRASTRUCTURE: READY`, `PRODUCTION_ZERO_TEST_RESIDUAL: YES`,
  `MOBILE_AUTH_CALLBACK_ACCEPTANCE: BLOCKED`,
  `PASSWORD_RECOVERY_MOBILE_ACCEPTANCE: BLOCKED`, `SIGNING_READY: NO` ve
  `COMMERCIAL_RELEASE_READY: NO` olarak korunur.
- Deferred `brand-logos`, `avatars`, `review-images` ile legacy order final drop durumları Wave 8'de değiştirilmedi ve bu başlık altında yanlışlıkla blocker'a yükseltilmedi.

### C10. Iconsax Release Build Hardening

- Durum: **COMPLETED / CLOSED**.
- Sorunlu `iconsax 0.0.8` kaldırıldı; `iconsax_flutter 1.0.1` lockfile'da direct dependency olarak sabittir.
- Repo-local `iconsax_compat.dart` yalnız uygulamanın kullandığı icon yüzeyini açar; geçersiz/sıfır codepoint regression testiyle korunur.
- Sentetik client-safe Production config ile standart Web release build ek icon workaround'u olmadan PASS oldu; gerçek Production artifact/config ve smoke C9 altında açık kalır.

## Güncelleme Kuralı

- Ürün sahibi karar verdiğinde ilgili madde `PRODUCT DECISION NEEDED` bölümünden onaylı işe taşınır ve karar metni açıkça kaydedilir.
- Kod tamamlandığında madde doğrudan silinmez; doğrulama ve release sonucu kaydedildikten sonra tamamlandı olarak işaretlenir veya geçmiş kaynağına taşınır.
- Production agentlar backlog'u geniş çapta yeniden yazmaz; merkezi güncelleme analiz/koordinasyon veya integration/release agentı tarafından yapılır.
