# EsnaftaVar — Taxonomy Batch 03 Finalization Audit

**Wave:** 32 / Taxonomy Finalization Sprint C

**Belge tarihi:** 29 Ağustos 2026

**Target branch:** `agent3/w32-taxonomy-finalize-batch03`

**Target base:** `origin/main@d54239c6de8b4637bd093ea1e849d19093bdce7a`

**Read-only source:** `origin/agent2/w15-overnight-taxonomy-batch-03@f1e766eeacbcbc1f1ed69ee18d040321645a6796`

## 1. Sonuç

Batch 03'teki sekiz canonical L1 için kaynakta önerilmiş 77 L2 adı ve sırası
değiştirilmeden korundu. Bunların altına müşteri tarafından anlaşılabilir ürün tipi
odaklı L3/L4 adayları tasarlandı. Üretilen ağaçta:

- 459 toplam düğüm;
- 77 L2, 366 L3 ve 16 L4;
- 379 terminal leaf;
- 8 L1 ve kaynakla birebir 77/77 L2;
- sıfır yinelenen tam yol;
- sıfır L4-without-L3;
- sıfır runtime/stable-ID/DB değişikliği vardır.

Her satır `CANDIDATE_FOR_PRODUCT_OWNER_FINALIZATION` durumundadır. Bu çalışma
Product Owner onayı, ürün yayınlama yetkisi, mevzuat uygunluğu veya satışa açılma
kararı değildir.

## 2. Geçerli master-owner kararları

Bu finalization adayı önceki master-owner kararlarını yeniden açmaz:

| Karar | Uygulanan kural | Bu çıktıya etkisi |
|---|---|---|
| OM-R06=B | Stable identity geçişi aşamalı olacak. | Üretim ID'si, UUID, slug migration veya redirect tablosu üretilmedi. |
| OM-R07=B | Product, domain-gated Variant ve Listing ayrı kavramlardır. | Ağaç yalnız product-type classification taşır; variant ve merchant listing düğümü yoktur. |
| OM-R10=A | Ordinary allowlist + sensitive fail-closed. | Hassas alanlar görünür taxonomy düğümü olsa bile SKU/merchant uygunluğu otomatik oluşmaz. |

L1 adları ve sırası Wave 15 Product Owner final kararından alınmıştır; bu belgede
L1 değişikliği yapılmamıştır.

## 3. Kaynak envanteri ve L2 reconciliation

| L1 | Kaynak L2 | Aday L2 | L3 | L4 | Leaf | Sonuç |
|---|---:|---:|---:|---:|---:|---|
| Otomotiv & Motosiklet | 11 | 11 | 61 | 14 | 71 | PASS |
| Kitap | 10 | 10 | 50 | 0 | 50 | PASS |
| Kırtasiye & Ofis | 11 | 11 | 59 | 2 | 60 | PASS |
| Evcil Hayvan Ürünleri | 7 | 7 | 43 | 0 | 43 | PASS |
| Gözlük & Optik | 7 | 7 | 21 | 0 | 22 | PASS |
| Saat & Takı | 11 | 11 | 35 | 0 | 36 | PASS |
| Sağlık & Medikal | 9 | 9 | 44 | 0 | 44 | PASS |
| Çiçek & Bahçe | 11 | 11 | 53 | 0 | 53 | PASS |
| **Toplam** | **77** | **77** | **366** | **16** | **379** | **PASS** |

`Hazır Okuma Gözlükleri` ve `Cep Saatleri` L2 seviyesinde yeterince açık ürün
tipleri olduğu için yapay alt seviye eklenmeden leaf bırakıldı. Derinlik her dalda
aynı olmak zorunda değildir; maksimum L4'tür.

## 4. CSV sözleşmesi

`TAXONOMY_BATCH_03_FINALIZATION_TREE.csv` şu alanları taşır:

