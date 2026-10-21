# Merchant MVP — ilk fiziksel pilot akışı

22 Ekim 2026. Dal: `agent/merchant-pilot-physical-acceptance`.
Entegre kaynak: `d037c7397208c2f9c94b4b910c583a7d6b245fbb`.
Durum: **Güncel cihaz çifti hazır; tek test hesabının onaylı rolü verildi.
Yeni Merchant kurulumu/giriş ve mağaza oluşturma ekranı kullanıcı tarafından
doğrulandı; kullanıcının oluşturduğu mağaza sunucudan kontrol edildi.
Dashboard ve boş Ürünler listesi de kullanıcı tarafından doğrulandı.
İlk fiziksel ürün için onaylanan Powerbank alt kategorisinin yerel hazırlığı
ve gerçek yerel servis/istemci provası tamamlandı; hosted kategori/yayın bekliyor.
Fiziksel kabul ve pilot açılışı henüz tamamlanmadı.**

## Öncelik

Product Owner, ilk MVP/pilotu başlatmayı genel iyileştirme ve ileri özelliklerden
öncelikli kıldı. Canonical §4.20/J17 bunu kaydeder. Bu teslim uygulama kodu,
dependency, migration veya özellik bayrağı değiştirmez. İlerleme sırası:
giriş/mağaza → seçilmiş ürün ve Customer görünürlüğü → iki telefonla mevcut QR.
Yeni geliştirme ancak bu yol üzerinde somut engel bulunursa seçilir.

## Güncel cihaz dosyaları

**İndirilenler → EsnaftaVar-MVP-d037c739**

- `merchant.apk`: EsnaftaVar Esnaf Pilot, esnaf telefonu.
- `customer.apk`: EsnaftaVar Dev, müşteri telefonu.
- `pair.json`, `sources.json`, boş saha formu ve `ONCE-OKU.txt` birlikte teslim.

Kaynak ve iki dosya aynı entegre commit'e bağlıdır. Development projesi
`tnipyxnvhgelwdpykyez`; bütün sonraki iş özellikleri OFF. Aynı uygulama
kimliği/debug sertifikası ve teslim kopyalarının SHA-256 eşleşmesi doğrulandı.
Bu, fiziksel kurulumun veya esnaflara release dağıtımının kabulü değildir.

Önceki `EsnaftaVar-Development-a0dfbdfd` klasöründeki iki APK değiştirilmedi.
Yeni dosyalar eski adayların üzerine yazılmadı. Ayrı eski `EsnaftaVar` kurulumu
bu Development denemesine dahil değildir.

## Gerçek test ortamında gözlenen engel ve onaylı çözüm

Resmi Development SQL panelinde salt okunur gözlem: esnaf rolündeki hesap,
mağaza, katalog ürünü ve mağaza ürünü sayıları **0 / 0 / 0 / 0**.
Mevcut tek seçilmiş test hesabı e-postası doğrulanmış `customer` rolündeydi.

Sahibin telefondan bildirdiği “Mağazan burada” metni giriş ekranına aittir;
dashboard kabulü sayılmadı. Girişten sonra “esnaf yetkisi yok” sonucu bildirildi.
Bu gözlem eski kurulu adaya aittir ve rol verilmeden önceki beklenen davranıştır.
Telefon ekranı/kurulu APK hash'i bağımsız gözlenmedi.

Product Owner ayrıca yalnız bu mevcut Development hesabının
`customer → merchant` geçişini açıkça onayladı. Hesap kimliği, iki tablodaki
eşleşen e-posta, doğrulama durumu ve eski rol kontrol edildi; profil/Auth
satır kilitleriyle tek satırlık korumalı işlem yürütüldü.
Bağımsız SELECT, seçilen hesapta `merchant`, toplam esnaf hesabı **1** ve
mağaza sayısı **0** döndürdü. Hesap kimliği/e-posta yazılı teslimin parçası değildir.
İşlem tekrar uygulanmamalı; Integration bu belgeyi birleştirirken SQL çalıştırmaz.

Kullanıcı, yeni `merchant.apk` ile güncelleme ve giriş sonrasında
“Mağazanı oluştur” ekranının açıldığını ayrıca bildirdi. Bu, güncel Merchant
adayında giriş/yetki ve onboarding ekranına ulaşma için kullanıcı beyanıdır;
mağaza kaydı veya dashboard kabulü değildir. Güncel Customer APK'sının kurulumu
henüz ayrıca doğrulanmadı. Telefon/kurulu dosya hash'i bağımsız incelenmedi.

Rol onayı mağaza, ürün, kategori/yayın, ikinci hesap, satın alma, ekonomik özellik
veya Production işlemi yetkisi değildir. Agent bu alanlarda yazma yapmadı.

Sonrasında kullanıcı, telefondan kendi seçtiği adla mağazayı oluşturduğunu
bildirdi. Agent önerilen alternatif deneme mağazasını oluşturmadı veya mevcut
kaydı yeniden adlandırmadı. Development'ta ayrı salt okunur işlemle seçilen
hesabın **1** mağazası olduğu, adın kullanıcı beyanıyla eşleştiği ve mağazanın
aktif olduğu doğrulandı. Konum koordinatları eksik; mağaza ürünü ve ortak
katalog ürünü sayıları **0 / 0**. Kullanıcı dashboard'un açıldığını ve Ürünler
listesinin boş olduğunu ayrıca bildirdi; sunucudaki sıfır kayıtla tutarlı.
Bu hazırlık gerçek pilot katılımcısı seçimi veya işletme
doğrulaması değildir; işletme iletişim bilgileri yazılı teslimde tutulmaz.

