# EsnaftaVar — Evcil Hayvan Ürünleri L2 Proposal

**Wave:** 15 / Overnight Taxonomy Batch 03

**Belge tarihi:** 28 Ağustos 2026

**Canonical L1:** **Evcil Hayvan Ürünleri — CONFIRMED / PRODUCT OWNER FINAL**

## 1. Status

**PROPOSED FOR OWNER REVIEW**

Yalnız L2 omurgası önerilir. Canlı hayvan, veteriner ilaç, L3/L4, stable ID,
runtime JSON, migration veya listing eligibility uygulaması üretilmez.

## 2. Scope

Kapsam; evcil hayvanların beslenme, ödül, bakım/hijyen, yatak/taşıma/yaşam alanı,
oyuncak/aktivite, tasma/gezdirme ve tür-spesifik yaşam sistemi ürünleridir.

Araştırma, Türkiye perakendesinde müşterinin çoğunlukla önce hayvan türünü seçtiğini
gösterir. Bu nedenle proposal **species-first L2 + function-first L3** yaklaşımını
önerir. `species` yine zorunlu typed facet'tir; kategoriye bakılmadan filtreleme ve
uygunluk sağlar. Açıkça birden çok türe yönelik ve baskın türü olmayan sınırlı
aksesuarlar için dar bir ortak L2 önerilir.

## 3. Sources

Kaynaklar 28 Ağustos 2026 tarihinde kontrol edildi.

