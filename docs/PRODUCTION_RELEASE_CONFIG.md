# Production Release Configuration

**Kaynak taban:** `origin/main@b793aeab5174733d329df7743d86e73b0c68eced`

**Production Supabase erişimi/yazması:** YOK

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

- Gerçek Production ref/URL/key güvenli kanaldan sağlanmalı ve iki bağımsız kaynakla
  doğrulanmalı.
- Canonical Site URL, web origin ve redirect allowlist kararı verilmelidir.
- Remote Auth/SMTP config ve gerçek inbox acceptance tamamlanmalıdır.
- Android/iOS identity/signing Agent 2/release owner tarafından kapatılmalıdır.
- Wave 8 cutover planı ile Production migration/postflight ve tam smoke PASS olmalıdır.

Bu kapılar kapanmadan gerçek release artifact'ı için GO verilmez.
