# Esenler pilotu — karar ve sunucu değişikliği dosyası

18 Ekim 2026 — **Güncel durum:** J7 Integration PASS ve ayrı Product Owner onayı
sonrası özel katalog altyapısı yalnız Development'ta kuruldu; gerçek ürün yayını
yapılmadı. [J8 kurulum kaydı](MERCHANT_PILOT_TEST_CATALOG_INSTALLATION_HANDOFF.md)
ve canonical §4.12 kurulum kanıtını ve gözlenen satır sonu farkını tanımlar.
**J9 yerel hazırlık uyarlaması tamamlandı:**
[kurulu yapıya bağlı hazırlık](MERCHANT_PILOT_INSTALLED_READINESS_HANDOFF.md)
ve canonical §4.13 geçerlidir. Yeni kategori/hesap/yayın paketleri ayrıca onaylanır;
J9 uzak ortamı okumadı veya değiştirmedi.

**Önceki tamamlanmış işler:** A kurulumu tamamlandı. J4 Integration PASS
sonrasında Product Owner C ve E'yi de yalnız Development için açıkça onayladı.
Dört giriş dönüş bağlantısı kaydedildi ve bildirimlerdeki altı Türkçe metnin
korumalı düzeltmesi uygulandı; bağımsız son kontroller PASS.
[A kaydı](MERCHANT_PILOT_TEST_INSTALLATION_HANDOFF.md) ve
[C/E uygulama kaydı](MERCHANT_PILOT_TEST_CE_HANDOFF.md) kapsam ve kanıtı içerir.
B/D hâlâ ayrı onay gerektirir. Hizmet esnafı için geniş başvuru / kademeli katılım
yaklaşımı korunur; canonical §4.7 ve §4.9 geçerlidir. Production'a erişilmedi.

**Önceki hazırlık (J6):** kategori, mevcut hesap/rol ve ürün eşleştirme hazırlığı
yerelde doğrulandı. Katılımcılar ve gerçek ürünler henüz belli olmadığı için
varsayılan dosyada yazma işlemi yoktur. Yeni ürünü ortak kataloğa yayımlama ve eski
fiyat alanıyla uyum sözleşmesi sonraki J7'de yerelde tamamlandı; gerçek içerik
yayımlanmadı. [Hazırlık teslimi](MERCHANT_PILOT_COHORT_HANDOFF.md).
Bu paket test sunucusunu okumadı veya değiştirmedi; B/D onayı verilmiş sayılmaz.

**Önceki hazırlık (J4):** E için altı metin düzeltmesi eşleşen yerel ortamda
doğrulandı; C'nin dört bağlantısı ve ilk katılım hazırlık dosyası paketlendi.
[Yeni teslim ve somut onay kapsamı](MERCHANT_PILOT_LAUNCH_PREPARATION_HANDOFF.md).
J4 hazırlığı kendi başına yazma izni değildi; sonraki açık C/E onayı ve uygulaması
J5 kaydındadır. A/E tekrar uygulanmamalıdır.

Aşağıdaki hazırlık değerlendirmesi kurulumdan önceki incelemenin kaydıdır.
Yerel hazırlık tamamlandı. İlk karşılaştırmada bulunan sunucu farkları ayrı yerel
provada korunarak yeniden üretildi; kurulum adayı bu eşdeğer ortamda geçti ve
gözlenen sunucu yapısıyla eşleşti. A kalemi onaya sunulabilir. Production kapsam
dışında; main birleşimini Integration Agent yapar.

## Katılım hedefi ve öneri

Kesinleşen hedef İstanbul / Esenler'de farklı esnaf türlerinin katılımına açık bir
pilot. Katılımcılar ve sayı henüz belli değil. Market, bakkal, kırtasiye, giyim ve
berber/salon adayları isteniyor. Bu niyet canonical §4.6'ya işlendi; yeni bir hizmet
özelliği veya bütün ürün kategorilerinin açılması kararı verilmedi.

