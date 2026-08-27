# Batch 03 Product Owner Review Digest

**Durum:** OWNER REVIEW PREPARATION — NO FINALIZATION

**Kapsam:** Wave 15 Overnight Taxonomy Batch 03

**Karar ilkesi:** Aşağıdaki öneriler mevcut sekiz L2 proposal'ının karar özeti olup yeni taxonomy tasarımı değildir. Product Owner onayı verilene kadar bütün yapılar `PROPOSED FOR OWNER REVIEW` durumundadır.

Bu digest; canonical tek-primary-leaf, en fazla dört seviye, kategori/facet ayrımı, fiziksel ürün kapsamı ve policy sınıfının kategori derinliği olmadığı ilkelerini korur. Regülasyonla ilişkili maddeler hukuki görüş değildir; mevcut araştırma kanıtına dayalı taxonomy önerileridir. Yetki veya ürün uygunluğu belirsizse önerilen tutum fail-closed'dur.

Karar öncelikleri:

- **P0:** Canonical taxonomy yapısını etkiler.
- **P1:** Gelecekteki L3/L4 tasarımını veya domainler arası sınırı etkiler.
- **P2:** Facet, synonym ya da policy uygulama ayrıntısını etkiler.
- **POLICY-SENSITIVE:** Product Owner kararına ek olarak yetkili hukuk/policy doğrulaması gerektirir; kategori onayı satış izni değildir.

## Otomotiv & Motosiklet

### Proposed L2

1. Otomobil Yedek Parçaları
2. Motosiklet Yedek Parçaları
3. Araç İçi Aksesuarları
4. Araç Dış Aksesuarları
5. Lastik, Jant & Tekerlek Ürünleri
6. Akü & Araç Elektriği
7. Araç Elektroniği
8. Araç Bakım & Temizlik
9. Motor Yağı, Sıvı & Katkılar
10. Motosiklet Kask & Koruma Ekipmanları
11. Araç Güvenlik & Acil Durum Ürünleri

### Recommend

Mevcut 11 L2'yi aynı ad ve sırayla koru. Araç uyumluluğunu marka/model/yıl/motor gibi typed facetlerle yönet; araç-spesifik elektrik ve elektronik ürünleri burada, genel amaçlı cihazları Elektronik'te tut. Kimyasal ve güvenlik ürünlerinin taxonomy yerini satış uygunluğundan ayrı değerlendir.

### Owner decisions required

#### AUTO-01 — P0

- **QUESTION:** 11 L2'nin exact adı ve sırası ile `Otomobil`/`Araç` dil ayrımı onaylanacak mı?
- **OPTION A:** Proposal listesini aynen onayla.
- **OPTION B:** Otomobil ve araç terimlerini tek bir kök terime normalize et.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Mevcut adlar müşteri dilini korurken otomobil parçası ile araç-geneli aksesuar/elektronik kapsamını ayırıyor.
- **CROSS-DOMAIN EFFECT:** Ad değişikliği gelecekteki fitment sözlüğünü, synonym'leri ve tüm otomotiv L3/L4 yollarını etkiler.

#### AUTO-02 — P1

- **QUESTION:** Araç-spesifik elektronik, motosiklet interkomu ve EV şarj ürünlerinin Otomotiv ile Elektronik/Yapı Market sınırı nasıl kurulmalı?
- **OPTION A:** Araca montaj, araç protokolü veya belirli araç uyumluluğu ana değer ise `Araç Elektroniği`; genel amaçlı cihaz Elektronik; sabit bina altyapılı wallbox Yapı Market/ayrı owner sınırı.
- **OPTION B:** Bütün elektronik ürünleri Elektronik altında topla.
- **OPTION C:** EV şarj ürünlerinin tamamını Otomotiv altında topla.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Vehicle-specific electronics için ana kullanım ve uyumluluk kanıtı kalıcı, denetlenebilir bir ayrım sağlar; interkom araç/motosiklet-primary ise aynı kurala uyar.
- **CROSS-DOMAIN EFFECT:** Elektronik'te generic kamera, GPS, ses ve giyilebilir ürün sızıntısını; Yapı Market'te sabit elektrik altyapısı sahipliğini belirler.

#### AUTO-03 — P2 — POLICY-SENSITIVE

- **QUESTION:** Motor yağı, araç sıvıları, katkılar, aküler, aerosoller ve yangın söndürücüler hangi uygunluk kapısıyla listelenmeli?
- **OPTION A:** L2'leri koru; ürün türü bazında belge, taşıma, ambalaj ve merchant uygunluk matrisi tamamlanana kadar hassas SKU'ları fail-closed tut.
- **OPTION B:** Tümünü normal ürün olarak aç ve yalnız genel içerik moderasyonu uygula.
- **OPTION C:** Bütün kimyasal/akü/güvenlik ürünlerini taxonomy kapsamından çıkar.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Bunlar gerçek fiziksel otomotiv ürünleridir fakat tehlikeli madde, taşıma, çevre ve güvenlik yükümlülükleri aynı değildir.
- **CROSS-DOMAIN EFFECT:** Yapı Market kimyasalları, Elektronik bataryaları ve genel temizlik ürünleri için ortak policy sınıflandırma sözleşmesi gerekir.

#### AUTO-04 — P1

- **QUESTION:** Araç bakım alet seti hangi kanıtla Otomotiv'de kalmalı?
- **OPTION A:** Ürün tasarımı veya açık uyumluluk yalnız/öncelikle araca özgüyse Otomotiv; genel el aleti ise Yapı Market.
- **OPTION B:** Satıcı `oto bakım` dediği tüm aletleri Otomotiv'e al.
- **OPTION C:** Bütün aletleri Yapı Market'e gönder.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Marketing metni yerine işlev ve fitment kanıtı duplicate leaf oluşmasını önler.
- **CROSS-DOMAIN EFFECT:** Yapı Market el aletleri ile Otomotiv bakım/onarım leaf'leri arasındaki primary-leaf kuralını belirler.

#### AUTO-05 — P0

