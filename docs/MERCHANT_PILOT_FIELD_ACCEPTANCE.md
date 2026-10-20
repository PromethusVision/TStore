# Esenler pilotu — cihaz kabulü ve saha çalışması

Bu dosya **yapılacak kabulün yönergesidir; kabul sonucu değildir**. Teknik iş
paketlerinin PASS olması pilotun açılmasına eşit değildir. Mevcut kapsam fiziksel
üründür. Berber/salon fiziksel ürün satışıyla katılabilir; hizmet/randevu/saç kesimi
ürün gibi kaydedilmez. Ücret, ödül, kupon veya yeni özellik bu yönergeyle açılmaz.

## Başlamadan önce

1. Integration Agent'ın kabul ettiği aynı kaynak sürümden, yalnız Development'a
   bağlı Customer ve Merchant adayları hazırlanır. `pair.json`, iki APK ve kaynak
   özeti birlikte incelenir. Sentetik anahtarlı `COMPILE_REHEARSAL` dosyaları
   kurulmaz, esnafa verilmez. Debug imzası dağıtım/release kabulü sayılmaz.
2. Product Owner gerçek katılımcıları, fiziksel ürünleri ve kategori/rol/yayın
   listelerini belirler. [Güncel hazırlık aracıyla](MERCHANT_PILOT_INTAKE_GUIDE.md)
   taze gözleme bağlı **ayrı** teklifler
   hazırlanır. Her sunucu yazımı tam kapsamıyla onaylanmadan uygulanmaz.
3. Cihaz denemesindeki giriş, kurtarma e-postası, dükkân/listing/fiyat/medya ve
   satın alma adımları da test sunucusunda veri/mesaj oluşturabilir. Ayrı bir
   saha denemesi onayı; tam proje, gerçek test hesapları, ürünler, denenecek
   işlemler ve bırakılacak kayıtları kapsamalıdır. Bu belge o onay değildir.

Yalnız `tnipyxnvhgelwdpykyez`; Production dışarıdadır. Gerçek hesap parolası veya
doğrulama kodu sohbet/dokümana girilmez, yalnız güvenli uygulama ekranında girilir.
Fotoğraf, kullanıcı kimliği, e-posta, QR/token ve özel geçmiş Git'e konulmaz.

## Oturum 1 — giriş ve hesap güvenliği

İki ayrı fiziksel cihazı `customer-device-1` ve `merchant-device-1` gibi adlandır.
Gerçek seri numarası/IMEI, telefon veya kişi adı kaydetme.

| Deneme | Beklenen sonuç |
|---|---|
| Yetkili esnaf girişi | Yalnız kendi dükkânı açılır; diğer esnafın özel bilgisi görünmez |
| Yanlış rol | Müşteri hesabı Merchant paneline giremez; kendine rol veremez |
| Gerçek kurtarma e-postası | Doğru Merchant uygulaması açılır, parola yenilenir; yeniden normal giriş gerekir |
| Gecikmiş bağlantı/hesap değişimi/yeniden başlatma | Önceki hesabın yanıtı yeni oturumu değiştirmez; belirsiz kurtarma özel paneli açmaz |

Customer ve Merchant bağlantıları birbirini açmamalı. C kalemi allowlist kurulumu
yalnız ayar kanıtıdır; gerçek e-posta teslimi ve cihazda açılma burada gözlenir.
Hesap değişirse veya başka hesabın verisi görünürse denemeyi durdur; ekran/kanıtı
özel alanda tut, işleme devam ederek sonucu düzeltmeye çalışma.

## Oturum 2 — esnafın günlük kullanımı ve müşteride görünürlük

| Deneme | Beklenen sonuç |
|---|---|
| Dükkân açılışı ve profil | Yalnız onaylı sahibi işlem yapar; tekrar girişten sonra bilgiler korunur |
| Ürün ekleme, fiyat, var/yok, pasife alma | Esnaf satış listesi değişir; merkezî ürün kimliği/fiyatı veya başka dükkân değişmez |
| Fotoğraf, birincil seçim, kesinti, tekrar açma | Yalnız kendi ürünü etkilenir; belirsiz yükleme körlemesine tekrarlanmaz |
| Customer görünümü | Güncel esnaf fiyatı ve uygun esnaf fotoğrafı görünür; liste dışı/pasif teklif yanlışlıkla satışta gösterilmez |
| Katalog fiyatı | Etiketli merkezî `0` ücretsiz ürün/indirim/stok gibi görünmez; esnaf fiyatı veya “Esnaf fiyatını gör” gösterilir |

Yeni katalog başvurusu otomatik yayın değildir. Yayın ayrı operatör onayı ve ayrı
esnaf listesi ekleme adımıdır. Yanlış ürün, GTIN, sahiplik veya kategori saptanırsa
yeni yayın durdurulur; eski kayıt silinip yeniden oluşturulmaz. Düzeltme ayrıca
incelenir. Ürün ya da hizmet uydurularak eksik veri doldurulmaz.

## Oturum 3 — iki cihazlı satın alma, bildirim ve kesinti