**Öneri:** sektör başvurusunu geniş tutalım; fiilen kullanıma almayı küçük gruplarla
yapalım. Böylece ilk grubun giriş, ürün ekleme, fiyat ve fotoğraf sorunlarını
çözerken diğer esnafların katılım kapısını kapatmayız. Grup büyüklüğü destek
kapasitesine ve ilk esnafların ürün hazırlığına göre belirlenmeli; sabit sayı vaat
edilmiyor. İlçe sınırı bir pilot organizasyon hedefidir; bu paket uygulamaya yeni
konum engeli veya sektör kısıtı eklemez.

Geniş kapsamın maliyetleri: daha çok ürün hazırlığı, her sektörde farklı kullanım
beklentileri, daha fazla destek ve sektör başına daha az gözlem. Aynı küçük bölgede
olmak bunları kolaylaştırır; tek başına ortadan kaldırmaz.

| Esnaf/işlem | Mevcut hazırlıkla yaklaşım |
|---|---|
| Market/bakkal | Açılması onaylanan ürün dalları ve hazırlanmış ortak katalogla aday |
| Kırtasiye | Aynı katalog → dükkân ürünü → fiyat/uygunluk akışıyla aday |
| Giyim | Mevcut ürün kimliği sözleşmesiyle aday; beden/renk için yeni varyant veya stok sistemi vaat edilmez |
| Berber/kuaförün fiziksel ürün satışı | Ürünün kendi kategorisi ve inceleme kuralları uygunsa değerlendirilebilir |
| Saç kesimi, bakım hizmeti, randevu | Hizmet fiyatı/rezervasyon kapsamı tanımlanmadığı için hazır özellik olarak sunulamaz |

Berber/salon sektör niyeti taxonomy §12'de zaten mevcut. Saç kesimini stok ürünü
gibi kaydetmek doğru bir kestirme değildir. Mevcut kozmetik dalları bu paketin
otomatik uygunluk filtresinden geçmiyor; fiziksel ürün satışı da koşulsuz açılmaz.

## Kategori ve katalog hazırlığı

Mevcut1.563 düğümde1.245 son ürün dalı var. Bunların247'si, bütün üst dallarıyla
birlikte NORMAL/not_required koşullarını sağlayan bu **dar otomatik hazırlık
filtresine** uyuyor. Kalan998 dalın tamamına “yasak” denmiyor; farklı inceleme veya
ürün/policy kararları gerekiyor. Hiçbir inceleme durumu otomatik değiştirilmedi.

| Ürün alanı | Bu filtreye uygun son dal | Ayrı inceleme gereken son dal |
|---|---:|---:|
| Gıda & İçecek | 36 | 35 |
| Kırtasiye & Ofis | 20 | 40 |
| Giyim & Moda | 32 | 11 |
| Ayakkabı | 9 | 32 |
| Kozmetik & Kişisel Bakım | 0 | 59 |

Tam envanter offline pakette `category-inventory.json` olarak üretilebiliyor.
Bu247 dalın topluca açılması önerilmiş veya onaylanmış değil. Katılımcıların gerçek
ürün ihtiyaçlarıyla seçilecek açık kimlik listesi ayrı onaya sunulmalı.

Sunucuda ürün sayısı şu an0. Şema kurulması ve kategori açılması ürün kataloğu
oluşturmaz. İlk esnafların satacağı ürünlerin ortak katalogda bulunması, fiyat ve
fotoğraf hazırlığı giriş planına dahil edilmeli. Ürün başvurusu onayı ve yeni ürün
oluşturma yetkisi kapalı kalıyor; pilot için ayrı, sınırlı katalog hazırlık yöntemi
kanıtlanmadan kullanıcıya otomatik yayın sözü verilmemeli.

## Ayrı onay kalemleri

