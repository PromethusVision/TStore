# Production Smoke Checklist

Bu liste **Production'a otomatik apply veya write yetkisi vermez**. Wave 10 Agent 1
Phase D1'de açık yetkiyle yalnız canonical `0001→0009` initial bootstrap'ı uyguladı ve
metadata/security postflight'ı PASS tamamladı. Integration migration'ı yeniden
uygulamadı, remote erişim/yazma yapmadı ve hesap oluşturmadı. Gerçek smoke'taki her
write önceden onaylı disposable principal/veriyle sınırlı tutulmalıdır.

## Wave 10 Phase E integrated read-only/client identity evidence

`PRODUCTION_CLIENT_SAFE_KEY_PRESENT: YES`

`PRODUCTION_RUNTIME_CONFIG: PASS`

`PRODUCTION_CLIENT_CONNECTION_READONLY: PASS`

`PRODUCTION_CLIENT_WIRED: YES`

`FINAL_APP_IDENTITY_WIRED: YES`

`FINAL_AUTH_CALLBACK_IMPLEMENTATION: PASS`

`PHASE_F_CALLBACK_INTEGRATED: YES`

`SMTP_CONFIGURATION_PRESENT: YES`

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

`READY_FOR_PHYSICAL_B2_RETEST: COMPLETED — INPUT/LOCATION PASS`

`PHYSICAL_DEVICE_REGRESSION: PARTIAL — INPUT/LOCATION PASS; CONFIRMATION BLOCKED`

`READY_FOR_MOBILE_AUTH_LIVE_ACCEPTANCE: YES`

`WAVE_11_B3A_AUTHORIZED_FIXTURE_CLEANUP: PASS`

`B3A_CANONICAL_SELF_DELETE_ACCEPTANCE: PASS`

`SAVED_LOCATION_RESIDUAL: ZERO`

`PRODUCTION_ZERO_TEST_BASELINE: RESTORED`

`READY_TO_RESTART_B3_MOBILE_AUTH: YES`

`COMMERCIAL_RELEASE_READY: NO`

## Wave 11 Phase A signed Android artifact evidence

Wave 11'de repo-dışı kalıcı upload keystore ve `esnaftavar-upload` alias'ı ile exact
Production kimliğinde ilk imzalı APK/AAB üretildi. APK `com.esnaftavar.app`, label
`EsnaftaVar`, `versionName 1.0.0` ve `versionCode 1` taşıyor; `apksigner` tek signer ve
v2 signature doğrulamasını PASS tamamladı. APK SHA-256 değeri
`E1A3E801FD648AE4665E9E2B6D5D88BF15350A3B75A388C94AC5B43701A88C25`, AAB SHA-256
değeri `0F34958E3F739E887C34E70E627FB75082EC4AE601D89346F1CC1B695E7B88CB` olarak
kaydedildi.

Build `main_production.dart`, production flavor ve client-safe gerçek Production
runtime config ile standart release yolunda, `--no-tree-shake-icons` olmadan PASS.
Artifact scan'i signing parolası, private key, service-role/server-only credential
ve Development URL bulmadı. Final callback mevcut, legacy callback yok. Geçici
`key.properties` ve runtime config build sonrasında silindi; keystore Git dışında ve
owner tarafından birincil repo-dışı yedek/parola yöneticisi kaydı tamamlandı. Secret
değer veya yedek bağlantısı belgelenmedi; ikinci offline yedek öneri/açık kaldı.
ADB'de fiziksel cihaz bulunmadığından install/startup, actual mobile callback opening
ve recovery acceptance bu build kanıtının parçası değildir.
Bu bölüm Production smoke PASS veya commercial release GO ilan etmez.

## Wave 11 Phase B2 physical bugfix automated evidence

Wave 11 B2 final integration'da fiziksel cihazda bildirilen üç client bug'ı için
otomatik regression PASS oldu:

- Açık renk müşteri input yüzeylerinde değer, hint/label, error, cursor ve selection
  koyu sistem temasında da okunabilir; login/signup/recovery ve parola maskeleme
  widget testleri kapsanır.