- **QUESTION:** Ağır ticari araç, tarım aracı ve deniz aracı ürünleri bu tüketici L1'ine dahil mi?
- **OPTION A:** V1'i otomobil ve motosiklet odaklı tut; diğer araç sınıflarını ayrı owner araştırmasına bırak.
- **OPTION B:** Uyumlu ürünleri aynı L2'lere facet ile dahil et.
- **OPTION C:** Şimdi ayrı L2'ler aç.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Proposal kanıtı tüketici otomobil/motosiklet niyetine dayanıyor; genişletme fitment ve merchant modelini maddi biçimde değiştirir.
- **CROSS-DOMAIN EFFECT:** Tarım, endüstriyel ekipman ve denizcilik için gelecekte ayrı domain/scope kararı doğurabilir.

### Low-risk decisions

- `AUTO-01`: Proposal ad/sırasını aynen onaylamak.
- `AUTO-04`: Araç-spesifiklik için ürün işlevi ve uyumluluk kanıtı istemek.

### High-impact decisions

- `AUTO-02`: Araç elektroniği ve EV ürünleri için cross-domain precedence.
- `AUTO-05`: Ağır ticari, tarım ve deniz araçlarının tüketici kapsamı.

### Policy-sensitive decisions

- `AUTO-03`: Yağ, sıvı, katkı, akü, aerosol ve güvenlik ürünlerinin uygunluk matrisi.

## Kitap

### Proposed L2

1. Edebiyat & Kurgu
2. Çocuk & Gençlik Kitapları
3. Eğitim & Ders Kitapları
4. Sınav Hazırlık Kitapları
5. Akademik & Mesleki Kitaplar
6. Araştırma, İnceleme & Düşünce
7. Kişisel Gelişim & Yaşam
8. Sanat, Kültür & Hobi Kitapları
9. Çizgi Roman & Manga
10. Dil Öğrenimi & Sözlükler

### Recommend

Mevcut 10 L2'yi aynı ad ve sırayla koru. V1'i fiziksel kitapla sınırla; dijital kitap, sesli kitap, abonelik ve salt dijital erişimi taxonomy dışında tut. Format, hedef kitle, eğitim seviyesi, sınav ve konu metadata'sını category/facet sözleşmesiyle deterministik yönet.

### Owner decisions required

#### BOOK-01 — P0

- **QUESTION:** Exact 10 L2 onaylanırken dergi, gazete ve süreli yayınlar bu L1'e eklenecek mi?
- **OPTION A:** 10 L2'yi aynen onayla; süreli yayınları mevcut scope dışında ayrı araştırmaya bırak.
- **OPTION B:** Şimdi ayrı bir `Dergi & Süreli Yayınlar` L2'si ekle.
- **OPTION C:** Süreli yayınları konu L2'lerine dağıt.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Mevcut proposal kitap keşfine dayanıyor; süreli yayınların abonelik, sayı/tarih ve güncellik şeması ayrı kanıt gerektirir.
- **CROSS-DOMAIN EFFECT:** Dijital abonelik, koleksiyon ve güncel içerik hizmeti sınırlarını etkiler.

#### BOOK-02 — P0

- **QUESTION:** Kitap domaini fiziksel ürünle mi sınırlı kalmalı, yoksa e-kitap/sesli kitap da dahil edilmeli mi?
- **OPTION A:** V1'de yalnız fiziksel kitap; e-kitap, sesli kitap, indirme kodu ve abonelik excluded.
- **OPTION B:** Dijital formatları aynı L2'lere format facet'iyle al.
- **OPTION C:** Dijital yayınlar için ayrı L2 aç.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Canonical ürün kapsamı fiziksel üründür; dijital lisans, erişim, iade ve teslimat modeli ayrı bir product decision gerektirir.
- **CROSS-DOMAIN EFFECT:** Dijital ürün/hizmet kapsamını, ödeme/teslimat sözleşmesini ve olası Medya domainini etkiler.

#### BOOK-03 — P1

- **QUESTION:** Çizgi roman ve manga, çocuk kitabı veya konu türü yerine format-first L2 olarak mı kalmalı?
- **OPTION A:** `Çizgi Roman & Manga` bağımsız L2 kalsın; yaş grubu ve konu facet olsun.
- **OPTION B:** Çocuk/gençlik ve edebiyat L2'lerine dağıt.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Müşteri araması güçlü biçimde format odaklıdır; çocuk başlıklarını yaş facet'iyle bulmak duplicate leaf yaratmaz.
- **CROSS-DOMAIN EFFECT:** Çocuk ürünleri ve koleksiyon kategorileriyle sınırda primary format kuralını netleştirir.

#### BOOK-04 — P1

- **QUESTION:** Eğitim, sınav hazırlık, akademik/mesleki ve araştırma kitapları arasındaki eşikler nasıl tanımlanmalı?
- **OPTION A:** Açık sınav hedefi varsa `Sınav Hazırlık`; formal ders/müfredat varsa `Eğitim`; uzmanlık/akademik kullanım varsa `Akademik`; genel düşünce/inceleme ise `Araştırma`.
- **OPTION B:** Bunları tek `Eğitim & Araştırma` L2'sinde birleştir.
- **OPTION C:** Satıcı seçimini serbest bırak.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Açık metadata eşikleri hem kullanıcı niyetini korur hem çift atamayı azaltır.
- **CROSS-DOMAIN EFFECT:** Kırtasiye eğitim gereçleri ve mesleki yayınların tek primary leaf kuralını destekler.

#### BOOK-05 — P1

- **QUESTION:** Kullanılmış kitap ile antika/koleksiyon kitabı arasındaki precedence ne olmalı?
- **OPTION A:** Okuma/kullanım değeri primary ise Kitap; nadirlik, baskı, provenance ve koleksiyon değeri primary ise Antika & Koleksiyon.
- **OPTION B:** Yaşı belirli eşiği geçen tüm kitapları Antika & Koleksiyon'a gönder.
- **OPTION C:** Tüm kullanılmış kitapları Kitap'ta tut.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Tek başına yaş, ürünün müşteri niyetini ve değer modelini güvenilir biçimde açıklamaz.
- **CROSS-DOMAIN EFFECT:** Antika & Koleksiyon için provenance/value facetleri ve ikinci el moderasyonu gerekir.

### Low-risk decisions

- `BOOK-03`: Çizgi roman/mangayı format-first L2 olarak korumak.
- `BOOK-04`: Eğitim ve sınav ayrımını açık hedef metadata'sıyla yapmak.

### High-impact decisions

- `BOOK-01`: Süreli yayın kapsamı.
- `BOOK-02`: Fiziksel ve dijital yayın sınırı.
- `BOOK-05`: Kitap ile Antika & Koleksiyon precedence'i.

