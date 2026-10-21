# Esenler pilotu — ilk katılım grubu hazırlığı

21 Ekim 2026 güncellemesi. Bu rehber hazırlık içindir; kategori açma, hesap oluşturma, rol verme,
ürün yayımlama veya pilotu başlatma izni değildir. Canonical §4.7–4.13 ve §4.18 geçerlidir.
A/C/E ve J8 katalog altyapısı testte tamamlandı; aşağıdaki güncel araç hiçbir kurulumu
tekrar uygulamaz. Bu pakette uzak ortam yeniden okunmadı veya değiştirilmedi.

## Önce kapatılacak boşluk

Son yetkili sunucu gözleminde teknik A kurulumu tamamlanmış, ürün kataloğu boş ve
kategoriler kapalıydı. Bu paket sunucudaki güncel durumu yeniden okumadı.
Bir esnaf uygulamaya giriş yapabilse bile bu durum satışa hazır ürünlerini
görebileceği anlamına gelmiyor. Kategori açmak tek başına ürün oluşturmaz. İlk
grubun kimlerden oluşacağı ve hangi gerçek ürünlerle başlayacağı birlikte seçilmeli.

Sektör başvurusu geniş kalabilir. Market/bakkal, kırtasiye ve giyim aynı temel ürün
akışıyla değerlendirilebilir. Berber/kuaför başvurusu da alınabilir; ancak hizmet,
randevu, çalışan/slot ve hizmet fiyatlandırması hazır özellik olarak sunulamaz.
Fiziksel ürün satışı için ürünün kendi kategorisi ve inceleme koşulları geçerlidir.
Kozmetik dalları mevcut dar otomatik uygunluk filtresinden geçmediği için berberin
fiziksel ürün satışı da doğrudan açılacak bir özellik olarak vaat edilmemeli.

## Esnaf başına hazırlanacak bilgi

Özel operasyon kaydında yalnız gerekli bilgileri tutun; bu kaydı Git'e veya sohbet
mesajına parola/kimlik belgesi olarak taşımayın. Şifre girişini kişi güvenli giriş
ekranında kendisi yapmalı. Bu paket hiçbir kişiye e-posta göndermez.

| Hazırlık | Somut çıktı | Eksikse sonuç |
|---|---|---|
| Katılımcı ve yetkili kişi | Hangi esnafın, hangi yetkiliyle ilk grupta olduğu | Hesap ve rol değişikliği teklif edilmez |
| Dükkân sahipliği | Mevcut hesap/dükkân ilişkisi kontrolü; yeni esnaf mevcut onboarding'i kullanır | Başka dükkânın sahibi yeniden atanmaz |
| İlk gerçek ürünler | Ürün adı/marka/barkod varsa barkod, gerekli fiziksel ürün kimliği, kaynak doğruluğu | Hayalî ürün veya otomatik toplu katalog oluşturulmaz |
| Ürün kategorisi | Her ürün için açık son dal kimliği ve tüm üst dalların uygunluğu | Sektör adıyla toplu kategori aktivasyonu yapılmaz |
| Katalog eşleştirme | Var olan ortak ürün mü, inceleme gerektiren yeni başvuru mu? | Ürün onayı kapısı atlanmaz; kararlar OFF kalır |
| Fiyat ve fotoğraf | Esnafın kendi fiyatı/uygunluğu ve kullanma hakkı olan ürün fotoğrafları | Şema kurulumu içerik hazırlığı sayılmaz |
| Eşleşen Customer hesabı | Aynı test ortamı ve kabul edilmiş özelliklerle deneme | Merchant ekranının tek başına çalışması yeterli sayılmaz |
| Destek sorumlusu | Sorun bildirme kanalı, görevli kişi, katılımı durdurma yöntemi | İlk gruba dağıtım yapılmaz |

Giyim için yeni beden/renk varyant sistemi, berber için hizmet stoğu veya başka
sektörler için yeni iş modeli bu hazırlığın içinde varsayılmamalı. Gerçek ürün
ihtiyacı mevcut sözleşmeye uymuyorsa ayrı ürün kararı gerekir.

## Teknik hazırlık dosyasını kullanma

Kurulu test yapısı için güncel giriş noktası
`node tool/merchant_acceptance/prepare_integrated_pilot.mjs cohort <yeni-ad>`.
Eksik hazırlık raporu, anonim hesap yuvaları ve salt okunur yapı/kategori/veri
gözlem sorguları üretir. Varsayılan dosyada hesap kimliği, ürün veya kategori
seçimi ve hiçbir yazma SQL'i yoktur. Eski J6/J7 komutlarının farklı başlangıç
kontrolleri değiştirilmez. J16'nın ayrı giriş noktası eşleşen güncel ekran ve
repository kanıtlarını, J9'un değişmemiş kurulu sunucu sözleşmesi ve açıkça
incelenmiş istemci farklarıyla birlikte kontrol eder. J12'nin
`prepare_current_pilot.mjs` komutu kendi eski kaynak kapsamını korur; son oturum
düzeltmelerini kapsamaz. Ret sonucu atlanmaz veya eski kanıt güncellenmez.
Eski `prepare_installed_pilot.mjs` tarihsel J9 kaynaklarına bağlıdır; güncel
kaynakta verdiği ret atlanmaz veya eski kanıt değiştirilerek giderilmez.
Çıktı `.buildlog/pilot-integrated-review/<yeni-ad>/` altında oluşur; aynı adla
tekrar çalıştırılıp önceki teklifin üzerine yazılmaz.

