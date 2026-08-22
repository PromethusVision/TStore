# Production Release Configuration

**Kaynak taban:** Wave 11 Phase B7 /
`origin/main@21f7224dc9e8b70400b7ae4503daaa20f40ed8c3`

**B7 sırasında Production Supabase erişimi:** authenticated read **YES**; remote write
**YES — yalnız owner-authorized exact legacy callback removal**. Database, Storage,
user/e-posta ve diğer Auth config write **NO**. Önceki authenticated management
**read-only** Auth/SMTP/template kanıtı ile Agent 1'in salt-okunur client-safe
publishable-key/build kanıtı ayrıca korunur.

Bu sözleşme Production Flutter artifact'ının yanlış Development, placeholder veya
server credential ile üretilmesini build öncesinde durdurur. Preflight'ın PASS olması
yalnız yerel yapılandırma yapısını kanıtlar; Production project ownership, remote Auth
ayarları, migration postflight ve smoke ayrıca PASS olmadan deployment yetkisi vermez.

## Tek resmi entrypoint

Production build target'ı yalnız:

```text
lib/main_production.dart
```

`main_production.dart` yalnız `SUPABASE_PRODUCTION_*` ad alanını okur. Development
değerlerine fallback yoktur. Preflight farklı target veya manifestte Development
alanı görürse fail-closed davranır.

## Final mobile identity decision

`FINAL_APP_IDENTIFIER: com.esnaftavar.app — OWNER FINAL / PLATFORM WIRING COMPLETE`

`PHASE_E1_PRODUCTION_CLIENT_WIRING: PASS`

`PRODUCTION_CLIENT_WIRED: YES`

`FINAL_APP_IDENTITY_WIRED: YES`

`PRODUCTION_CLIENT_SAFE_KEY_PRESENT: YES`

`PRODUCTION_RUNTIME_CONFIG: PASS`

`PRODUCTION_CLIENT_CONNECTION_READONLY: PASS`

`FINAL_AUTH_CALLBACK_IMPLEMENTATION: PASS`

`PHASE_F_CALLBACK_INTEGRATED: YES`

`FINAL_PRODUCTION_AUTH_CALLBACK: com.esnaftavar.app://login-callback/`

`LEGACY_PRODUCTION_ALLOWLIST_REMOVAL_REQUIRED: NO`

`SMTP_CONFIGURATION_PRESENT: YES`

`PRODUCTION_SITE_URL_FINAL_CALLBACK: PASS`

`REAL_SMTP_DELIVERY: PASS`

`SERVER_SIDE_EMAIL_CONFIRMATION: PASS`

`FINAL_CALLBACK_EMAIL_CONTRACT: PASS`

`PRODUCTION_EMAIL_INFRASTRUCTURE: READY`

`PRODUCTION_ZERO_TEST_RESIDUAL: YES`

`F2_PRODUCTION_SMTP_PRECHECK: FAIL — HISTORICAL PRE-LIVE CHECK`

`EMAIL_TEMPLATE_PRECHECK: PASS`

`MOBILE_AUTH_CALLBACK_ACCEPTANCE: PASS — B6 PHYSICAL`

`PASSWORD_RECOVERY_MOBILE_ACCEPTANCE: PASS — B6 PHYSICAL`

`LEGACY_PRODUCTION_CALLBACK_REMOVAL: COMPLETED — B7`

`FINAL_PRODUCTION_CALLBACK_ONLY: YES`

`AUTH_CONFIG_POSTFLIGHT: PASS`

`EMAIL_DELIVERABILITY_TUNING: OPEN — CONFIRMATION EMAIL REACHED SPAM`

`ANDROID_SIGNING_READY: YES`

`SIGNED_ANDROID_ARTIFACT_EVIDENCE: PASS`

`KEYSTORE_PRIMARY_BACKUP: COMPLETED`

`IOS_SIGNING_READY: NO`

`COMMERCIAL_RELEASE_READY: NO`