### Policy-sensitive decisions

- Bu domain için mevcut proposal'da ayrı regulatory/policy-sensitive owner kararı yoktur; dijital kapsam ticari ürün kararıdır.

## Kırtasiye & Ofis

### Proposed L2

1. Kalem & Yazım Gereçleri
2. Defter, Ajanda & Planlayıcılar
3. Kağıt, Etiket & Baskı Sarfı
4. Dosyalama & Arşivleme
5. Masaüstü Ofis Gereçleri
6. Yapıştırıcı, Bant & Kesim Gereçleri
7. Okul Kırtasiyesi & Eğitim Gereçleri
8. Sanat & Çizim Malzemeleri
9. Sunum, Pano & Yazı Tahtası Ürünleri
10. Ofis Makineleri & Ciltleme Ekipmanları
11. Paketleme & Postalama Ürünleri

### Recommend

Mevcut 11 L2'yi aynı ad ve sırayla koru. Canonical toner/kartuş kararını yeniden açma: cihaz ve cihaz-uyumluluk odaklı toner/kartuş Bilgisayar & Tablet'te; genel kağıt, etiket ve termal rulo Kırtasiye & Ofis'te kalır. Okul, sanat ve ofis niyetlerini ürün işleviyle ayır; marka ya da kullanıcı yaşı category olmasın.

### Owner decisions required

#### STAT-01 — P0

- **QUESTION:** Exact 11 L2 adı ve sırası onaylanacak mı?
- **OPTION A:** Proposal listesini aynen onayla.
- **OPTION B:** Okul veya sanat gruplarını temel ürün gruplarına dağıtarak listeyi küçült.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Liste fiziksel perakende keşfini koruyor ve ürün/niyet ailelerini facetlerden ayırıyor.
- **CROSS-DOMAIN EFFECT:** Kitap, Bilgisayar & Tablet, Hobi ve Ev & Yaşam sınırlarını sabitler.

#### STAT-02 — P1

- **QUESTION:** `Okul Kırtasiyesi & Eğitim Gereçleri` hangi ürünleri kabul etmeli?
- **OPTION A:** Yalnız school-specific set, eğitim yardımcısı ve açık okul işlevli ürünleri al; kalem/defter gibi genel ürünler kendi canonical leaf'inde kalsın.
- **OPTION B:** Okulda kullanılabilen bütün ürünleri bu L2'ye kopyala.
- **OPTION C:** Bu L2'yi kaldırıp tüm ürünleri işlev L2'lerine dağıt.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Okul kullanım bağlamı tek başına ürün türü değildir; strict eligibility duplicate leaf'i önler.
- **CROSS-DOMAIN EFFECT:** Kitap/Eğitim ile çocuk ürünleri sınırında product-versus-context kuralı oluşur.

#### STAT-03 — P1

- **QUESTION:** Toner/kartuş ve label printer ailesi nasıl ayrılmalı?
- **OPTION A:** Canonical kararı koru: toner/kartuş ve cihaz-spesifik baskı sarfı Bilgisayar & Tablet; genel kağıt/etiket/termal rulo burada. Label printer cihazı için ana kullanım ve cihaz ailesi temelli ayrı owner boundary uygula.
- **OPTION B:** Bütün baskı sarfını Kırtasiye & Ofis'e taşı.
- **OPTION C:** Bütün etiket ürünlerini Bilgisayar & Tablet'e taşı.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Toner/kartuş kararı Owner tarafından zaten finaldir; sarfın fiziksel biçimi değil cihaz uyumluluğu belirleyicidir.
- **CROSS-DOMAIN EFFECT:** Bilgisayar & Tablet → Yazıcı, Tarayıcı & Sarf Malzemeleri ile duplicate oluşmasını engeller.

#### STAT-04 — P1

- **QUESTION:** Kalem kutusu, evrak çantası ve masaüstü organizer hangi primary-function kuralıyla ayrılmalı?
- **OPTION A:** Yazım aracı taşıma/okul işlevi burada; genel moda çantası Giyim & Aksesuar; ev/dekor storage Ev & Yaşam.
- **OPTION B:** Boyutu küçük bütün çanta ve kutuları Kırtasiye'ye al.
- **OPTION C:** Bütün çanta/kutuları Giyim veya Ev & Yaşam'a gönder.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Ürün formu benzer olsa da ana kullanım farklıdır; kullanım amacı daha kalıcıdır.
- **CROSS-DOMAIN EFFECT:** Giyim & Aksesuar ve Ev & Yaşam ile storage/bag precedence'ini belirler.

#### STAT-05 — P2 — POLICY-SENSITIVE

- **QUESTION:** Laminasyon/ciltleme sarfı ile kesici, solventli yapıştırıcı ve sanat kimyasalları nasıl yönetilmeli?
- **OPTION A:** Makine-spesifik sarfı principal cihaz ailesine ata; kesici ve kimyasal ürünleri yaş, tehlike, taşıma ve ürün uygunluk matrisiyle fail-closed değerlendir.
- **OPTION B:** Bütün sarfları `Kağıt, Etiket & Baskı Sarfı`na, bütün kimyasalları normal kırtasiye olarak al.
- **OPTION C:** Hassas ürünlerin tamamını exclude et.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Compatibility kategoriden, tehlike sınıfı da taxonomy derinliğinden ayrılmalıdır.
- **CROSS-DOMAIN EFFECT:** Ofis makineleri, Sanat & Hobi ve Yapı Market kimyasalları için ortak uygunluk alanları gerekir.

### Low-risk decisions

- `STAT-01`: Exact 11 L2'yi onaylamak.
- `STAT-02`: Okul L2'sini strict school-specific eligibility ile sınırlamak.
- `STAT-03`: Toner/kartuş için mevcut canonical kararı korumak.

### High-impact decisions

- `STAT-04`: Çanta/kutu/organizer için Giyim ve Ev & Yaşam sınırı.

### Policy-sensitive decisions

- `STAT-05`: Kesici ve kimyasal ürünler için fail-closed uygunluk matrisi.

## Evcil Hayvan Ürünleri

### Proposed L2

1. Kedi Ürünleri
2. Köpek Ürünleri
3. Akvaryum & Balık Ürünleri
4. Kuş Ürünleri
5. Küçük Hayvan Ürünleri
6. Sürüngen & Egzotik Pet Ürünleri
7. Ortak Pet Bakım & Aksesuarları