Gerçek bilgiler belli olduğunda şablonun özel kopyası
`.buildlog/pilot-installed-input/cohort/<ad>.json` altında tutulur. Hesap yuvalarına güvenli
ekranda doğrulanan mevcut hesabın sistem kimliği ve özel inceleme kaydının referansı
eklenir. Kişisel isim, e-posta, telefon, parola veya token bu dosyaya konmaz; gerçek
hesap kimlikleri içeren dosya da Git'e eklenmez. Hesap henüz yoksa kişi güvenli
kayıt ekranını kullanır; araç hesap oluşturmaz veya e-posta göndermez.

Ürün için gerçek ad/marka/model/çeşit, varsa barkod, kategori, kanıt referansı ve
var olan katalogdan açık ürün seçimi gerekir. Bir ortak ürün farklı esnaflarca
seçilebilir. Çelişen barkodlar, aynı esnafta tekrar eden ürünler, hizmet kaydı ve
eksik incelemeler raporda ayrılır. Benzer isim, otomatik eşleştirme yetkisi vermez.

Salt okunur gözlemin sonucu aynı klasörde `<ad>.observation.json`, taksonomi sorgusu
metni `<ad>.taxonomy.json` olarak tutulur. Komuta `cohort <yeni-çıktı-adı> <ad>`
verilir; son argüman yalnız bu özel dosya adıdır. Eksiksiz gözlem varsa seçilen
kategoriler ve uygun mevcut hesap rolleri için ayrı öneri üretilebilir. Bu öneriler
onay veya uygulama değildir; uygulamadan önce güncel durum tekrar karşılaştırılır.
`distribution_ready` daima false kalır; gerçek cihaz ve açılış kabulü ayrıca gerekir.

**Katalog yayını — güncel hazırlık:** kontrollü yeni ürün yayını ve eski fiyat
uyumu J7'de doğrulandı; J8'de yalnız altyapısı onayla test sunucusuna kuruldu.
Gerçek ürün yayımlanmadı. Güncel araç J9'un kurulu tam yapı kontrolünü korur.
Yayın için `node tool/merchant_acceptance/prepare_integrated_pilot.mjs publication <yeni-ad>`
ayrı bir boş form üretir. Gerçek bekleyen başvurular ve uyumlu uygulama incelemesi
seçilince özel `.json`/`.observation.json` dosyaları `pilot-installed-input/publication`
altında tutulur; tam liste ayrıca onaylanır. Esnaf satış fiyatını kendi ürün kaydında
belirler. Uyumsuz eski uygulama sürümleriyle ilk yayın açılmaz.
Gerçek ürünleri şimdi uydurmamız gerekmiyor; katılımcılar seçilince başvuruları ve
fiziksel ürün bilgilerini birlikte inceleriz.
[Güncel hazırlık yöntemi ve onay sınırları](MERCHANT_PILOT_INSTALLED_READINESS_HANDOFF.md).
J16 güncel yerel kabulün kapsamı ve kalan kapılar
[birleşik pilot kabul tesliminde](MERCHANT_PILOT_INTEGRATED_ACCEPTANCE_HANDOFF.md) açıklanır.

## Açılış için üç somut kabul

1. Seçilmiş gerçek hesap ve ürünlerle giriş → dükkân → ürün/fiyat/fotoğraf → Customer
   görünürlüğü → bildirim akışı; yanlış hesabın erişemediği de doğrulanmalı.
2. Gerçek kurtarma e-postası ve soğuk/sıcak uygulama dönüşü; gerçek iki cihazda QR
   ve kamera kabulü. Yerel benzetim veya bağlantı listesi bunların yerine geçmez.
3. İncelenmiş imzalı paket, seçilmiş özellikler, destek ve geri dönüş planı ile
   Product Owner'ın ilk katılım grubunu açma kararı.

## Bağımsız onaylar

- **B:** kesin ürün dalları; policy ve profesyonel inceleme alanları korunur.
- **C:** Development'ta tamamlandı; bu paket tekrar uygulamaz.
- **D:** açık hesap/rol kapsamı ve ayrıca kanıtlanmış katalog hazırlık yöntemi.
- **E:** Development'ta tamamlandı; bu paket tekrar uygulamaz.

Bir kalemin onayı diğerine izin vermez. Production bu paketin tamamen dışındadır.
