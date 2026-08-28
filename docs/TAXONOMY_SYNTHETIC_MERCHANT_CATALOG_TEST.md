# Synthetic Local Merchant Catalog Taxonomy Test

## Status and principle

**AUDIT TEST — NO MERCHANT OR PRODUCT TAXONOMY IMPLEMENTATION**

A merchant may stock products from multiple L1 domains. `SHOP_TYPE` is an archetype for testing catalog reality, never the canonical owner of every product in that shop. Each SKU still needs its own primary product leaf.

## Merchant archetypes

| ID | Shop type | Likely L1 | Likely L2 mix | Cross-L1 product mix | Onboarding complexity | Taxonomy problem | Recommendation |
|---|---|---|---|---|---|---|---|
| MER-001 | Mahalle bakkalı | Gıda & İçecek | Alkolsüz İçecekler; Atıştırmalık; Kahvaltılık; Hazır Gıda | Ev Temizliği; Kişisel Hijyen | MEDIUM | Merchant sector cannot own non-food convenience stock. | Permit per-SKU cross-L1 assignment; offer recent/common leaf shortcuts. |
| MER-002 | Manav | Gıda & İçecek | Taze Meyve & Sebze | Çiçek & Bahçe seasonal plants | LOW | Live herb sold as food vs planted herb. | Use sellable intended form: harvested food vs living plant. |
| MER-003 | Kasap ve şarküteri | Gıda & İçecek | Et, Tavuk, Balık & Şarküteri; Kahvaltılık | Züccaciye knives/boards as occasional stock | LOW | Accessory stock is not food. | Keep cross-L1 stock explicit. |
| MER-004 | Fırın ve pastane satış noktası | Gıda & İçecek | Ekmek, Unlu Mamuller & Pastacılık; Atıştırmalık | Hediyelik party cake accessories | LOW | Finished food vs celebration accessory. | Classify the physical item, not occasion. |
| MER-005 | Mahalle kırtasiyesi | Kırtasiye & Ofis | Writing; paper; school; art; packaging | Kitap; Oyuncak; Hediyelik & Parti | HIGH | Typical inventory spans four L1s. | Bulk onboarding needs product-family suggestions, not a one-L1 merchant cage. |
| MER-006 | Fotokopi ve ofis sarf dükkânı | Kırtasiye & Ofis | Baskı Sarfı; Dosyalama; Ofis Makineleri | Bilgisayar printer accessories; services | MEDIUM | Toner ownership and copy service can leak. | Hardware/sarf follow product owner; copying labor excluded to services. |
| MER-007 | Kitabevi | Kitap | Literature; education; exam; children | Kırtasiye; puzzle; cards | MEDIUM | Topic/audience and mixed stationery. | ISBN/publication form remains Book; adjacent products retain their own L1. |
| MER-008 | Çocuk kitapçısı | Kitap | Çocuk & Gençlik; Education | Oyuncak educational kits; Kırtasiye activity supplies | MEDIUM | Activity book vs detachable kit. | Use bound publication vs kit/loose-material rule. |
| MER-009 | Telefoncu | Elektronik | Telefon & Aksesuarları; Güç, Şarj & Bağlantı; Giyilebilir | Bilgisayar peripherals; repair service | HIGH | Generic chargers, device-specific accessories and labor collide. | Apply final compatibility boundary; exclude labor from product taxonomy. |
| MER-010 | Bilgisayarcı | Bilgisayar & Tablet | Computers; components; storage; peripherals; network | Electronics chargers/audio; repair service | HIGH | Internal/external components and generic connection products. | Use owner-final component/accessory rules and compatibility facets. |
| MER-011 | Güvenlik sistemleri mağazası | Elektronik | Akıllı Ev & Güvenlik; connectivity | Hırdavat locks/cabling; installation service | HIGH | Smart lock vs mechanical lock vs installation. | Connected device, mechanical hardware and service must remain separate layers. |
| MER-012 | Tüketici ses sistemi mağazası | Elektronik | Ses & Kulaklık; TV & Görüntü | Music pro-audio and cables | MEDIUM | Consumer playback vs production/live sound. | Intended workflow root rule; generic cables stay Power/Connection. |
| MER-013 | Beyaz eşya bayisi | Beyaz Eşya & Ev Aletleri | Large cooking; cooling; laundry; climate | Electronics smart accessories; appliance filters | MEDIUM | Smart feature could misroute devices. | Appliance primary function wins; smart/protocol remains facet. |
| MER-014 | Küçük ev aletleri mağazası | Beyaz Eşya & Ev Aletleri | Small kitchen; cleaning; personal care devices | Züccaciye manual tools | MEDIUM | Electric grinder vs manual grinder. | Electric-device vs manual-utensil rule. |
| MER-015 | Züccaciye | Züccaciye & Mutfak | Cookware; tableware; drinkware; preparation; storage | Small appliances; home organizers | HIGH | Near-identical manual/electric and room-specific products. | Ask power source and primary room/function during onboarding. |
| MER-016 | Ev tekstili mağazası | Ev & Yaşam | Bedding; home textiles; curtain; rugs | Giyim sleepwear; kitchen textiles | MEDIUM | Textile material alone cannot decide owner. | Product form/room function first; material as facet. |
| MER-017 | Mobilyacı | Ev & Yaşam | Mobilya; sleep products | Fixed bathroom units; garden furniture | MEDIUM | Fixed-installation and outdoor use boundaries. | Retain furniture owner unless product is structural/installation hardware. |
| MER-018 | Aydınlatmacı | Ev & Yaşam | Aydınlatma | Hırdavat electrical installation; Electronics smart bulbs | HIGH | Finished luminaire, wiring component and connected device differ. | Three-way root rule required; merchant may list all three L1s. |
| MER-019 | Nalbur | Yapı, Hırdavat & Tesisat | Fasteners; tools; paint; plumbing; electrical | Garden tools; PPE; household cleaners | HIGH | Broad co-stock and primary-function overlaps. | Task-assisted search plus per-SKU leaf assignment. |
| MER-020 | Boya ve yapı kimyasalları mağazası | Yapı, Hırdavat & Tesisat | Paint; surface prep; adhesives; chemicals | Home cleaning; garden chemicals | HIGH | Chemical intended use and legal labels. | Separate product ownership from hazard/policy metadata. |
| MER-021 | Elektrik malzemecisi | Yapı, Hırdavat & Tesisat | Electrical installation; measurement | Electronics components/chargers; smart devices | HIGH | USB tester, smart switch, generic cable. | Primary function + connected-device rule. |
| MER-022 | Tesisatçı malzeme mağazası | Yapı, Hırdavat & Tesisat | Plumbing; heating/gas/ventilation; fixtures | Bathroom accessories; appliances | MEDIUM | Fixed fixture vs movable bathroom accessory/device. | Movable-vs-fixed and device-vs-installation rules. |
| MER-023 | Kozmetikçi ve parfümeri | Kozmetik & Kişisel Bakım | Makeup; skin; hair; perfume; hygiene | Electric care devices; baby care | HIGH | Claim, age and powered-device leakage. | Keep claim/age facets; route powered device to appliance owner. |
| MER-024 | Medikal mağaza | Sağlık & Medikal | Measurement; orthopedic; mobility; patient care; PPE | Optics; regulated nutrition | HIGH | Drug/supplement assumptions and PPE overlap. | Fail closed for ingestibles/medicines; certification as policy. |
| MER-025 | Optik mağazası | Gözlük & Optik | Frames; lenses; sunglasses; contacts; care | Safety/sports eyewear; services | MEDIUM | Sport/PPE purpose and lens fitting labor. | Optical correction vs PPE/sport rule; exclude fitting labor. |
| MER-026 | Anne-bebek mağazası | Anne & Bebek | Feeding; diapers; bath; travel; safety; maternity | Baby clothing/shoes/toys; baby food | HIGH | Baby override can duplicate generic domains. | Use safety/formulation/device-specific rule, not age alone. |
| MER-027 | Oyuncakçı | Oyuncak & Hobi | Preschool; educational; figures; vehicles; games | Books; stationery; electronics | HIGH | Electronic toy vs functional device and activity book. | Toy-grade capability/age safety rule. |
| MER-028 | Hobi ve maket mağazası | Oyuncak & Hobi | Models; crafts; collection | Stationery art; electronics maker boards; jewelry supplies | HIGH | Kit vs component/supply and age intent. | Finished kit/intended-use rule; merchant crosses L1 freely. |
| MER-029 | Müzik mağazası | Müzik & Enstrüman | Instruments; accessories; amps; recording | Consumer audio; computers; cases | HIGH | Pro-audio, USB peripherals and equipment cases. | Intended workflow and domain-specific case rules. |
| MER-030 | Spor mağazası | Spor & Outdoor | Fitness; team; racket; individual; combat | Technical clothing; shoes; bags; nutrition | HIGH | Product form vs sport use and supplement gap. | Equipment remains Sport; apparel/shoes retain form owners; nutrition owner decision. |
| MER-031 | Bisikletçi | Spor & Outdoor | Bisiklet | Bags; electronics; tools; apparel | HIGH | Frame bag, GPS/light and repair service. | Fitment-specific bicycle products Sport; generic items keep base owner; labor excluded. |
| MER-032 | Kamp ve outdoor mağazası | Spor & Outdoor | Outdoor, Camp & Trekking | Technical bags/shoes/clothing; garden/outdoor furniture | HIGH | Technical gear crosses product-form L1s. | Safety/fitment-specific equipment rule plus usage facets. |
| MER-033 | Balıkçılık mağazası | Spor & Outdoor | Balıkçılık & Avcılık | Clothing; coolers; restricted goods | HIGH | “Avcılık” mixes regulated products with benign equipment. | Policy gate dangerous items; consider owner review of combined L2. |
| MER-034 | Ayakkabıcı | Ayakkabı | Daily; sport; classic; boots; sandals | Care products; technical/PPE shoes | MEDIUM | Style, age and use axes overlap. | Capture product form and technical standard; use facets for style/age. |
| MER-035 | Çantacı ve valizci | Çanta & Aksesuar | Hand/shoulder; backpack; laptop; luggage; wallet | Technical camera/instrument/baby/sport cases | HIGH | Equipment bags cannot all stay generic. | Generic bag owner vs domain-specific protective case root rule. |
| MER-036 | Butik ve giyim mağazası | Giyim & Moda | Tops; bottoms; dresses; outerwear; sleep; swim | Bags; jewelry; shoes; sportswear | HIGH | Merchant assortment naturally spans four L1s. | Multi-L1 catalog is mandatory; gender/style remain filters. |
| MER-037 | İş güvenliği mağazası | Yapı, Hırdavat & Tesisat | PPE | Safety shoes; protective clothing; medical PPE | HIGH | Product form competes with certified intended use. | PPE root rule based on standard/intended use, not merchant type. |
| MER-038 | Pet shop | Evcil Hayvan Ürünleri | Cat; dog; aquarium; bird; small animal; shared care | Veterinary diets/products; storage/cleaning | HIGH | Species-wide L2s are broad; shared products duplicate. | Owner-review product-family vs species architecture; policy-gate veterinary items. |
| MER-039 | Çiçekçi | Çiçek & Bahçe | Live plants; cut flowers; arrangements; pots | Gifts; cards; decorations | MEDIUM | Gift intent tries to duplicate flowers. | Flower remains primary; gift is collection/occasion. |
| MER-040 | Bahçe malzemecisi | Çiçek & Bahçe | Soil; irrigation; tools; care; greenhouse | Power tools; furniture; smart sensors; chemicals | HIGH | Finished device/tool and pesticide policy boundaries. | Primary function rule and fail-closed chemical policy. |
| MER-041 | Kuyumcu | Saat & Takı | Rings; necklaces; bracelets; watches | Gift packaging; personalized service | MEDIUM | Precious material and gift signals can become categories. | Form-based owner; material/personalization as policy/facet. |
| MER-042 | Bijuteri ve aksesuarcı | Saat & Takı / Çanta & Aksesuar | Costume jewelry; hair accessories; wallets | Gift items and party costume accessories | HIGH | Same shop does not imply one L1; body location/product form matters. | Per-SKU classification with form-first prompts. |
| MER-043 | Parti malzemecisi | Hediyelik & Parti | Balloons; decor; tableware; costumes; cake accessories | Toys; stationery; kitchen disposables | HIGH | Several narrow L2s and occasion-driven duplicates. | Keep true party supplies; do not absorb gift-intent products. |
| MER-044 | Hediyelik eşya dükkânı | Hediyelik & Parti | Souvenir objects; gift packaging; cards | Food; flowers; jewelry; mugs; textiles | HIGH | Most inventory has a stronger physical-product owner. | Use a gift collection across L1s; dedicated L1 only for actual souvenir/supply objects. |
| MER-045 | Oto aksesuarcı | Otomotiv & Motosiklet | Interior/exterior accessories; electronics; care; safety | Generic chargers; bags; audio | HIGH | Vehicle fitment competes with generic electronics/product form. | Apply explicit fitment threshold and preserve generic adapter boundary. |
| MER-046 | Motosiklet ekipman mağazası | Otomotiv & Motosiklet | Parts; protection; electronics | Apparel; bags; phone mounts | HIGH | Certified protective gear and vehicle-mounted accessories. | Vehicle-specific intended use wins; size/style remain facets. |

## Results

- Merchant archetypes tested: **46**.
- Archetypes with cross-L1 stock: **46/46**.
- Merchant onboarding complexity: LOW 3, MEDIUM 14, HIGH 29.
- No archetype can be represented safely by assigning its entire catalog to one merchant-owned L1.
- Highest recurring problems: generic/domain-specific accessories, fitment, powered/manual devices, PPE, regulated ingestibles/chemicals, equipment cases and gift intent.

## Onboarding implications

1. Merchant profile may record shop type for discovery and suggested defaults, but must not constrain product ownership.
2. The product form/primary function should be asked first; compatibility, target audience, material and occasion follow as facets.
3. Recent leaves, common bundles and search synonyms can reduce onboarding effort without flattening the taxonomy.
4. Services, restricted goods and uncertain policy scopes must fail closed rather than being placed in the nearest physical-product L2.

## Validation

- Minimum merchant archetypes: 46/40 PASS.
- Domain coverage: 24/24 L1 represented.
- Cross-L1 merchant inventory supported conceptually: PASS.
- Merchant taxonomy confused with product taxonomy: NO.
- Owner finalization/runtime implementation: NO.

`SYNTHETIC_MERCHANT_CATALOG_TEST: PASS`