### Recommend

Mevcut 7 L2'yi species-first omurga olarak koru; işlev ailelerini gelecekte L3, türü ayrıca zorunlu typed facet yap. `Ortak Pet Bakım & Aksesuarları` yalnız gerçekten çok-türlü/evrensel ve dominant türü olmayan ürünlere açık olsun; catch-all olarak kullanılmasın. Canlı hayvan ve veteriner ilacı kapsam dışı kalsın.

### Owner decisions required

#### PET-01 — P0

- **QUESTION:** Yedi species-first L2 ve türün ayrıca typed facet olması onaylanacak mı?
- **OPTION A:** Proposal'daki 7 L2'yi koru; gelecekte işlev-first L3 ve required species facet kullan.
- **OPTION B:** L2'yi mama, bakım, oyuncak gibi function-first kur.
- **OPTION C:** Tür ve işlevi paralel L2'ler olarak birlikte kullan.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Türkiye müşteri dili türle başlıyor; function-first L3 ile büyürken paralel L2 duplicate'i yaratmıyor.
- **CROSS-DOMAIN EFFECT:** Canlı hayvan, Gıda, Sağlık ve Elektronik sınırlarında tür metadata'sı ortak filtre olarak kullanılabilir.

#### PET-02 — P1

- **QUESTION:** `Ortak Pet Bakım & Aksesuarları`na giriş eşiği ne olmalı?
- **OPTION A:** Yalnız birden çok tür için gerçekten aynı fiziksel ürün ve dominant species niyeti olmayan SKU'lar.
- **OPTION B:** Türü eksik bildirilen her ürünü buraya al.
- **OPTION C:** Ortak L2'yi kaldır ve her ürünü bir species leaf'ine zorla.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Strict rule, veri eksikliğini category'ye dönüştürmeden evrensel ürünleri kapsar.
- **CROSS-DOMAIN EFFECT:** Merchant onboarding'de species bilgisinin zorunluluğunu ve katalog kalite kontrollerini etkiler.

#### PET-03 — P2 — POLICY-SENSITIVE

- **QUESTION:** Veteriner ürünü, reçeteli diyet, supplement, pire/kene ürünü ve medikal tasma nasıl açılmalı?
- **OPTION A:** Veteriner ilaçlarını excluded tut; diğer hassas ürünleri authoritative ürün/merchant matrisi tamamlanana kadar fail-closed sınıflandır.
- **OPTION B:** Pet etiketi taşıyan tüm ürünleri normal listing'e aç.
- **OPTION C:** Bütün bakım ve beslenme ürünlerini exclude et.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Aynı müşteri dili altında gıda, biyosidal, veteriner ve aksesuar rejimleri karışabilir; category satış yetkisi vermez.
- **CROSS-DOMAIN EFFECT:** Sağlık & Medikal, Gıda & Market ve kimyasal ürün policy'siyle uyum gerekir.

#### PET-04 — P1

- **QUESTION:** Pet kamerası, GPS tracker ve otomatik besleyici Pet mi Elektronik mi olmalı?
- **OPTION A:** Pet bakım/izleme işlevi ve pet-specific form/uyumluluk primary ise species/common pet leaf; generic kamera/GPS/smart-home cihazı Elektronik.
- **OPTION B:** Bağlantılı bütün ürünleri Elektronik'e gönder.
- **OPTION C:** Pet etiketi taşıyan bütün elektronik ürünleri Pet'e al.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Primary function ve product-specific evidence, marketing etiketinden daha deterministiktir.
- **CROSS-DOMAIN EFFECT:** Elektronik → kamera, konum ve akıllı ev yapısıyla duplicate'i engeller.

#### PET-05 — P1 — POLICY-SENSITIVE

- **QUESTION:** Canlı akvaryum bitkisi/yem, canlı hayvan ve hobby-farm/poultry ürünlerinin sınırı ne olmalı?
- **OPTION A:** Canlı hayvanı V1'de excluded tut; canlı bitki/yemi ayrı live-product policy kararına bırak; consumer pet olmayan çiftlik ekipmanını scope dışı tut.
- **OPTION B:** Pet mağazasında satılan tüm canlı ve çiftlik ürünlerini bu L1'e al.
- **OPTION C:** Tüm akvaryum canlı ürünlerini Çiçek & Bahçe'ye gönder.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Canlı ürün fulfilment'i ile pet türü taxonomy'si aynı karar değildir; hobby-farm da consumer pet evidence'ını aşar.
- **CROSS-DOMAIN EFFECT:** Çiçek & Bahçe canlı bitki, Gıda canlı yem ve olası Tarım/Hayvancılık kapsamını etkiler.

### Low-risk decisions

- `PET-02`: Ortak pet L2'sini strict eligibility ile sınırlamak.

### High-impact decisions

- `PET-01`: Species-first omurga ve species facet sözleşmesi.
- `PET-04`: Pet elektroniği precedence'i.
- `PET-05`: Canlı ürün ve hobby-farm kapsamı.

### Policy-sensitive decisions

- `PET-03`: Veteriner, reçeteli diyet, supplement ve pire/kene ürünleri.
- `PET-05`: Canlı ürünlerin fail-closed kapsam kararı.

## Gözlük & Optik

### Proposed L2

1. Optik Gözlük Çerçeveleri
2. Güneş Gözlükleri
3. Hazır Okuma Gözlükleri
4. Gözlük Camları
5. Kontakt Lensler
6. Kontakt Lens Bakım Ürünleri
7. Gözlük & Optik Aksesuarları

### Recommend

Mevcut 7 L2'yi aynı ad ve sırayla koru. Fiziksel çerçeve/cam/lens ürününü ölçüm, kesim, fitting ve muayene hizmetinden ayır. Reçeteli/custom optik, hazır okuma gözlüğü, kontakt lens ve lens bakım ürünlerini authoritative merchant/product eligibility tamamlanana kadar fail-closed tut; kozmetik/renkli kontakt lensi normal fashion ürünü sayma.

### Owner decisions required

#### OPT-01 — P0

