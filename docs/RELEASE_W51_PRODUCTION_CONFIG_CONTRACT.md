# W51A — Yerel Production yapılandırma sözleşmesi

Tarih: 2026-09-05. **Yerel sözleşme tanımlı; gerçek onaylı client key girdisi eksik.**
Owner bu görevde ref/URL ve `lib/main_production.dart` entrypoint'ini doğruladı.
Production'a bağlanılmadı; aşağıdaki remote alanlar geçmiş kanıttan güncel PASS sayılmaz.

## Alan sınıflandırması

| Alan / davranış | Yerel sözleşme | Sınıf |
|---|---|---|
| Android app id / namespace | `com.esnaftavar.app` | APPROVED_STATIC |
| Label | `EsnaftaVar` | APPROVED_STATIC |
| versionName / versionCode | `1.0.0` / `1`; bu yerel aday için mevcut değer korunur | APPROVED_STATIC |
| Build target / flavor / mode | `lib/main_production.dart` / `production` / `release` | APPROVED_STATIC |
| `SUPABASE_PRODUCTION_URL` | `https://mefhfvrgkwciubeajjeb.supabase.co` | APPROVED_STATIC |
| `PRODUCTION_PROJECT_REF` | `mefhfvrgkwciubeajjeb` | APPROVED_STATIC |
| `SUPABASE_PRODUCTION_ANON_KEY` — seçim | Bu Production projesine ait owner tarafından onaylanan güncel client-safe anahtar; henüz verilmedi | NEEDS_OWNER_APPROVAL |
| Aynı alan — saklama/taşıma | Dış JSON'dan injection; gerçek değer source control/log dışında | SECRET_EXTERNAL |
| Aynı alan — uzak geçerlilik | Anahtarın beklenen projeye ait/aktif olduğunun sonraki doğrulaması | NEEDS_REMOTE_READONLY_PROOF |
| `PRODUCTION_AUTH_SITE_URL` — beklenen değer | `com.esnaftavar.app://login-callback/`; owner-final Android pilot sözleşmesi | APPROVED_STATIC |
| `PRODUCTION_AUTH_MOBILE_CALLBACK_URL` | `com.esnaftavar.app://login-callback/` | APPROVED_STATIC |
| `PRODUCTION_AUTH_WEB_REDIRECT_URL` | Alan mevcut, değer boş; Android pilot için hosted web dönüşü yok | APPROVED_STATIC |
| Remote Site URL / redirect allowlist | Beklenen mobile callback; Development/legacy callback kabul edilmemeli | NEEDS_REMOTE_READONLY_PROOF |
| Auth/SMTP ve erişim politikalarının güncel durumu | Yalnız ayrıca yetkili sonraki read-only kapsamda doğrulanır | NEEDS_REMOTE_READONLY_PROOF |
| Signing parolaları / özel key | Dış properties ve mevcut dış JKS; Dart config'e girmez | SECRET_EXTERNAL |
| Signing public fingerprint | Mevcut upload sertifikası pin'i; signing proof belgesinde | APPROVED_STATIC |
| Canonical taxonomy runtime | Production bootstrap açıkça `legacy(production)` | APPROVED_STATIC |
| Development canonical opt-in | Production entrypoint tüketmez; Development varsayılanı false | APPROVED_STATIC |
| Canonical preview / capability activation | OFF; Production bootstrap tarafından seçilmez | APPROVED_STATIC |
| Reward runtime / reward economics | OFF; Home default false, progress/action yok | APPROVED_STATIC |
| Home/Product Details deneysel görünüm | OFF | APPROVED_STATIC |
| Cart/Nearby/Shop `visualPrototype=true` | Tarihsel isimli, gerçek veri kullanan onaylı Final UI seçicisi; fixture modu değildir | APPROVED_STATIC |
| Prototype fixture/demo/test endpoint | Aktif Customer veri yolu için NONE; test manifest flag'leri reddedilir | APPROVED_STATIC |
| Shared Logger | Release'te `Level.off` | APPROVED_STATIC |
| Supabase Flutter debug stdout | Bağlı SDK'da varsayılan `debug ?? kDebugMode`; release'te false | APPROVED_STATIC |
| Realtime `logLevel: info` | Sunucu bağlantı seviyesi parametresi; özel client logger verilmemiş; verbose çıktı etkinleştirmez | APPROVED_STATIC |
| PKCE / callback handler | PKCE, `detectSessionInUri: false`, tek app-owned doğrulama; Android framework deep-link handler kapalı | APPROVED_STATIC |
| Network/backup | HTTPS, cleartext false, backup ve persistent transfer hariç tutma | APPROVED_STATIC |