| Kalem | Somut kapsam | Şimdiki durum |
|---|---|---|
| A — Veritabanı | Değişmemiş catalog-media0016 + operations0017, iki yeni geçmiş kaydı,6 tablo, özel fotoğraf alanı ve ilgili işlemler | Açık onayla yalnız Development'a kuruldu; son kontroller PASS |
| B — Kategoriler | Açıkça listelenmiş son dallar ve gerekli üst dallar; policy/inceleme alanlarına dokunulmaz | Kesin liste seçilmedi, uygulanamaz |
| C — Giriş dönüş bağlantıları | Aşağıdaki4 tam bağlantıyı mevcut listeye eklemek | Açık onayla Development'a kaydedildi; yeniden yüklemede doğrulandı |
| D — Hesaplar/katalog | Seçilmiş gerçek kimlikler, merchant/customer rolleri ve sınırlı ürün hazırlığı | Esnaflar belli değil; hesap/rol/veri oluşturulmaz |
| E — Bildirim metni düzeltmesi | İki mevcut işlevdeki6 bozuk Türkçe sabitin doğru kaynakla ileri düzeltmesi; tek yeni geçmiş kaydı | Açık onayla yalnız Development'a uygulandı; bağımsız son kontrol PASS |

A için daha dar sunucu izinlerini ve yönetilen RLS davranışını koruyan yerel
uyum provası tamamlandı. Uygulamadan hemen önce salt okunur kontrol tekrar geçmeli;
değişmiş sunucuya aynı paket uygulanamaz. İzinler genişletilmedi veya kontrol kaldırılmadı.
E, eski bildirim kayıtlarını topluca değiştirmeyi veya geçmiş migration'ı yeniden
uygulamayı içermez. Bunlar ayrı onay kalemleridir; bir kalemin onayı diğerlerine
izin vermez.

C önerisindeki tam bağlantılar:

```text
com.esnaftavar.app.merchant.pilot://login-callback/
com.esnaftavar.app.merchant.pilot://login-callback/?auth_action=password_recovery
io.supabase.tstore://login-callback/
io.supabase.tstore://login-callback/?auth_action=password_recovery
```

Hedef yalnız `tnipyxnvhgelwdpykyez` test projesidir. Liste yazılmadan hemen önce
yeniden okunmalı; başka geçerli kayıtlar korunmalı. Site URL, e-posta doğrulama,
SMTP/parola/anahtar ve şablonlar bu kalemde değiştirilmez. Bu ekleme e-posta
teslimatını veya fiziksel cihazda güvenli hesap kurtarmayı kanıtlamaz.

## Pilot açılışı için kalan kanıt

**J11 güncel e-posta durumu:** mevcut Resend hesabı ve `auth.esnaftavar.com`
doğrulandı; yeni sağlayıcı/hesap oluşturulmaz. Development custom SMTP ve Confirm
email kapalıdır. Production'ın tarihsel e-posta kabulü bu test projesini kapsamaz.
[Salt okunur inceleme](MERCHANT_PILOT_EXISTING_EMAIL_AUDIT.md) ve
[gerçek yerel Auth/e-posta provası](MERCHANT_PILOT_AUTH_MAIL_HANDOFF.md) hazırdır.
SMTP/credential bağlama, confirmation/fallback/şablon değişimi ve gerçek gönderim
ayrı açık onay kalemleridir. Anahtar dosyaya/Flutter'a/Git'e yazılmaz; mevcut
Production adlı anahtar otomatik kopyalanmaz/yenilenmez. Paylaşılan Resend/DNS/TLS
değişiklikleri yalnız Development onayına dahil değildir.

J10 bu kapılar için [eşleşen Android dosyası hazırlığı](MERCHANT_PILOT_DEVICE_PACKAGE_HANDOFF.md)
ve [üç oturumlu saha kabul yönergesini](MERCHANT_PILOT_FIELD_ACCEPTANCE.md) ekler.
Sentetik debug derleme provası gerçek cihaz adayı/dağıtım değildir; hiçbir onay
kalemini otomatik tamamlamaz. Gerçek cihaz akışlarının sunucuda oluşturacağı kayıt
ve e-posta işlemleri de ayrı, somut saha denemesi onayına dahil edilmelidir.

1. Onaylanmış test sunucusu değişiklikleri, gerçek hesap/ürün hazırlığı ve aynı
   özelliklere sahip Customer–Merchant bağlantısının sunucuda doğrulanması.
2. Gerçek e-posta/kurtarma bağlantısı ve gerekli bildirim sağlayıcısı hazırlığı;
   gerçek iki cihazda QR/kamera kabulü ayrı kalır.
