# Esenler pilotu — ilk katılım grubu hazırlığı

17 Ekim 2026. Bu rehber hazırlık içindir; kategori açma, hesap oluşturma, rol verme,
ürün yayımlama veya pilotu başlatma izni değildir. Canonical §4.7–4.8 geçerlidir.

## Önce kapatılacak boşluk

Test sunucusunda teknik A kurulumu tamamlandı; ürün kataloğu boş ve kategoriler
kapalı. Bir esnaf uygulamaya giriş yapabilse bile bu durum satışa hazır ürünlerini
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

`prepare_pilot_launch.mjs <yeni-paket-adı>` yeni bir offline inceleme klasörü üretir.
İçinde kategori envanteri, eksik hazırlık raporu, anonim rol yuvaları, C giriş
bağlantıları ve E bildirim düzeltmesi bulunur. A tekrar kurulum dosyası yoktur.
Varsayılan durumda hiçbir kategori seçilmez ve bütün hazırlık bayrakları false'tur.

İleride gerçek hazırlık tamamlandığında `intake.template.json` dosyasının özel
yerel kopyası `.buildlog/pilot-intake/<ad>.json` altında tutulabilir. İkinci CLI
argümanı yalnız bu yerel adı kabul eder. Dosyaya isim, e-posta, telefon, parola,
token veya ek alan koymayın. `product_leaf_ids` yalnız önerilen ürün dalı UUID'lerini
taşır; bu kimlikler otomatik yetki oluşturmaz. Seçim varsa ayrı B planı üretilir.

Rapordaki işaretler beyanı temsil eder. Hepsi true olsa bile sonuç
`CLAIMED_COMPLETE_REQUIRES_INDEPENDENT_EVIDENCE` olur; `distribution_ready` daima
false kalır. Gerçek sunucu/cihaz kanıtı ve Product Owner açılış kabulü ayrıca gerekir.

## Açılış için üç somut kabul

1. Seçilmiş gerçek hesap ve ürünlerle giriş → dükkân → ürün/fiyat/fotoğraf → Customer
   görünürlüğü → bildirim akışı; yanlış hesabın erişemediği de doğrulanmalı.
2. Gerçek kurtarma e-postası ve soğuk/sıcak uygulama dönüşü; gerçek iki cihazda QR
   ve kamera kabulü. Yerel benzetim veya bağlantı listesi bunların yerine geçmez.
3. İncelenmiş imzalı paket, seçilmiş özellikler, destek ve geri dönüş planı ile
   Product Owner'ın ilk katılım grubunu açma kararı.

## Bağımsız onaylar

- **B:** kesin ürün dalları; policy ve profesyonel inceleme alanları korunur.
- **C:** yalnız dört tam giriş dönüş bağlantısının eklenmesi; diğer Auth ayarları aynı.
- **D:** açık hesap/rol kapsamı ve ayrıca kanıtlanmış katalog hazırlık yöntemi.
- **E:** iki mevcut bildirim işlevinde altı metin düzeltmesi; eski bildirimler aynı.

Bir kalemin onayı diğerine izin vermez. Production bu paketin tamamen dışındadır.
