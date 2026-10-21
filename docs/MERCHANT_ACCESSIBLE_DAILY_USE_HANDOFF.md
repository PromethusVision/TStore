# Merchant günlük kullanım ve büyük yazı teslimi

Başlangıç: `c5ceb548c96cdfe7cb435d58e68703b4c8f4f0cc`.
Dal: `agent/merchant-accessible-daily-use`. Tarih: 2026-10-22.

## Yeniden üretilen sorunlar ve çözüm

320 × 640dp, %200 yazı boyutunda önce dört başarısız kontrol yeniden üretildi:
fiyat doğrulama açıklaması kesiliyor, ürün ve mağaza formlarında ilk hatalı alan
görüş dışında kalıyor, kaydırma açık klavyeyi kapatmıyordu. Ardından iki uzun
alan adı, kategori adı ve iki arama etiketi için beş ayrı kesilme kontrolü
başarısız oldu; toplam dokuz başarısız assertion.
Yerel başlangıç kayıtları: `.buildlog/accessibility-baseline.log`,
`.buildlog/labels-baseline.log`, `.buildlog/category-baseline.log`,
`.buildlog/search-labels-baseline.log`.

Merchant sayfalarında hata açıklaması satıra yayılır. Giriş, parola kurtarma,
mağaza, ürün ve katalog başvurusu doğrulaması ilk hatalı alanı görünür kılar.
Bu işlem yalnız ekranı kaydırır; kaydı tekrar göndermez. Kapanmış veya başka
sayfanın altında kalmış forma ait ertelenmiş kaydırma çalışmaz.

Büyük yazıda mağaza/ürün/başvuru ve arama etiketleri kutunun üstüne alınır; tam etiket
erişilebilir girdi adı olarak korunur. Normal yazı boyutunda mevcut görünüm
korunur. Uzun kategori adları menüde ve seçildikten sonra kısaltılmaz.
Kaydırmayla klavye kapanır; fiyat/metin taslağı korunur.

İlk çok satırlı floating-label denemesi görsel incelemede kutu dışına taşıyordu;
teslim edilen uygulama bu yaklaşımı kullanmaz. Mevcut katalog testinde
`ensureVisible` sonrası layout beklemeden tıklanıyordu. Bir `pumpAndSettle`
ve tıklanabilirlik assertion'ı eklendi; mevcut assertion'lar kaldırılmadı.

## Kapsam ve doğrulama

Altı runtime dosyası yalnız Merchant katmanındadır: ortak Merchant sayfa/form
yardımcıları, Merchant giriş yüzeyi, kurtarma yüzeyi, mağaza, ürün ve başvuru.
Ortak/çakışma alanları: `merchant_widgets.dart`, `merchant_app.dart` ve canonical/
implementation slices belgeleri. Customer düzeni, ortak Auth/notification,
repository, backend, SQL ve dependency değişmez.

Yeni testler: büyük yazı ve küçük ekranda beş sekme, tam hata/etiket/kategori,
klavye, mağaza kaydı, giriş/kurtarmada geçersiz girişin gönderilmemesi,
erişilebilir girdi adı/değeri, Android dokunma hedefleri, kayıp yanıtta tek yazma
ve taslak koruma, kapanan/örtülen formun ertelenmiş kaydırması.
İki yeni golden görsel incelenir; mevcut görseller yeniden üretilmez.

Son sayısal test, analyzer, derleme ve APK koruma sonuçları
`docs/data/merchant_accessible_daily_use_verification.json` içinde teslim edilir.
Derleme provası sentetik yapılandırma kullanır; telefona kurulacak güncel aday
veya fiziksel kabul kanıtı değildir.

Son doğrulama:

- Tam Flutter: **3626 PASS / 0 FAIL / öncekiyle aynı 6 koşullu SKIP**.
  Son koşudaki Merchant unit/widget alt kümesi **833 PASS**; **22 yeni** test.
- `flutter analyze --no-pub`: **PASS**, sıfır sorun.
- Customer Development, Merchant Pilot ve Merchant Development ARM64 debug:
  **PASS**. Ek paket/geri dönüş/imza uyumluluk testleri: **135 PASS**.
- J16 hazırlık koruması: **20 PASS**; güncel kaynakta gerçek hazırlık komutu
  çıktı üretmeden reddedildi. Tarihsel iki J16 kaydı değişmedi.
- İki yeni görsel incelendi; mevcut golden dosyaları değişmedi:
  [fiyat hatası](../test/widget/merchant/goldens/accessible_price_error_320_200.png),
  [çalışma saatleri](../test/widget/merchant/goldens/accessible_shop_hours_320_200.png).
- Teslim edilmiş iki APK ve önceki üç derleme APK'sı SHA-256 ile değişmemiş.
  Yeni üç APK ayrı görev arşivinde; konumu doğrulama JSON'unda kayıtlı.
- Customer build günlüğünde Kotlin incremental-cache tanıları var. Derleme
  işlemi sıfır koduyla tamamlandı; üretilen APK, manifest ve imza kontrolleri
  geçti. SDK, global Gradle/Flutter yapılandırması veya dependency değiştirilmedi.
- Kaynak özeti:
  `116381f2b3f5406e73fab0a39edc2081c4b704a438ad6154f791687c30f92c39`.
  `git diff --check`, kapsam ve secret/PII taraması PASS.

## Pilot için açık noktalar

1. Gerçek esnaf/ürün seçimi, yetkili hesap/katalog hazırlığı ve mağaza konumu.
   Mevcut Merchant mağaza formu adres alır; koordinat hazırlamaz. Yakınlık ve
   alan kuralları doğrulanmış koordinat ister. Bu paket konum doğrulama yetkisi
   eklemez; pilot katılımında koordinatların nasıl doğrulanacağı ayrıca çözülmeli.
2. Güncel ve uyumlu cihaz paketleriyle telefon/iki cihaz QR, kamera ve gerekli
   sağlayıcı kabulü. Android ekran okuyucu/üretici klavyesi fiziksel denemesi bu
   widget testlerinin kapsamı değildir.
3. J16'nın mevcut kayıtları kendi kaynaklarına ait tarihsel kanıttır. Bu runtime
   değişikliği sonrası güncel hazırlığı açamaz; kaynak koruması gevşetilmez.
   Dağıtım ve pilot açılış kararı ayrıca bekler.

Production/hosted Development erişimi ve yazması: NONE. Migration/provider
gönderimi: NONE. Main merge/push yapılmaz; Integration Agent bağımsız doğrular.