3. Seçilmiş özellikler, imzalı dağıtım paketi, destek/geri dönüş planı ve Product
   Owner pilot açılış kabulü. Yerel PASS bu açılış kararının yerine geçmez.

Teknik kanıt ve yeniden üretim: [J2 teslimi](MERCHANT_PILOT_PREPARATION_HANDOFF.md).

## J7 — Kontrollü katalog yayını: yeni ve ayrı onay kapsamı

**Güncel durum — J8:** Integration PASS ve Product Owner'ın ayrı “onaylıyorum”
mesajından sonra aşağıdaki **altyapı kapsamı yalnız Development'ta uygulandı**.
[Kurulum kaydı](MERCHANT_PILOT_TEST_CATALOG_INSTALLATION_HANDOFF.md): PASS; gerçek
ürün yayını yok. A/C/E tekrarlanmadı. Kurulum yeniden uygulanmamalıdır.

- **Onaylanıp tamamlanan kurulum kapsamı:** yalnız Development
  `tnipyxnvhgelwdpykyez` üzerinde bir özel yayın kayıt tablosu, üç kapalı yardımcı
  işlev, iki koruma tetikleyicisi ve bir kurulum kaydı. Ürün/fiyat, hesap, kategori,
  bildirim, Storage veya Auth ayarları değiştirilmez. Genel ürün onay anahtarı
  kapalı kaldı. Integration PASS, açık onay ve taze ön kontrol doğrulandı.
  Üretim ortamı tamamen dışarıdadır.
- **Gerçek katalog içeriği için ayrı kapsam:** henüz seçilmiş ürün/esnaf yok.
  Uyumluluğu incelenmiş Customer/Merchant sürümleri, uygun gerçek başvurular ve
  güncel gözlem hazır olduğunda her yayın paketinin tam listesi ayrıca sunulacak.
  Kurulum onayı ürün yayımlama veya esnafın satış listesini açma izni değildir.

Somut kaynak, etkiler, doğrulama ve geri dönüş sınırları:
[J7 teslim/onay dosyası](MERCHANT_PILOT_CATALOG_PUBLICATION_HANDOFF.md).
Varsayılan inceleme paketi ürün yayını SQL'i üretmez; yalnız kurulum adayı ve
salt okunur gözlem/doğrulama içerir. Tarihsel kurulum adayı tekrar çalıştırılmaz.
Yeni sunucuda gözlenen üç işlevin CRLF biçimi için J9 yerel hazırlık uyarlaması
tamamlandı; eski LF-only kanıt/korumalar değiştirilmedi. Kurulu yapıda yeni J9
giriş noktası kullanılır. Gerçek veri paketleri taze gözlem, gerçek kimlik/ürün
seçimi ve yeni tam liste onayı olmadan uygulanmaz. Varsayılan J9 dosyalarında
yazma veya kurulum SQL'i yoktur.

## A kaleminin teknik onay kimliği (tarihsel; tekrar uygulama)

Son salt okunur sunucu ön kontrolü: **PASS**, eşleşme `true`, katalog ürün sayısı0.
Bu sonuç sunucuda kurulum veya kullanım testi yapıldığı anlamına gelmez.

- Plan SHA-256: `8bf0303b5c3c2ea48663b73eb15c83e922617474ce9e83362ad82dff54a0348a`.
- Gözlenen başlangıç yapı özeti: `d4cb86def9cc856135f09ab83588b83c`.
- Kaynaklar: `20261013001600_0016_catalog_listing_media.sql` ve
  `20261014001700_0017_merchant_daily_operations.sql`.
- Üretim komutu: `node tool/merchant_acceptance/prepare_pilot.mjs <yeni-paket-adı>`.
  Üretilen `schema.plan.json` kimliği yukarıdakiyle, dosya özetleri `bundle.json`
  ile doğrulanmalı. Farklı kaynak/ortam özeti yeni inceleme gerektirir.
- Onay yalnız A'yı kapsarsa B–E uygulanmaz. Onaydan sonra da sunucu kimliği,
  güncel ön kontrol ve eşzamanlı başka kurulum bulunmadığı doğrulanır.