- Exact environment confirmation callback'i Auth/profile state'ini yeniden yükler;
  authenticated kullanıcı shell'e, session oluşmayan confirmed kullanıcı Login'e
  gider. Waiting state kapanır, başarı mesajı bir kez gösterilir; malformed/duplicate
  callback güvenle ele alınır. Production final ve Development legacy callback
  izolasyonu korunur.
- Konum akışı cihaz servisini kontrol eder, `denied` durumunda Android runtime izin
  isteğini başlatır, `deniedForever` için uygulama ayarlarını ve servis kapalıyken
  location settings'i açar; resume sonrasında durumu yeniden okur. Current-position
  timeout/unavailable halinde geçerli last-known position güvenli fallback'tir.

Agent hedefli testleri 88/88 ve kayıtlı konum widget regresyonu 13/13; integration
hedefli matrisi 118/118 ve tam Flutter suite 1177 PASS (5 explicit opt-in live skip)
tamamladı. Analyzer ve Agent'ın secretsız Development debug APK derlemesi PASS.
Production/Development remote erişimi veya write, signup ya da e-posta yoktur.
Wave 11 B2R'de POCO X7 Pro / Android 16 fiziksel cihaz olarak ADB ve Flutter tarafından
doğrulandı. Canonical repo-dışı keystore ile current main'den yeni Production APK
üretildi; `com.esnaftavar.app` üzerine uninstall/clear-data olmadan normal upgrade
kuruldu. APK signature/package/final callback ve artifact secret scan PASS; geçici
`key.properties` ve runtime config build sonrasında silindi.

- [x] Erişilebilir Home arama input'unda yazılan değer, hint ve cursor açık zeminde
      fiziksel olarak okunabilir. Mevcut oturum korunarak login/signup açılmadı;
      parola maskelemesi widget testinde PASS kaldı.
- [x] Konum aksiyonu Android runtime izin dialog'unu açtı. “Uygulamayı kullanırken izin
      ver” sonrasında fine/coarse izin, gerçek location access ve çalışan app process'i
      ADB ile doğrulandı; product-owner konum sonucunu, hata/crash olmadığını fiziksel
      olarak onayladı. Exact koordinat kaydedilmedi.
- [ ] Ayrı yetkili canlı Auth turunda final callback app-opening/waiting-state kapanışı
      doğrulanır; B2R yeni signup/e-posta/confirmation üretmedi.

Fiziksel denied/deniedForever ve Settings-return negatif turu çalıştırılmadı; bu akışın
service/widget sözleşmeleri hedefli testlerde PASS. B2R hedefli paket 114 PASS, tam
Flutter suite 1177 PASS (5 explicit opt-in live skip) ve analyzer PASS; integration
B2 hedefli matrisi 118/118 PASS. Production veya Development backend write, Auth
e-postası, yeni user, QR ya da Storage işlemi yoktur.
Confirmation/recovery canlı turundan önce mevcut Production test-user inventory ve
gerekiyorsa exact scoped cleanup durumu yeniden doğrulanmalıdır.

Wave 11 B3A'da fresh authoritative gate bu fiziksel testten kalan tek disposable
customer'ı doğruladı: Auth user/identity/profile `1/1/1`, session `2`, customer role
`1`, merchant/admin `0`, legal consent `2`, saved location `1`; diğer user-linked
business ve Storage satırları `0`. Owner'ın exact fixture yetkisiyle uygulamadaki
canonical `delete_current_customer_account` self-delete akışı kullanıldı. Sonrasında
Auth user/identity/session/profile/legal consent/saved location, diğer user-linked
business ve Storage exact `0` doğrulandı. Saved location cascade ile temizlendi; ek
targeted/admin delete gerekmedi. Yeni signup/e-posta/recovery, Auth config, migration,
schema, Storage veya Development işlemi yapılmadı. B3 mobile acceptance yeniden
başlatılabilir; confirmation app-opening ve full recovery lifecycle hâlâ açık gate'tir.
B3A integration bu cleanup'ı tekrar çalıştırmadı ve Production remote read/write
yapmadı.

