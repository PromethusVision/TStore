# EsnaftaVar — Çiçek & Bahçe L2 Proposal

**Wave:** 15 / Overnight Taxonomy Batch 03

**Belge tarihi:** 28 Ağustos 2026

**Canonical L1:** **Çiçek & Bahçe — CONFIRMED / PRODUCT OWNER FINAL**

## 1. Status

**PROPOSED FOR OWNER REVIEW**

Bu belge yalnız L2 bilgi mimarisi önerir. Canlı ürün eligibility/lojistik sistemi,
L3/L4, stable ID, runtime taxonomy, migration, seed veya remote değişiklik yapmaz.

## 2. Scope

Kapsam; canlı saksı bitkisi, kesme çiçek ve fiziksel aranjman, tohum/fide/soğan,
yapay çiçek/bitki, saksı/bitki kabı, toprak/gübre/bitki besleme, sulama, bahçe el
aleti, bitki bakım/yetiştirme ürünü, sera ekipmanı ve bahçe/peyzaj aksesuarıdır.

Canlı bitki, tohum/fidan, gübre ve kimyasal ürünler aynı müşteri alanında bulunsa da
farklı legal/fulfilment kapıları taşır. Taxonomy ataması satış izni vermez. Flower
arrangement fiziksel olarak teslim edilen ürünse burada; tasarım, kurulum, peyzaj,
abonelik veya yalnız teslimat hizmeti Product Taxonomy dışında kalır.

## 3. Sources

Kaynaklar 28 Ağustos 2026 tarihinde kontrol edildi.