## Doğrulama

- Mevcut paired-build uyumluluk paketi: **135 PASS / 0 FAIL / 0 SKIP**.
- Customer Development ve Merchant Pilot ARM64 debug derlemeleri: **PASS**.
- APK kimlik, callback, imza, yapılandırma işaretleri ve kaynak incelemesi: **PASS**.
- `review_pair.mjs`: **PAIR_ARTIFACTS_VERIFIED**.
- `flutter analyze --no-pub`: **PASS**, sıfır sorun, 63,7 saniye.
- Customer derlemesinde Java 8 kaynak/hedef sürümü uyarıları var; derleme başarılı.
  SDK, Gradle, dependency veya ortak runtime değiştirilmedi.
- Tam Flutter paketi yeniden çalıştırılmadı; bu teslimde runtime değişikliği yok.
  Önceki entegrasyonun tam regresyonu bu görevde yeniden koşulmuş gibi sunulmaz.

## İlk ürünün kategori engeli ve yerel çözüm

Kullanıcı ilaç adayını kapsam dışı olduğu için geri çekti; seçilen ürün barkodsuz
**Baseus EnerFill FM11 10.000 mAh**, deneme mağaza fiyatı **990 TL**.
Üreticinin [ürün sayfası](https://www.baseus.com/products/enerfill-fm11-magnetic-power-bank-10000mah-22-5w)
markayı Baseus olarak tanımlar; MagSafe marka alanına yazılmaz. Renk, barkod,
gerçek satış veya pilot katılımcısı yeterliliği uydurulmadı.

Yeni canonical yerleşim Elektronik / Güç, Şarj & Bağlantı'dır. Eski snapshot'taki
telefon aksesuarları yolu kullanılmadı. Bu L2'nin altı boş ve atanamaz olduğu
için Product Owner tek **Powerbank L3 yaprağını** açıkça onayladı.
Karar canonical §4.20 ve J17'ye işlendi; tarihsel 1.563 kayıt/alias/migration
değiştirilmedi. Bir yeni UUID ve iki mevcut üst düğümün aktivasyonu için çevrimdışı
inceleme hazırlayıcısı eklendi. Kimlik tekrar denemede değişmez. Ayrı geri çekme
planı kayıt silmez; ürün/yayın varsa çalışmaz.

- Son yerel prova: `ev-merchant-ab-904c6a4f7846`, **14 PostgreSQL grubu PASS**.
- Yeni 10 test dahil bitişik katalog/yayın/kanıt sözleşmeleri: **80 PASS / 0 FAIL / 0 SKIP**.
- Gerçek Auth/PostgREST + güncel Flutter repository'leri: **7 kontrol PASS**
  (iki aşamalı Flutter servis testi). Yeni yaprak seçimi, barkodsuz/idempotent
  öneri, kontrollü yerel yayın, 990 TL fiyat, Customer görünürlüğü, stok kapatma/
  açma, eski fiyat yanıtı ve farklı esnafın yazma reddi doğrulandı.
- Kanıt sadece bu dar kategori/ürün yolunu kapsar; eski J16 UI kanıtını yenilemez.
- Son `flutter analyze --no-pub`: **PASS**, sıfır sorun, 41,6 saniye.
- Gerçek hosted son gözlem: şema aynı, 1.563 kategori, aktif kategori/ürün/listing/
  bu dalın alt kategorisi **0**. Yalnız SELECT; kategori/yayın yazması yapılmadı.

[Uygulama öncesi kapsam ve yeniden üretim](MERCHANT_POWERBANK_CATEGORY_REVIEW.md).
[Yeni kaynak bağlı yerel kanıt](data/merchant_pilot_powerbank_acceptance.json).
Önceki kanıtlar ve iki APK çifti korunur; yeni APK gerekmez.

Sanitize kayıt: [cihaz ve test hesabı hazırlığı](data/merchant_mvp_physical_preparation.json).
Yerel asıl çıktı: `.buildlog/pilot-device/mvp-physical-20261022/`.
Güncel çiftin tam saha formu OPEN kalır; yukarıdaki kısmi kullanıcı gözlemi
ayrı kaydedilir. Eski telefondaki gözlem yeni APK'ya taşınmaz.

## Sıradaki somut adımlar

1. Güncel Customer APK kurulumunu doğrulama. Merchant güncellemesi/girişi ve
   mağaza oluşturma ekranına geçiş kullanıcı tarafından doğrulandı.
2. Seçilmiş fiziksel ürün, gerekli konum ve Customer hesabı için en küçük somut
   hazırlığı ayrıca onaylayıp günlük akışı yürütme. Gerçek ilk pilot esnafı,
   konumu veya ürün listesi bu teslimde uydurulmaz.
3. Hazırlanan iki hesap/mağaza/ürünle fiziksel QR kabulü; ardından imzalı
   dağıtım, destek sorumlusu ve Product Owner'ın ilk pilot açılış kararı.

Production erişimi/yazması **NONE**. Migration uygulanması **NO**.
Main merge/push Merchant Agent tarafından yapılmaz. J16 tarihsel kanıtı ve
güncel kaynak reddi korunur; bu teslim onu güncel yerel kabul olarak yeniden yazmaz.