`WAVE_11_B2_AUTOMATED_REGRESSION: PASS`

`ANDROID_SIGNED_APK_INSTALL_UPGRADE: PASS`

`ANDROID_STARTUP_PHYSICAL_ACCEPTANCE: PASS`

`INPUT_PHYSICAL_ACCEPTANCE: PASS — HOME SEARCH VALUE/HINT/CURSOR`

`LOCATION_PHYSICAL_ACCEPTANCE: PASS`

`CONFIRMATION_UI_PHYSICAL_ACCEPTANCE: BLOCKED — NO AUTH/EMAIL FIXTURE CREATED`

`SETTINGS_RETURN_NEGATIVE_PHYSICAL_ACCEPTANCE: OPEN`

`PHYSICAL_DEVICE_REGRESSION: PARTIAL — INPUT/LOCATION PASS; CONFIRMATION BLOCKED`

`READY_FOR_MOBILE_AUTH_LIVE_ACCEPTANCE: YES`

## Wave 10 Phase F3 live email acceptance and authorized cleanup

`PRODUCTION_SITE_URL_FINAL_CALLBACK: PASS`

`PHASE_F3_PREWRITE_GATE: PASS — EXACT SQL ZERO`

`AUTH_USER_BASELINE_EXPLAINED: YES`

`REAL_SMTP_DELIVERY: PASS`

`SERVER_SIDE_EMAIL_CONFIRMATION: PASS`

`FINAL_CALLBACK_EMAIL_CONTRACT: PASS`

`FINAL_CALLBACK_APP_OPENING: BLOCKED`

`PRODUCTION_PASSWORD_RECOVERY: BLOCKED`

`AUTHORIZED_TEST_USER_CLEANUP: PASS`

`PRODUCTION_ZERO_AUTH_BASELINE_RESTORED: YES`

`TEST_FIXTURE_CLEANUP: PASS`

`PHASE_F_LIVE_EMAIL_ACCEPTANCE: PARTIAL`

`PRODUCTION_EMAIL_INFRASTRUCTURE: READY`

`PRODUCTION_ZERO_TEST_RESIDUAL: YES`

`MOBILE_AUTH_CALLBACK_ACCEPTANCE: BLOCKED`

`PASSWORD_RECOVERY_MOBILE_ACCEPTANCE: BLOCKED`

`LEGACY_PRODUCTION_CALLBACK_REMOVAL: OPEN`

`EMAIL_DELIVERABILITY_TUNING: OPEN — CONFIRMATION EMAIL REACHED SPAM`

2026-08-17 salt-okunur tekrar kontrolde exact Production name/ref, Development
exclusion, Custom SMTP, Confirm Email, final Site URL ve iki callback'li allowlist PASS
oldu. Auth Users ekranı refresh sonrasında `10 users (estimated)` gösterdi; beklenen
pre-write baseline `0` idi. Mevcut hesapların kimliği incelenmedi ve hiçbir hesaba
dokunulmadı. Disposable signup, inbox gönderimi, resend, recovery ve cleanup akışları
başlatılmadı; Production write `0`, Development erişimi/yazması `0` kaldı.

Phase F3A exact salt-okunur SQL snapshot'ı (`2026-08-17 00:59:49 UTC`)
`auth.users/identities/sessions = 0/0/0`, profiles/consents `0/0` ve bütün user-linked
business relation count'larını `0` doğruladı. Dashboard estimated değeri gerçek user
relation count'u değildir; sınıflandırılacak veya silinecek kullanıcı yoktur. D1
zero-state kanıtı current state ile tutarlıdır.

