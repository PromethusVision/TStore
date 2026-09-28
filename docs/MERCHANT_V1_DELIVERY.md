# Merchant V1 yerel çekirdek teslimi

Tarih: 2026-09-29. Dal: `agent/merchant-v1`.
Başlangıç: `origin/main@79fc1adc9ef48ef12607cf4cac7fd7d4db6d5463`.

## Sonuç

Merchant V1'in mevcut backend sözleşmesiyle çalışabilen yerel çekirdeği,
ayrı uygulama kabuğu, ekranları ve gerçek Supabase adaptörü hazırdır.
Sentetik önizleme backend'e bağlanmadan incelenebilir. Bu teslim Production'a
bağlı uygulama, signed release, gerçek push veya fiziksel QR E2E tamamlandı
anlamına gelmez.

- Merchant auth/rol/exact-owner erişim kapısı ve onaylı esnaf mağaza kurulumu.
- Mağaza özeti, profil/iletişim/saatler yönetimi.
- Ortak katalogdan ürün ekleme, esnaf açıklaması/fiyat/bulunabilirlik düzenleme.
- Ürün pasife alma ve yeniden aktifleştirme; tarihsel listing kimliği korunur.
- Sayfalama, ürün arama, boş/hata/yükleniyor/başarı ve tekrar deneme durumları.
- Mevcut QR repository/usecase/cubit üzerinden exact-shop tarama/onay ekranı.
- Mevcut NotificationRepository/NotificationsCubit/Realtime ve yerel tercih ekranı.
- Hesap yüzeyi, güvenli çıkış ve gelecekte ortak PushCoordinator disable bağlantısı.
- Ayrı Android geliştirme varyantı ve ağsız sentetik önizleme.

## Doğrulama kanıtı

| Kontrol | Sonuç |
|---|---|
| Merchant unit + widget | **39 PASS** |
| Nihai tam Flutter suite | **2282 PASS / 0 FAIL / mevcut 6 koşullu skip** |
| flutter analyze --no-pub | **No issues found** |
| Android merchantDevelopment debug build | **PASS** |
| Web preview build + Wasm dry run | **PASS** |
| 320/390/430 px, %130 metin; dört golden | **PASS**, görseller incelendi |
| Tarayıcı ürün listesi → düzenleme → fiyat/bulunabilirlik kaydı | **PASS**, sentetik veri |
| Tarayıcı warning/error log | **0** |
| Diff whitespace / yeni dosyalarda privileged-key taraması | **PASS** |

Testler; rol reddi, askıya alınmış mağaza, yabancı mağaza/ürün kimliği, oturum
değişimi, geciken yanıt, çift login/submit, stale update, duplicate insert,
sayfalama, güvenli hata, onaylı onboarding, sistem geri tuşu, resume, bildirim
okundu durumu, QR shop mismatch ve tekrar onay korumasını kapsar.

İlk Android derlemesi Windows C:/E: Kotlin incremental cache uyarılarından sonra
başarıyla tamamlandı. Nihai derlemede yalnız işlem ortamında
`ORG_GRADLE_PROJECT_kotlin.incremental=false` kullanıldı; Gradle/dependency
dosyalarına bu ayar eklenmedi. Nihai Android log temiz ve build başarılıdır.

## Yerel artifact

- APK: `build/app/outputs/flutter-apk/app-merchantdevelopment-debug.apk`
- Paket: `com.esnaftavar.app.merchant.dev`
- Etiket: `EsnaftaVar Esnaf Dev`
- Tür: debug / sentetik önizleme / 1.0.0+5 / 206685321 byte
- SHA-256: `1D51B740DFE2B1FD9F332AC4CDE69BA2A1B695A71038685ACA7430E7BDC6DD3B`
- Web: `build/web`; bu oturumdaki yerel önizleme `http://127.0.0.1:8777`.
- Görseller: `test/widget/merchant/goldens/`.

## Korunan sınırlar ve açık işler

Customer Dart/UI/runtime, ortak DI/theme/navigation, pubspec/lockfile ve Supabase
migration/proposal dosyalarında değişiklik yoktur. Ortak/çakışma alanı yalnız
`android/app/build.gradle`: additive Merchant development flavor ve Merchant
release engeli. Customer flavor kimlikleri ve release kuralları korunmuştur.

Remote backend erişimi, Production write/apply, credential işlemi, main merge,
mağaza rolü verme, fiziksel iki cihaz testi ve provider kurulumu yapılmadı.
Migration gerekmedi; mevcut güvenlik izinleri genişletilmedi.

Mevcut backend'in sunmadığı başvuru/onay kuyruğu, master ürün yayınlama,
adet/UNKNOWN/TEMP stok sözleşmesi ve merchant hesap silme ayrı öneriler olarak
mimari envanterde açıklanmıştır. Bunlar çalışır özellik gibi gösterilmez.

Final Merchant callback/recovery/release ve gerçek push kurulumu ayrı entegrasyon
işidir. Reviews/ratings/badges/reward/reputation/advanced ads ve final Trust &
Engagement kapsamı eklenmemiştir. QR'ın gerçek iki cihazlı fiziksel kabulü
kullanıcının belirlediği sonraki faza bırakılmıştır.

