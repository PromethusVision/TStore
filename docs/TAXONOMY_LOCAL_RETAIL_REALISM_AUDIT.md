# Taxonomy Local Physical Retail Realism Audit

## Status and lens

**AUDIT RATING — NO OWNER FINALIZATION / NO RUNTIME**

This scorecard tests all 24 owner-final L1 domains against Turkish neighborhood physical retail rather than giant-marketplace completeness. Ratings consider familiar shop language, realistic co-stock patterns, customer discovery and merchant onboarding burden. A low rating is a review signal, not a source-proposal rewrite.

## Per-L1 ratings

| L1 | Rating | Typical neighborhood shop compatibility | Discoverability and co-stock realism | Marketplace/onboarding risk | Recommendation |
|---|---|---|---|---|---|
| Elektronik | STRONG | Telefoncu, elektronikçi, güvenlik/ses mağazası | Final L2 boundaries match common customer language. | Cross-domain chargers and smart devices need root rules. | Preserve; apply generic/domain-specific accessory rules. |
| Bilgisayar & Tablet | STRONG | Bilgisayarcı, yazıcı/sarf ve ağ mağazası | Final device/component/peripheral separation is recognizable. | Internal/external component confusion. | Preserve final boundaries and compatibility facets. |
| Gıda & İçecek | STRONG | Market, manav, kasap, şarküteri, fırın | Core 14 departments cover daily local shopping. | Supplements/medical nutrition are missing and regulated. | Preserve core; owner-review ingestible gap. |
| Giyim & Moda | ACCEPTABLE | Butik, konfeksiyon, iç giyim mağazası | Product-form groups are usable. | Sport/work/use axes overlap facets and PPE. | Clarify technical/PPE rules before L3. |
| Ev & Yaşam | ACCEPTABLE | Ev tekstili, perdeci, halıcı, mobilyacı | Familiar home departments. | `Mobilya` is very broad; fixed/movable boundaries cross Hırdavat. | Keep L1; prioritize furniture and fixed-installation descendants. |
| Züccaciye & Mutfak | STRONG | Züccaciye, mutfak gereçleri mağazası | Closely matches products stocked together locally. | Manual/electric boundary with appliances. | Preserve; document electric-vs-manual rule. |
| Yapı, Hırdavat & Tesisat | STRONG | Nalbur, elektrikçi, tesisatçı, boya mağazası | Strong local shop mapping and task-based discovery. | Very broad assortment; PPE/electronics/garden overlaps. | Retain; use primary-function and professional safety rules. |
| Kozmetik & Kişisel Bakım | STRONG | Kozmetikçi, parfümeri, kişisel bakım mağazası | Customer-facing routines are familiar. | Claims can leak into medikal; electric devices into appliances. | Separate claim/policy from category and device form. |
| Ayakkabı | ACCEPTABLE | Ayakkabıcı and shoe-repair accessory sellers | Product intent clear for most customers. | Daily/classic/age are cross-cutting; technical shoes overlap sport/PPE. | Review L2 axes before L3. |
| Çanta & Aksesuar | ACCEPTABLE | Çantacı, valizci, accessory shop | Generic bag forms work locally. | Technical equipment, baby, sport and vehicle bags need domain rule. | Preserve generic branch; domain-specific case rule. |
| Beyaz Eşya & Ev Aletleri | STRONG | White-goods dealer, small-appliance seller, vacuum shop | Large/small appliance distinction maps to retail. | Smart feature should not move appliance; accessory/sarf is broad. | Preserve with device-first rule. |
| Anne & Bebek | STRONG | Bebe mağazası, mother-baby specialty shop | Safety/formulation needs justify domain-specific grouping. | Baby food and diaper bag compete with generic domains. | Owner-review baby-specific override and regulation. |
| Oyuncak & Hobi | ACCEPTABLE | Oyuncakçı, hobby/model shop | Major play/model intents are discoverable. | Toy-grade electronics, collection and regulated items. | Define functional-toy and age/safety boundary. |
| Müzik & Enstrüman | ACCEPTABLE | Müzik mağazası and instrument repair/supply seller | Instrument families fit specialist local retail. | Traditional registry overlaps form; pro audio overlaps electronics/computer. | Use registry metadata and pro-audio intended-use rule. |
| Spor & Outdoor | ACCEPTABLE | Spor mağazası, bisikletçi, kamp/balıkçı shop | Equipment departments are recognizable. | Apparel/shoes and regulated hunting items blur scope. | Keep equipment-first; policy-gate risky products. |
| Hediyelik & Parti | NEEDS_SIMPLIFICATION | Parti malzemecisi and hediyelikçi exist locally | True party supplies are discoverable. | Gift intent duplicates every other L1; several narrow party L2s. | Limit ownership to actual party/gift-supply objects; use collections for gift intent. |
| Otomotiv & Motosiklet | STRONG | Oto aksesuarcı, yedek parçacı, motosiklet shop | Fitment-centered local commerce is strong. | Vehicle electronics and bags/chargers cross domains. | Preserve; adopt vehicle-fitment root rule. |
| Kitap | STRONG | Mahalle kitabevi and textbook seller | Reader/search language is established. | Topic boundaries can overlap; personalized/digital formats outside scope. | Preserve; use subject/audience facets and physical-format rule. |
| Çiçek & Bahçe | STRONG | Çiçekçi, fideci, garden supply shop | Living plants, arrangements and growing supplies map locally. | Power tools, furniture and smart sensors cross domains. | Preserve; clarify finished garden equipment vs generic tool/device. |
| Sağlık & Medikal | ACCEPTABLE | Medikal supply shop and home-care seller | Device/sarf focus is realistic and safer than broad “health.” | Supplements, medical nutrition and licensed medicines lack/require policy. | Keep device focus; fail closed on ingestible/drug scope. |
| Gözlük & Optik | STRONG | Optik mağazası | Highly coherent local specialist assortment. | Finished non-prescription glasses and sport/PPE eyewear boundaries. | Preserve; add future leaf/scope clarification. |
| Evcil Hayvan Ürünleri | NEEDS_RESTRUCTURE | Pet shop | Species navigation feels familiar. | Species-wide L2s mix food, health, habitat, grooming and accessories; shared products duplicate. | Owner-review species-first vs product-family architecture before L3. |
| Kırtasiye & Ofis | STRONG | Mahalle kırtasiyesi, copy/office supply shop | Closely matches mixed local inventory and search terms. | Art/education/tool-form overlaps are manageable. | Preserve; resolve product-form vs use-specific precedence. |
| Saat & Takı | STRONG | Kuyumcu, bijuteri, saatçi | Form-based jewelry L2s are customer-readable. | Material, personalization, gift and bundle signals must stay facets/policy. | Preserve form ownership; add material disclosure facets. |

## Distribution

| Rating | Count |
|---|---:|
| STRONG | 14 |
| ACCEPTABLE | 8 |
| NEEDS_SIMPLIFICATION | 1 |
| NEEDS_RESTRUCTURE | 1 |

The table has 24 L1 rows and the distribution sums to 24.

## Cross-domain local-shop findings

1. A merchant is not a taxonomy node. A neighborhood store must be able to list products across several L1s without choosing one “merchant category” as an ownership cage.
2. Product-form and primary-function language is usually more stable than gender, occasion, gift, professional or smart labels.
3. Specialist local shops justify domain-specific accessories when compatibility/safety is intrinsic: vehicle fitment, instrument cases, camera cases, baby safety and medical consumables.
4. Giant-marketplace fragmentation is most visible in narrow party nodes, style/age footwear axes and species-wide pet duplication.

## Validation

- Owner-final L1 evaluated: 24/24.
- Proposal rewrite: NO.
- Merchant taxonomy confused with product taxonomy: NO.
- Runtime/merchant onboarding implementation: NO.

`LOCAL_RETAIL_REALISM_AUDIT: PASS`