F3B'de yalnız bir disposable normal-client customer oluşturuldu. Gerçek confirmation
e-postası inbox'a ulaştı (Spam klasörü), sender adı/domain beklenen sözleşmeyle uyumluydu
ve link Supabase server-side confirmation'ı tamamladı. Link final
`com.esnaftavar.app://login-callback/` contract'ını taşıdı; Windows Chrome'da bu mobile
scheme'i karşılayan Production uygulaması bulunmadığından actual app opening BLOCKED
kaldı. Recovery isteği kabul edildi, fakat link kullanılmadı ve full mobile PKCE
recovery lifecycle doğrulanmadı.

Spam klasörüne teslim, SMTP veya Auth confirmation failure değildir. Bu sonuç ayrı
`EMAIL_DELIVERABILITY_TUNING` release follow-up'ı olarak açık tutulur; bu integration
provider planı veya DNS ayarı değiştirmez.

F3D fresh gate'te yalnız masked disposable fixture doğrulandı: Auth user/identity/
profile `1/1/1`, customer role `1`, merchant/admin `0`, legal consent `2`, session `2`,
user-linked business ve Storage object `0`. Owner'ın açık exact-account yetkisiyle
Supabase Dashboard Auth Admin delete uygulandı. Authoritative post-delete SQL sonucu
Auth user/identity/session/profile/legal consent/business residual/Storage object
`0/0/0/0/0/0/0` oldu. Başka user/veri bulunmadı; Auth config, schema, migration,
Storage ve Development değiştirilmedi. Legacy Production callback allowlist kaydı
korunur.

## Wave 10 Phase F2 Production Auth/SMTP read-only precheck

`F2_PRODUCTION_SMTP_PRECHECK: FAIL — HISTORICAL PRE-LIVE CHECK`

`EMAIL_TEMPLATE_PRECHECK: PASS`

`F2_LIVE_EMAIL_ACCEPTANCE_READY: NO — HISTORICAL; F3B LATER EXECUTED`

Authenticated management read-only inceleme exact `EsnaftaVar Production` /
`mefhfvrgkwciubeajjeb` projesinde Email provider, Confirm Email ve Custom SMTP'nin
etkin; SMTP host/port değerlerinin `smtp.resend.com:465` olduğunu doğruladı. Final ve
legacy mobile callback URL'leri allowlist'te birlikte mevcut. Confirm-signup,
reset-password ve change-email hosted şablonları `ConfirmationURL` kullanıyor;
hardcoded localhost/demo/TStore linki bulunmadı.

Bu F2 kanıtı tek başına canlı teslimat kabulü değildir; sonraki F3B gerçek SMTP
teslimatı ve server-side confirmation'ı doğruladı. Production signup, resend, recovery
ve PKCE akışları final callback'e açık ve environment-isolated olarak bağlıdır. Site URL
final mobile callback'tir; HTTPS web recovery route/allowlist'i yoktur. Resend
link-tracking durumu ile dashboard'un geri göstermediği exact sender/username ayrıca
doğrulanmalıdır. Ayrıntılı kanıt [`PRODUCTION_AUTH_EMAIL_PRECHECK.md`](PRODUCTION_AUTH_EMAIL_PRECHECK.md)
içindedir.

E1 gerçek Production URL/ref ve client-safe publishable key ile yalnız anonymous
read-only bağlantı yaptı. Key source/log/belgeye yazılmadı; service-role/server secret
kullanılmadı. Categories/products/shops/banners request'leri başarılı empty state,
Auth client user/session yok ve üç active Storage bucket public URL/not-found contract'ı
PASS oldu. Standard `main_production.dart` Web release build'i gerçek runtime injection
ile icon workaround olmadan PASS; credential taşıyan geçici artifact kaldırıldı.

Bu evidence full smoke veya deploy GO değildir. SMTP delivery ve server-side
confirmation PASS olsa da actual mobile callback opening, full recovery lifecycle,
iOS signing ve broader Production smoke açık kalır. Android signing ve ilk artifact
record Wave 11'de PASS olmuştur.
Final Android/iOS kimliği ve Production callback
`com.esnaftavar.app://login-callback/` kaynakta wired durumdadır. Development legacy
callback'i ayrı sözleşmede korunur. Production legacy allowlist kaydı yalnız gerçek
final mobile Auth acceptance ve fixture cleanup tamamlandıktan sonra yetkili owner
tarafından kaldırılır.

