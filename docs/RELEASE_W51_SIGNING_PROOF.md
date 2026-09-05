# W51A — Signing kanıtı

Tarih: 2026-09-05. **Sertifika kimliği okunabildi; mevcut özel anahtarla imzalama kanıtı tamamlanamadı.**

| Açık metadata | Yerel gözlem |
|---|---|
| Keystore tipi | JKS; bir `PrivateKeyEntry`, chain length 1 |
| Alias | `esnaftavar-upload` |
| Subject / issuer | `CN=EsnaftaVar Upload Key, OU=Mobile, O=EsnaftaVar, L=Istanbul, C=TR` |
| Public key | RSA 4096 bit |
| Sertifika imza algoritması | SHA256withRSA |
| Geçerlilik (UTC) | 2026-08-18 01:08:21 → 2054-01-03 01:08:21 |
| SHA-256 | `3B:83:D9:8A:B8:D3:2E:0F:3B:99:30:FA:83:76:36:E0:E9:E1:32:19:78:4F:FC:A3:9C:EF:8C:AE:82:A6:66:9B` |
| Tarihsel operasyonel SHA-1 | `3E:D8:D3:C5:FF:1E:9E:6E:B2:D1:B5:74:22:34:B6:C9:D6:E0:92:F3` |

JDK keytool ile parola verilmeden yalnız açık metadata okundu. Keytool'un
**keystore integrity NOT verified** uyarısı korunur: bu işlem store parolasını,
key parolasını veya özel anahtarla imzalama yeteneğini kanıtlamaz. Özel anahtar
dışarı çıkarılmadı. JKS biçim uyarısı nedeniyle format değiştirilmedi veya key rotate edilmedi.

Fingerprint [önceki upload kimliği](MOBILE_RELEASE_IDENTITY_SIGNING.md) ile aynı.
Repo dışında korunmuş 2026-08-23 APK'nın SHA-256'sı da tarihsel
`47650AB049F8212DB05EEFE382689B8EB3321C1799AAE8C797C125D63CA534DA` değeridir.
Bu eski APK, W51A kaynaklarının veya yeni imzalama yeteneğinin kanıtı değildir.

## Paketleme öncesi yeni yerel kontrol

`android/release-signing.gradle` dış girdinin tamamlığını doğrular, store'u parola
ile açar, alias özel anahtarını key parolasıyla çözer, sertifika geçerliliğini ve
mevcut owner SHA-256 pin'ini kontrol eder. Bellekte rastgele challenge imzalanıp
aynı sertifikayla doğrulanmadan APK/AAB paketleme başlayamaz. Pin için env override
yoktur; olası gelecek key rotation ayrı açık owner değişikliği gerektirir.

Mevcut ortamda `:app:verifyReleaseSigning` beklenen şekilde
`external signing properties path is missing` ile durdu. Gerçek parolalar bulunmadı.
Negatif regresyon, geçerli fakat farklı sentetik/debug kimliğini de reddeder;
test anahtarı geçici dış dizinde oluşturulup kaldırılır, uygulama imzalamaz.

`PUBLIC_CERTIFICATE_METADATA: PASS`

`CURRENT_KEYSTORE_INTEGRITY_PROVEN: NO`

`CURRENT_PRIVATE_KEY_SIGNING_PROVEN: NO`

`SIGNING_BLOCKER_CLOSED: NO`

W51A yeni APK/AAB oluşturmadı. Artifact yolu, boyutu, SHA-256'sı, package/version,
ABI ve artifact signer alanları **NOT_GENERATED**; eski dosyalar aday yerine kullanılmaz.
Owner parolaları güvenli dış properties kaydına yeniden bağlandığında aynı doğrulama
çalıştırılır; başarılı olana kadar paket üretimi durur.