- **QUESTION:** Exact 7 L2 adı ve sırası onaylanacak mı?
- **OPTION A:** Proposal listesini aynen onayla.
- **OPTION B:** Çerçeve ve camı tek `Optik Gözlük` L2'sinde birleştir.
- **OPTION C:** Kontakt lens ve bakım ürünlerini tek L2'de birleştir.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Çerçeve, custom cam, bitmiş gözlük, kontakt lens ve bakım ürünleri farklı attribute, fulfilment ve policy kapıları taşır.
- **CROSS-DOMAIN EFFECT:** Sağlık & Medikal, Moda, Spor & Outdoor ve Elektronik sınırlarını etkiler.

#### OPT-02 — P1

- **QUESTION:** `Gözlük Camları` fiziksel ürünü ile kesim, ölçüm, fitting ve optisyenlik hizmeti nasıl ayrılmalı?
- **OPTION A:** Yalnız teslim edilen fiziksel cam/ürün listelenir; muayene, ölçüm, fitting ve salt hizmet Product Taxonomy dışında kalır.
- **OPTION B:** Fiziksel ürün ve hizmet aynı listing'de serbestçe birleştirilir.
- **OPTION C:** Custom camın tamamı scope dışı bırakılır.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Canonical taxonomy fiziksel ürünü sınıflandırır; hizmet akışı farklı yetki, fiyat ve teslim sözleşmesi gerektirir.
- **CROSS-DOMAIN EFFECT:** Genel hizmet/rezervasyon kapsamını ve bundle/listing contract'ını etkiler.

#### OPT-03 — P2 — POLICY-SENSITIVE

- **QUESTION:** Reçeteli/custom cam, çerçeve ve hazır okuma gözlüğü için merchant/product eligibility nasıl uygulanmalı?
- **OPTION A:** Yetkili legal/policy matrisi; merchant doğrulaması, ürün statüsü, claim ve gerekli belgelere göre fail-closed gate.
- **OPTION B:** Category assignment ile otomatik satış izni ver.
- **OPTION C:** Tüm optik ürünleri exclude et.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Kategori yeri ile optisyenlik/tıbbi cihaz/satış yetkisi aynı şey değildir; kesin statü yetkili kaynakla doğrulanmalıdır.
- **CROSS-DOMAIN EFFECT:** Sağlık & Medikal cihaz uygunluğu, merchant onboarding ve hassas ölçüm verisi süreçleriyle ortak kontrol gerekir.

#### OPT-04 — P2 — POLICY-SENSITIVE

- **QUESTION:** Kontakt lens ve lens bakım ürünleri, kozmetik/renkli lens dahil, hangi launch posture ile ele alınmalı?
- **OPTION A:** Amaç veya renk ayrımı yapmadan bütün kontakt lensleri aynı fail-closed legal/product gate'e al; bakım ürünlerine kendi uygunluk matrisi uygula.
- **OPTION B:** Reçetesiz/renkli lensleri normal moda ürünü olarak aç.
- **OPTION C:** Kontakt lens ve bakım ürünlerini kalıcı olarak exclude et.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Gözle temas ve ürün statüsü kullanım niyetiyle ortadan kalkmaz; bakım ürünü lensin kendisiyle aynı SKU sınıfı değildir.
- **CROSS-DOMAIN EFFECT:** Moda amaçlı ürünlerin Sağlık/Optik policy'sini baypas etmesini önler.

#### OPT-05 — P1 — POLICY-SENSITIVE

- **QUESTION:** Mavi ışık gözlüğü, spor/iş güvenliği gözlüğü, numaralı spor gözlüğü ve akıllı gözlükte precedence ne olmalı?
- **OPTION A:** Primary function kuralı: custom/vision optic burada; sport/PPE primary ise Spor veya OHS owner domaini; bağlantı/display/audio/camera primary ise Elektronik; medical claim ayrıca legal gate.
- **OPTION B:** Gözlük formundaki bütün ürünleri Gözlük & Optik'e al.
- **OPTION C:** Bütün hybrid ürünleri Elektronik'e gönder.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Fiziksel form tek başına ürünün ana işlevini açıklamaz; claim ve custom prescription ayrı policy kanıtıdır.
- **CROSS-DOMAIN EFFECT:** Elektronik, Spor & Outdoor, Yapı Market/OHS ve Sağlık & Medikal leaf sahipliğini belirler.

### Low-risk decisions

- `OPT-01`: Exact 7 L2'yi yapısal olarak onaylamak.
- `OPT-02`: Fiziksel ürün ile salt hizmeti ayırmak.

### High-impact decisions

- `OPT-05`: Hybrid, spor, OHS ve smart eyewear precedence'i.

### Policy-sensitive decisions

- `OPT-03`: Reçeteli/custom optik ve merchant eligibility.
- `OPT-04`: Kontakt lens ve bakım ürünü launch gate'i.
- `OPT-05`: Medical claim veya koruyucu işlev taşıyan hybrid ürünler.

## Saat & Takı

### Proposed L2

1. Klasik Kol Saatleri
2. Cep Saatleri
3. Saat Kayışları & Aksesuarları
4. Kolyeler & Takı Uçları
5. Küpeler
6. Yüzükler
7. Bileklik, Bilezik & Halhallar
8. Broş & Giyim Takıları
9. Vücut Takıları
10. Takı Aksesuarları & Saklama
11. Takı Yapım Malzemeleri

### Recommend

Mevcut 11 L2'yi form/use-first yapıyla koru; materyal, değer, cinsiyet ve taş türünü facet yap. Smartwatch ve smart ring'i Elektronik → Giyilebilir Teknoloji'de tut. Değerli metal/taş ve high-value ürünleri taxonomy'de ilgili form leaf'ine atasa bile seller, provenance, doğruluk ve güvenli ticaret kapısı olmadan satışa açma.

### Owner decisions required

#### WATCH-01 — P0

- **QUESTION:** Exact 11 L2 onaylanırken `Cep Saatleri` bağımsız L2 olarak kalmalı mı?
- **OPTION A:** Proposal listesini aynen koru; cep saatini ayrı L2 bırak.
- **OPTION B:** Cep saatini `Klasik Kol Saatleri` ile daha genel `Klasik Saatler` altında birleştir.
- **OPTION C:** Cep saatini Antika & Koleksiyon'a taşı.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Cep saati farklı kullanım/arama niyeti taşır; antika oluşu ürün formundan değil provenance ve değer niyetinden çıkar.
- **CROSS-DOMAIN EFFECT:** Antika & Koleksiyon sınırını ve düşük hacimli leaf kabul eşiğini etkiler.