## Wave 11 B3R physical mobile Auth kanıtı

| Kontrol | Sonuç |
| --- | --- |
| Exact Production / Development exclusion | PASS; `mefhfvrgkwciubeajjeb`, Development write yok |
| Normal signup / waiting UI / profile / role | PASS; exact bir disposable customer, role `customer` |
| Confirmation Inbox / sender / domain | PASS; Spam değil, kişisel veri belgelenmedi |
| Confirmation final callback / app opening | PASS; POCO X7 Pro doğrudan Production uygulamasını açtı |
| Confirmation canonical başarı mesajı | FAIL; Home açıldı fakat kısa başarı mesajı görünmedi |
| Recovery Inbox / final callback / update UI | PASS; tek recovery e-postası ve tek link kullanımı |
| Eski credential login | PASS; reddedildi |
| Yeni credential login | FAIL; patched signed build dahil Auth `invalid_credentials` |
| Role escalation | PASS; kullanıcı `customer` kaldı, merchant/admin olmadı |
| Canonical self-delete / zero residual | Self-delete session yoktu; owner-authorized exact Auth Admin cleanup ve zero residual PASS |

Acceptance turunda ikinci recovery, resend, signup veya admin cleanup çalıştırılmadı.
2026-08-22 ayrı owner-authorized cleanup görevinde fresh gate yalnız exact B3R fixture'ı
doğruladı; Supabase Dashboard Auth Admin delete sonrasında Auth user/identity/session/
profile/consent, bütün user-linked business rows ve Storage objects exact `0` oldu.
Cleanup PASS olsa da recovery final login ve confirmation success feedback FAIL/OPEN
kaldığı için legacy callback removal ve Wave 11 mobile Auth acceptance gate'i açıktır.

## 1. Başlatma kapıları

Smoke başlamadan önce tamamı işaretlenmelidir:

- [ ] `PRODUCTION_READINESS_AUDIT.md` içindeki BLOCKER'lar kapatıldı.
- [x] Canonical Production kimliği Wave 10'da `EsnaftaVar Production` /
      `mefhfvrgkwciubeajjeb` / exact HTTPS ref-host / Frankfurt olarak doğrulandı;
      Development `tnipyxnvhgelwdpykyez` Production değildir.
- [ ] Smoke change window'unda Production project ref ve HTTPS URL iki kişi/iki
      bağımsız kaynakla yeniden doğrulandı.
- [x] İlk Android artifact'i `main_production.dart` ile güvenli geçici local secret
      injection kullanılarak üretildi; base, version/build number ve hash kaydedildi.
      Kalıcı CI provenance ayrıca açıktır.
- [x] İlk Android artifact'i standart release komutuyla ve ek icon workaround'u
      olmadan üretildi; gerçek APK/AAB hash'leri kayıtlı.
- [x] Android artifact scan'i service-role, DB password, private key veya signing
      secret bulmadı.
- [x] 0001–0009 apply/postflight ledger ve schema diff'i PASS; backup/restore kanıtı
      veya yalnız boş ilk bootstrap için kayıtlı owner exception geçerli.
- [x] Canonical Git/LF migration manifesti
      `node tool/verify_migration_artifact_manifest.mjs` ile 9/9 PASS.
- [x] Production schema/RLS/RPC/Storage/Realtime metadata/security postflight PASS.
- [x] Phase E1 gerçek Production runtime config ve anonymous read-only empty-state
      bağlantısı PASS; Production write/Auth account/Storage mutation yok.
- [x] Android/iOS final application/bundle identity `com.esnaftavar.app` ve Android
      Development `.dev` varyantı kaynak sözleşmesine bağlandı.
- [x] Final Production callback istemci/platform/preflight kaynak wiring'i tamamlandı.
- [x] Final callback signed-artifact confirmation app opening POCO X7 Pro üzerinde
      PASS.
