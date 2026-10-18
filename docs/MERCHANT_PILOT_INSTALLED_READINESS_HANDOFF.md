# J9 — Kurulu test yapısıyla kategori, hesap ve katalog yayını hazırlığı

Başlangıç: `origin/main@62e7ba4a4839abc190fd6bf8493c2709a333b861` (J8 entegre).
Görev dalı: `agent/merchant-pilot-installed-readiness`.
Durum: **yerel uygulama ve kabul PASS; uzak ortam okunmadı/değiştirilmedi.**

## Kullanıcıya etkisi

Test sunucusundaki kurulumdan sonra kalan hazırlık uyumsuzluğu giderildi.
Kategori, mevcut hesabın esnaf rolüne hazırlanması ve ürün yayını için inceleme
dosyaları artık **kurulu yapının tam özetiyle** hazırlanabilir. Gerçek esnaflar ve
ürünler hâlâ seçilmediği için teslimdeki varsayılan iki dosya paketi yalnız boş
formlar ve salt okunur sorgular içerir; gerçek hesap, fiyat veya ürün uydurmaz.

Bu görev Product Owner'ın “sıradaki çalışmaya başlayalım” talebinin yerel uygulama
kapsamındadır. Production erişimi yoktur. Development'a yeni yazma yetkisi alınmadı
ve uzak bağlantı kurulmadı. Önceki kurulum, callback veya bildirim işlemleri
tekrarlanmadı. Main merge Integration Agent'a aittir.

## Mevcut yapı ve uygulanan çözüm

| Mevcut parça | J9 kullanımı |
|---|---|
| J8 kurulum kaydı | Değişmeyen SHA-256 ile doğrulanan tarihsel sunucu biçimi kanıtı |
| J7 yayın sözleşmesi ve 53 kaynak kanıtı | Aynen korundu; her hazırlık öncesi tekrar doğrulanır |
| J6 kategori ve hesap kontrolleri | Aynı veri/yetki kuralları, kilitler ve ayrı onay belirteçleri |
| J7 ürün kimliği/GTIN/özel sahiplik/fiyat/karar/kayıt işlemi | Aynı atomik yayın ve salt okunur sonuç kurtarma sözleşmesi |
| Merchant/Customer veri erişim katmanı | Kod değiştirilmeden gerçek yerel Auth, RPC ve Storage ile sınandı |
| Yeni kurulu profil uyarlaması | Yalnız üç gözlenmiş işlev gövdesinin tam satır sonu biçimini yerelde üretir |
| Yeni hazırlık giriş noktası | Kategori/hesap ve ürün yayını için ayrı, bağlantısız inceleme dosyaları |

Yeni ekran, yönlendirme, bağımlılık, migration veya ekonomik özellik eklenmedi.
Customer V1 ekran düzenleri korunur. Berber gibi hizmet esnafı fiziksel ürünlerle
katılabilir; hizmet/randevu ürünü yayınlamak bu paketin kapsamında değildir.

### Biçim farkı güvenlik kontrolünü gevşetmez

Yerel uyarlama önce değişmemiş J7 yapısını
`590f31a8d4e3485d6b23434e17bd9d40` olarak doğrular. J8 kaydındaki **yalnız üç**
işlevin LF ve ham tanım özetleri ile satır sonu sayıları eşleşirse bu gövdeleri
127.0.0.1:55432 üzerindeki görev ortamında yeniden oluşturur. Sonuç bütün şema
olarak **tam ham sunucu özeti** `d9607df877e9115eb811d984e561b4e7` ile eşleşmelidir.
Diğer işlevler, izinler, tablolar ve bütün yapısal alanlar karşılaştırmada aynıdır.