| Alan | Anlam |
|---|---|
| `L1`–`L4` | Canonical yol; boş son seviyeler değişken derinliği gösterir. |
| `LEAF_YN` | Ürünün atanabileceği terminal candidate node. Parent node'a ürün atanmaz. |
| `NODE_STATE` | Tüm satırlarda owner-finalization adayı; hiçbir satır final değildir. |
| `POLICY_CLASS` | `NORMAL`, `REGULATED` veya `LEGAL_REVIEW_REQUIRED`; satış izni değildir. |
| `PRIMARY_DOMAIN` | Her satırda L1 ile aynıdır; tek primary-domain ilkesini korur. |
| `FACET_NOTES` | Uyum, tür, malzeme, beden, claim ve eligibility bilgisinin hiyerarşi dışında kaldığını hatırlatır. |
| `SYNONYM_NOTES` | Search eşanlamlılarının yeni leaf veya eligibility üretmeyeceğini belirtir. |
| `OWNER_DECISION_REQUIRED` | Her satır `YES`; ağaç Product Owner tarafından final ilan edilmedi. |
| `PROFESSIONAL_REVIEW_REQUIRED` | Hukuk/policy/uzman incelemesi gereken dalı işaretler. |
| `SOURCE_NOTES` | Kaynak batch ile OM-R06/R07/R10 izini taşır. |

Parent policy sınıfı, altındaki en sıkı candidate leaf sınıfına yükseltilmiştir.
Bu yüzden parent sayıları satışa açılacak ürün sayısı olarak okunamaz.

## 5. Policy dağılımı

| Policy class | Düğüm | Yorum |
|---|---:|---|
| `NORMAL` | 137 | Ordinary taxonomy adayı; genel ürün güvenliği yine saklıdır. |
| `REGULATED` | 146 | Teknik güvenlik, yaş/çocuk, elektrik, PPE veya benzeri doğrulama gerekir. |
| `LEGAL_REVIEW_REQUIRED` | 176 | Exact SKU, merchant, claim, kayıt/izin veya satış kanalı fail-closed incelenmelidir. |

322 düğüm `PROFESSIONAL_REVIEW_REQUIRED=YES`, 137 düğüm `NO` taşır. Özellikle
Sağlık & Medikal'in bütün görünür dalları fail-closed bırakılmıştır. Policy class
category depth değildir ve bir kategoriye dahil olmak satışa uygunluk sağlamaz.

## 6. Hiyerarşi ve facet denetimi

### 6.1 Bir ürün, bir primary leaf

- Her leaf yalnız bir L1/L2/L3/L4 yolunda bulunur.
- Aynı ürün birden çok işlev taşıyorsa ana işlev/ürün tipi primary leaf'i belirler;
  ikincil kullanım search/facet olabilir.
- Bundle/kit yeni kategori değildir; principal product leaf + bundle facet gerekir.
- Variant, listing, merchant sector, service ve policy state taxonomy düğümü değildir.

### 6.2 Category yapılmayan özellikler

Marka, model, araç marka/model/yıl/motor uyumu, ISBN/yazar/yayınevi/dil, okul sınıfı,
renk, malzeme, beden, pet tür/ırk/yaş, reçete, göz numarası, lens eğrisi, değerli
maden/ayar, tıbbi claim/risk sınıfı, bitki türü/cultivar/mevsim ve ürün izin durumu
facet veya policy metadata olarak kalır.

### 6.3 Değişken derinlik

L4 yalnız uzun ürün ailesinin customer-recognized ayrımını taşıdığı otomobil yedek
parçaları ve boya alt ailelerinde kullanıldı. Diğer dallar gereksiz düğüm üretmeden
L2 veya L3 leaf olabilir. Maksimum derinlik 4, minimum terminal derinlik 2'dir.

## 7. Özel sınır denetimleri