- [ ] Full recovery kabulü yeni credential login ile tamamlandı; ardından legacy
      Production allowlist kaydı kaldırıldı. B3R'de callback/update UI PASS, login FAIL.
- [x] Phase F2 read-only Auth/SMTP/template precheck tamamlandı; Production write,
      kullanıcı veya e-posta gönderimi yapılmadı.
- [x] Supabase remote Site URL localhost'tan exact final mobile callback
      `com.esnaftavar.app://login-callback/` değerine geçirildi; final ve legacy
      callback allowlist'te birlikte doğrulandı.
- [ ] Web release kapsamındaysa HTTPS Site URL/recovery route/allowlist kararı ve
      Resend link-tracking doğrulaması birlikte PASS.
- [x] Phase F3A exact SQL `auth.users/identities/sessions = 0/0/0`; Dashboard
      `10 users (estimated)` sinyali authoritative user count değildir ve baseline
      contradiction kapanmıştır.
- [x] F3B gerçek SMTP teslimatı, gözlenen sender adı/domain, server-side confirmation
      ve final callback e-posta URL contract'ı PASS; F3D exact authorized fixture
      cleanup sonrası Auth/profile/consent/business/Storage baseline yeniden sıfır.
- [x] B3R owner-authorized exact fixture cleanup sonrası Auth user/identity/session/
      profile/consent, bütün user-linked business ve Storage residual exact sıfır.
- [x] Signed Production mobil uygulamada confirmation final callback app opening PASS.
- [ ] Full recovery PKCE lifecycle yeni credential login ve cleanup ile PASS;
      Resend link-tracking ayrıca doğrulanmalı.
- [x] Android gerçek application ID ve upload-key release signing PASS.
- [x] Android keystore birincil repo-dışı yedeği ve parola yöneticisi kaydı tamamlandı.
- [ ] Android ikinci offline keystore yedeği ve kalıcı CI signing provenance tamamlandı.
- [ ] Google Play Console package / Play App Signing kabulü tamamlandı.
- [ ] iOS gerçek bundle ID ile Distribution signing/archive PASS.
- [ ] Web kullanılıyorsa HTTPS origin, allowed origins ve Auth redirect allowlist PASS.
- [ ] Production owner iki bağımsız disposable müşteri principal'ı ve gerekiyorsa ayrı
      merchant principal'ı onaylı güvenli yöntemle hazırladı.
- [ ] Test verisi prefix'i, TTL/cleanup sahibi ve gerçek müşteri verisine dokunmama
      kuralı kayıtlı.
- [ ] Log/monitor erişimi, stop kriteri ve incident sorumlusu hazır.

**Kanıt başlığı**

- Production project ref (değer loga secret olarak yazılmamalı):
- Commit / artifact hash:
- Platform / sürüm:
- Tarih-saat / tester:
- Test principal referansları (parola/token yazılmaz):
- Cleanup sahibi:

## 2. Salt-okunur başlangıç kontrolleri

| # | Kontrol | Beklenen sonuç | Sonuç / kanıt |
| --- | --- | --- | --- |
| R1 | Production migration ledger | Exact 0001–0009 sırası ve beklenen checksum/dosya eşleşmesi | |
| R2 | Public schema / RLS | Canonical 23 tablo, 23/23 RLS; beklenmeyen açık tablo yok | |
| R3 | RPC / grant / trigger | Exact signature, revoke/grant, search path ve trigger contract'ı | |
| R4 | Storage inventory | Yalnız aktif üç bucket zorunlu; deferred bucket'lar beklenmez | |
| R5 | Realtime publication | `chat_messages` ve `notifications` üyedir; beklenmeyen tablo yok | |
| R6 | Auth config | Email/SMTP, redirect URL, allowed origin ve rate-limit ayarları onaylı | |

Herhangi bir remote drift, yanlış project ref veya restore edilemeyen backup görülürse
smoke durdurulur; düzeltme bu checklist içinde doğaçlanmaz.

