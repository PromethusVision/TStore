# J10 — Customer/Merchant Android çifti ve saha kabulü hazırlığı

Başlangıç: `origin/main@3a2d0361bc7765a0919cbdf37ae9bcd1a5b43388` (J9 entegre).
Görev dalı: `agent/merchant-pilot-device-package`.
Kapsam: canonical §4.14 / slices J10; Product Owner'ın kapsamlı sonraki yerel iş
paketi talebi. Main merge yalnız Integration Agent'a aittir.

## Ne tamamlanır, ne anlama gelmez?

Birbirinden bağımsız derleme komutlarının yerine aynı kaynak, aynı test projesi
ve aynı kapalı özellik profiline bağlı iki Android dosyası hazırlanır. Araç önce
gerçek uygulama yapılandırma kurallarını ve hedefli regresyonları çalıştırır;
ardından her APK'nın gerçek paket kimliğini, giriş bağlantısını, sürümünü,
imzasını, izinlerini ve gerekli derlenmiş metinlerini inceler.

Bu teslim **yerel teknik derleme provasıdır**. Sentetik, çalışmayan istemci anahtarı
kullanılır. APK'lar kurulmaz/açılmaz, esnafa verilmez; Supabase'e bağlantı kurulmaz.
Gerçek katılımcı, ürün yayını, imzalı dağıtım ve saha kabulü tamamlanmış sayılmaz.
“Bu paket PASS” ifadesi “uygulama pilot kullanıma tamamen hazır” anlamına gelmez.

## Korunan mimari

| Alan | Sözleşme |
|---|---|
| Customer | Mevcut `development` / `lib/main_development.dart`; `com.esnaftavar.app.dev` |
| Merchant | Mevcut `merchantPilot` / `lib/main_merchant_pilot.dart`; `com.esnaftavar.app.merchant.pilot` |
| Backend | Yalnız Development `tnipyxnvhgelwdpykyez`; farklı URL/proje/anahtar eşleşmesi reddedilir |
| Giriş bağlantıları | `io.supabase.tstore://login-callback/` ve `com.esnaftavar.app.merchant.pilot://login-callback/` |
| Özellikler | Claims-v2, ödül, kupon, reviews-v2, trust, hesap ekstresi, tanıtım, push şeması ve canonical-taxonomy opt-in OFF |
| Bildirim | Mevcut ortak altyapı; sağlayıcı kurulumu/yeni sistem yok |
| Katalog fiyatı | Mevcut etiketli fiyat koruması ve satış listesi önceliği; Customer düzeni değişmez |
| Release imzası | Mevcut dış girdi ve sabit owner sertifikası; yeni anahtar/fallback yok |

Yeni uygulama ekranı, bootstrap, yönlendirme, Gradle ayarı, bağımlılık veya migration
yoktur. `lib/`, `android/`, `supabase/`, `pubspec*` ve geçmiş J7/J9 kanıt kaynakları
değiştirilmez. Yeni geliştirme `tool/pilot_device/` ve dokümantasyondadır.

## Araçların kullanımı

Windows üzerinde mevcut Node, Flutter SDK, Android SDK build-tools 35.0.0,
uygun JDK ve kurulu 7-Zip gerekir. Uygulama bağımlılığı eklenmez. APK arşivi tek
girdi olarak stdout'a okunur; dosya çıkarılmaz, APK çalıştırılmaz ve PowerShell
çalıştırma politikası değiştirilmez.

Yerel sentetik prova:

```text
node tool/pilot_device/build_pair.mjs rehearse <yeni-paket-adı> <Flutter-SDK> <Android-SDK> <java.exe>
node tool/pilot_device/review_pair.mjs <aynı-paket-adı>
node --test tool/pilot_device/contract.test.mjs
```

Çıktı `.buildlog/pilot-device/<yeni-paket-adı>/` altındadır. Aynı dizinin üzerine
yazılmaz; dizin bağlantısı/kaçışı reddedilir. Bir görev kilidi aynı worktree içinde
eşzamanlı iki çift derlemesini önler. Ayrı görevler ayrı worktree kullanmalıdır.
Kilit dosyası başka çalışmaya aitken silinmez. Başarısız çalışmada `FAILED.json`
aşaması ve özel log korunur; başarısız paket için `pair.json` üretilmez.

Başarılı çıktılar:

- `customer.apk`, `merchant.apk`: ARM64 dosyaları; prova için debug imzalıdır.
- `pair.json`: kimlik, callback, sürüm, gerçek APK SHA-256, aynı imza, toolchain,
  test sonucu, temel kaynak commit'i ve çalışma kaynaklarının özeti.
