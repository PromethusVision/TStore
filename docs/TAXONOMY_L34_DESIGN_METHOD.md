# EsnaftaVar L3/L4 Taxonomy Design Method

**Durum:** CANONICAL WORKING METHOD

**Kaynak pilotlar:** Telefon & Aksesuarları ve Bilgisayar Bileşenleri —
**CONFIRMED — PRODUCT OWNER FINAL**

**Kapsam:** Gelecekteki L3/L4 proposal ve owner-review çalışmalarının operasyonel
yöntemi. Runtime, stable ID, migration, Flutter, Figma veya remote apply sözleşmesi
değildir.

## 1. Hierarchy

- Maksimum yol `L1 → L2 → L3 → L4`'tür.
- Variable depth kullanılır; leaf `L2`, `L3` veya `L4` olabilir.
- Gerçek ürün tipi ayrımı gerekmiyorsa artificial depth oluşturma.
- `L5` oluşturma.

## 2. Core rule

Category describes **WHAT THE PRODUCT IS** — ürünün ne olduğunu. Facet/attribute
describes **WHAT CHARACTERISTICS THE PRODUCT HAS** — ürünün hangi özelliklere sahip
olduğunu.

Brand, model compatibility, color, size, capacity, material, connector, power, OS,
CPU/GPU, network generation ve technical compatibility varsayılan olarak facet'tir.
Explicit canonical gerekçe ve owner kararı olmadan category depth'e dönüştürülmez.

## 3. Primary leaf

- Her canonical product sonunda exactly one primary canonical leaf kullanır.
- Cross-domain duplication yasaktır.
- Belirsiz ürün için ana işlev, customer intent ve merchant data schema birlikte
  değerlendirilir; çözülmeyen sınır `OPEN/TBD` kalır ve review'a gider.

## 4. Product vs service

- Fiziksel, ayrı satılabilir ürün Product Taxonomy'ye girebilir.
- Labor / reservation / subscription / tariff / activation service Product
  Taxonomy'ye sessizce alınmaz.
- Service-domain soruları ayrı Merchant/Service Taxonomy veya capability kararında
  tutulur.

## 5. Generic vs specific accessories

Primary functional/domain identity kullanılır:

- generic charger → general charging domain;
- phone-model-specific charger → phone accessory domain;
- PC-specific device → computer domain;
- general consumer electronics → electronics domain.

Ürünün yalnız başka bir cihazla kullanılabilmesi, tek başına specific-domain
ownership üretmez.

## 6. Technical compatibility

Compatibility category depth değildir; typed facet ve versioned relationship olarak
tasarlanır. Gelecek conceptual sonuçlar yalnız:

- `compatible`
- `incompatible`
- `conditional`
- `unknown`

olmalıdır. Eksik veri otomatik olarak `compatible` sayılmaz.

## 7. Bundles

Bundle/kit otomatik category değildir. Owner açıkça farklı karar vermedikçe ürün,
principal product leaf'ine atanır; bundle/kit bilgisi tag/facet/metadata olarak
tutulur. Principal ürün kesin değilse rastgele leaf seçilmez, review gerekir.

## 8. Search synonyms

- Synonym ve alias discovery'yi destekler; taxonomy node oluşturmaz.
- Brand adları, individual modeller ve ordinary typo'lar canonical category veya
  canonical synonym yapılmaz.
- Exact canonical name, semantic synonym, alias ve normalized search token ayrı
  sorumluluklardır.

## 9. Research requirements

Proposal mümkün olduğunda birden fazla credible/current kaynağı karşılaştırır:

- Google Product Taxonomy / Merchant Center
- Trendyol
- Hepsiburada
- n11
- yararlı olduğunda Amazon Türkiye
- teknik sınır gerektiğinde manufacturer veya standards authority

Marketplace ağaçları körlemesine kopyalanmaz. EsnaftaVar'ın hedefi yerel fiziksel
perakende discoverability'sidir; kaynak tarihi, erişim sınırlaması ve negatif sınır
kanıtları açıkça yazılır.

## 10. Owner states

İzin verilen karar durumları:

- `PROPOSED FOR OWNER REVIEW`
- `CONFIRMED — PRODUCT OWNER FINAL`

Agent, açık owner kararı olmadan `PROPOSED` durumunu `FINAL` yapamaz. Açık kalan
kararlar `OPEN/TBD` olarak korunur.

## 11. Unattended-safe behavior

Overnight/unattended taxonomy batch'lerinde:

- araştırmayı otonom yürüt;
- mikro-onay isteme;
- çözülmeyen owner kararlarını `OPEN/TBD` bırak ve karar uydurma;
- bir domainde non-fatal blocker varsa kaydet, diğer bağımsız domaine devam et;
- tamamlanan her domain sonrası scoped checkpoint commit/push yap;
- yalnız atanmış proposal/domain dosyalarını değiştir; canonical merkezi belgeleri
  integration owner'ına bırak;
- Production, Development, runtime JSON, stable ID, DB/migration, Flutter ve Figma'ya
  görev açıkça yetki vermedikçe dokunma;
- maksimum depth, node/leaf counts, duplicate, primary-leaf, category/facet,
  product/service ve cross-domain boundary kontrollerini raporla.

`L34_DESIGN_METHOD_CANONICAL: PASS`

`MAX_DEPTH: 4`

`ARTIFICIAL_DEPTH: FORBIDDEN`

`EXACTLY_ONE_PRIMARY_LEAF: REQUIRED`

`OWNER_DECISION_INVENTION: FORBIDDEN`

`RUNTIME_IMPLEMENTATION: NOT_STARTED`