Mimari/ekran envanteri: `MERCHANT_V1_ARCHITECTURE.md`.
Çalıştırma ve entegrasyon rehberi: `MERCHANT_V1_LOCAL_GUIDE.md`.

## MERCHANT V1 LOCAL CORE — Integration doğrulaması

2026-09-29; `integration/merchant-v1-local-core`.
Başlangıç main: `79fc1adc9ef48ef12607cf4cac7fd7d4db6d5463`.
Kaynak: `647fec168d609df642445aae400223311302e1c0` (`agent/merchant-v1`).
Kaynak doğrudan bu main'in tek commit ilerisindedir: ahead 1 / behind 0.
`--no-ff` birleşim adayı çakışmasızdır. Yukarıdaki teslim ve artifact kaydı
kaynak agent'ın çalışmasına aittir; aşağıdaki kontroller Integration tarafından
birleşim adayında ayrıca çalıştırılmıştır.

Ürün sahibinin mevcut Merchant V1 görsel yönü kabulü korunmuştur. Yeniden tasarım
yapılmadı. K'pasa zorunlu bir yeniden tasarım kaynağı değildir.

| Integration kontrolü | Sonuç |
|---|---|
| Merchant unit/widget testleri | **39 PASS / 0 FAIL** |
| Tam Flutter suite | **2282 PASS / 0 FAIL / mevcut 6 SKIP** |
| Skip karşılaştırması | Önceki Customer +5 koşullu testleriyle adları aynı; yeni skip yok |
| `flutter analyze --no-pub` | **PASS**, sorun yok |
| Merchant preview Android debug derlemesi | **PASS**, `merchantDevelopment` |
| Web preview derlemesi ve Wasm dry run | **PASS** |
| 320/390/430 px ve %130 metin düzeni | **PASS**, tüm sekmeler widget testinden geçti |
| Dört mevcut Merchant golden | **PASS**, yeniden üretilmeden eşleşti ve görseller incelendi |
| Merchant release yasağı | **PASS**, offline Gradle dry-run beklenen nedenle reddedildi |
| Merchant flavor / yanlış Customer giriş noktası | **PASS**, offline Gradle dry-run beklenen nedenle reddedildi |
| Customer mevcut Gradle kuralları | Merchant'a ait 27 ek satır dışında birebir aynı |
| `git diff --check` | **PASS** |
| Gelen 28 dosyada secret/PII ve PNG metadata taraması | **PASS**, yalnız `.invalid` sentetik e-posta eşleşmeleri |

Android debug çıktısının paket kimliği `com.esnaftavar.app.merchant.dev`,
etiketi `EsnaftaVar Esnaf Dev`, sürümü `1.0.0+5`; ABI'ları
`arm64-v8a`, `armeabi-v7a`, `x86_64` olarak ayrıca okundu.
Integration debug APK SHA-256:
`489c651db0c9df9c59383f7b43ac244831fbb4c59f2f6056dcff552a4950feb5`.
Bu sentetik yerel debug çıktısı signed Merchant release değildir ve git'e
eklenmez. Kotlin incremental ayarı yalnız derleme işleminin ortamında kapatıldı.

Rol/exact-owner denetimi, askıya alınmış mağazanın reddi, ortak ürün kimliğine
yazılmaması, soft-deactivate/boolean bulunabilirlik, güncelleme zamanı çakışma
kontrolü ve başarısız yazmada hata dönüşü incelendi; ilgili regresyon testleri
geçti. QR sunucu sözleşmesi ve ortak bildirim altyapısı yeniden kullanılıyor.
Gerçek adaptörün başlangıç ayarı yalnız loopback backend kabul ediyor;
sentetik önizleme uzaktaki bir backend'e bağlanmıyor.

Customer Dart/UI/runtime, navigation, DI, taxonomy, müşteri QR davranışı,
pubspec/lockfile, migration/proposal ve mevcut release/signing kaynakları
değişmedi. Tek ortak kaynak eklemesi yukarıda incelenen Gradle alanıdır.
Customer +5'in dondurulmuş dosyaları salt okunur olarak yeniden hash'lendi:

- APK: `4c49f9ee2d619c12a8ff53dbc93174acf8f5eb1e59fbe7f54d117cfb0e20c5b1` — aynı.
- AAB: `95b14f301a5a628971f9ad7725c59c1cc3ee5e5c963b35bd1cbc9057ad0778da` — aynı.

Customer signed artifact yeniden oluşturulmadı. Production'a erişilmedi veya
yazılmadı; mevcut public canonical ON kaydı değiştirilmedi. Backend/migration
uygulanmadı. Integration'da cihaz kurulumu veya fiziksel QR kabulü yapılmadı.

`MERCHANT_UI_DIRECTION_ACCEPTED=YES`, `CUSTOMER_V1_CHANGED=NO`,
`QR_TWO_DEVICE_PHYSICAL_GATE=OPEN`, `TRUST_ENGAGEMENT=DEFERRED`,
`FIREBASE_APNS=PENDING`, `PRODUCTION_ACCESSED=NO`,
`PRODUCTION_WRITE_PERFORMED=NO`.
Yerel çekirdek Merchant release hazırlığına hazırdır; fiziksel QR, callback,
signed release, canlı provider ve nihai Trust & Engagement işleri açık kalır.