## 3. Customer akış matrisi

Her satır için PASS/FAIL, zaman damgası, cihaz/tarayıcı ve mümkünse kişisel veri
içermeyen ekran/log kanıtı eklenir.

| Akış | Uygulama adımı | Beklenen sonuç | Sonuç / kanıt |
| --- | --- | --- | --- |
| App startup | Production artifact'ı temiz kurulum/oturumla aç | Splash tamamlanır; yanlış environment/fallback, config exception veya secret görünmez | |
| Guest Home/discovery | Oturum açmadan Home'u aç, yenile ve listeyi kaydır | Public katalog açılır; loading/empty/error durumu kontrollüdür | |
| Categories | Kategori listesi ve bir kategori detayı aç | Doğru ürünler ve kategori görseli gelir; çapraz/bozuk veri crash üretmez | |
| Search | Var olan, olmayan ve özel karakterli sorgu dene | Sonuç/empty state doğru; duplicate ve beklenmeyen private veri yok | |
| ProductDetails | Guest olarak ürün detayına gir | Ürün, fiyat ve satıcılar doğru; legacy HTTPS/canonical product image güvenli görüntülenir | |
| Sellers | Aynı ürünün satıcılarını ve mağaza detayını aç | Yalnız aktif/görünür satıcılar, konum/mesafe izin akışı ve fallback doğru | |
| Login/signup | Disposable User A ile signup/email confirmation/login/logout yap | SMTP/link/session/profile/legal consent çalışır; yanlış veya kullanılmış link reddedilir | B3R: delivery/callback/session/profile/customer role PASS; canonical success mesajı FAIL |
| Password recovery | Web ve/veya mobile recovery linkini aç | Allowlist'teki origin/scheme uygulamaya döner; token bir kez kullanılır, loga sızmaz | B3R: callback/update UI PASS; yeni credential login FAIL |
| CartV2 | User A bir shop-product ekler, miktar değiştirir/siler; başka mağaza eklemeyi dener | Tek-mağaza kuralı, stok/fiyat revalidation ve duplicate tap koruması çalışır; legacy checkout açılmaz | |
| Favorites | User A ekler/çıkarır; User B ile izolasyonu kontrol et | Own CRUD çalışır; B, A'nın favorisini okuyamaz/değiştiremez | |
| Chat | A ve B aynı conversation'da mesajlaşır; üçüncü conversation ile izolasyonu dene | Real event bir kez gelir; RLS, unread/summary, unsubscribe/reconnect/dedup doğru | |
| Notifications | Canonical ürün trigger'ı ile A için bildirim üret; B'yi gözle | Yalnız A alır; direct authenticated INSERT reddedilir; unread/mark-read/reconnect/dedup doğru | |
| QR create | User A'nın CartV2 verisiyle QR oluştur | Server-authoritative kısa ömürlü session ve immutable item snapshot oluşur | |
| QR physical confirm | Ayrı gerçek merchant cihazında okut/onayla | Doğru mağaza onaylar; yanlış mağaza, expired/cancelled/used token ve double confirm reddedilir | |
| Verified purchase | User A cihazında polling/tamamlanma ve geçmişi aç | İşlem bir kez tamamlanır; doğru ürün snapshot'ları görünür; legacy order akışı açılmaz | |
| Shop rating | Doğrulanmış işlem sonrası mağaza puanı oluştur/güncelle | Eligibility server-derived; yetkisiz, başka kullanıcı ve duplicate davranışı kontrollü | |
| Product review | Yalnız doğrulanmış transaction item ürünü için create/read/update/delete/recreate yap | RPC-only eligibility, server-derived verified flag, idempotent duplicate ve aggregate tutarlılığı çalışır | |
| Profile | Profil görüntüle/düzenle; adres/konum izin reddi ve kabulünü dene | Own data çalışır; cross-user RLS reddeder; izin reddi kontrollü fallback verir | |
| Account deletion | Ayrı disposable hesapta uyarıyı kabul edip sil | Auth/profile ilişkili veri canonical sözleşmeye göre temizlenir; tekrar login olmaz; başka principal etkilenmez | B3R: self-delete session yoktu; owner-authorized exact Auth Admin cleanup ve authoritative zero residual PASS |
| Storage images | Product/category/banner için controlled path ve legacy HTTPS örneği aç; malformed kaynak dene | Public GET çalışır; doğru ortam URL'si kullanılır; malformed/unsupported kaynak fallback verir; list/write/update/delete yoktur | |

