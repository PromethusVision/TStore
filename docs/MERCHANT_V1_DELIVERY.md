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