| Deneme | Beklenen sonuç |
|---|---|
| Customer QR → doğru esnaf/kamera | Seçilen mevcut temel QR akışına göre tek satın alma kaydı oluşur |
| Yanlış dükkân, süresi dolan ve tekrar kullanılan kod | İşlem reddedilir; yeni veya yinelenen satın alma oluşmaz |
| Yavaş ağ/yanıt kaybı | Başarı uydurulmaz; mevcut yetkili geçmiş kontrol edilmeden tekrar satış denenmez |
| Geçmiş ve bildirim kutusu | Kayıt ilgili hesapta görünür, başka hesapta görünmez; bildirim hatası satın almayı geri almış sayılmaz |

Bu temel çift claims-v2/ödül/kupon aktivasyonu içermez. Eski QR tekrar onayı
“kullanılmış” reddiyle sonuçlanabilir; sonraki sürümün idempotent yanıtı beklenmez.
Buradaki cihaz kabulü, kapsam dışı ekonomik özellikleri kabul etmez. Kamera/GPS ve
OS izni gerçek cihazda kontrol edilir. QR ekran kaydında kod/token açık bırakılmaz.

Bildirim kutusu, Realtime güncellemesi ve telefon push bildirimi üç ayrı sonuçtur.
Firebase/APNs sağlayıcısı hazır olmadığı için telefon bildirimi PASS yazılmaz.
Sağlayıcı ve nihai pilot özellik seçimi ayrı karar/kurulum/kabul gerektirir.

## Kanıt ve durdurma

- Her aday çift kendi `field-observation.template.json` dosyasını üretir. 12
  senaryo üç oturum altında ayrı izlenir. Sonuç `OPEN`, `PASS` veya `FAIL` olur;
  cihaz takma adları, UTC gözlem zamanı ve özel kanıt dosyasının SHA-256 özeti
  kullanılır. Dosya adları/içeriği ve kişisel bilgiler kamuya açık rapora taşınmaz.
- Sentetik derleme çiftinin formu yalnız OPEN kalabilir; fiziksel PASS/FAIL
  kaydı kabul edilmez. Customer takma adı `customer-device-1`, Merchant takma
  adı `merchant-device-1` biçiminde rolüne uygun olmalıdır. İki farklı takma ad
  tek başına iki farklı telefonun kullanıldığını kanıtlamaz; bu insan gözlemidir.
- Oturum sonucunu farklı APK'ya kopyalama. Aday dosyası, kodu veya kaynak özeti
  değişirse çift tekrar hazırlanır; etkilenen cihaz adımları yeniden kabul edilir.
  Otomatik inceleme eşleşmeyi kontrol eder, insanın gözlemini bağımsız doğrulamaz.
- Yanlış hesap/veri görünmesi, yinelenen satın alma, yanlış fiyat, kayıp sahiplik
  veya güvensiz kurtarma **durdurma nedenidir**. Yeni esnaf kurulumu/yayın/test
  işlemi durdurulur, özel kayıt korunur ve Merchant Agent'a bulgu aktarılır.
  Yetkisiz veritabanı silme, toplu rol değiştirme, migration geri alma yapılmaz.

`review_pair.mjs <paket-adı> <gözlem-adı>` sonucunu şöyle değerlendirin:

| Sonuç | Çıkış kodu | Anlamı |
|---|---|---|
| `PAIR_REVIEW_REFUSED` | 1 | Bozuk, eski veya uyuşmayan dosya; rapor kabul edilmedi |
| `FIELD_BLOCKED` | 2 | En az bir FAIL var; denemeyi durdurup bulguyu inceleyin |
| `FIELD_INCOMPLETE` | 3 | FAIL yok; tamamlanmamış senaryolar var |
| `FIELD_REPORTED_COMPLETE_REQUIRES_OWNER_REVIEW` | 0 | 12 insan gözlemi bildirilmiş; bağımsız kabul veya pilot açılışı değil |

Gözlem verilmeden yapılan dosya kontrolü yalnız `PAIR_ARTIFACTS_VERIFIED` döndürür.
Her rapor giriş gözleminin dosya özetine bağlıdır; eski raporun üzerine yazılmaz.
Geçersiz takvim tarihi, paketten önceki/gelecekteki zaman ve yinelenen JSON
alanları reddedilir. Tüm satırlar PASS olsa bile dağıtım, sağlayıcı ve açılış
kararları kendi onaylarını gerektirir.

## Destek, katılımdan ayrılma ve açılış kararı

Pilot açılmadan Product Owner bir destek sorumlusu ve ulaşım kanalı belirler;
esnafa kapsam, deneme koşulları ve kime başvuracağı anlatılır. Henüz sorumlu/kanal
atanmış değildir. Katılımdan ayrılmak isteyen esnaf için yeni işlemler durdurulur,
görünürlük ve hesap durumu yetkili mevcut akışla incelenir. Bu talep otomatik
Auth silme, satın alma geçmişi/ekonomik delil silme veya sahiplik devri değildir.
Veri saklama/hukuki ve ticari politika kararı ayrıca tamamlanır.

Son açılış değerlendirmesi; gerçek katılımcı/katalog, gerekli server kurulumları,
nihai özellik seçimi, aynı imzalı aday çift, üç cihaz oturumu, e-posta/provider,
destek/ayrılma sorumlusu ve Product Owner kabulünü birlikte ele alır. Boş şablon,
yerel test PASS veya teknik paketin tamamlanması bu kararı otomatik kapatmaz.
