# Çanta & Aksesuar L2 Taksonomi Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW**

- Canonical L1: `Çanta & Aksesuar`
- Önerilen L2 sayısı: **10**
- Bu belge owner-final karar veya runtime taksonomisi değildir.
- L3/L4 örnekleri yalnız gelecek genişleyebilirlik kontrolüdür.

## 2. Scope

Bu alan, taşıma işlevi baskın çantaları, seyahat bagajını ve günlük giyim tamamlayıcılarını kapsar. Amaç; Türkiye'deki yerel çanta, valiz ve aksesuar mağazalarını bulunabilir kılarken marka, hedef cinsiyet, malzeme ve kullanım cihazını kategoriye dönüştürmemektir.

Ana ilke: Bir ürünün kimliği “bir şeyi taşımak veya giyimi tamamlamak” ise bu L1 güçlü adaydır. Taşınan cihaz veya kullanım senaryosu çoğunlukla uyumluluk/facet bilgisidir.

## 3. Sources reviewed

| Kaynak | Kullanılan sinyal | Sınırlama |
|---|---|---|
| [Google Product Taxonomy](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) | `Luggage & Bags` altında briefcase, diaper bag, duffel, messenger, suitcase ve aksesuar ayrımları; moda aksesuarları sinyali | Kamuya açık sürüm 2021-09-21; Türkiye terimleri ayrıca uyarlanmalı |
| [Google Merchant Center kategori rehberi](https://support.google.com/merchants/answer/6324436?hl=tr) | Ürünün en spesifik ve tek uygun ürün kategorisine atanması yaklaşımı | Müşteri gezinme ağacı değildir |
| [n11 Ayakkabı & Çanta](https://www.n11.com/ayakkabi-ve-canta) | El/omuz/sırt çantası, valiz ve aksesuarların yerel müşteri dilindeki karşılıkları | Ayakkabı ile ortak merchandising ağacı canonical L1 sınırı sayılmaz |
| [Amazon Türkiye kategori dizini](https://www.amazon.com.tr/b?node=21034466031) | Bagaj, çanta ve aksesuarların ayrı alışveriş niyetleri | Tam ve stabil L2 ağacı kamuya açık değildir |

Marketplace bölümleri birebir alınmamış; ürün kimliği, yerel mağaza keşfi ve başka L1'lerle tekil sahiplik birlikte değerlendirilmiştir.

## 4. Recommended L2 count

**10 L2** önerilir.

- El/omuz/bel çantaları tek moda taşıma ailesinde tutulur.
- Sırt, iş/cihaz ve seyahat taşıma niyetleri ayrı raflardır.
- Küçük deri ürünleri ile giyim tamamlayıcıları kendi anlamlı kümelerini alır.
- Şemsiye ile seyahat aksesuarı, yalnız “aksesuar” oldukları için aynı düğümde birleştirilmez.

## 5. Exact L2 list

1. El, Omuz & Bel Çantaları
2. Sırt Çantaları
3. Evrak, Laptop & Ekipman Çantaları
4. Valiz & Seyahat Çantaları
5. Cüzdan, Kartlık & Anahtarlık
6. Kemer, Pantolon Askısı & Kravat
7. Şapka, Bere & Saç Aksesuarları
8. Atkı, Şal & Eldiven
9. Şemsiyeler
10. Seyahat Aksesuarları

## 6. Granularity rationale

- Taşıma biçimi ve kullanım amacı, müşterinin doğrudan aradığı anlamlı ürün aileleridir.
- Laptop/kamera/enstrüman taşıyan çantalar, içindeki cihazın değil çanta işlevinin ürünüdür; cihaz türü uyumluluk facet'idir.
- Valiz ve seyahat çantaları, boyut/tekerlek/bagaj standardı nedeniyle günlük çantadan ayrılır.
- Cüzdan/kartlık/anahtarlık küçük kişisel taşıma ürünleridir; çanta modellerine karışmamalıdır.
- Moda tamamlayıcıları her küçük ürün için ayrı L2 açmadan dört anlaşılır kümede tutulur.

## 7. Inclusions

### 1. El, Omuz & Bel Çantaları

El çantası, omuz çantası, çapraz çanta, clutch, portföy çanta ve bel çantası.

### 2. Sırt Çantaları

Günlük, okul ve şehir tipi sırt çantaları. Spor veya cihaz kullanım amacı facet olabilir.

### 3. Evrak, Laptop & Ekipman Çantaları

Evrak çantası, laptop çantası, kamera/enstrüman taşıma çantası ve korumalı ekipman çantası. Çanta bağımsız bir satış ürünüyse burada kalır.

### 4. Valiz & Seyahat Çantaları

Kabin/büyük boy valiz, seyahat çantası, duffel, takım elbise taşıma çantası ve seyahat seti.

### 5. Cüzdan, Kartlık & Anahtarlık

Cüzdan, kartlık, bozuk para çantası, pasaport cüzdanı ve genel anahtarlık.

### 6. Kemer, Pantolon Askısı & Kravat

Kemer, pantolon askısı, kravat, papyon ve bunların fiziksel aksesuarları.

### 7. Şapka, Bere & Saç Aksesuarları

Şapka, bere, kep, toka, taç, bandana ve saç bandı gibi giyilebilir aksesuarlar.

### 8. Atkı, Şal & Eldiven

Moda veya mevsim kullanımına yönelik atkı, şal, fular ve günlük eldivenler.

### 9. Şemsiyeler

Günlük yağmur şemsiyesi, kompakt şemsiye ve şemsiye kılıfı gibi doğrudan bağlı aksesuarlar.

### 10. Seyahat Aksesuarları

Bagaj etiketi, valiz kılıfı/kemeri, seyahat organizeri, boyun yastığı ve seyahat cüzdanı dışındaki bagaj yardımcıları.

## 8. Exclusions

- Ayakkabı ve ayakkabı bakım ürünü → `Ayakkabı`.
- Takı ve kol saati → `Saat & Takı`; akıllı saat → `Elektronik > Giyilebilir Teknoloji`.
- Genel giysi → `Giyim & Moda`.
- Telefon modeline özgü kılıf → `Elektronik > Telefon & Aksesuarları`.
- Alışveriş/çöp/saklama poşeti gibi ev sarfı → `Ev & Yaşam` veya ilgili sarf alanı.
- Bebek arabası, taşıyıcı ve çocuk oto koltuğu → `Anne & Bebek`.
- Sporun ayrılmaz güvenlik/taşıma ekipmanı olan özel ürün → `Spor & Outdoor`; yalnız bağımsız genel çanta burada.
- Takı yapımı veya dikiş gibi ürün olmayan hizmet → ürün taksonomisinin dışında.

## 9. Cross-domain boundaries

| Sınır | Canonical yönlendirme kuralı |
|---|---|
| Çanta & Aksesuar vs Bilgisayar & Tablet | Laptop çantası burada; laptop, donanım ve cihaz parçası Bilgisayar & Tablet'te. Cihaz modeli uyumluluk facet'idir. |
| Çanta & Aksesuar vs Fotoğraf & Kamera | Bağımsız kamera taşıma çantası burada; kamera, lens ve çekim donanımı Fotoğraf & Kamera'da. |
| Çanta & Aksesuar vs Müzik & Enstrüman | Enstrüman çantası bağımsız taşıma ürünü olarak burada; enstrümanın sabit/özel aksesuar setinin parçasıysa Müzik & Enstrüman ağacında değerlendirilebilir. |
| Çanta & Aksesuar vs Spor & Outdoor | Genel sırt/duffel çantası burada; sporun teknik güvenlik ekipmanı veya entegre hidrasyon sistemi Spor & Outdoor alanında olabilir. |
| Çanta & Aksesuar vs Anne & Bebek | Bebek bakım çantası ürün kimliği bakımından çantadır; owner kararıyla Anne & Bebek'e ayrılmadıkça burada önerilir. |
| Çanta & Aksesuar vs Giyim & Moda | Giyimi tamamlayan aksesuarlar burada; ana gövde giysi Giyim & Moda'da. |
| Çanta & Aksesuar vs Hediyelik & Parti | Ürünün hediye edilmesi kategori değildir. Parti kostümünün tek kullanımlık aksesuarı Hediyelik & Parti'ye gider. |
| Çanta & Aksesuar vs Otomotiv | Araç içine sabitlenen organizer Otomotiv; kişisel seyahat organizeri burada. |

Ürün tek primary leaf alır; mağazanın “spor”, “bebek” veya “elektronik” mağazası olması çantanın ürün kimliğini değiştirmez.

## 10. Category vs facet

Aşağıdakiler facet/attribute olmalıdır:

- Marka.
- Hedef kullanıcı/cinsiyet sunumu.
- Renk, desen, malzeme ve deri türü.
- Boyut, hacim/litre ve kabin uygunluğu.
- Laptop ekran ölçüsü, kamera modeli veya enstrüman formu uyumluluğu.
- Su geçirmezlik, tekerlek sayısı, kilit tipi ve bölme sayısı.
- Stil, sezon ve kullanım ortamı.
- Lisanslı karakter veya kişiselleştirilebilirlik.

`Kadın çanta`, `deri çanta`, `15,6 inç laptop çantası` ayrı L2 değildir.

## 11. Search synonyms

| Canonical terim | Arama eş anlamlıları / halk dili |
|---|---|
| El, Omuz & Bel Çantaları | handbag, clutch, portföy, çapraz çanta, crossbody, bel çantası |
| Sırt Çantaları | backpack, okul çantası, günlük sırt çantası |
| Evrak, Laptop & Ekipman Çantaları | laptop çantası, notebook çantası, briefcase, kamera çantası |
| Valiz & Seyahat Çantaları | bavul, kabin boy, büyük boy valiz, duffel, seyahat bagajı |
| Cüzdan, Kartlık & Anahtarlık | wallet, kartlık, pasaportluk, bozuk para cüzdanı |
| Kemer, Pantolon Askısı & Kravat | belt, suspender, papyon, boyun bağı |
| Şapka, Bere & Saç Aksesuarları | kep, cap, toka, taç, bandana |
| Atkı, Şal & Eldiven | fular, eşarp, boyunluk, eldiven |
| Şemsiyeler | yağmur şemsiyesi, cep şemsiyesi, otomatik şemsiye |
| Seyahat Aksesuarları | bagaj etiketi, valiz kemeri, organizer, boyun yastığı |

Eş anlamlılar arama ipucudur; backend sözlüğü bu görevde uygulanmamıştır.

## 12. Policy notes

- Normal çanta ve moda aksesuarları: `NORMAL`.
- Korunan marka/logolu sahte ürün riski, ilan ve marka doğrulama politikasına tabidir.
- “Gerçek deri”, su geçirmezlik, RFID engelleme veya güvenlik kilidi gibi doğrulanabilir iddialar yanıltıcı olmamalıdır.
- Çocuk ürünlerinde boğulma riski doğurabilecek küçük parça/uzun kordon uyarıları gerekebilir.
- Silah taşıma amacıyla tasarlanmış kılıf/çanta ya da gizleme ürünü: `LEGAL_REVIEW_REQUIRED`; normal müşteri ağacına otomatik alınmamalıdır.
- Kişiselleştirme işi ayrı bir hizmet ilanına dönüşemez; fiziksel ürünün özelliği olarak modellenebilir.

## 13. Ambiguous products

| Ürün | Önerilen yer | Gerekçe / owner konusu |
|---|---|---|
| Bebek bakım çantası | Çanta & Aksesuar | Ana kimliği çantadır; bebek kullanım amacı facet. Owner Anne & Bebek'e taşımayı seçebilir. |
| Hidrasyon sırt çantası | Spor & Outdoor veya Sırt Çantaları | Entegre spor/hidrasyon sistemi baskınsa Spor & Outdoor; genel taşıma ürünü ise burada. |
| Sert kamera ekipman çantası | Evrak, Laptop & Ekipman Çantaları | Bağımsız taşıma ürünü; cihaz uyumluluğu facet. |
| Enstrüman gig bag | Bu alan veya Müzik & Enstrüman | Genel taşıma ilkesi burada; enstrümana özel satış deneyimi için owner kararı gerekir. |
| Akıllı takip özellikli valiz | Valiz & Seyahat Çantaları | “Akıllı” özellik ürünü Elektronik yapmaz; batarya/seyahat uyumluluğu facet/policy olur. |
| Akıllı telefon tutan bel çantası | El, Omuz & Bel Çantaları | Telefon taşımak ürün kimliğini telefon aksesuarına dönüştürmez. |
| Dekoratif kostüm şapkası | Hediyelik & Parti | Normal giyim aksesuarı değil, parti/kostüm işlevi baskınsa parti alanına gider. |

## 14. Future L3/L4 examples

Yalnız yapısal örnekler:

- `El, Omuz & Bel Çantaları → Omuz Çantaları → Çapraz Çantalar`
- `Sırt Çantaları → Okul Sırt Çantaları`
- `Evrak, Laptop & Ekipman Çantaları → Cihaz Çantaları → Laptop Çantaları`
- `Valiz & Seyahat Çantaları → Valizler → Kabin Boy Valizler`
- `Seyahat Aksesuarları → Bagaj Düzenleme → Seyahat Organizerleri`

Bu örnekler final L3/L4 ağacı değildir. Değişken derinlik ve maksimum L4 ilkesi korunur.

## 15. Open owner decisions

1. Bebek bakım çantası ürün kimliğiyle burada mı kalmalı, yoksa Anne & Bebek altında özel L3'e mi taşınmalı?
2. Enstrüman ve kamera gibi cihaza form verilmiş çantalar genel taşıma dalında mı kalmalı, yoksa ilgili uzman L1'e mi ait olmalı?
3. Hidrasyon sırt çantası ve bisiklet çantası için hangi teknik özellik Spor & Outdoor sahipliğini tetiklemeli?
4. Kemer/kravat gibi moda aksesuarları uzun vadede ayrı bir moda L1 mimarisine taşınacak mı?
5. Silah/av ekipmanı taşıma kılıfları V1'de tamamen dışlanmalı mı?

Bu konular owner tarafından karara bağlanmadan final değildir.

## 16. Validation summary

- Canonical L1 adı `Çanta & Aksesuar` değişmedi: **PASS**
- L2 sayısı 10 ve duplicate L2 yok: **PASS**
- Şemsiye ile seyahat aksesuarı anlamsız tek düğümde birleştirilmedi: **PASS**
- Marka, cinsiyet, malzeme ve cihaz uyumluluğu facet olarak korundu: **PASS**
- Bilgisayar, kamera, müzik, spor, anne-bebek ve otomotiv sınırları yazıldı: **PASS**
- Hizmet ve riskli taşıma ürünü politikaları fail-closed kaydedildi: **PASS**
- Full L3/L4 finalize edilmedi: **PASS**
- Runtime/Figma/backend değişikliği: **NONE**

`BAGS_ACCESSORIES_L2_STATE: PROPOSED FOR OWNER REVIEW`

`BAGS_ACCESSORIES_L2_COUNT: 10`

`MAX_FUTURE_DEPTH: 4`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`

`BAGS_ACCESSORIES_READY_FOR_OWNER_REVIEW: YES`