Uzaktaki sorgulara genel satır sonu normalleştirmesi veya “benzer şemayı kabul et”
yolu eklenmedi. Farklı çalıştırılabilir metin, izin değişikliği, yanlış yerel port,
uzak adres, eski başlangıç ve uyarlamayı tekrar deneme reddedilir. Hazırlık SQL'i
ham şemayı işlem içinde aynen kontrol eder. Tarihsel J7 araçları eski biçim için
korunur; J9 kullanımında aşağıdaki yeni giriş noktası tercih edilir.

## Tamamlanan doğrulama

- **32 PostgreSQL/gerçek yerel servis kontrol grubu PASS.** Tam ham yapı eşleşmesi;
  değişmeyen geçmiş kaynaklar; ayrı kategori/rol/yayın onayı; izin ve veri sapması;
  eşzamanlı Auth değişikliği; iki esnafın tek GTIN kimliğini paylaşması; yanlış ikinci
  ürünün tüm işlemi geri alması; istemci/service-role engeli; tekrar ve kayıp yanıt
  kurtarma; değiştirilemeyen yayın kaydı ve fiyat etiketi doğrulandı.
- **18 gerçek Flutter repository kontrol noktası PASS.** Dükkân açılışı ve profil
  güncelleme, katalog arama, ürün/fiyat/stok, medya, yeni oturumdan okuma, Customer
  görünümü, bildirim ayrımı ve mevcut satın alma/QR repository yolu çalıştı.
  Esnaf liste fiyatı ve satın alma tutarı merkezî sıfır yer tutucudan bağımsız kaldı.
  Bu test fiziksel kamera/iki cihaz QR kabulü değildir.
- **107 Node testi PASS / 0 FAIL / 0 SKIP**; 19 yeni hedefli kontrol dahil.
  Eksik girdi, yanlış hedef, eski şema, özel veri/dizin kaçışı, uygun olmayan hesap,
  hizmet ürünü, eksik uyum kanıtı ve bozuk girdi reddi doğrulandı. Kaynak değişince
  eski prova kanıtıyla çıktı dizini dahi oluşmadı; mevcut paket üzerine yazılmadı.
- **Flutter analyzer PASS**, sorun yok. Standart başlatıcı beklediği için yalnız
  görev analizi durdurulup aynı SDK'nın `flutter_tools.snapshot` girişinden
  `--no-version-check --suppress-analytics analyze --no-pub` çalıştırıldı; 130,6
  saniyede tamamlandı. Beş yeni Node dosyasının sözdizimi kontrolü de PASS.
- Yeni hazırlık komutları gerçek giriş noktasından çalıştırıldı. İki varsayılan
  pakette kurulum veya yazma SQL'i bulunmuyor. Dolu sentetik girdilerin planları
  yerel provada çalıştırılmış planlarla aynı onay kimliklerini üretti.

Kanıt: [yeni yerel kabul kaydı](data/merchant_pilot_installed_acceptance.json).
Eski J7/J8 kanıtları değiştirilmedi. Yeni kayıt 60 kaynak dosyasına bağlıdır.
Başlangıçta yalnız prova verilerinde iki uyumsuzluk bulundu (kategori alanı ve
mevcut Flutter testinin aradığı ürün adı); test hazırlığı düzeltildi ve tam kabul
yeni boş ortamda yeniden geçti. Uygulama veya geçmiş test sözleşmesi değiştirilmedi.
Windows junction güvenlik testi sandbox dışında geçici yerel dizinlerle doğrulandı.
Görev servisleri durduruldu; deneme verileri korundu.

## Hazırlık dosyaları ve kullanım

```text
node tool/merchant_acceptance/prepare_installed_pilot.mjs cohort <new-output-name>
node tool/merchant_acceptance/prepare_installed_pilot.mjs publication <new-output-name>
```

Çıktı: `.buildlog/pilot-installed-review/<new-output-name>/`.
Her pakette `intake.template.json`, `observation.readonly.sql`,
`structure.readonly.sql`, `readiness.json` ve içerik özetlerini taşıyan `bundle.json`
bulunur. Kategori/hesap paketine ayrıca `taxonomy.readonly.sql` eklenir.
Varsayılan durum `INCOMPLETE_NO_MUTATION` olur; bu bir hata veya pilot kabulü değildir.
Yeni kurulum adayı oluşturulmaz ve mevcut sunucuya otomatik bağlantı yoktur.

