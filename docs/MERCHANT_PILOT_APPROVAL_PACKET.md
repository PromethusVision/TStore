# Esenler pilotu — karar ve sunucu değişikliği dosyası

17 Ekim 2026 — **Güncel durum:** A kurulumu tamamlandı. J4 Integration PASS
sonrasında Product Owner C ve E'yi de yalnız Development için açıkça onayladı.
Dört giriş dönüş bağlantısı kaydedildi ve bildirimlerdeki altı Türkçe metnin
korumalı düzeltmesi uygulandı; bağımsız son kontroller PASS.
[A kaydı](MERCHANT_PILOT_TEST_INSTALLATION_HANDOFF.md) ve
[C/E uygulama kaydı](MERCHANT_PILOT_TEST_CE_HANDOFF.md) kapsam ve kanıtı içerir.
B/D hâlâ ayrı onay gerektirir. Hizmet esnafı için geniş başvuru / kademeli katılım
yaklaşımı korunur; canonical §4.7 ve §4.9 geçerlidir. Production'a erişilmedi.

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

1. Onaylanmış test sunucusu değişiklikleri, gerçek hesap/ürün hazırlığı ve aynı
   özelliklere sahip Customer–Merchant bağlantısının sunucuda doğrulanması.
2. Gerçek e-posta/kurtarma bağlantısı ve gerekli bildirim sağlayıcısı hazırlığı;
   gerçek iki cihazda QR/kamera kabulü ayrı kalır.
3. Seçilmiş özellikler, imzalı dağıtım paketi, destek/geri dönüş planı ve Product
   Owner pilot açılış kabulü. Yerel PASS bu açılış kararının yerine geçmez.

Teknik kanıt ve yeniden üretim: [J2 teslimi](MERCHANT_PILOT_PREPARATION_HANDOFF.md).

## A kaleminin teknik onay kimliği

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