Canonical Android application ID/namespace, Development `.dev` varyantı ve iOS
Runner/RunnerTests bundle identifier değerleri final `com.esnaftavar.app` kimliğine
bağlandı. Production callback istemci, Android production flavor, iOS Profile/Release
ve release preflight'ta final `com.esnaftavar.app://login-callback/` değerine taşındı.
Development istemcisi, Android development flavor ve iOS Debug mevcut
`io.supabase.tstore://login-callback/` sözleşmesini korur; ortamlar arasında fallback
yoktur. B6 final mobile confirmation/recovery acceptance sonrasında B7 owner-authorized
remote Auth write yalnız legacy Production allowlist kaydını kaldırdı; Production
allowlist artık yalnız final callback'i içerir. Read-only precheck Custom SMTP'nin açık,
`smtp.resend.com:465` ve sender name'in `EsnaftaVar` olduğunu; Confirm Email'in açık
ve üç hosted email template'inin canonical `ConfirmationURL` kullandığını doğruladı.
F3 remote Site URL'yi exact final mobile callback olarak doğruladı. F3B gerçek inbox
SMTP teslimatı, server-side confirmation, final callback email contract'ı ve customer
role/profile davranışını PASS doğruladı; F3D cleanup Production Auth/business/Storage
zero baseline'ını geri kurdu. Confirmation e-postasının Spam'e düşmesi Auth failure
değildir; deliverability tuning açık follow-up'tır. B6 actual mobile app opening ve
full recovery lifecycle'ı PASS tamamladı; B7 legacy allowlist removal ve Auth config
postflight PASS'tir. Kalan release kapıları nedeniyle bu kanıt tek başına deploy veya
commercial release GO vermez.

## Wave 11 Phase B7 remote Auth callback postflight

Authenticated Supabase Dashboard fresh pre-write gate exact Production
`EsnaftaVar Production` / `mefhfvrgkwciubeajjeb` için Site URL'nin final callback,
allowlist'in final+legacy iki exact URI, Custom SMTP'nin Enabled ve Confirm Email'in
Enabled olduğunu doğruladı. Owner-authorized tek config write yalnız
`io.supabase.tstore://login-callback/` kaydını kaldırdı.

Fresh reload/postflight allowlist'in yalnız
`com.esnaftavar.app://login-callback/` değerini içerdiğini; Site URL, Custom SMTP ve
Confirm Email'in değişmediğini doğruladı. Development remote'a erişilmedi ve kaynak
Development callback'i `io.supabase.tstore://login-callback/` olarak korunur. User,
e-posta, database, Storage, migration veya başka Auth config write yapılmadı.

Callback, deep-link/platform, Production/Development isolation, Supabase config ve
release-preflight hedefli yerel matris 45/45 PASS'tir.

## Wave 10 Phase E1 real runtime evidence

Authenticated Supabase CLI, exact `EsnaftaVar Production` /
`mefhfvrgkwciubeajjeb` için client-safe publishable key bulunduğunu doğruladı. CLI
`--reveal` kullanmadı; publishable key yalnız test/build süreç belleğinde kullanıldı,
değeri source, manifest, belge veya loga yazılmadı. Service-role, `sb_secret_*` veya
server credential kullanılmadı.

Opt-in [`production_readonly_integration_test.dart`](../test/live/production_readonly_integration_test.dart)
şunları gerçek Production runtime değerleriyle PASS doğruladı:

- `main_production.dart` üzerinden `AppEnvironment.production` seçimi ve exact
  ref-host; Development namespace/fallback yok;
- anonymous Auth client initialize; current user/session yok;
- `categories`, `products`, `shops`, `banners` read istekleri başarılı ve boş;
- exact üç active bucket için client-visible liste boş, public URL host/path contract'ı
  doğru ve non-existent object GET güvenli not-found;
- database/Auth/Storage mutation yok.

Standart Web release compile/build, gerçek Production URL ve publishable key runtime
injection ile `lib/main_production.dart` target'ında, `--no-tree-shake-icons`
kullanılmadan PASS oldu. Credential taşıyan geçici artifact izole temp dizininde
üretildi, hash/shape doğrulamasından sonra kaldırıldı. Bu E1 build kanıtı, remote Auth
Site URL/redirect kararı manifestte henüz tamamlanmadığı için deploy edilebilir final
release artifact'ı veya full Production smoke değildir. Fail-closed structural release
preflight gereksinimleri değiştirilmedi.

Phase E final integration aynı gerçek runtime Web build'ini standart tree-shaking ile
yeniden PASS doğruladı. Exact Production endpoint ve publishable runtime injection
artifact içinde doğrulandı; gerçek server-side API key değerleri bulunmadı. Geçici
config ve artifact doğrulama sonrasında yeniden tamamen silindi.

## Release manifest sözleşmesi

Gerçek değerler repo içine yazılmaz. Güvenli CI/release store'dan alınan, repo dışındaki
bir JSON dosyası aşağıdaki altı alanı taşımalıdır:

| Alan | Kullanım | Kural |
| --- | --- | --- |
| `SUPABASE_PRODUCTION_URL` | Flutter Dart define | Exact `https://<PRODUCTION_PROJECT_REF>.supabase.co`; root URL |
| `SUPABASE_PRODUCTION_ANON_KEY` | Flutter Dart define | Client-safe `sb_publishable_…` veya role=`anon` legacy JWT |
| `PRODUCTION_PROJECT_REF` | Preflight evidence | 20 karakter lowercase Supabase ref; Development ref olamaz |
| `PRODUCTION_AUTH_SITE_URL` | Auth release gate | Canonical Production HTTPS web origin root |
| `PRODUCTION_AUTH_WEB_REDIRECT_URL` | Auth allowlist gate | Aynı origin üzerinde `/?auth_action=password_recovery` |
| `PRODUCTION_AUTH_MOBILE_CALLBACK_URL` | Auth allowlist gate | Exact `com.esnaftavar.app://login-callback/` |

[`tool/production_release_config.example.json`](../tool/production_release_config.example.json)
yalnız shape template'idir ve placeholder içerdiği için bilerek FAIL olur. `.env.example`
de yalnız client-safe Development/Production URL-key adlarını içerir; uygulama asset'i
değildir.

## Fail-closed kontroller

Preflight ve startup validator şu durumları reddeder:

- eksik URL, key, project ref veya Auth redirect kararı;
- malformed, HTTP, localhost/loopback URL;
- `example`, `dummy`, `placeholder`, `your-*`, `replace_me` veya `changeme` değeri;
- bilinen Development ref `tnipyxnvhgelwdpykyez`;
- URL host ile beyan edilen Production project ref uyuşmazlığı;
- `sb_secret_`, service-role veya anon dışı JWT role;
- geçersiz/kısa publishable key biçimi;
- Development namespace ya da allowlist dışı manifest alanı;
- `main_production.dart` dışındaki build target'ı;
- Site URL ile web recovery redirect origin/path/query uyuşmazlığı;
- yanlış mobile callback;
- compile-contract fixture'ının release modunda kullanılması.

Hata mesajları yalnız alan ve kural adını içerir; URL/key/ref değerini yazdırmaz.

## Güvenli operator workflow

Komutlar repo kökünde çalıştırılır. `<secure-config-path>` release sistemi tarafından
okunabilen, repo ve build artifact'ı dışında kalan bir konumdur.

### 1. Config injection

Template shape'i güvenli release store'da gerçek client-safe değerlerle doldur. Server
key, database password, JWT signing secret, SMTP credential veya mobile signing değeri
bu dosyaya girmez. Dosya commit edilmez ve terminal çıktısına basılmaz.

### 2. Preflight

```powershell
dart run tool/production_release_preflight.dart `
  --mode=release `
  --config=<secure-config-path>/production-release.json `
  --target=lib/main_production.dart
```

Beklenen çıktı `PASS (STRUCTURAL_RELEASE)` ve remote verification gereksinimidir.
Herhangi bir FAIL'de build/deployment durur. Aynı manifest path'i build adımında
değiştirilmeden kullanılır.

### 3. Standart Web release build

```powershell
flutter build web --release `
  -t lib/main_production.dart `
  --dart-define-from-file=<secure-config-path>/production-release.json
```

`--no-tree-shake-icons` kullanılmaz. Android/iOS identity ve signing bu config
sözleşmesinin dışındadır; `MOBILE_RELEASE_IDENTITY_SIGNING.md` ve release owner
kapılarıyla yönetilir.

### 4. Artifact identification

- Web artifact: `build/web/`
- Commit, app version/build number, platform ve build zamanı release kaydına eklenir.
- Artifact dosyaları için deterministik hash manifesti üretilip release kaydında
  saklanır; gerçek config dosyası artifact paketine eklenmez.
- Secret scan ve Production endpoint/ref attestation PASS olmadan yayınlanmaz.

### 5. Smoke gate

Artifact, migration/RLS/RPC/Storage/Realtime postflight ve Auth/SMTP kapıları PASS
olduktan sonra `PRODUCTION_SMOKE_CHECKLIST.md` ile kontrollü smoke'a alınır. Preflight
ve compile başarısı startup, Auth veya Production smoke PASS değildir.

## Compile-contract ile gerçek release ayrımı

Repo içindeki [`tool/production_compile_contract.json`](../tool/production_compile_contract.json)
yalnız sentetik compile kanıtıdır:

```powershell
dart run tool/production_release_preflight.dart `
  --mode=contract `
  --config=tool/production_compile_contract.json `
  --target=lib/main_production.dart

flutter build web --release `
  -t lib/main_production.dart `
  --dart-define-from-file=tool/production_compile_contract.json
```