#### WATCH-02 — P1

- **QUESTION:** Smartwatch, smart ring ve hibrit analog-smart saat için exclusion/precedence kuralı ne olmalı?
- **OPTION A:** App, sensör veya bağlantı ana değer ise Elektronik → Giyilebilir Teknoloji; pasif klasik timepiece ana değer ise Klasik Kol Saatleri.
- **OPTION B:** Saat veya yüzük formundaki bütün ürünleri Saat & Takı'ya al.
- **OPTION C:** Bütün hibrit saatleri Elektronik'e gönder.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Smart işlev ürünün ana değeriyse fiziksel form kategori sahipliğini değiştirmemelidir.
- **CROSS-DOMAIN EFFECT:** Elektronik → Giyilebilir Teknoloji ile canonical smartwatch exclusion'ını korur.

#### WATCH-03 — P0 — POLICY-SENSITIVE

- **QUESTION:** Değerli metal/taş, high-value jewelry, investment gold/sikke ve loose gemstone kapsamı nasıl yönetilmeli?
- **OPTION A:** Bitmiş takıyı form leaf'inde tut fakat eşik, seller doğrulama, ayar/sertifika/provenance, güvenli ödeme/teslimat/iade ve fraud kontrolleri tamamlanana kadar fail-closed; yatırım ürünü ve loose stone'u ayrı owner/legal kararı olmadan açma.
- **OPTION B:** Materyal beyanıyla bütün high-value ürünleri normal listing'e aç.
- **OPTION C:** Değerli ürünlerin tamamını taxonomy'den çıkar.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Material/value category değildir fakat özgünlük, mülkiyet ve yüksek değer riski ticari/policy readiness gerektirir.
- **CROSS-DOMAIN EFFECT:** Antika & Koleksiyon, yatırım ürünü kapsamı, ödeme/fraud ve güvenli lojistik kararlarını etkiler.

#### WATCH-04 — P1

- **QUESTION:** Çok-form takı seti hangi canonical leaf'e atanmalı?
- **OPTION A:** Principal ürün leaf'i; set/bundle facet. Eşit ağırlıklı sette deterministik öncelik kuralı kullan.
- **OPTION B:** Ayrı `Takı Setleri` L2'si aç.
- **OPTION C:** Aynı ürünü birden çok leaf'e ata.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Canonical bundle kuralı ayrı kategori veya çoklu primary leaf oluşturmaz.
- **CROSS-DOMAIN EFFECT:** Tüm taxonomy'deki bundle/kit davranışıyla tutarlılığı korur.

#### WATCH-05 — P1

- **QUESTION:** Saat pili ile generic button-cell battery sınırı nasıl kurulmalı?
- **OPTION A:** Açık watch-specific uyumluluk ve kullanım varsa `Saat Kayışları & Aksesuarları`; generic pil Elektronik'teki uygun batarya leaf'i.
- **OPTION B:** Tüm button-cell pilleri Saat & Takı'ya al.
- **OPTION C:** Saat pilini de her durumda Elektronik'e gönder.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Compatibility-led accessory ile genel enerji ürünü arasında doğrulanabilir ayrım sağlar.
- **CROSS-DOMAIN EFFECT:** Elektronik batarya taxonomy'si ve device-specific consumable kuralıyla uyum gerekir.

### Low-risk decisions

- `WATCH-02`: Smartwatch ve smart ring exclusion'ını korumak.
- `WATCH-04`: Bundle'ı facet olarak tutmak.
- `WATCH-05`: Watch-specific pil ile generic pili ayırmak.

### High-impact decisions

- `WATCH-01`: Cep saatinin bağımsız L2 olması.
- `WATCH-03`: High-value, investment ve loose gemstone ticari kapsamı.

### Policy-sensitive decisions

- `WATCH-03`: Değerli/high-value takı ve yatırım niteliğindeki ürünlerin uygunluk kapısı.

## Sağlık & Medikal

### Proposed L2

1. İlk Yardım & Yara Bakımı
2. Evde Sağlık Ölçüm Cihazları
3. Ortopedik Destekler & Kompresyon
4. Hareket & Mobilite Yardımcıları
5. Rehabilitasyon & Fizik Tedavi Ürünleri
6. Solunum & Evde Bakım Cihazları
7. Medikal Sarf & Hasta Bakım Ürünleri
8. Kişisel Koruyucu Medikal Ürünler
9. Günlük Yaşam & Erişilebilirlik Yardımcıları

### Recommend

Mevcut 9 L2'yi aynı ad ve sırayla, fail-closed launch posture ile koru. Reçeteli/kısıtlı ilaçları kapsam dışında tut; supplement/takviye ürününü bu L2'lere atama ve ayrı owner/legal scope kararı olmadan açma. Cihaz, sarf, PPE, ortopedik ve solunum ürünlerinde exact SKU/merchant/registration ve claim doğrulaması category assignment'tan ayrı zorunlu kapı olsun.

### Owner decisions required

#### HLTH-01 — P0

- **QUESTION:** Exact 9 L2 ve domain-geneli fail-closed launch posture onaylanacak mı?
- **OPTION A:** Proposal listesini aynen koru; ürün/merchant uygunluğu doğrulanmadan satışa açma.
- **OPTION B:** L2'leri onayla ve tüm ürünleri varsayılan açık kabul et.
- **OPTION C:** Sağlık & Medikal domainini bütünüyle ertele.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Yapı kullanıcı keşfini karşılar; risk ürün bazında değiştiği için taxonomy onayı otomatik satış izni olmamalıdır.
- **CROSS-DOMAIN EFFECT:** Merchant onboarding, moderation, recall ve compliance altyapısında domain-geneli gate gerektirir.

#### HLTH-02 — P0 — POLICY-SENSITIVE

- **QUESTION:** Reçeteli/kısıtlı ilaçlar ve supplement/takviye ürünleri V1 kapsamına nasıl alınmalı?
- **OPTION A:** Reçeteli/kısıtlı ilaçlar excluded; supplement/takviye mevcut 9 L2'ye alınmaz ve ayrı owner/legal proposal olmadan açılmaz.
- **OPTION B:** Supplement'i `Günlük Yaşam` veya `Hasta Bakım` içine al; ilaçları merchant belgesiyle aç.
- **OPTION C:** İlaç ve supplement için şimdi yeni L2'ler ekle.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** İlaç ve takviye, mevcut fiziksel cihaz/sarf taxonomy'sinden farklı yasal ve claim rejimleri taşır; belirsizlik fail-closed kalmalıdır.
- **CROSS-DOMAIN EFFECT:** Gıda & Market, Kozmetik/Kişisel Bakım ve veteriner ürünleri için de kapsam/claim sınırı oluşturur.