| Riskli sınır | Candidate kural | Sonuç |
|---|---|---|
| Fitment electronics vs generic electronics | Araca özgü kamera, park, OBD, multimedya ve alarm `Araç Elektroniği`; generic consumer electronics ve fixed infrastructure kendi domain'inde. Marka/model/yıl/motor uyumu facet. | PASS |
| Vehicle chemicals | Yağ, sıvı, katkı ve kimyasal temizlik dalları görünür fakat `LEGAL_REVIEW_REQUIRED`; tehlikeli madde/fulfilment/label kontrolü leaf'ten ayrıdır. | PASS |
| Physical vs digital books | Ağaç yalnız fiziksel kitapları sınıflandırır. E-kitap, sesli kitap, lisans ve abonelik bu Product Taxonomy'de yoktur. | PASS |
| Toner/kartuş | Printer-specific toner, kartuş ve drum `Bilgisayar & Tablet` sahibidir. Batch 03 yalnız generic kağıt, etiket ve termal/plotter rulolarını içerir. | PASS |
| Pet species taxonomy vs facet | Species-first yedi L2 ve function-first L3 kullanıldı. Species ayrıca typed facet olarak tutulur; ırk/yaş/beden kategori değildir. | PASS |
| Veterinary health | Veteriner ilaçları, reçeteli ürünler ve tedavi hakkı yaratılmadı. Pet gıda/bakım claim'leri exact-SKU gate'tedir. | PASS |
| Live animals | Canlı hayvan leaf'i, synonym'i veya launch hakkı yoktur. | PASS |
| Prescription/custom optics | Çerçeve, cam, kontakt lens ve bakım ürünleri ayrı ürün aileleri; reçete/customization/optisyen yetkisi policy metadata ve `LEGAL_REVIEW_REQUIRED`. Muayene/uygulama hizmeti dışarıda. | PASS |
| Contact lenses | Sferik, torik, multifokal ve renkli/kosmetik lensler görünür; sınıflandırma satış hakkı değildir. Lens bakımı ayrı L2. | PASS |
| Smartwatch exclusion | `Klasik Kol Saatleri` yalnız analog, klasik dijital ve mekanik/otomatik saatleri içerir. Smartwatch ve smart ring `Elektronik` sahibidir. | PASS |
| Precious goods | Maden, ayar, taş, sertifika ve değer facet/policy'dir. Takı/saat dalları high-value SKU için fail-closed; yatırım altını ve loose stone kapsam dışı/açık owner kararıdır. | PASS |
| Supplements | Vitamin, mineral, bitkisel ürün, spor supplementi ve gıda takviyesi için leaf yoktur; ayrı owner/legal proposal olmadan Sağlık ağacına girmez. | PASS |
| Medical nutrition | Tıbbi beslenme ürünü için leaf yoktur; gıda/sağlık/ilaç rejimi ayrı owner/legal kararıdır. | PASS |
| Prescription/restricted medical | İlaç, aşı, hormon, tıbbi gaz ve kontrollü ürün normal commerce node'u değildir. | PASS |
| Professional medical devices | Görünür cihaz yolları ev kullanım amacıyla adlandırıldı. Professional-only, invasive/sterile diagnostic, implantable ve ağır hastane cihazları otomatik kapsamda değildir. | PASS |
| Pesticides | Pestisit, herbisit, fungisit ve ruhsatlı bitki koruma ürünü leaf/synonym değildir; kaynak contract'a göre online normal ürün akışından excluded kalır. | PASS |
| Live plants | Canlı bitki, tohum, fide/fidan ve soğan dalları `LEGAL_REVIEW_REQUIRED`; kayıt/pasaport/traceability/fulfilment ayrı kapıdır. | PASS |
| Garden furniture/tools | Manual garden-first el aletleri burada; powered/industrial tool `Yapı, Hırdavat & Tesisat`. Masa, sandalye, bank ve genel outdoor furniture `Ev & Yaşam`. | PASS |
| Flower product vs service | Fiziksel kesme çiçek, buket, aranjman ve çelenk product leaf'idir. Tasarım, kurulum, bakım, abonelik ve delivery-only hizmet taxonomy dışıdır. | PASS |

## 8. Cross-domain ve semantic overlap denetimi

- Tam yol tekrarları: **0**.
- Aynı L1 içinde aynı isimli iki scoped L3 ailesi vardır: `Fren Parçaları` ve
  `Egzoz Parçaları`, otomobil ve motosiklet L2'lerinin altında ayrı stable path
  taşır. Bunlar duplicate product leaf değildir; üst yol zorunlu kimlik parçasıdır.
- `Takviye` sözcüğü Otomotiv'de akü takviye cihazı/kablosu anlamındadır; Sağlık'ta
  supplement leaf'i yoktur.
- Garden grow light yalnız plant-first kullanımda Çiçek & Bahçe'dedir; generic lamp
  ve smart-home cihazı Elektronik/Ev & Yaşam sınırında kalır.
- Dedicated medical measurement device Sağlık'tadır; wellness smartwatch ve generic
  wearable Elektronik'te kalır.
- Generic paper/ribbon Kırtasiye'de; bitmiş yapay çiçek/aranjman Çiçek & Bahçe'dedir.
- Araç mevzuat seti olan first-aid kit Otomotiv'de; generic/home first-aid kit
  Sağlık'tadır.

Cross-domain çözüm tek primary leaf ve controlled precedence rule ile yapılır;
ürünü iki leaf'e kopyalama yöntemi kullanılmaz.

## 9. Domain sonuçları

