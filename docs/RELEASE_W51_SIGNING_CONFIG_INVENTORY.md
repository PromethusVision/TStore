# W51A — Yerel Android signing envanteri

Tarih: 2026-09-05. Base: `8f8847bcdef610f40992f87dad03a9bc2a99a391`.
Branch: `astra-release/w51a-rc-signing-config-readiness`.
Production erişimi, cihaz kurulumu ve store upload bu görevin dışında.

| Alan | İncelenen başlangıç | W51A son sözleşmesi |
|---|---|---|
| Release signingConfig | Hazırsa `signingConfigs.release`, değilse `null` | Korundu; paketlemeden önce kriptografik kanıt zorunlu |
| Properties kaynağı | `android/key.properties`; iki checkout'ta da yok | `ESNAFTAVAR_SIGNING_PROPERTIES` yalnız mutlak repo-dışı dosya yolu taşır |
| Keystore | Repo dışındaki mevcut upload JKS bulundu | Properties içindeki `storeFile`; mutlak ve bütün Git checkout'larının dışında |
| Alias | Eski geçici properties kaldırılmış | Dış properties içindeki `keyAlias` |
| Parolalar | Parola yöneticisi tarihsel kaydı; yerel dosya bulunamadı | Dış properties içindeki `storePassword` ve `keyPassword`; konsola verilmez |
| Debug fallback | Otomatik debug fallback yoktu | Yok; ayrıca başka/debug sertifikası owner fingerprint pin'iyle reddedilir |
| Eksik/bozuk ayar | Release paketleme durur; compile-only mümkün | Korundu; geçersiz dış yol için eski repo-içi dosyaya dönüş yok |
| Sertifika/özel anahtar | Paketleme öncesi açık kanıt görevi yoktu | `:app:verifyReleaseSigning`; bütünlük, parola, geçerlilik, fingerprint ve imzala/doğrula challenge |

## Yerel gözlem sınırı

- Mevcut keystore: `C:\Users\Mustafa\AppData\Local\EsnaftaVar\signing\esnaftavar-upload.jks`, 3.914 byte; değiştirilmedi.
- Aynı `EsnaftaVar` dizinindeki `build-secrets` boş. Signing dizininde yalnız JKS var.
- `EsnaftavarReleases` ve bu iki uygulamaya ait yerel dizinde ilgili JSON/properties/DPAPI/CLIXML girdisi yok.
- Canonical CLEAN repo'da isim odaklı config taraması yalnız güvenli örnekleri ve sentetik compile sözleşmesini buldu; gerçek signing properties veya Production release JSON bulunmadı.
- İlgili process environment değişken adlarında signing/Production girdi yok. Değerler yazdırılmadı.
- Canonical `.env` yalnız eski `SUPABASE_URL` / `SUPABASE_ANON_KEY` alanlarını taşıyor; namespaced Production manifesti değil. Değerleri çıktılanmadı veya Production girdisi olarak kullanılmadı.
- Owner, mevcut keystore yolunu doğruladı; parola properties ve eski Production JSON yolunu henüz bulamadığını bildirdi. Parola yöneticisine, başka uygulama credential depolarına veya korunan eski `TStore` repo'suna erişilmedi.
- Bu envanter makinede hiçbir yerde parola bulunmadığı iddiası değildir. İncelenen mevcut uygulama mekanizması imza için eksik.

## Güvenli yeniden bağlama

`android/key.properties.example` yalnız şablondur. Doldurulmuş kopyası örneğin
`%LOCALAPPDATA%\EsnaftaVar\build-secrets\release-signing.properties` altında,
repo dışında tutulur. Mevcut owner anahtarı ve parola yöneticisindeki değerler
kullanılır; yeni upload anahtarı üretilmez. Windows dosya yollarında `/` kullanılır.
Bu görev gerçek parola dosyası oluşturmadı.

Build process yalnız dış properties dosyasının yolunu
`ESNAFTAVAR_SIGNING_PROPERTIES` ile alır. Dosya/key yolu relatifse, bir Git checkout'ı
içindeyse, eksikse veya placeholder taşıyorsa release reddedilir. Var olan sembolik
bağlantılar gerçek yola çözülür. Dış dosyanın erişimi owner ve yetkili build hesabıyla
sınırlı tutulur. Parolalar komut satırına, Dart defines'a veya build log'una konmaz.

Repo kökünden, dış yol güvenli oturumda ayarlandıktan sonra:

```powershell
Push-Location android
.\gradlew.bat :app:verifyReleaseSigning --no-daemon --no-configuration-cache --console=plain
Pop-Location
```

Bu komut artifact üretmez. Başarılı sonuç yalnız açık SHA-256/geçerlilik bilgisi
yazar. Alt exception'lar değer veya yol sızdırmamak için log'a eklenmez.
Gerçek parolalı işlemlerde `--debug`, `--info`, build scan veya configuration cache
kullanılmaz. İmza task'ı, build başlatma yetkisi veya Production bağlantı yetkisi vermez.

## Ortak alan değişikliği kaydı

`SHARED_COMPONENT_CHANGE_REQUIRED: YES` — Android release configuration.
Exact files: `android/app/build.gradle`, yeni `android/release-signing.gradle`,
`android/key.properties.example`. Gerekçe: task'ın parolaları repo dışında tutma
şartını ve mevcut owner anahtarını paketlemeden önce doğrulama şartını bağlamak.
Consumers: Android Production/Development release paketleme; debug ve compile-only
korunur. Test: gerçek Gradle negatif matrisi, mevcut signing/platform testleri,
Android release compile/lint. Tek owner bu W51A branch'i; gözlenen collision `NONE`.
Global Flutter runtime, dependency sürümleri ve backend değiştirilmedi.