- `sources.json`: uygulama, Android, varlıklar, lockfile, araç ve hedefli testlerin
  kaynak listesi/özetleri. Derleme başında/sonunda aynılık zorunludur.
- `field-observation.template.json`: gerçek cihaz sonucu yazılmamış 12 senaryo.
- Özel derleme/test logları; anahtarlar raporlara yazılmaz. Geçici iki yapılandırma
  dosyası başarıda/hatada kaldırılır. Hiçbir gerçek girdi veya APK Git'e alınmaz.

`review_pair` dosya adı veya yalnız PASS metnine güvenmez: gerçek APK baytlarını,
kaynak listesini ve mevcut kaynakları kontrol eder. Kaynak veya APK değişirse
yeni çift gerekir. Hash bir değişiklik tespitidir; saldırganın yeniden yazdığı
tüm dosyaları tasdik eden imza veya insan onayı değildir.

### Daha sonra gerçek cihaz adayı

Bu yol bu teslimde gerçek anahtar veya owner imzasıyla **çalıştırılmadı**. Ayrı
yetkili adımda, Integration sonrası temiz incelenmiş commit gerekir. Yalnız üç
alanlı Merchant istemci girdisi ignored
`.buildlog/pilot-device-input/<girdi-adı>.json` konumuna güvenli şekilde konur:
`MERCHANT_PILOT_ENABLED`, `MERCHANT_PILOT_URL`, `MERCHANT_PILOT_ANON_KEY`.
Başka özellik, URL, ortam veya ikinci Customer anahtarı alınmaz. Tek girdiden
eşleşen iki yapılandırma üretilir. Yinelenmiş/kaçışla yazılmış JSON alanı,
server/service-role anahtarı, yanlış proje veya sentetik prova anahtarı reddedilir.

```text
node tool/pilot_device/build_pair.mjs candidate <yeni-paket-adı> <Flutter-SDK> <Android-SDK> <java.exe> <girdi-adı> debug
```

`release` seçeneği mevcut `ESNAFTAVAR_SIGNING_PROPERTIES` dış dosya yolunu ve
Gradle'ın owner sertifika/private-key doğrulamasını gerektirir. Araç bu gizli
dosyayı keşfetmez/okumaz/oluşturmaz; imzalamayı mevcut Gradle yapar. Gerçek release
üretimi ve dağıtımı ayrıca yetkilendirilir. Çıktı her durumda adaydır; bir CLI
seçeneği sunucuya yazma, fiziksel deneme veya esnafa dağıtım yetkisi değildir.

## Kanıtın sınırı ve saha çalışması

APK metin taraması yalnız verilen istemci anahtarının, Development URL'sinin ve
`_catalog_price_contract` işaretinin varlığını gösterir. Debug derlemesi kullanılmayan
kaynak metinlerini de içerebilir; metin taraması seçilen davranışı veya bütün
gizli bilgilerin yokluğunu tek başına kanıtlamaz. Seçilen ayarlar gerçek Dart
ön kontrolüyle, fiyat davranışı hedefli widget testleriyle, backend davranışı ise
önceki J9 yerel kanıtıyla ayrı değerlendirilir. J9 veritabanı kanıtı burada yeniden
çalıştırılmış gibi gösterilmez.

[Saha kabul yönergesi](MERCHANT_PILOT_FIELD_ACCEPTANCE.md) üç oturum içerir:
giriş/kurtarma, günlük ürün/medya kullanımı ve iki cihazlı satın alma. Her sonuç
tam APK çifti, cihaz takma adı, zaman ve özel kanıt özetiyle bağlanır. Özel
gözlem dosyası `.buildlog/pilot-device-input/<gözlem-adı>.json` altında tutulabilir:

```text
node tool/pilot_device/review_pair.mjs <paket-adı> <gözlem-adı>
```

Otomatik inceleme eksik/başka sürüme ait gözlem, tekrar senaryo, keyfi özel alan,
yanlış proje ve erken/gelecek zaman kaydını reddeder. İnsan beyanını bağımsız
kanıt saymaz; 12 satır PASS olsa bile pilot açılışı, gerçek mail/provider,
destek/ayrılma politikası ve Product Owner kabulü otomatik PASS olmaz.

## Tamamlanan yerel doğrulama

