# EsnaftaVar Yapı, Hırdavat & Tesisat L2 Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW — NOT CANONICAL / NOT RUNTIME.**

- Araştırma ve öneri tarihi: **2026-08-28**
- Kapsam: final L1 **Yapı, Hırdavat & Tesisat** için L2 spine önerisi
- Bu belge owner-final karar, stable ID, slug/sort, full L3/L4, policy/facet
  implementation, runtime/JSON/DB veya remote değişiklik değildir.
- Canonical 24 L1 ve Product/Merchant/Facet/Service ayrımları korunur.

## 2. Scope

Kapsam; yapım, onarım, montaj, ölçüm, yüzey işlemi, sabit su/elektrik/ısıtma-gaz-
havalandırma tesisatı ve iş güvenliği için satılan fiziksel consumer/prosumer ürünlerdir.
Bahçe, otomotiv fitment, connected smart-home, finished appliance ve hizmetler kendi
domain'lerinde kalır.

Bir SKU tek primary leaf kullanır. Güç kaynağı, ölçü, materyal, voltage, tool/battery
compatibility, kullanım ortamı, protection class, sertifika ve marka facet/policy
verisidir; category ağacında kopyalanmaz.

## 3. Sources reviewed

Erişim tarihi **2026-08-28**:

- [Google Merchant Center — Google product category](https://support.google.com/merchants/answer/6324436?hl=tr):
  ürün başına tek external category ve full-path/ID yaklaşımı incelendi.
- [Google Product Taxonomy — Türkçe](https://www.google.com/basepages/producttype/taxonomy-with-ids.tr-TR.txt):
  hardware, tools, plumbing, electrical supplies, building materials, paint ve
  protective equipment ayrımları cross-check edildi; hierarchy kopyalanmadı.
- [n11 — Yapı Market & Bahçe](https://www.n11.com/yapi-market-ve-bahce): nalburiye,
  el/elektrikli alet, boya, yapı malzemesi, elektrik/aydınlatma, kaynak/lehim, ölçüm
  ve iş güvenliği yerel intent sinyalleri incelendi. Bahçe/smart-home komşuluğu
  canonical ownership sayılmadı.
- [n11 — Elektrikli Aletler](https://www.n11.com/yapi-market-ve-bahce/elektrikli-aletler-yapi-market):
  delme, kesme, doğrama, vidalama ve profesyonel/amatör kullanım ayrımı incelendi.
- [Trendyol — Yapı Market](https://www.trendyol.com/yapi-market-x-c103720): hırdavat,
  alçı, boya, yüzey koruma ve el aleti discovery sinyalleri cross-check edildi.
- [Amazon Türkiye — Yapı Market](https://www.amazon.com.tr/b?node=26248552031):
  Yapı Market'in Mutfak, Ev & Yaşam ve Elektronik'ten ayrı üst intent'i incelendi.
- [Ticaret Bakanlığı — Yapı Malzemeleri](https://urunkurallari.ticaret.gov.tr/tr/sektorel-rehber/yapi-malzemeleri):
  performans beyanı, CE/G işaretleri ve mekanik/yangın/hijyen/güvenlik gerekleri
  category'den ayrı compliance contract için authoritative kaynaktır.
- [Ticaret Bakanlığı — Elektrikli Materyaller](https://urunkurallari.ticaret.gov.tr/tr/sektorel-rehber/elektrikli-materyaller):
  electrical safety, EMC ve CE gereksinimleri policy notlarına girdi verdi.
- [Ticaret Bakanlığı — Makinalar](https://urunkurallari.ticaret.gov.tr/tr/sektorel-rehber/makinalar):
  powered machinery safety'nin manual tool'dan ayrı product-policy profili oluşturduğu
  doğrulandı.
- [Ticaret Bakanlığı — Kişisel Koruyucu Donanımlar](https://urunkurallari.ticaret.gov.tr/tr/sektorel-rehber/kisisel-koruyucu-donanimlar):
  KKD tanımı, risk kategorileri, kullanım kılavuzu ve CE katmanı incelendi.

**SOURCE LIMITATION:** Marketplace'ler `Yapı Market & Bahçe` gibi EsnaftaVar'da ayrı
L1'lere ait ürünleri aynı commercial menüde toplar; bu geniş şemsiye canonical kanıt
sayılmadı. Tam seller trees statik export olarak doğrulanamadı. Hepsiburada'nın güncel
public full-tree export'u bulunamadığı için öneri ona bağımlı değildir.

## 4. Recommended L2 count

**Önerilen L2 sayısı: 14.**

Üst banda rağmen ayrımlar yapay değildir: tool/accessory compatibility, yapı kimyasalı
hazard verisi, üç farklı tesisat profile'ı ve KKD uygunluğu ayrı merchant schema ve
safety gate gerektirir. Marka, meslek, proje veya usage level üzerinden ek L2 yoktur.

## 5. Exact recommended L2 list

| # | Recommended L2 | Primary customer intent |
|---:|---|---|
| 1 | El Aletleri & Atölye Ekipmanları | Manuel yapım/onarım aleti veya tezgâh desteği bulmak |
| 2 | Elektrikli & Akülü El Aletleri | Motorlu/elektrikli taşınabilir çalışma aleti bulmak |
| 3 | Alet Uçları, Aksesuarları & Sarfları | Belirli aletle kullanılan uç, disk, bıçak veya sarf bulmak |
| 4 | Bağlantı Elemanları & Nalburiye | Vida, dübel, çivi ve genel montaj donanımı bulmak |
| 5 | Ölçüm, Test & İşaretleme | Yapı/atölye ölçme, test veya işaretleme aracı bulmak |
| 6 | Boya, Kaplama & Yüzey Hazırlama | Yüzeyi boyama/kaplama veya hazırlama ürünü bulmak |
| 7 | Yapıştırıcı, Dolgu & Yapı Kimyasalları | Birleştirme, sızdırmazlık veya kimyasal yapı ürünü bulmak |
| 8 | Yapı Malzemeleri | Yapıya kalıcı giren temel fiziksel malzeme bulmak |
| 9 | Su Tesisatı & Armatürler | Su taşıma, kontrol ve sanitary fixture ürünü bulmak |
| 10 | Elektrik Tesisatı Malzemeleri | Sabit elektrik dağıtım/bağlantı ürünü bulmak |
| 11 | Isıtma, Gaz & Havalandırma Tesisatı | Sabit thermal/gas/air installation bileşeni bulmak |
| 12 | Kilit, Kapı & Pencere Donanımları | Mekanik erişim ve kapı/pencere hardware ürünü bulmak |
| 13 | Kaynak, Lehim & Metal İşleme | Metal birleştirme/işleme ekipmanı veya sarfı bulmak |
| 14 | İş Güvenliği & Koruyucu Donanım | İş riskine karşı sertifikalı koruyucu ürün bulmak |

Normalized duplicate: **0**. Exact ad/sıra owner approval'a kadar öneridir.

## 6. Why this granularity

- Manual ve powered tools ayrı safety/power/attribute profiline sahiptir; uç/sarf ise
  yoğun compatibility verisi nedeniyle ayrı L2'dir.
- Fastener/nalburiye ile chemical bonding ayrılmıştır; hazard, cure ve substrate
  şeması chemical tarafta baskındır.
- Su, elektrik ve ısıtma/gaz/havalandırma installation bileşenleri farklı teknik ve
  compliance profile'ına sahiptir; gevşek `Tesisat` catch-all'ı kullanılmamıştır.
- Mechanical lock burada, connected lock owner-final Elektronik sınırındadır.
- KKD, kullanım amacı ve mevzuat tanımı nedeniyle ayrı L2'dir; sıradan giyim/gözlük/
  sağlık ürünü bu dala çekilmez.

## 7. Inclusions

| L2 | Dahil olan representative ürünler |
|---|---|
| El Aletleri & Atölye Ekipmanları | çekiç, tornavida, anahtar, pense, manuel testere, mengene, iş tezgâhı, takım çantası |
| Elektrikli & Akülü El Aletleri | matkap, vidalama, taşlama, zımpara, dekupaj/daire testere, kırıcı, freze |
| Alet Uçları, Aksesuarları & Sarfları | matkap ucu, testere bıçağı, kesme/zımpara diski, freze ucu, tool battery/charger |
| Bağlantı Elemanları & Nalburiye | vida, çivi, dübel, somun, civata, pul, kanca, menteşe/genel fitting |
| Ölçüm, Test & İşaretleme | şerit metre, su terazisi, lazer metre, multimetre, kalem/çizgi, stud detector |
| Boya, Kaplama & Yüzey Hazırlama | iç/dış cephe boya, vernik, astar, rulo/fırça, zımpara kâğıdı, maskeleme |
| Yapıştırıcı, Dolgu & Yapı Kimyasalları | silikon, mastik, epoksi, montaj yapıştırıcısı, derz/dolgu, harç katkısı |
| Yapı Malzemeleri | çimento, alçı, tuğla/blok, izolasyon, panel, çatı/zemin/duvar kaplama malzemesi |
| Su Tesisatı & Armatürler | boru/fitting, vana, musluk/batarya, lavabo, duş/sifon, pompa/tesisat parçası |
| Elektrik Tesisatı Malzemeleri | kablo, priz, anahtar, sigorta, pano, terminal, conduit, normal installation sensor |
| Isıtma, Gaz & Havalandırma Tesisatı | radyatör/valf, gaz fitting/regülatör, baca/kanal, menfez, fixed HVAC component |
| Kilit, Kapı & Pencere Donanımları | mekanik kilit, silindir, kol, kapı hidroliği, pencere fitting'i, menteşe |
| Kaynak, Lehim & Metal İşleme | kaynak makinesi, havya, elektrot/tel, torch, metal işleme fixture/sarfı |
| İş Güvenliği & Koruyucu Donanım | baret, iş gözlüğü, respirator, hearing protection, safety harness, protective glove |

## 8. Exclusions

- Bahçe aleti, canlı bitki, sulama/growing ürünü: **Çiçek & Bahçe** domain review.
- Vehicle-fitment tool/part/accessory: **Otomotiv & Motosiklet**; generic tool burada.
- Smart plug/bulb/lock, connected camera/sensor: owner-final **Elektronik → Akıllı Ev
  & Güvenlik**.
- Finished klima, fan, heater ve household appliance: **Beyaz Eşya & Ev Aletleri**;
  installation component burada.
- Dekoratif/taşınabilir consumer luminaire: **Ev & Yaşam → Aydınlatma** proposal;
  fixed wiring/switch/cable burada.
- Normal clothing, shoe, eyewear ve sports protection kendi L1'lerinde; yalnız iş
  riskine karşı tasarlanmış KKD bu domain'de.
- İnşaat, tesisatçı, elektrikçi, boya, anahtarcı, kaynak ve montaj hizmetleri kapsam dışı.
- Patlayıcı/pyrotechnic, regulated weapon ve bulk industrial hazardous material V1
  consumer proposal'a sessizce alınmaz.

## 9. Cross-domain boundaries

| Sınır | Kural |
|---|---|
| Hırdavat ↔ Elektronik | Mechanical/fixed installation hardware burada; connected consumer endpoint Elektronik'te. Embedded connectivity ana product function'i değiştirmiyorsa policy review gerekir. |
| Hırdavat ↔ Ev & Yaşam | Building/install/repair product burada; movable decor/furniture/household accessory Ev & Yaşam'da. |
| Hırdavat ↔ Beyaz Eşya & Ev Aletleri | Installation component burada; finished consumer appliance diğer L1'de. Replacement spare part exact future policy ister. |
| Hırdavat ↔ Çiçek & Bahçe | Generic workshop tool burada; primarily gardening/growing tool ve irrigation garden domain review'ünde. Building water installation burada kalır. |
| Hırdavat ↔ Otomotiv | Generic tool burada; vehicle-model fitment/diagnostic/part Otomotiv'de. |
| Hırdavat ↔ Giyim/Ayakkabı/Gözlük | Certified occupational PPE burada; ordinary garment/boot/glasses kendi product L1'inde. `İş tipi` marketing sözü tek başına KKD yapmaz. |
| Hırdavat ↔ Sağlık & Medikal | Occupational risk protection burada; diagnosis/treatment/medical device Sağlık & Medikal'de. FFP/respirator claim exact intended use/policy review ister. |

## 10. Category vs facet decisions

| Category değildir | Facet/policy hint |
|---|---|
| Güç | manual, corded, battery/pneumatic; voltage, watt, battery platform |
| Uyumluluk | tool model/platform, shank, disc diameter, pipe/thread size, fitting standard |
| Materyal/yüzey | wood, metal, concrete, ceramic, plastic; supported substrate |
| Performans | torque, speed, pressure, flow, measurement range/accuracy, protection rating |
| Yapı özelliği | fire class, thermal/acoustic value, load/strength, use environment |
| Chemical data | base chemistry, cure time, coverage, VOC/hazard, shelf life |
| KKD | hazard class, protection level, standard/certificate, size/fit |
| Ticari | marka, profesyonel/hobi etiketi, fiyat, stok, kampanya, featured, nearby |

## 11. Search synonyms

| L2 | Controlled search/synonym hints |
|---|---|
| El Aletleri & Atölye Ekipmanları | hand tools, takım, anahtar, pense, çekiç, tezgâh |
| Elektrikli & Akülü El Aletleri | power tools, şarjlı alet, matkap, taşlama, vidalama |
| Alet Uçları, Aksesuarları & Sarfları | bit, uç seti, disk, blade, tool battery |
| Bağlantı Elemanları & Nalburiye | fastener, vida, dübel, civata, nalbur |
| Ölçüm, Test & İşaretleme | measuring tool, metre, terazi, test cihazı, multimetre |
| Boya, Kaplama & Yüzey Hazırlama | paint, vernik, astar, boya malzemesi, yüzey hazırlık |
| Yapıştırıcı, Dolgu & Yapı Kimyasalları | adhesive, silikon, mastik, epoksi, derz |
| Yapı Malzemeleri | construction material, inşaat malzemesi, izolasyon |
| Su Tesisatı & Armatürler | plumbing, sıhhi tesisat, musluk, batarya, boru |
| Elektrik Tesisatı Malzemeleri | electrical supplies, elektrik malzemesi, priz, kablo, sigorta |
| Isıtma, Gaz & Havalandırma Tesisatı | HVAC component, kalorifer, gaz tesisatı, menfez, kanal |
| Kilit, Kapı & Pencere Donanımları | lock, kapı kolu, pencere aksesuarı, silindir |
| Kaynak, Lehim & Metal İşleme | welding, soldering, havya, kaynak makinesi, elektrot |
| İş Güvenliği & Koruyucu Donanım | PPE, KKD, iş güvenliği, baret, koruyucu gözlük |

`Batarya` sözcüğü su armatürü ve akü anlamına gelebilir; title, product type ve
compatibility context ile disambiguate edilmelidir.

## 12. Policy/compliance notes

- Applicable yapı malzemesinde performans beyanı ile CE/G işaretlemesi category'den
  ayrı doğrulanmalıdır; category placement uygunluk kanıtı değildir.
- Powered tool/electrical installation için voltage, electrical safety, EMC, machine
  safety, kullanım kılavuzu ve applicable conformity evidence gerekir.
- Gaz, basınç, yangın, structural load ve fixed electrical ürünleri yüksek riskli
  olabilir; installation-required görünürlüğü ve profesyonel kurulum uyarısı gerekir.
- Yapı kimyasalında hazard classification, kullanım/ventilation/PPE, shelf life ve
  transport/store restriction typed policy verisidir.
- KKD'de intended hazard, risk category, standard, CE/evidence, kullanım kılavuzu ve
  size/fit doğrulanmadan protection claim gösterilmemelidir.
- Yaş kısıtı, kesici/yanıcı ürün visibility'si ve seller eligibility ayrıca policy
  owner gerektirir; L2 listesi satış yetkisi vermez.

## 13. Ambiguous products

| Ürün | Proposed primary placement / rule |
|---|---|
| Matkap seti + uçlar | Principal powered tool ise Elektrikli/Akülü; yalnız uç seti Alet Uçları |
| Tool battery/charger | Belirli power-tool platform'u için Alet Uçları/Aksesuarları; generic consumer charger Elektronik boundary review |
| Multimetre | Ölçüm, Test & İşaretleme; computer/electronics bench use ownership'i değiştirmez |
| Smart priz | Elektronik → Akıllı Ev & Güvenlik; normal fixed priz Elektrik Tesisatı |
| Smart lock | Elektronik → Akıllı Ev & Güvenlik; mechanical cylinder/lock burada |
| LED ampul | Normal luminaire/lighting owner L3 review; smart bulb Elektronik; fixed electrical driver/component burada olabilir |
| Klima | Finished appliance Beyaz Eşya; duct/menfez/fixed fitting Tesisat |
| Bahçe hortumu | Çiçek & Bahçe; bina içi su borusu/fitting Su Tesisatı |
| Araç lokma seti | Generic socket set El Aletleri; vehicle-model-specific part/tool Otomotiv |
| İş ayakkabısı | Certified PPE intent'iyse İş Güvenliği; ordinary rugged boot Ayakkabı |
| Kaynak maskesi | İş Güvenliği & Koruyucu Donanım; kaynak makinesi Kaynak/Lehim |
| Havya | Kaynak, Lehim & Metal İşleme; solder consumable da aynı L2 future child'ı |
| Silikon mastik | Yapıştırıcı/Dolgu; sanitary-use facet Su Tesisatı'na duplicate etmez |
| Menteşe | Genel connection hardware ise Bağlantı Elemanları; kapı/pencere-specific ise ilgili donanım L2 |

Adjudication: ana işlev → power/fixed/install context → compatibility → safety/policy
profile → cross-domain owner → tek leaf. Çözülemeyen SKU review'a alınır.

## 14. Future L3/L4 examples

Yalnız feasibility örnekleri; full/final tree değildir:

| L2 | Olası variable-depth örneği | Guard |
|---|---|---|
| El Aletleri & Atölye Ekipmanları | Sıkma & Sabitleme → Anahtarlar | Ölçü/material facet'tir. |
| Elektrikli & Akülü El Aletleri | Delme & Vidalama → Matkap | Güç/battery platform facet'tir. |
| Alet Uçları, Aksesuarları & Sarfları | Delme Uçları → Matkap Ucu | Shank/diameter/substrate facet'tir. |
| Su Tesisatı & Armatürler | Armatürler → Mutfak Bataryası | Finish/ölçü/installation facet'tir. |
| Elektrik Tesisatı Malzemeleri | Anahtar & Priz → Priz | Smart endpoint bu child'a girmez. |
| İş Güvenliği & Koruyucu Donanım | Baş Koruma → Baret | Protection standard category adı olmaz. |

## 15. Open owner decisions

1. **14 L2 exact adı ve sırası** kabul/ret/revise edilmelidir.
2. **KKD ownership:** certified occupational PPE'nin bu L1'de kalması önerilir;
   ordinary Giyim/Ayakkabı/Gözlük ve medical product sınırı owner-final olmalıdır.
3. **Normal ampul/driver/fixed luminaire:** Ev & Yaşam Aydınlatma ile Elektrik
   Tesisatı arasındaki exact L3 placement gerçek SKU pilotuyla çözülmelidir.
4. **Tool battery/charger:** model-specific accessory rule önerisi, generic charging
   için owner-final Electronics boundary ile uyumlu olarak onaylanmalıdır.
5. **Heating/gas/HVAC component scope:** consumer discovery ile regulated installer-
   only ürünlerin visibility/seller policy sınırı ayrı policy-owner kararı ister.

Bu kararlar açıkken agent `FINAL`, stable ID veya runtime mapping üretemez.

## 16. Validation summary

- Canonical L1 **Yapı, Hırdavat & Tesisat**: **PASS — unchanged**
- Status **PROPOSED FOR OWNER REVIEW**: **PASS**
- Recommended L2 / duplicate: **14 / 0**
- Tool/accessory, chemical, installation and PPE profiles separated: **PASS**
- Electronics/Appliance/Garden/Automotive leakage guards: **PASS**
- Brand/project/professional level as category: **0**
- Product/Merchant/Service separation: **PASS**
- Full L3/L4 tree: **NOT PRODUCED**
- Flutter/Figma/JSON/DB/runtime/remote changes: **NONE**

`HARDWARE_PLUMBING_L2_PROPOSAL: READY_FOR_OWNER_REVIEW`

`HARDWARE_PLUMBING_L2_COUNT: 14`

`OWNER_APPROVAL: OPEN`