| Kaynak | Gözlem | Kullanım / sınırlama |
|---|---|---|
| [Google Product Taxonomy public file](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center ana-fonksiyon kuralı](https://support.google.com/merchants/answer/6324436?hl=en-GB) | Bird, cat, dog, fish, reptile/amphibian ve small-animal supplies tür bazlı; generic carrier, bowl, grooming, leash gibi ürünler ortak pet-supply dallarında yer alır. Live Animals ayrı; pet medicine ayrıca ayrışır. | Species-first + dar ortak ürün modeli ve tek primary leaf ilkesi desteklenir. Public dosya header'ı `2021-09-21`; Türkiye 2026 ağacı değildir. |
| [Trendyol Pet Shop](https://www.trendyol.com/pet-shop-x-c1142) ve [Evcil Hayvan Ürünleri](https://www.trendyol.com/evcil-hayvan-urunleri-x-c144116) | Kedi, köpek, kuş, kemirgen ve balık müşteri başlangıçları; mama, oyuncak, kum, tasma ve akvaryum ürünleri görünürdür. | Türkiye customer language ve species-first browse kanıtı alındı; merchandising kopyalanmadı. |
| [n11 Evcil Hayvan Ürünleri](https://www.n11.com/evcil-hayvan-urunleri?m=Gezer+Akvaryum) | Kedi, köpek, balık, kuş ve kemirgen üst ayrımı; akvaryum/kafes/oyuncak/tasma/beslenme aileleri vardır. | Tür bazlı major department yaklaşımını doğrular; marka veya tek ürün tipi L2 yapılmadı. |
| [Tarım ve Orman Bakanlığı — Veteriner Sağlık Ürünleri](https://www.tarimorman.gov.tr/HAYGEM/Menu/67/Veteriner-Saglik-Urunleri) | Veteriner tıbbi ürünlerin pazarlama ve satış izni; tıbbi olmayan veteriner sağlık ürünlerinin ayrıca düzenlenmesi açıklanır. | İlaç/tedavi ürünlerinin normal pet aksesuarı gibi listelenmemesi gerektiğini destekler. |
| [Tarım ve Orman Bakanlığı politika belgesi](https://www.tarimorman.gov.tr/TAGEM/Belgeler/yayin/HAYVAN%20SA%C4%9ELI%C4%9EI%20SEKT%C3%96R%20POL%C4%B0T%C4%B0KA%20BELGES%C4%B0_2021-2025.pdf) | Veteriner tıbbi ürün perakendesi izinli kanal ve yerlerle sınırlandırılır; internet dahil belirtilen yerler dışında satış yapılamayacağı açıklanır. | Veteriner ilaçları için **EXCLUDED / regulated channel** guard'ı kondu. |
| [Av ve yaban hayvanları ticareti yönetmeliği](https://www.tarimorman.gov.tr/DKMP/Belgeler/MEVZUAT/Av%20Y%C3%B6netimi/Y%C3%B6netmelik/AV%20VE%20YABAN%20HAYVANLARI%20%C4%B0LE%20BUNLARDAN%20ELDE%20ED%C4%B0LEN%20%C3%9CR%C3%9CNLER%C4%B0N%20BULUNDURULMASI%2C%20%C3%9CRET%C4%B0M%C4%B0%20VE%20T%C4%B0CARET%C4%B0%20HAKKINDA%20Y%C3%96NETMEL%C4%B0K.pdf) | Canlı av/yaban hayvanlarının üretim, satış ve taşıması izin/belge rejimine tabidir. | Canlı hayvanın consumer product taxonomy'ye sessizce eklenmemesini destekler; belge hukuki yorum yapmaz. |

**Source limitation:** Hepsiburada ve Amazon Türkiye'nin 2026 tam public kategori
ağacı güvenilir biçimde alınamadı. Google global taxonomy'nin canlı hayvan node'u
EsnaftaVar V1'e taşınmadı.

## 4. Recommended L2 count

Önerilen L2 sayısı: **7**.

Altı tür/ekosistem major department'ı ve yalnız baskın türü olmayan fiziksel bakım/
aksesuarlar için bir dar ortak dal önerilir. Mama, ödül, oyuncak ve bakımın her biri
L2 yapılmaz; bunlar tür altında gelecek L3 olur.

## 5. Exact L2 list

1. Kedi Ürünleri
2. Köpek Ürünleri
3. Akvaryum & Balık Ürünleri
4. Kuş Ürünleri
5. Küçük Hayvan Ürünleri
6. Sürüngen & Egzotik Pet Ürünleri
7. Ortak Pet Bakım & Aksesuarları

Normalized duplicate: **0**. Pet türü marka değildir; tür aynı zamanda zorunlu
facet olarak korunur.

## 6. Granularity rationale

- Kedi ve köpek; mama, ödül, hijyen, yatak, oyuncak ve gezdirme şemaları ayrı ve
  yüksek hacimli olduğu için kendi L2'sidir.
- Akvaryum/balık; tank, filtre, su düzenleme, aydınlatma ve habitat teknikleriyle
  başka pet ürünlerinden kökten ayrılır.
- Kuş, küçük hayvan ve sürüngen/egzotik pet; kafes/habitat, substrat, yem ve ısı/
  ışık uyumluluğu bakımından ayrı ekosistemlerdir.
- Tavşan, hamster, guinea pig gibi türler ayrı L2 yapılmaz; `Küçük Hayvan` altında
  species facet ve gerekirse gelecek L3 ile ayrılır.
- `Ortak Pet Bakım & Aksesuarları` bir catch-all değildir. Yalnız üretici tarafından
  gerçekten multi-species/universal tanımlanan ve baskın türü bulunmayan taşıma,
  bakım, beslenme kabı veya güvenlik aksesuarı burada olabilir. Mama, ödül, ilaç,
  tür-spesifik habitat ve açık kedi/köpek ürünü buraya alınmaz.

## 7. Inclusions

| L2 | Dahil olan ana ürünler |
|---|---|
| Kedi Ürünleri | Kedi maması/ödülü, kum/tuvalet, bakım, yatak/taşıma, tırmalama, oyuncak, tasma ve kedi aksesuarı |
| Köpek Ürünleri | Köpek maması/ödülü/çiğneme, bakım/hijyen, yatak/taşıma, oyuncak/aktivite, tasma/gezdirme ve eğitim aksesuarı |
| Akvaryum & Balık Ürünleri | Akvaryum, filtre/pompa, aydınlatma/ısıtma, dekor/substrat, su bakım ürünü, balık yemi ve ekipman |
| Kuş Ürünleri | Kuş yemi/ödülü, kafes/stand, tünek, suluk/yemlik, oyuncak, bakım ve habitat aksesuarı |
| Küçük Hayvan Ürünleri | Kemirgen/tavşan/gelincik yemi, ödül, kafes, altlık, yatak, oyuncak, suluk ve bakım ürünü |
| Sürüngen & Egzotik Pet Ürünleri | Teraryum, habitat ısı/ışık, substrat, yemleme, dekor ve bakım ekipmanı; legal tür guard'ı saklıdır |
| Ortak Pet Bakım & Aksesuarları | Açık multi-species tarak/fırça, tırnak aracı, universal taşıyıcı, ortak mama/su kabı, kimlik etiketi ve bariyer |

## 8. Exclusions

- Canlı hayvan, balık, kuş, sürüngen, böcek veya yemlik canlı: Product Taxonomy V1'e
  **EXCLUDED**; izinli işletme/lojistik olsa bile bu proposal'a eklenmez.
- Veteriner reçeteli/reçetesiz tıbbi ürün, aşı, antibiyotik ve tedavi ilacı:
  normal product taxonomy'de **EXCLUDED / regulated channel**.
- Veteriner muayene, bakım, kuaför, eğitim, gezdirme, pet hotel ve abonelik:
  **service scope — excluded**.
- İnsan gıdası, bebek ürünü ve insan medikal cihazı: ilgili L1.
- Genel ev temizleyicisi: **Ev & Yaşam**; açık pet-environment primary kullanım ve
  mevzuat statüsü yoksa pet bakımı değildir.
- Wild/exotic trade accessory that enables prohibited keeping/trade: policy review;
  canlı tür eligibility'si aksesuar kategorisinden türetilemez.
- Pet temalı oyuncak/dekor: hayvan tarafından kullanılmıyorsa **Oyuncak** veya
  **Ev & Yaşam**.

## 9. Cross-domain boundaries

| Sınır | Canonical kural |
|---|---|
| Sağlık & Medikal | İnsan medikal ürünü orada; veteriner tıbbi ürün bu consumer taxonomy'de normal category değildir ve izinli kanal/policy dışında listelenmez. |
| Gıda & Market | İnsan tüketimi ürünü orada; evcil hayvan yemi/maması burada. Ürünün intended species/use etiketi belirleyicidir. |
| Ev & Yaşam | Pet tarafından kullanılan yatak/kafes/kap burada; insan/ev dekoru veya genel temizlik ürünü orada. |
| Elektronik | Akvaryum filtresi/ısıtıcısı veya pet-specific tracker primary pet ecosystem ise burada; generic kamera/GPS/elektronik cihaz Elektronik. |
| Oyuncak | Hayvan için tasarlanmış pet toy burada; pet figürlü çocuk oyuncağı Oyuncak. |
| Çanta & Aksesuar | Hayvan taşıyıcı primary ise burada; insanın eşya taşıma çantası orada. |
| Çiçek & Bahçe | Akvaryum bitkisi/canlı bitki bu V1 canlı ürün policy'sine göre review; bahçe bitkisi Çiçek & Bahçe. |

## 10. Category vs facet

Category ürün ailesidir. Aşağıdakiler facet/compatibility alanıdır:

- intended species, breed/ırk, yaş/life stage ve boyut;
- mama formu, protein kaynağı, aroma, içerik, ağırlık ve beslenme amacı;
- prescription/diet claim ve kısırlaştırılmış/sensitive gibi claimler;
- tasma tipi, beden, boyun/göğüs ölçüsü, çekme kapasitesi;
- kafes/akvaryum/teraryum hacmi, ölçü, habitat uyumu;
- su tipi (tatlı/tuzlu), filtration capacity, sıcaklık/ışık ihtiyacı;
- malzeme, renk, paket adedi ve yıkanabilirlik;
- compatible/incompatible/conditional/unknown;
- bundle/kit. Set category değildir.

Species hem L2 navigation ekseni hem de typed facet'tir. Bu tekrar değil: kategori
primary ownership, facet ise arama/uyumluluk doğrulamasıdır.

## 11. Search synonyms

| Canonical L2 | Controlled search hints |
|---|---|
| Kedi Ürünleri | kedi malzemesi, cat supplies, kedi mama/kum/oyuncak |
| Köpek Ürünleri | köpek malzemesi, dog supplies, köpek mama/tasma/oyuncak |
| Akvaryum & Balık Ürünleri | akvaryum malzemesi, balık ürünü, aquarium supplies |
| Kuş Ürünleri | kuş malzemesi, kafes kuşu ürünü, bird supplies |
| Küçük Hayvan Ürünleri | kemirgen ürünü, hamster, tavşan, guinea pig, küçük pet |
| Sürüngen & Egzotik Pet Ürünleri | teraryum, sürüngen malzemesi, reptile supplies, egzotik pet |
| Ortak Pet Bakım & Aksesuarları | evcil hayvan aksesuarı, pet bakım, universal pet, pet taşıma |

Marka ve ırk synonym değildir. `Kuş kafesi` yalnız kuş L2'sine; `kedi/köpek taşıma`
açıkça iki türe uygunsa ortak dala yönlenebilir.

## 12. Policy/compliance

- Standart pet aksesuarı **NORMAL** olabilir; pet food/feed etiket ve mevzuat
  uygunluğu ayrıca doğrulanır.
- Veteriner tıbbi ürünler normal pet category'sine alınmaz: **EXCLUDED / regulated
  channel**. Kategori adı satış yetkisi sağlamaz.
- Supplement, vitamin, calming/therapeutic claim, flea/tick, medical collar,
  diagnostic monitor ve prescription diet iddiası **LEGAL_REVIEW_REQUIRED**.
- Tıbbi olmayan veteriner sağlık ürünü de exact mevzuat statüsü doğrulanmadan
  normal bakım ürünü sayılmaz.
- Canlı hayvan V1'de **EXCLUDED**. Exotic/wildlife ürününde türün yasal sahipliği,
  ticareti veya taşınabilirliği aksesuar listing'inden türetilmez.
- Gıda güvenliği, soğuk zincir, tehlikeli kimyasal, aerosol ve akvaryum water
  treatment ürünleri için fulfilment/policy kontrolü gerekir.
- Policy class category depth değildir.

## 13. Ambiguous products

| Ürün | Öneri / belirsizlik |
|---|---|
| Kedi-köpek ortak taşıma çantası | Gerçek multi-species etiketi varsa Ortak Pet; yalnız tek tür için pazarlanıyorsa o tür L2. |
| Universal mama/su kabı | Intended pet use açık ve tür dominant değilse Ortak Pet. İnsan mutfak kabı Ev & Yaşam/Züccaciye. |
| Pet kamera | Besleme/treat/pet monitoring primary ise pet L2 adayı; generic security camera Elektronik. Owner rule gerekli. |
| GPS pet tracker | Pet collar ecosystem primary ise ilgili species veya ortak aksesuar; generic tracker Elektronik. |
| Reçeteli diyet mama | İlaç olmayabilir ancak therapeutic/prescription claim nedeniyle LEGAL_REVIEW_REQUIRED; normal mama leaf'ine otomatik açılmaz. |
| Flea/tick ürünü | İlacın/biocidal/tıbbi olmayan bakım ürününün statüsü exact SKU ile belirlenir; normal hijyene sessizce atanmaz. |
| Akvaryum canlı bitkisi | Canlı ürün policy ve Çiçek & Bahçe sınırı owner kararı; bu proposal otomatik atamaz. |
| Tavuk/kümes ekipmanı | Hobby pet mi agricultural livestock mı olduğu belirsiz; farm/B2B boundary owner review. |
| Pet stroller | Hayvan taşıma primary ise species/ortak pet; bebek arabası Anne & Bebek. |

## 14. Future L3/L4 examples

Örnekler final değildir:

- Kedi Ürünleri → Mama; Ödül; Kum & Tuvalet; Bakım & Hijyen; Yatak & Taşıma;
  Tırmalama & Yaşam Alanı; Oyuncak; Tasma & Güvenlik.
- Köpek Ürünleri → Mama; Ödül & Çiğneme; Bakım & Hijyen; Yatak & Taşıma;
  Oyuncak & Aktivite; Tasma & Gezdirme; Eğitim Aksesuarları.
- Akvaryum & Balık → Akvaryum; Filtre & Pompa; Isıtma & Aydınlatma; Dekor &
  Substrat; Su Bakımı; Balık Yemi; Temizlik Ekipmanı.
- Kuş Ürünleri → Yem & Ödül; Kafes & Stand; Tünek; Suluk & Yemlik; Oyuncak;
  Bakım & Hijyen.
- Küçük Hayvan → Yem & Ödül; Kafes & Yaşam Alanı; Altlık; Oyuncak; Bakım.
- Sürüngen & Egzotik → Teraryum; Isıtma & Aydınlatma; Substrat; Yemleme;
  Habitat Dekoru.

Tür, ırk, yaş, lezzet, ağırlık ve beden L3/L4 yapılmaz.

## 15. Owner decisions

1. Species-first 7 L2 ve exact sıra/adlar onaylanmalı.
2. `Ortak Pet Bakım & Aksesuarları`nın strict eligibility kuralı ve catch-all
   olmasını engelleyecek metadata eşiği kararlaştırılmalı.
3. Pet camera/tracker gibi pet-first elektroniklerin tür dalında mı ortak dalda mı
   kalacağı belirlenmeli.
4. Prescription diet, supplement, flea/tick ve medical collar için exact policy
   matrix oluşturulmalı.
5. Akvaryum canlı bitkisi ve canlı yem dahil tüm canlı ürünlerin V1 exclusion
   kapsamı açıkça onaylanmalı.
6. Kümes/hobby farm products ile pet taxonomy sınırı belirlenmeli.

Owner onayı olmadan proposal **FINAL** yapılmaz.

## 16. Validation

- Canonical L1 adı değişmedi: **PASS**
- Proposed L2 count: **7**
- Normalized duplicate L2: **0**
- Species architecture: **SPECIES-FIRST + REQUIRED FACET DOCUMENTED**
- Live animal leakage: **0**
- Veterinary medicine normal-category leakage: **0**
- Human medical/cosmetics leakage: **0**
- Service leakage: **0**
- Marka/ırk/yaş-as-category: **0**
- Future max depth: **4**
- Runtime/DB/remote değişikliği: **NONE**

`PET_PRODUCTS_L2_ARCHITECTURE: PASS`

`PET_PRODUCTS_L2_READY_FOR_OWNER_REVIEW: YES`

`OWNER_FINALIZATION: NO`

`RUNTIME_IMPLEMENTATION: NO`