#### HLTH-03 — P2 — POLICY-SENSITIVE

- **QUESTION:** Tıbbi cihaz, sarf, PPE, ortopedik ve solunum ürünleri için hangi listing kanıtları zorunlu olmalı?
- **OPTION A:** Authoritative risk sınıfı/registration, conformity, traceability, seller authorization, intended use, advertisement claim ve recall alanlarından oluşan exact eligibility matrisi.
- **OPTION B:** Satıcının kategori seçimini yeterli kabul et.
- **OPTION C:** Tüm medikal cihazları exclude et.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Risk ve satış uygunluğu SKU türüne göre değişir; policy class category depth değildir.
- **CROSS-DOMAIN EFFECT:** Gözlük & Optik, PPE/OHS ve app-connected sağlık cihazlarında ortak compliance verisi gerekir.

#### HLTH-04 — P0 — POLICY-SENSITIVE

- **QUESTION:** Professional-only, invasive/sterile, diagnostic, implantable ve diğer high-risk ürünlerin consumer marketplace eşiği ne olmalı?
- **OPTION A:** Yetkili legal/product matrisi açıkça izin vermedikçe excluded veya fail-closed; profesyonel ürünleri normal consumer leaf'e sessizce alma.
- **OPTION B:** Merchant profesyonel olduğunu beyan ederse aç.
- **OPTION C:** Tüm home-care ürünlerini normal consumer ürün kabul et.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Profesyonel intended use ve risk sınıfı, ürünün evde kullanılabilir görünmesinden çıkarılamaz.
- **CROSS-DOMAIN EFFECT:** B2B/merchant-equipment kapsamı ve ilerideki profesyonel katalog kararı üzerinde yüksek etkilidir.

#### HLTH-05 — P1 — POLICY-SENSITIVE

- **QUESTION:** Wellness cihazı ile medical intended-use ürünü; smart scale, masaj tabancası, ortopedik yastık ve hospital bed gibi sınır ürünler nasıl ayrılmalı?
- **OPTION A:** Kanıtlanmış intended use/registration ve primary function kuralı; medical ürün ilgili Health leaf'ine legal gate ile, consumer wellness ürünü Spor/Elektronik/Ev & Yaşam'a. Recall/UDI/health-data gereksinimleri ayrı readiness workstream'i.
- **OPTION B:** Sağlık çağrışımı taşıyan tüm ürünleri Health'e al.
- **OPTION C:** Bağlantılı tüm ürünleri Elektronik'e gönder.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Marketing claim tek başına medical classification değildir; kişisel sağlık verisi de taxonomy facet'i değildir.
- **CROSS-DOMAIN EFFECT:** Elektronik, Spor & Outdoor, Ev & Yaşam ve veri gizliliği/recall altyapısını etkiler.

### Low-risk decisions

- L2 adlarının kendisi araştırma açısından tutarlıdır; düşük riskli görünen karar bile fail-closed satış kapısını kaldırmaz.

### High-impact decisions

- `HLTH-01`: Domain-geneli launch posture.
- `HLTH-02`: İlaç ve supplement kapsamı.
- `HLTH-04`: Profesyonel/high-risk consumer eşiği.

### Policy-sensitive decisions

- `HLTH-02`: Reçeteli/kısıtlı ürün ve supplement scope'u.
- `HLTH-03`: Cihaz/sarf/PPE eligibility matrisi.
- `HLTH-04`: Professional-only, invasive ve high-risk ürünler.
- `HLTH-05`: Medical intended use, claim, recall ve health-data sınırı.

## Çiçek & Bahçe

### Proposed L2

1. Canlı Saksı Bitkileri
2. Kesme Çiçek & Fiziksel Aranjmanlar
3. Tohum, Fide & Bitki Soğanları
4. Yapay Çiçek & Yapay Bitkiler
5. Saksı, Saksılık & Bitki Kapları
6. Toprak, Gübre & Bitki Besleme
7. Sulama Ürünleri
8. Bahçe El Aletleri
9. Bitki Bakım & Yetiştirme Ürünleri
10. Sera & Yetiştirme Ekipmanları
11. Bahçe Dekorasyonu & Peyzaj Aksesuarları

### Recommend

Mevcut 11 L2'yi aynı ad ve sırayla koru. Canlı bitki/tohum/fide için kayıt, traceability ve fulfilment kararı olmadan normal launch yapma. Ruhsatlı bitki koruma ürünlerini online satıştan fail-closed exclude et; gübre ve bitki besinini ayrı eligibility matrisiyle değerlendir. Yalnız fiziksel çiçek/aranjman ürününü sınıflandır; bakım, yerleştirme, abonelik ve salt teslimat hizmetini Product Taxonomy dışında tut.

### Owner decisions required

#### FLWR-01 — P0

- **QUESTION:** Exact 11 L2 adı ve sırası onaylanacak mı?
- **OPTION A:** Proposal listesini aynen onayla.
- **OPTION B:** Canlı saksı bitkisi ile tohum/fide/soğanı tek `Canlı Bitkiler` L2'sinde birleştir.
- **OPTION C:** Sulama, sera ve bahçe aletlerini Yapı Market'e taşı.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Canlı ürün, üretim materyali, durable ekipman ve dekor farklı schema/niyet taşır; mevcut liste micro-category üretmeden bunları ayırır.
- **CROSS-DOMAIN EFFECT:** Yapı Market, Ev & Yaşam, Gıda ve Evcil Hayvan sınırlarını belirler.

#### FLWR-02 — P2 — POLICY-SENSITIVE

- **QUESTION:** Canlı bitki, tohum, fide ve bitki soğanlarının launch/fulfilment eşiği ne olmalı?
- **OPTION A:** Kayıt, yetkili seller, bitki pasaportu/traceability, tür uygunluğu, local-delivery/seasonality ve return kuralları doğrulanana kadar fail-closed; mature plant ile fideyi intended growth/maturity ile ayır.
- **OPTION B:** Bütün canlı bitki ürünlerini normal kargo ürünü olarak aç.
- **OPTION C:** Canlı ürünlerin tamamını kalıcı exclude et.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Taxonomy yeri açıktır fakat canlı fulfilment ve ürün uygunluğu tür/SKU bazında ayrıca doğrulanmalıdır.
- **CROSS-DOMAIN EFFECT:** Evcil Hayvan canlı ürünleri, Gıda amaçlı canlı bitki ve lojistik/iade politikalarını etkiler.