### 9.1 Otomotiv & Motosiklet

11 L2 korunmuştur. Fitment L3/L4'e dönüştürülmemiş, ürün family'leri customer-facing
leaf olmuştur. Araç kimyasalları, akü/elektrik, safety gear ve teknik cihazlar
policy/professional review taşır. Fixed wallbox/şarj altyapısı bu ağaçta açılmadı.

### 9.2 Kitap

10 L2 korunmuştur. 50 fiziksel ürün/shelf leaf'i üretilmiştir. Format, dil, yazar,
yayınevi, baskı ve yaş uygunluğu facet/policy'dir. Dijital yayın ve abonelik yoktur.

### 9.3 Kırtasiye & Ofis

11 L2 korunmuştur. Toner/kartuş sızıntısı yoktur. Kesici, kimyasal yapıştırıcı,
sanat boyası ve elektrikli ofis makinesi dalları daha sıkı policy taşır.

### 9.4 Evcil Hayvan Ürünleri

7 L2 korunmuştur. Species-first / function-first model uygulanmıştır. Canlı hayvan
ve veteriner ilaç dalı yoktur; pet food, treatment claim ve su bakım kimyasalları
exact-SKU review olmadan açılmaz.

### 9.5 Gözlük & Optik

7 L2 korunmuştur. Prescription/customization ve contact lens aileleri taxonomy'de
ayırt edilir fakat legal/merchant eligibility dış policy kapısında kalır. Optisyen
hizmeti Product Taxonomy'ye alınmamıştır.

### 9.6 Saat & Takı

11 L2 korunmuştur. Smart wearable sızıntısı yoktur. Maden/ayar/taş/sertifika
facet'tir; high-value ürünler, vücut takıları ve bakım kimyasalları fail-closed
inceleme ister.

### 9.7 Sağlık & Medikal

9 L2 korunmuştur. 53 düğümün tamamı `LEGAL_REVIEW_REQUIRED` ve professional review
taşır. İlaç, supplement, medical nutrition ve professional hospital equipment
normal launch leaf'i değildir. Taxonomy onayı hiçbir medical ürünün satış onayı
sayılmaz.

### 9.8 Çiçek & Bahçe

11 L2 korunmuştur. Canlı/kesme/yapay ürünler ayrılmış; pesticide leaf'i yoktur.
Canlı ürün, tohum/fide ve gübre legal/fulfilment gate taşır. Furniture, powered
tools ve hizmetler dışarıda tutulmuştur.

## 10. Makine kontrolleri

| Kontrol | Sonuç |
|---|---|
| CSV sütun sayısı ve başlık sözleşmesi | PASS — 13 sütun |
| L1 count | PASS — 8 |
| L2 source reconciliation | PASS — 77/77 |
| Exact path uniqueness | PASS — 0 duplicate |
| L4 without L3 | PASS — 0 |
| Maximum depth | PASS — L4 |
| `PRIMARY_DOMAIN == L1` | PASS — 459/459 |
| Candidate state | PASS — 459/459 |
| Owner decision required | PASS — 459/459 `YES` |
| Leaf count | PASS — 379 |
| Runtime/stable ID | PASS — none |

## 11. Açık kapılar ve STOP koşulları

Şunlar tamamlanmadan ağaç runtime'a veya commerce eligibility'ye çevrilemez:

1. Product Owner'ın exact L2/L3/L4 candidate tree kararını vermesi;
2. OM-R06=B için stable opaque ID allocation/mapping işinin ayrı runtime wave'de
   yapılması;
3. automotive chemical/fitment, optics, precious goods, pet food/claims, health,
   live plant/seed/fertilizer policy matrislerinin yetkili uzmanlarca doğrulanması;
4. excluded/restricted ürünlerin ingestion ve search katmanında fail-closed
   uygulanması;
5. Product/Variant/Listing contract'ının bu taxonomy yollarına ayrı bağlanması.

Bu audit yapısal owner review'a engel bulmamıştır. Policy kapılarının açık olması,
hassas SKU'ların launch'a hazır olduğu anlamına gelmez.

## 12. Son durum

`BATCH_03_TAXONOMY_FINALIZATION: PASS`

`L2_RECONCILIATION: PASS`

`L34_DESIGN: PASS`

`CROSS_DOMAIN_AUDIT: PASS`

`READY_FOR_BULK_OWNER_FINALIZATION: YES`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`