`SECRET_EXTERNAL` client key için operasyonel saklama sınıfıdır: publishable/anon
anahtar mobil client'a dağıtılabilir; server secret değildir. Buna rağmen gerçek
değer bu görevin talebi gereği repo/log'a yazılmaz. `sb_secret`, service_role, DB,
SMTP veya JWT signing secret mobil manifestte asla yer almaz.

## Somut yerel girdi

`tool/production_mobile_release_config.example.json` onaylı public ref/URL ve
mobile callback sözleşmesini taşır. Tek gerçek credential alanı güvenli placeholder
olarak bırakılır. Örnek **release preflight'ı geçmez**; hazır Production JSON gibi
sunulmaz. Gerçek JSON repo dışında hazırlanmalı ve yalnız şu altı string alanı
içermelidir: `SUPABASE_PRODUCTION_URL`, `SUPABASE_PRODUCTION_ANON_KEY`,
`PRODUCTION_PROJECT_REF`, `PRODUCTION_AUTH_SITE_URL`,
`PRODUCTION_AUTH_WEB_REDIRECT_URL`, `PRODUCTION_AUTH_MOBILE_CALLBACK_URL`.

Repo kökünden, onaylı dış JSON sağlandıktan sonra:

```text
dart run tool/production_release_preflight.dart --mode=release --config=<absolute-external-json-path> --target=lib/main_production.dart
```

Preflight yereldir; ağ çağrısı yapmaz. Eksik/ek alanları, Development/local URL'yi,
server credential'ı, placeholder'ı, compile fixture'ı, ref/URL uyuşmazlığını ve
callback sapmasını reddeder. Genel preflight başka yapısal olarak geçerli ref için
owner kararı vermez; RC operatörü bu tabloda sabitlenmiş exact ref/URL'yi ayrıca
eşleştirir. Client key biçiminin geçmesi uzak key/proje eşleşmesi kanıtı değildir.

Production entrypoint `.env` veya Development adlarına fallback yapmaz. Owner'ın
eski JSON yolunu hatırlamaması üzerine yalnız uygulamaya ait yerel dizinler ve
canonical CLEAN config dosya adları incelendi; onaylı güncel JSON bulunmadı.
Eski APK'dan key çıkarılıp güncel onaylı anahtar olarak kullanılmadı.

## Fixture ve artifact sınırı

Aktif Customer runtime fixture kaynağı kullanmıyor. W50 missing-media düzeltmesi
korunuyor. Mevcut `pubspec.yaml` hâlâ tarihsel `assets/images/products`, `banners`,
`reviews` gibi statik görsel dizinlerini paket kapsamına alıyor; bunların her biri
gerçek müşteri verisi değildir. **Runtime fixture sızıntısının olmaması, bütün
kullanılmayan örnek görsellerin binary'den çıkarıldığı anlamına gelmez.** Bu görev
UI/asset kapsamını değiştirmedi. Yeni signed artifact bulunmadığından binary'de
Development config ve fixture/asset yokluğu kanıtı `NOT_PROVEN` olarak kalır.

## Sonraki yerel aday üretiminin ön şartları

1. Mevcut özel key ile `verifyReleaseSigning` PASS.
2. Owner onaylı dış client JSON, exact ref/URL eşleşmesi ve release preflight PASS.
3. Aynı JSON ile production flavor/entrypoint APK ve gerekiyorsa AAB üretimi;
   kaynak SHA, boyut, hash, package/version/ABI, certificate ve binary leakage kanıtı.

APK `build/app/outputs/flutter-apk/app-production-release.apk`, AAB
`build/app/outputs/bundle/productionRelease/app-production-release.aab` beklenen
çıkışlardır. Mevcut eski dosyalar yeni aday sayılmaz. Bu görevde imza ön şartı
tamamlanmadığı için üretim yapılmadı. Build, install/launch veya uzak Production
doğrulaması yerine geçmez; W51A cihaz kurulumu ve store publish içermez.
