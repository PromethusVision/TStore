# Production Release Configuration

**Kaynak taban:** Wave 10 Phase E final integration /
`origin/main@eda5759ff2b19ea02cb38db2d50d5df69f887685`

**Bu belge güncellemesinde Production Supabase erişimi:** Anonymous read-only **YES**;
remote write **NO**

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

`FINAL_AUTH_CALLBACK_CUTOVER_REQUIRED: YES`

`SIGNING_READY: NO`

`READY_FOR_PHASE_F_AUTH_EMAIL_CUTOVER: YES`

`COMMERCIAL_RELEASE_READY: NO`

Canonical Android application ID/namespace, Development `.dev` varyantı ve iOS
Runner/RunnerTests bundle identifier değerleri final `com.esnaftavar.app` kimliğine
bağlandı. Callback `io.supabase.tstore://login-callback/` bu aşamada bilinçli olarak
değiştirilmedi; Site URL, redirect allowlist, web recovery ve SMTP ile birlikte Phase F
atomik cutover kapısıdır. Gerçek Android/Apple signing materyali yoktur. Client wiring
ve kimlik wiring'in tamamlanması tek başına deploy veya commercial release GO vermez.

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
| `PRODUCTION_AUTH_MOBILE_CALLBACK_URL` | Auth allowlist gate | Exact `io.supabase.tstore://login-callback/` |

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

1. Site URL exact canonical Production HTTPS web originidir; localhost/preview/
   Development origin değildir.
2. Additional Redirect URLs allowlist exact web recovery URL'sini içerir:
   `https://<production-origin>/?auth_action=password_recovery`.
3. Mobile callback allowlist uygulama kaydıyla eşleşir:
   `io.supabase.tstore://login-callback/`. Password recovery'nin ürettiği aynı callback
   üzerindeki `?auth_action=password_recovery` dönüşü de kabul edilmelidir.
4. Production'da geniş Development wildcard'ı kullanılmaz; exact Production path
   tercih edilir.
5. Email confirmation, custom SMTP, recovery template ve gerçek inbox kabulü ayrıca
   test edilir.

Canonical Site URL/web origin henüz ürün-release sahibi tarafından belirlenmemişse veya
remote allowlist kanıtı yoksa Auth release gate **BLOCKED** kalır.

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
- Canonical Site URL, web origin ve redirect allowlist kararı verilmelidir.
- Remote Auth/SMTP config ve gerçek inbox acceptance tamamlanmalıdır.
- Android/iOS identifier kararı ve platform wiring `com.esnaftavar.app` ile
  tamamlandı; Android upload ve Apple Distribution signing materyali hâlâ açıktır.
- `FINAL_AUTH_CALLBACK_CUTOVER_REQUIRED`: Site URL, exact redirect allowlist, web
  recovery callback ve SMTP/e-posta kabulü Phase F'te birlikte kapatılmalıdır.
- Production canonical migration ve metadata/security postflight PASS'tir; Auth/client
  wiring sonrasında kontrollü Production smoke ayrıca PASS olmalıdır.
- Fiziksel iki-cihaz QR, fixture tabanlı Storage negative listing kabulü, controlled
  Production write smoke ve signed AAB/APK/IPA henüz tamamlanmadı.

Bu kapılar kapanmadan gerçek release artifact'ı için GO verilmez.