- **135 hedefli Flutter testi PASS / 0 FAIL / 0 SKIP.** Gerçek katalog fiyatı
  widget'ları, callback ayrımı, Merchant kurtarma SDK yanıt yarışları, kurtarma
  ekranı ve yeni eşleşen yapılandırma kontrolleri. Tam Flutter paketi yeniden
  çalıştırılmadı; uygulama davranışı değiştirilmedi.
- **28 yeni Node + 107 mevcut Node testi PASS**, sıfır hata/atlanan test.
  Bozuk/çift JSON alanı, yanlış ortam/rol/anahtar, paket/callback/imza sapması,
  yarım test sonucu, dizin kaçışı ve Windows junction engeli doğrulandı.
- **34 gerçek Gradle yapılandırma kontrolü + 8 paketleme engeli PASS.** Yanlış
  target, eksik ayar/imza, toplu belirsiz paketleme ve MerchantDevelopment release
  reddi; Customer mevcut release imza koruması yerel dry-run ile korundu.
- **Customer Development ve Merchant Pilot ARM64 debug APK PASS.** Her ikisi
  `1.0.0 (5)`; ayrı kimlik/callback, aynı debug sertifikası, backup kapalı,
  internet/kamera/konum izinleri, app_links'in tek callback yönlendirmesi ve
  beklenen derlenmiş metinler doğrulandı. İki dosya da sentetik prova ürünüdür.
- **10 ek gerçek dosya/CLI denetimi PASS.** APK'nın tek baytı değiştirilince ret,
  kaynak eklenince eski kanıtın reddi, kaynağın aynen geri dönüşünde kabul,
  boş saha formunda 12 OPEN, tekrar yazma/dizin kaçışı/eski çıktı reddi, temiz
  olmayan kaynaktan gerçek aday üretiminin credential okumadan reddi.
- **Flutter analyzer PASS**, sorun yok (40,1 saniye). Diff ve kaynak kapsamı
  kontrol edildi. J7/J8/J9 mevcut 60-kaynak kanıt zinciri değişmeden doğrulandı.

Kalıcı kayıt: [J10 yerel doğrulaması](data/merchant_pilot_device_package_validation.json).
APK ve ayrıntılı kaynak listesi ignored
`.buildlog/pilot-device/paired-rehearsal-final/` altındadır. `source_commit` başlangıç
commit'ini, `uncommitted_sources=true` ve tam kaynak özeti bu görevde henüz commit
edilmemiş araçları dürüstçe kaydeder; başlangıç commit'inden tek başına üretilmiş
artifact iddiası yoktur. Görev commit'i sonrasında aynı kaynak özeti tekrar kontrol
edilir. Integration sonrası gerçek aday temiz incelenmiş kaynakta yeniden üretilir.

İlk üç deneme yeni araçta Windows CRLF imza çıktısı, Windows PowerShell script
politikası ve kernel metin taraması varsayımlarında durdu. Bunlar uygulama hatası
değildi. Ayrıştırıcı düzeltildi; politika değiştirilmeden mevcut arşiv okuyucuya
geçildi; gerçek fiyat işareti esas alındı ve metin taraması sınırı açık yazıldı.
Tam çift üretimi ve denetimi yeni boş dördüncü dizinde geçti. Son kapsam denetiminde
komutların uyarı akışını JSON/binary veri çıktısından ayıran ek düzeltme yapıldı;
hedefli testi geçtikten sonra final çift yeni boş dizinde yeniden üretildi. Debug kernel
metinleri birleştirebildiği için genel metin regex'iyle “hiç secret yok” sonucu
üretilmiyor. Girdiler gerçek uygulama validator'larıyla istemci anahtarı olarak
kontrol edilir; değerler loglardan ayıklanır. Gerçek anahtar kullanılmadı.

## Integration ve sonraki kapılar

Integration yalnız kod/doküman ve testleri birleştirir; sunucu SQL'i çalıştırmaz,
APK dağıtmaz veya eski kurulumları tekrarlamaz. Ortak inceleme alanları canonical
§4.14 ve slices J10'dur. Production erişimi/yazması, Development erişimi/yazması,
Auth/Storage/SMTP işlemi, e-posta/push gönderimi ve fiziksel cihaz kurulumu yoktur.

Gerçek esnaf ve ürünler hâlâ seçilmemiştir. Kategori/rol/yayın ayrı tam liste onayı,
güvenli gerçek istemci girdisi/incelemiş imzalı aday, üç saha oturumu ve nihai pilot
özellik/operasyon/açılış kabulü gerekir. Bu teknik iş paketinin tamamlanması bu
bağımsız kapıları kapatmaz.