#### FLWR-03 — P2 — POLICY-SENSITIVE

- **QUESTION:** Pestisit/bitki koruma ürünü ile gübre/bitki besini nasıl yönetilmeli?
- **OPTION A:** Ruhsatlı bitki koruma ürünlerini online listing/satışta fail-closed exclude et; gübre/bitki besinini registration, composition, label, claim, seller ve taşıma matrisiyle değerlendir.
- **OPTION B:** İkisini de `Toprak, Gübre & Bitki Besleme` altında normal aç.
- **OPTION C:** Bütün kimyasal bahçe ürünlerini exclude et.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Mevcut araştırma iki ürün grubunun aynı satış rejiminde olmadığını gösteriyor; bu özet hukuki tavsiye yerine authoritative doğrulama gereğini kaydeder.
- **CROSS-DOMAIN EFFECT:** Yapı Market/Ev & Yaşam biyosidal ve kimyasal ürün ingestion kurallarıyla ortak fail-closed enforcement gerekir.

#### FLWR-04 — P1 — POLICY-SENSITIVE

- **QUESTION:** Plant-first grow light/akıllı sulama, yenilebilir saksı bitkisi ve akvaryum canlı bitkisi için precedence ne olmalı?
- **OPTION A:** Primary function: plant-specific yetiştirme/sulama ürünü burada; generic lamp/hub Elektronik; immediate food-consumption primary ise Gıda; aquatic habitat primary ise Evcil Hayvan. Canlı ürün gate'i her durumda korunur.
- **OPTION B:** Elektronik içeren her ürünü Elektronik'e, yenilebilir her bitkiyi Gıda'ya gönder.
- **OPTION C:** Bitki formundaki her ürünü Çiçek & Bahçe'ye al.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Ürün formu, teknoloji veya yenilebilirlik tek başına ana müşteri niyetini belirlemez; live-product riski cross-domain geçişte kaybolmamalıdır.
- **CROSS-DOMAIN EFFECT:** Elektronik, Gıda & Market ve Evcil Hayvan taxonomy/policy sözleşmesini etkiler.

#### FLWR-05 — P1

- **QUESTION:** Fiziksel çiçek/aranjman ile tasarım, yerleştirme, bakım, abonelik ve teslim hizmeti nasıl ayrılmalı?
- **OPTION A:** Teslim edilen fiziksel buket/aranjman principal product ise burada; salt hizmet ve abonelik Product Taxonomy dışında. Ürün+hizmet paketinde fiziksel ürün açıkça ayrıştırılmalı.
- **OPTION B:** Çiçekle ilişkili tüm hizmetleri aynı listing altında aç.
- **OPTION C:** Aranjmanların tamamını hizmet sayıp exclude et.
- **RECOMMENDED OPTION:** OPTION A.
- **WHY:** Fiziksel aranjman gerçek bir üründür; hizmet süresi, personel ve abonelik davranışı ise farklı commerce contract gerektirir.
- **CROSS-DOMAIN EFFECT:** Hizmet marketplace kapsamı, düğün/etkinlik ve teslimat ücretlerinin taxonomy dışı yönetimini belirler.

### Low-risk decisions

- `FLWR-01`: Exact 11 L2'yi yapısal olarak onaylamak.
- `FLWR-05`: Fiziksel ürün ile salt hizmeti ayırmak.

### High-impact decisions

- `FLWR-02`: Canlı ürün launch/fulfilment kapsamı.
- `FLWR-04`: Elektronik, Gıda ve Evcil Hayvan precedence'i.

### Policy-sensitive decisions

- `FLWR-02`: Canlı bitki/tohum/fide uygunluğu ve fulfilment.
- `FLWR-03`: Online bitki koruma exclusion'ı ve gübre eligibility'si.
- `FLWR-04`: Cross-domain canlı ürün gate'inin korunması.

## Final summary

| Ölçü | Sonuç |
|---|---:|
| Total L1 | 8 |
| Total proposed L2 | 77 |
| Total owner decisions | 40 |
| P0 | 13 |
| P1 | 19 |
| P2 | 8 |
| Regulatory/policy-sensitive | 15 |

### Likely approve-as-is domains

L2 omurgası açısından `Otomotiv & Motosiklet`, `Kitap` ve `Kırtasiye & Ofis` proposal'ları araştırma kanıtıyla doğrudan onaya en yakın gruptur. Bu ifade boundary/policy kararlarının otomatik onaylandığı anlamına gelmez; özellikle araç elektroniği/kimyasalları, fiziksel-dijital kitap sınırı ve baskı sarfı kararları yine kayda geçirilmelidir.

### Domains requiring substantive owner review

- `Evcil Hayvan Ürünleri`: species-first yapı, ortak ürün eşiği, veteriner/canlı ürün kapsamı.
- `Gözlük & Optik`: prescription/custom ürün, kontakt lens ve hybrid eyewear policy'si.
- `Saat & Takı`: cep saati leaf'i ile precious/high-value/investment ürün kapsamı.
- `Sağlık & Medikal`: fail-closed launch, supplement, restricted/professional cihaz ve merchant eligibility.
- `Çiçek & Bahçe`: canlı ürün fulfilment'i, bitki koruma exclusion'ı ve ürün-hizmet ayrımı.

### Fast review order

1. Önce 13 adet **P0** kararıyla L2 omurgalarını ve launch kapsamlarını kilitle.
2. Ardından 19 adet **P1** kararıyla cross-domain precedence ve gelecekteki L3/L4 sınırlarını onayla.
3. Son olarak 8 adet **P2** kararını policy/facet uygulama işlerine ata.
4. **POLICY-SENSITIVE** 15 kararın hiçbirini yalnız taxonomy onayıyla satış izni sayma; authoritative hukuk/policy doğrulaması tamamlanana kadar fail-closed bırak.

Bu digest onay kaydı değildir. Product Owner kararları ilgili proposal'lara ayrı finalization göreviyle işlenmelidir.