Gerçek katılımcılar seçilince özel girdiler yalnız ignored dizinlerde tutulur:

- Kategori/hesap: `.buildlog/pilot-installed-input/cohort/<name>.json`,
  aynı adlı `.observation.json` ve `.taxonomy.json`.
- Yayın: `.buildlog/pilot-installed-input/publication/<name>.json` ve
  aynı adlı `.observation.json`.

Komuta dördüncü argüman olarak yalnız bu düz özel girdi adı verilir. Tam dosya
yolu, dizin dışına bağlantı veya `--apply` gibi uzak çalıştırma seçeneği yoktur.
Parola, anahtar, özel iletişim bilgisi ve gerçek kişi kimlikleri Git'e konulmaz.
Boş başvuru/bilinmeyen katılımcıdan kimlik türetilmez. J8 kurulum kaydı **güncel
hesap/ürün/kategori gözlemi yerine kullanılamaz**.

Tam girdiler ayrı `categories`, `roles` veya `publication` inceleme adayları
üretebilir. Aynı dosya paketinde bulunmaları tek onayla hepsini çalıştırma izni
değildir. Kullanıcının seçtiği tam kapsam ve hedef yeniden doğrulanır. Planlar
önceki kaynakların veri/yetki kilitlerini, tam durum kontrolünü ve geri alma
koşullarını kullanır; onay belirteci otomatik ayarlanmaz. Yayın kayıp yanıtında
`receipt.readonly.sql` ile mevcut sonuç okunur, işlem körlemesine tekrarlanmaz.

Bu görevde hazırlanan boş inceleme paketleri:

```text
.buildlog/pilot-installed-review/esenler-installed-cohort-final
.buildlog/pilot-installed-review/esenler-installed-publication-final
```

## Yerel provayı tekrar üretme

```text
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <new-owned-run>
node tool/merchant_acceptance/pilot_installed.mjs <same-run> <Flutter-SDK-directory>
node tool/merchant_acceptance/local.mjs stop <same-run>
node --test tool/merchant_acceptance/*.test.mjs
```

Yeni ve boş görev ortamı zorunludur; başka görevin verisi sıfırlanmaz. Önceki A/C/E
ve J7 kaynaklarının bu runner'daki kullanımı yalnız bu yeni yerel başlangıcı kurar.
Hiçbiri test/Production sunucusunda yeniden çalıştırılmaz. Gerçek servis yanıtları
ve repository sonucu taklit edilmez. Yerel hesap parolaları yalnız görev geçici
dosyasında kullanılır ve runner sonunda bu dosya kaldırılır.

## Integration ve kalan sınırlar

Integration bu görev dalını ve yeni kanıtı inceler; **uzakta hiçbir SQL çalıştırmaz**.
Canonical §4.13/slices J9 ve onay dosyası ortak inceleme alanlarıdır. Uygulama,
migration, dependency, routing ve bootstrap değişikliği yoktur. Yeni APK ve tam
Flutter testi, değişmeyen uygulama kodu için tekrar çalıştırılmadı; gerçek yerel
repository testi yukarıda ayrıca çalıştırıldı.

Gerçek katılımcılar/ürünler seçildiğinde, güncel gözlemle tam kategori/hesap/yayın
listesi ayrıca hazırlanıp onaya sunulur. Uyumlu Customer/Merchant sürüm çiftinin
incelenmesi, gerçek e-posta/provider, imzalı dağıtım, iki cihazlı fiziksel QR ve
pilot açılış kabulü hâlâ açıktır. Bu yerel paket için kullanıcıya bırakılmış manuel
kontrol veya yeni sunucu izni talebi yoktur.