| Kaynak | Gözlem | Kullanım / sınırlama |
|---|---|---|
| [Google Product Taxonomy public file](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center ana-fonksiyon kuralı](https://support.google.com/merchants/answer/6324436?hl=en-GB) | Plants, flowers, seeds, pots/planters, gardening tools, watering, soils/fertilizers ve decor farklı product families olarak ayrılır; tek en uygun kategori istenir. | Functional schema ve one-primary-leaf ilkesi alındı. Public taxonomy header'ı `2021-09-21`; Türkiye 2026 regulation kaynağı değildir. |
| [n11 Bahçe & Çiçek](https://www.n11.com/yapi-market-ve-bahce/bahce-ve-cicek?promotions=1972464) | Toprak, tohum, fide/fidan, canlı iç mekan bitkisi, gübre, saksı ve bitki destekleri aynı müşteri alanında görünürdür. | Türkiye ürün dili ve major family breadth'i doğrulandı; marketplace ağacı kopyalanmadı. |
| [n11 Bahçe Sulama](https://www.n11.com/yapi-market-ve-bahce/bahce-sulama?q=saks%C4%B1+sulama) | Hortum, bağlantı, sulama başlığı, zamanlayıcı, sulama kabı ve damla sistemleri ayrı teknik ailelerdir. | Sulama bağımsız L2 olarak desteklendi. |
| [Trendyol Çiçek Bakımı & Bitki Yetiştirme 2026](https://www.trendyol.com/cicek-bakimi-bitki-yetistirme-x-c104229) | Tohum, saksı, bakım/yetiştirme, ışık ve sera/balkon kullanımı görünürdür. | Bitki bakım/yetiştirme ile sera expansion pointleri desteklendi. |
| [Trendyol Balkon Çiçeği 2026](https://www.trendyol.com/balkon-cicegi-y-s10252) | Canlı saksı bitkisi, tohum ve yetiştirme kiti birlikte satılır; fiziksel ürün tipleri farklıdır. | Kit/bundle'ın category olmaması ve canlı ürünün ayrı fulfilment gerektirmesi doğrulandı. |
| [Amazon Türkiye Bahçe Aletleri ve Sulama](https://p-nt-www-amazon-com-tr-kalias.amazon.com.tr/b?node=21440344031) | El aleti, saksı/aksesuar ve sulama ekipmanı farklı browse family'leridir. | Garden-use hand tool ile watering ayrımı desteklendi; eski crawl tam 2026 tree sayılmadı. |
| [Tarım ve Orman Bakanlığı — Bitki Pasaportu](https://isparta.tarimorman.gov.tr/Sayfalar/Detay.aspx?SayfaId=48) ve [yetkilendirme/denetim özeti](https://bilecik.tarimorman.gov.tr/Sayfalar/Detay.aspx?SayfaId=37) | Canlı bitki/tohum dahil belirli bitki ve materyallerin kayıt, denetim ve bitki pasaportu koşulları vardır. | Live product merchant/SKU verification ve traceability ihtiyacını destekler. |
| [Bitki Koruma Ürünleri satış/depolama yönetmeliği](https://sanliurfa.tarimorman.gov.tr/Duyuru/613/Bitki-Koruma-Urunlerinin-Toptan-Ve-Perakende-Satilmasi-Ile-Depolanmasi-Hakkinda-Yonetmelik) | Ruhsat/izin/karekod/reçete kuralları vardır; Bakanlıkça ruhsatlı bitki koruma ürünlerinin internet ve sosyal iletişim araçlarıyla tanıtım/satışı yasaklanır. | Pesticide/plant-protection products marketplace L2'ye normal ürün gibi alınmaz; **EXCLUDED online** guard'ı kondu. |
| [Tarım ve Orman Bakanlığı — Bitki Besleme](https://www.tarimorman.gov.tr/konular/bitkisel-uretim/bitki-besleme-ve-tarimsal-teknolojiler/bitki-besleme) | Gübre ve toprak düzenleyici üretim/ithalat/piyasa süreçlerinde belge ve analiz gereklilikleri vardır. | Gübre/bitki besleme exact SKU'su legal review gerektirir; category adı uygunluk sağlamaz. |

**Source limitation:** Hepsiburada'nın güncel tam public garden tree'si alınamadı.
Canlı/kimyasal ürünlerin pazaryerinde görünmesi legal eligibility kanıtı sayılmadı.

## 4. Recommended L2 count

Önerilen L2 sayısı: **11**.

Canlı/cut/artificial ürünleri ve bahçe bakım altyapısını farklı schema/fulfilment
ailelerine ayırır; bitki türü, kullanım yeri, sezon ve renk gibi facetleri L2 yapmaz.

## 5. Exact L2 list

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

Normalized duplicate: **0**. Bitki türü/renk/mevsim-as-category: **0**. Power-tool
leakage: **0**.

## 6. Granularity rationale

- Canlı saksı bitkisi; species, size, climate, light, toxicity ve live fulfilment
  gerektirir. Kesme çiçek/aranjman ise kısa ömür, adet/stem ve occasion schema'sıdır.
- Tohum/fide/soğan üretim materyalidir; mature/live decorative plant'tan farklı
  certification ve growth metadata'sı taşır.
- Yapay çiçek/bitki botanical decor arama niyetidir ama canlı ürün policy/lojistiği
  taşımaz; ayrı L2 olmalıdır.
- Saksı/kap, sulama, el aleti ve sera ekipmanı bağımsız durable-product families'dir.
- Toprak/gübre/besleme chemical/composition/regulatory profile nedeniyle bakım
  aksesuarından ayrılır.
- Bitki bakım/yetiştirme yalnız tek bitki/saksı düzeyindeki support, propagation,
  tying, pruning accessory ve bitki-özel grow light gibi fiziksel yardımcıları
  toplar; sera/enclosure sistemi veya pesticide catch-all değildir.
- Sera/yetiştirme ekipmanı, birden çok bitkiyi barındıran enclosure, raf, örtü,
  havalandırma ve iklim sistemidir; tek bitki destek çubuğu ya da fide kabı değildir.
- Bahçe dekorasyonu garden-specific ornament/edging/trellis/peyzaj aksesuarını
  kapsar; mobilya ve power tool'u yutmaz.

## 7. Inclusions

| L2 | Dahil olan ana ürünler — exact eligibility saklıdır |
|---|---|
| Canlı Saksı Bitkileri | İç/dış mekan saksılı çiçek, yeşil bitki, sukulent/kaktüs, küçük ağaç/fidan formunda dekoratif canlı ürün |
| Kesme Çiçek & Fiziksel Aranjmanlar | Kesme çiçek, buket, çelenk ve fiziksel hazırlanmış flower arrangement; teslim edilen asıl ürün çiçektir |
| Tohum, Fide & Bitki Soğanları | Çiçek/sebze/ot/çim tohumu, fide, fidan, yumru, rizom ve bitki soğanı; legal guard saklıdır |
| Yapay Çiçek & Yapay Bitkiler | Yapay çiçek dalı, yapay saksı bitkisi, yapay sarmaşık, floral arrangement ve botanical decor |
| Saksı, Saksılık & Bitki Kapları | Saksı, planter, grow bag, saksı tabağı, askı/stand ve bitki kabı |
| Toprak, Gübre & Bitki Besleme | Saksı/bahçe toprağı, torf, perlit, cocopeat, kompost, gübre, toprak düzenleyici ve bitki besini |
| Sulama Ürünleri | Hortum, makara, bağlantı, başlık, sulama kabı, damla/mikro sistem, fıskiye ve zamanlayıcı |
| Bahçe El Aletleri | Bahçe makası, kürek, tırmık, çapa, dikim aracı ve manual garden-specific hand tool |
| Bitki Bakım & Yetiştirme Ürünleri | Bitki destek çubuğu/bağı, klips, köklendirme kabı, propagation tray, budama accessory, nem/ışık destek ürünü |
| Sera & Yetiştirme Ekipmanları | Hobi sera, grow tent, sera örtüsü, raf, havalandırma/iklim destek ekipmanı ve yetiştirme sistemi |
| Bahçe Dekorasyonu & Peyzaj Aksesuarları | Garden ornament, çit/edging, trellis, bitki kafesi, landscape fabric, garden-specific dekor ve peyzaj aksesuarı |

## 8. Exclusions

- Bakanlıkça ruhsatlı bitki koruma/pesticide/herbicide/fungicide ürünlerinin internet
  tanıtım ve satışı yasak olduğundan marketplace normal taxonomy'sinde **EXCLUDED
  online**; görünür L2 veya synonym yapılmaz.
- Elektrikli/akülü/benzinli çim biçme, budama, testere, üfleme ve power garden tool:
  **Yapı Market**.
- Genel garden furniture, masa/sandalye, salıncak ve outdoor seating:
  **Ev & Yaşam**.
- Genel dekoratif vazo, sepet, aydınlatma ve ev dekoru: **Ev & Yaşam**; garden-
  specific plant container/landscape function yoksa burada değildir.
- Çiçek tasarım/kurulum, peyzaj, bahçıvanlık, düğün dekorasyonu, mezar bakımı,
  abonelik ve yalnız teslimat: **service scope — excluded**.
- Meyve/sebze/gıda olarak tüketim primary ise **Gıda & Market**; yetiştirme
  materyali/tohum/fide ise burada.
- Oyuncak bahçe seti: **Oyuncak**; gerçek child-sized garden tool ise safety/policy
  review ile burada olabilir.
- Büyük tarım makinesi, traktör ekipmanı ve professional agricultural input:
  consumer garden taxonomy'ye sessizce alınmaz.

## 9. Cross-domain boundaries

| Sınır | Canonical kural |
|---|---|
| Yapı Market | Main-use manual garden hand tool burada; power tool/machinery, generic hardware ve construction equipment Yapı Market. |
| Ev & Yaşam | Garden furniture/general decor orada; plant-growing container, garden-specific ornament/edging/trellis burada. |
| Gıda & Market | Tüketilecek ürün orada; yetiştirmek için tohum/fide/soğan burada. Edible herb in live pot owner rule gerektirir. |
| Elektronik | Generic lighting, camera, smart-home cihazı Elektronik; grow light/irrigation controller primary plant-growing system ise burada, hybrid owner review. |
| Evcil Hayvan | Akvaryum/pet habitat ürünü orada; garden plant burada. Canlı akvaryum bitkisi ve pet-toxic plant metadata'sı owner/policy review. |
| Hediyelik/occasion | Buket/aranjman fiziksel ürün burada; kurulum, mesaj/deneyim ve delivery service category değildir. Occasion facet'tir. |
| Kırtasiye & Ofis | Floristry craft paper/ribbon generic kırtasiye ise orada; finished artificial flower/arrangement burada. |

## 10. Category vs facet

Aşağıdakiler category değil facet/policy metadata'sıdır:

- botanik/tür adı, cultivar/çeşit, indoor/outdoor, perennial/annual;
- canlı/yapay (zaten family guard), boy/yükseklik, pot size, maturity;
- ışık/su/iklim ihtiyacı, hardiness, season, bloom color/time;
- toxicity/pet-safe/child-safe ve invasive/protected status;
- seed count, germination rate, certification/lot, harvest/expiry;
- soil type, volume, pH, composition; fertilizer NPK, form, volume;
- hose length/diameter, connection, flow, irrigation area;
- tool material, size, hand orientation ve power source (power tool boundary);
- greenhouse dimensions/material/ventilation;
- occasion: doğum günü, düğün, cenaze, yeni iş vb.;
- bundle/kit. Yetiştirme kiti principal product leaf + bundle facet alır.

Bitki adı category yerine discovery facet/controlled vocabulary olur; her tür için
L2/L3 node açılmaz.

## 11. Search synonyms

| Canonical L2 | Controlled search hints |
|---|---|
| Canlı Saksı Bitkileri | canlı çiçek, salon bitkisi, balkon bitkisi, saksı çiçeği |
| Kesme Çiçek & Fiziksel Aranjmanlar | buket, kesme çiçek, çiçek aranjmanı, çelenk |
| Tohum, Fide & Bitki Soğanları | tohum, fide, fidan, çiçek soğanı, çim tohumu |
| Yapay Çiçek & Yapay Bitkiler | yapma çiçek, suni çiçek, yapay bitki, artificial plant |
| Saksı, Saksılık & Bitki Kapları | saksı, planter, saksılık, grow bag, saksı standı |
| Toprak, Gübre & Bitki Besleme | torf, toprak, perlit, kompost, gübre, bitki besini |
| Sulama Ürünleri | bahçe sulama, hortum, damla sulama, fıskiye, sulama kabı |
| Bahçe El Aletleri | bahçe makası, kürek, tırmık, çapa, dikim aleti |
| Bitki Bakım & Yetiştirme Ürünleri | bitki desteği, klips, köklendirme, fide tepsisi, yetiştirme aksesuarı |
| Sera & Yetiştirme Ekipmanları | hobi sera, grow tent, sera örtüsü, yetiştirme sistemi |
| Bahçe Dekorasyonu & Peyzaj Aksesuarları | bahçe dekoru, çit, bordür, trellis, peyzaj örtüsü |

`İlaç`, `pestisit`, `herbisit`, `fungusit` normal commerce synonym'i olarak
eklenmez; prohibited-online product discovery açılmamalıdır.

## 12. Policy/compliance

- Canlı bitki/tohum/fide/fidan: kayıt, yetkili üretici/satıcı, bitki pasaportu,
  phytosanitary/traceability, invasive/protected species, seasonality ve canlı
  fulfilment koşulları nedeniyle **LEGAL_REVIEW_REQUIRED**.
- Gübre/bitki besini/toprak düzenleyici: registration, composition, label, claim,
  storage/shipping doğrulamasıyla **LEGAL_REVIEW_REQUIRED**.
- Ruhsatlı bitki koruma ürünlerinin internetten tanıtım/satışı mevcut authoritative
  rule nedeniyle **EXCLUDED ONLINE**. Bu proposal alternatif satış yolu tasarlamaz.
- Aerosol, chemical, compressed container ve heavy/bulk substrate ayrıca fulfilment
  policy ister.
- Yapay çiçek, normal saksı, manual tool ve non-chemical accessory çoğunlukla
  **NORMAL** olabilir; product safety saklıdır.
- Canlı üründe iade/bozulma, teslimat zamanı/sıcaklığı ve merchant stock freshness
  category değil commerce policy'dir.
- Policy class category depth değildir.

## 13. Ambiguous products

| Ürün | Öneri / belirsizlik |
|---|---|
| Yenilebilir ot/fesleğen saksısı | Growing/live plant primary ise Canlı Saksı Bitkileri; immediate food consumption primary ise Gıda & Market. Owner rule gerekli. |
| Çiçek buketi + vazo | Physical flower primary ise Kesme Çiçek/Aranjman + bundle facet; vazo primary/generic ise Ev & Yaşam. |
| Saksılı meyve fidanı | Tohum, Fide & Bitki Soğanları; maturity ve intended planting facet. Dekoratif mature plant ile rule gerekli. |
| Grow light | Plant-growing-specific spectrum/form primary ise Bitki Bakım veya Sera; generic lamp Elektronik/Ev & Yaşam. |
| Akıllı sulama kontrolörü | Irrigation system primary ise Sulama; generic smart-home hub Elektronik. |
| Elektrikli budama makası | Yapı Market power tool; manual garden pruner Bahçe El Aletleri. |
| Bahçe bankı | Ev & Yaşam garden furniture; Bahçe Dekorasyonu değildir. |
| İnsektisit/pestisit | Ruhsatlı bitki koruma statüsünde online sale excluded; household biocidal status da separate legal review. |
| Akvaryum canlı bitkisi | Pet habitat mı live plant mı: Evcil Hayvan/Çiçek boundary ve live-product policy owner decision. |
| Mezarlık çiçeği + bakım | Fiziksel flower product burada; bakım/yerleştirme service excluded. |

## 14. Future L3/L4 examples

Örnekler final değildir:

- Canlı Saksı Bitkileri → İç Mekan; Dış Mekan/Balkon; Sukulent & Kaktüs;
  Dekoratif Ağaç/Fidan (schema/volume kanıtıyla).
- Kesme Çiçek & Fiziksel Aranjmanlar → Kesme Çiçek; Buket; Aranjman; Çelenk.
- Tohum, Fide & Soğan → Çiçek Tohumu; Sebze/Ot Tohumu; Çim Tohumu; Fide/Fidan;
  Soğan/Yumru/Rizom.
- Toprak, Gübre & Besleme → Toprak/Torf; Substrat & Düzenleyici; Gübre;
  Bitki Besini (legal guard ile).
- Sulama → Hortum & Makara; Bağlantı/Başlık; Damla Sulama; Fıskiye;
  Kontrol/Zamanlayıcı; Sulama Kabı.
- Bahçe El Aletleri → Budama; Kazma/Dikim; Tırmık/Çapa; Toplama/Temizlik.
- Sera & Yetiştirme → Hobi Sera; Grow Tent; Örtü; Raf/Support; İklim Ekipmanı.

Bitki türü, renk, mevsim, saksı boyu, hacim ve marka L3/L4 yapılmaz.

## 15. Owner decisions

1. Exact 11 L2 adı ve sırası onaylanmalı.
2. Canlı ürün launch scope'u, kayıt/pasaport/traceability, local-delivery radius,
   fulfilment ve return policy'si kararlaştırılmalı.
3. Tohum/fide/fidan ile mature decorative plant arasındaki primary rule
   tanımlanmalı.
4. Grow light/irrigation controller gibi plant-first elektroniklerin boundary'si
   finalleştirilmeli.
5. Edible potted plant ve akvaryum canlı bitkisi precedence rule'u belirlenmeli.
6. Gübre/bitki besleme için exact product/merchant eligibility matrix hazırlanmalı.
7. İnternetten satışı yasak bitki koruma ürünlerinin search/listing ingestion'da
   nasıl fail-closed engelleneceği ayrı policy işine atanmalı.
8. Fiziksel aranjman ile hizmet/abonelik ayrımının listing contract'ı tanımlanmalı.

Owner onayı olmadan proposal **FINAL** yapılmaz.

## 16. Validation

- Canonical L1 adı değişmedi: **PASS**
- Proposed L2 count: **11**
- Normalized duplicate L2: **0**
- Live/cut/artificial product separation: **PASS**
- Power tool leakage: **0**
- Garden furniture leakage: **0**
- Flower arrangement service leakage: **0**
- Pesticide/plant-protection online listing: **EXCLUDED / DOCUMENTED**
- Bitki türü/renk/mevsim-as-category: **0**
- Future max depth: **4**
- Runtime/DB/remote değişikliği: **NONE**

`FLOWERS_GARDEN_L2_ARCHITECTURE: PASS`

`FLOWERS_GARDEN_L2_READY_FOR_OWNER_REVIEW: YES`

`OWNER_FINALIZATION: NO`

`RUNTIME_IMPLEMENTATION: NO`