Contract modu yalnız repo içindeki exact sentetik fixture'ı kabul eder ve
`Deployment authorization: NO` üretir. Release modu fixture marker'larını reddeder.
Bu artifact dağıtılamaz ve backend'e bağlanarak test edilmez.

## Auth redirect bağımlılıkları

Preflight yalnız karar manifestinin uygulama koduyla tutarlı olduğunu doğrular; remote
Supabase Auth ayarını değiştirmez veya okumaz. Release sahibi Dashboard/Management API
kanıtıyla şunları ayrıca doğrulamalıdır:

1. Güncel mobile-first Production Site URL exact final callback'tir:
   `com.esnaftavar.app://login-callback/`; localhost/Development değildir.
2. Web artifact release kapsamına alınırsa ayrıca owner-onaylı canonical HTTPS origin
   ve exact web recovery URL'si gerekir:
   `https://<production-origin>/?auth_action=password_recovery`.
3. Mobile callback allowlist uygulama kaydıyla eşleşir:
   `com.esnaftavar.app://login-callback/`. Password recovery'nin ürettiği aynı callback
   üzerindeki `?auth_action=password_recovery` dönüşü de kabul edilmelidir.
4. Production'da geniş Development wildcard'ı kullanılmaz; exact Production path
   tercih edilir.
5. Legacy `io.supabase.tstore://login-callback/` Production allowlist kaydı B7'de
   kaldırıldı; Production allowlist yalnız final callback'i içerir. Aynı URI'nin
   Development kaynak sözleşmesinde bulunması Production remote config'ine geri
   eklendiği anlamına gelmez. Development remote config'i bu operasyona dahil değildir.
6. Email confirmation, custom SMTP, recovery template ve gerçek inbox kabulü ayrıca
   test edilir.

Mobile Site URL kararı remote'da final callback'e geçirilmiştir. Web release için
canonical HTTPS origin/route kararı yoksa yalnız web Auth gate'i **BLOCKED** kalır.

## Değer içermeyen PASS / FAIL örnekleri

| Senaryo | Sonuç |
| --- | --- |
| Doğru target + exact ref/URL + client-safe key + uyumlu Auth kararları | `PASS (STRUCTURAL_RELEASE)` |
| Canonical sentetik fixture + `--mode=contract` | `PASS (COMPILE_CONTRACT_ONLY)`; deploy NO |
| Missing URL/key | FAIL |
| Development ref, localhost veya placeholder/example/dummy | FAIL |
| Malformed URL veya ref-host mismatch | FAIL |
| `sb_secret_` / service-role credential | FAIL |
| Development entrypoint | FAIL |
| Auth Site URL/redirect/mobile callback mismatch | FAIL |
| Compile fixture + `--mode=release` | FAIL |

## Kalan zorunlu release kapıları

- Production ref/URL doğrulandı; client-safe key güvenli release kanalından sağlanmalı
  ve değer sohbet/repo/log içine yazılmadan doğrulanmalıdır.
- Mobile Site URL ve final callback remote'da hizalıdır. Web release kapsamındaysa
  canonical HTTPS origin/recovery route ve allowlist kararı ayrıca verilmelidir.
- Production Custom SMTP, gerçek inbox delivery, server-side confirmation ve B6 full
  mobile recovery lifecycle PASS'tir. Email deliverability/spam tuning izlenir.
- Android/iOS identifier kararı ve platform wiring `com.esnaftavar.app` ile
  tamamlandı. Android upload signing, birincil keystore yedeği ve ilk signed APK/AAB
  PASS; fiziksel Android kabulü, Play Console/Play App Signing, kalıcı CI provenance
  ve Apple Distribution signing materyali hâlâ açıktır.
- Final callback kaynak cutover, email URL contract'ı, actual signed-app opening ve
  legacy Production callback removal tamamlandı; Auth config postflight PASS'tir.
- Production canonical migration ve metadata/security postflight PASS'tir; Auth/client
  wiring sonrasında kontrollü Production smoke ayrıca PASS olmalıdır.
- Fiziksel iki-cihaz QR, fixture tabanlı Storage negative listing kabulü, controlled
  Production write smoke, signed Android artifact'ın fiziksel kabulü ve signed IPA
  henüz tamamlanmadı.

Bu kapılar kapanmadan gerçek release artifact'ı için GO verilmez.