## 4. Negatif güvenlik ve yaşam döngüsü

- [ ] Anonymous kullanıcı private profile/cart/favorite/chat/notification/review mutation
      yapamaz.
- [ ] User B, User A'nın private satırlarını okuyamaz veya değiştiremez.
- [ ] Müşteri merchant/admin rolüne client payload ile yükselemez.
- [ ] Direct notification INSERT ve client Storage write/update/delete/list reddedilir.
- [ ] Disposable fixture ile Storage negative listing denial kabulü doğrulandı;
      Phase E empty-list sonucu bu davranışın kanıtı olarak kullanılmaz.
- [ ] QR token, Auth token, e-posta, parola ve kişisel veri uygulama/edge/CI logunda yoktur.
- [ ] Offline/timeout sonrası retry aynı QR, mesaj, bildirim, rating veya review kaydını
      iki kez oluşturmaz.
- [ ] Logout/login ve Realtime reconnect sonrasında eski kullanıcı kanalı açık kalmaz;
      duplicate subscription/event yoktur.
- [ ] Uygulama yanlış/eksik Production define ile başka ortama fallback yapmadan güvenli
      şekilde durur.

## 5. Storage ve media kabulü

- [ ] `product-images`: `catalog/<product_id>/...` public read.
- [ ] `product-images`: `shops/<shop_id>/<shop_product_id>/...` public read.
- [ ] `category-images`: controlled category path public read.
- [ ] `banner-images`: controlled banner path public read.
- [ ] Existing valid HTTPS media geriye uyumlu okunur.
- [ ] `javascript:`, `data:`, local file, malformed ve unknown bucket/path güvenli fallback.
- [ ] Anonymous object GET çalışırken object listesi ve tüm client mutation'ları reddedilir.
- [ ] `brand-logos`, `avatars`, `review-images` bulunmaması FAIL değildir.

## 6. Stop, rollback ve cleanup

Şunlardan biri görülürse smoke hemen durur:

- yanlış Supabase project ref/origin;
- secret/service-role/DB credential sızıntısı;
- RLS ile başka kullanıcı verisine erişim;
- beklenmeyen migration drift veya veri kaybı;
- duplicate financial/verified purchase kanıtı ya da tekrar kullanılabilir QR;
- hesap silmenin başka kullanıcıya etkisi;
- crash loop veya kontrolsüz hata logu.

Smoke sonunda:

- [ ] Yalnız onaylı test prefix'li chat/notification/cart/QR/rating/review verisi canonical
      cleanup yoluyla temizlendi; gerçek müşteri verisine dokunulmadı.
- [x] Phase F3 disposable principal cleanup'ını yetkili Auth sahibi exact fixture ile
      sınırlı tuttu; broader smoke principal'ları için bu madde yeniden uygulanır.
- [x] Phase F3 residual sayımları kaydedildi ve Auth/business/Storage exact `0` bulundu;
      broader smoke sonrasında residual kontrolü yeniden zorunludur.
- [x] B3R disposable principal owner-authorized exact Auth Admin cleanup ile silindi;
      Auth/profile/consent/business/Storage residual exact `0`, Development write `0`.
- [x] Phase F3 Git kanıtı secret/PII açısından redakte edildi.
- [ ] PASS/FAIL ve açık incidentler release sahibi tarafından imzalandı.

**Final karar**

- [ ] PASS — Production release kapısı açılabilir.
- [ ] FAIL — Release durduruldu; incident/owner/takip işi kayıtlı.
