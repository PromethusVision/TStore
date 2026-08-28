# EsnaftaVar Global L2 Collision Registry

**Wave:** 15 / Global L2 Cross-Batch Audit

**State:** Audit registry only; all owner-required resolutions remain open.

## Collision classes

- `A — EXACT DUPLICATE`: same normalized L2 display name under multiple L1s.
- `B — SEMANTIC OVERLAP`: differently named nodes cover materially the same sellable product family.
- `C — BOUNDARY AMBIGUITY`: a product can reasonably satisfy multiple L1 definitions without an approved precedence rule.
- `D — FACET-AS-CATEGORY`: attribute, audience, occasion or merchandising intent can masquerade as a canonical category.
- `E — SERVICE LEAKAGE`: labor, reservation, project or subscription can enter Product Taxonomy through a product-like label.
- `F — POLICY OWNERSHIP ISSUE`: category ownership and legal/listing eligibility can be conflated.
- `G — FUTURE L3/L4 DEPENDENCY`: L2 can remain, but deterministic leaf assignment needs a later lower-level rule.

Independent normalized comparison found **0 class-A exact duplicate L2 names** among the 224 proposals. The registry therefore begins with class B.

## Registry

| COLLISION ID | TYPE | L1 A | L1 B/C | PRODUCT EXAMPLES | WHY COLLISION EXISTS | CURRENT PROPOSAL STATE | RECOMMENDED CANONICAL OWNER/RULE | OWNER DECISION REQUIRED | P0/P1/P2 | DOWNSTREAM IMPACT | CAN AUTO-RESOLVE AFTER OWNER DECISION? YES/NO |
|---|---|---|---|---|---|---|---|:---:|:---:|---|:---:|
| COL-B-001 | B — SEMANTIC OVERLAP | Gıda & İçecek | Anne & Bebek | Baby food, baby snack | Food form overlaps life-stage feeding schema | Both proposals flag ownership as open | Anne & Bebek for explicitly baby-intended food | YES | P0 | L3, policy metadata, merchant input | YES |
| COL-B-002 | B — SEMANTIC OVERLAP | Gıda & İçecek | Sağlık & Medikal | Medical nutrition, enteral product | Nutrition form overlaps medical intended use | Health scope excludes silent assignment | Health when evidenced medical purpose exists | YES | P0 | Eligibility, claims, search | YES |
| COL-B-003 | B — SEMANTIC OVERLAP | Kozmetik & Kişisel Bakım | Sağlık & Medikal | Dermocosmetic, medicated cream | Cosmetic form can carry treatment claims | Open intended-use threshold | Cosmetic purpose in Cosmetics; medical purpose in Health/legal gate | YES | P0 | Claims, moderation, leaf profiles | YES |
| COL-B-004 | B — SEMANTIC OVERLAP | Giyim & Moda | Spor & Outdoor | Technical jacket, base layer | Apparel form and sport performance both appear primary | Cross-batch threshold open | Giyim by product form unless an approved specialist-system rule applies | YES | P0 | Apparel leaf tree, sport discovery | YES |
| COL-B-005 | B — SEMANTIC OVERLAP | Giyim & Moda | Yapı, Hırdavat & Tesisat | Protective suit, reflective PPE vest | Garment form overlaps certified protection | PPE precedence open | Hardware/OHS for certified protective purpose; uniform in Giyim | YES | P0 | Compliance evidence, search projection | YES |
| COL-B-006 | B — SEMANTIC OVERLAP | Ev & Yaşam | Züccaciye & Mutfak | Organizer, storage box, food container | Both proposals contain storage concepts | Food-contact threshold proposed, not approved | Kitchen for food storage/contact; Home for general objects | YES | P0 | L3, food-contact profile | YES |
| COL-B-007 | B — SEMANTIC OVERLAP | Ev & Yaşam | Züccaciye & Mutfak | Kitchen towel, table textile | Material is home textile; function is kitchen | Open functional-use rule | Kitchen for kitchen-functional textile | YES | P0 | Leaf assignment and browse | YES |
| COL-B-008 | B — SEMANTIC OVERLAP | Ev & Yaşam | Beyaz Eşya & Ev Aletleri | Mop, powered cleaner, steam cleaner | Manual consumable and powered appliance share cleaning intent | Power/device threshold proposed | Powered device in Appliances; manual home-care product in Home | YES | P0 | Attribute schemas, filters | YES |
| COL-B-009 | B — SEMANTIC OVERLAP | Ev & Yaşam | Çiçek & Bahçe | Garden chair, balcony table | Furniture form overlaps garden purpose | Garden-primary threshold open | Garden-specific furniture in Flowers/Garden; general furniture in Home | YES | P0 | L2 ownership and search | YES |
| COL-B-010 | B — SEMANTIC OVERLAP | Otomotiv & Motosiklet | Elektronik | GPS, charger, multimedia | Consumer electronics may be installed in a vehicle | Owner-final fitment guard exists but generic threshold needs owner wording | Vehicle fitment/protocol in Automotive; generic device in Electronics | YES | P0 | Compatibility, offer ingestion | YES |
| COL-B-011 | B — SEMANTIC OVERLAP | Evcil Hayvan Ürünleri | Gıda & İçecek | Pet food, pet treat | Physical food form is similar but intended consumer differs | Pet species-first proposal | Pet domain for animal-intended nutrition | YES | P0 | Safety metadata, search isolation | YES |
| COL-B-012 | B — SEMANTIC OVERLAP | Saat & Takı | Çanta & Aksesuar | Fashion jewelry, brooch, hair jewelry | Fashion merchandising can obscure jewelry form | Form precedence open | Jewelry form in Saat & Takı; textile/hair accessory in Bags/Accessories | YES | P0 | Naming and leaf mapping | YES |
| COL-C-001 | C — BOUNDARY AMBIGUITY | Gıda & İçecek | Sağlık & Medikal | Gluten-free meal, diabetic-labeled food | Special-diet facet can become medical intended use | Open claim threshold | Ordinary food in Gıda; evidenced medical purpose in Health | YES | P1 | Claim evidence, moderation | NO |
| COL-C-002 | C — BOUNDARY AMBIGUITY | Ayakkabı | Spor & Outdoor | Running shoe | Sport purpose competes with footwear identity | Batch 02 recommends Shoes | Ayakkabı | YES | P0 | Sports projection and L3 | YES |
| COL-C-003 | C — BOUNDARY AMBIGUITY | Ayakkabı | Spor & Outdoor | Trekking boot | Outdoor context is stronger than ordinary sport use | Future L3 open | Ayakkabı; likely trekking shoe L3 | YES | P1 | Lower-level tree | YES |
| COL-C-004 | C — BOUNDARY AMBIGUITY | Giyim & Moda | Spor & Outdoor | Swimsuit, rash guard | Wearable apparel overlaps water-sport equipment | Primary-function rule proposed | Giyim for swimwear; Sports for safety/equipment | YES | P1 | Product assignment | YES |
| COL-C-005 | C — BOUNDARY AMBIGUITY | Giyim & Moda | Spor & Outdoor | Sports bra | Innerwear form and performance purpose compete | Internal leaf rule open | Giyim; owner selects Innerwear versus Performance leaf rule | YES | P1 | Future L3/L4 | YES |
| COL-C-006 | C — BOUNDARY AMBIGUITY | Çanta & Aksesuar | Anne & Bebek | Diaper bag | Carrying product also performs baby-care organization | Shared BAG-01 open | Standalone in Bags; integrated module in Mother/Baby | YES | P0 | Duplicate prevention | YES |
| COL-C-007 | C — BOUNDARY AMBIGUITY | Çanta & Aksesuar | Müzik & Enstrüman | Guitar case, gig bag | Carry function competes with instrument compatibility | Shared BAG-02 open | Standalone case in Bags | YES | P0 | Compatibility facets | YES |
| COL-C-008 | C — BOUNDARY AMBIGUITY | Çanta & Aksesuar | Spor & Outdoor | Hydration pack, fixed bike bag | Bag form can be an integrated technical system | Shared BAG-03 open | General bag in Bags; integrated system in Sports | YES | P0 | Ingestion rule | YES |
| COL-C-009 | C — BOUNDARY AMBIGUITY | Züccaciye & Mutfak | Beyaz Eşya & Ev Aletleri | Cezve, French press, coffee machine | Brewing intent spans manual and electric products | Manual/electric split proposed | Manual in Kitchen; powered device in Appliances | YES | P0 | L2 and attributes | YES |
| COL-C-010 | C — BOUNDARY AMBIGUITY | Züccaciye & Mutfak | Beyaz Eşya & Ev Aletleri | Blender accessory, manual chopper | Accessory/function and energy source can conflict | Principal-device rule open | Device-specific accessory follows appliance; manual utensil Kitchen | YES | P0 | Compatibility and leaf design | YES |
| COL-C-011 | C — BOUNDARY AMBIGUITY | Ev & Yaşam | Yapı, Hırdavat & Tesisat | Soap holder, faucet, shower head | Same room contains movable and plumbed products | Connection rule proposed | Movable accessory Home; plumbed fixture Hardware | YES | P0 | L3 mapping | YES |
| COL-C-012 | C — BOUNDARY AMBIGUITY | Ev & Yaşam | Çiçek & Bahçe / Hardware | Garden cabinet, shed | Storage product may be movable, garden-specific or fixed | No exact installation threshold | Primary use plus fixed-installation rule | YES | P1 | Service/product boundary | YES |
| COL-C-013 | C — BOUNDARY AMBIGUITY | Çiçek & Bahçe | Yapı, Hırdavat & Tesisat | Drip set, garden hose, building irrigation | Garden purpose and plumbing infrastructure overlap | Plant-primary rule proposed | Garden consumer irrigation in Flowers; building system in Hardware | YES | P0 | Leaf assignment | YES |
| COL-C-014 | C — BOUNDARY AMBIGUITY | Yapı, Hırdavat & Tesisat | Elektronik | Tool battery, charger | Tool ecosystem competes with generic power | Device-platform threshold open | Tool-specific in Hardware; generic power in Electronics | YES | P0 | Compatibility registry | NO |
| COL-C-015 | C — BOUNDARY AMBIGUITY | Yapı, Hırdavat & Tesisat | Elektronik | Solder station, electronic module | Tool and worked-on component share context | Tool/component distinction proposed | Tool/station/consumable Hardware; component Electronics | YES | P1 | Merchant data schema | YES |
| COL-C-016 | C — BOUNDARY AMBIGUITY | Otomotiv & Motosiklet | Elektronik | USB car adapter, hardwired charger | Vehicle use does not always mean vehicle-specific identity | Exact fitment threshold open | Vehicle-only harness in Auto; generic adapter Electronics | YES | P1 | Compatibility and search | NO |
| COL-C-017 | C — BOUNDARY AMBIGUITY | Otomotiv & Motosiklet | Elektronik / Spor & Outdoor | In-dash navigation, portable GPS, hiking GPS | Navigation function spans vehicle and outdoor contexts | No full owner precedence | Fitment/context-specific primary function | YES | P1 | Product profile and discovery | NO |
| COL-C-018 | C — BOUNDARY AMBIGUITY | Oyuncak & Hobi | Elektronik | Programmable toy, electronic kit | Play purpose and real device capability overlap | Capability threshold open | Toys for play product; Electronics for real component/device | YES | P1 | Safety and leaf schema | YES |
| COL-C-019 | C — BOUNDARY AMBIGUITY | Oyuncak & Hobi | Elektronik / Spor & Outdoor | Hobby RC car, competition RC | Hobby/play, real device and competition contexts overlap | No exact competition threshold | Primary capability and use rule | YES | P1 | Future L3 and policy | YES |
| COL-C-020 | C — BOUNDARY AMBIGUITY | Oyuncak & Hobi | Spor & Outdoor | Soft toy ball, regulation football | Similar form but different safety/performance schema | Play-scale rule proposed | Toy object in Toys; regulation equipment in Sports | YES | P1 | Merchant attributes | YES |
| COL-C-021 | C — BOUNDARY AMBIGUITY | Gözlük & Optik | Spor & Outdoor / Hardware | Prescription sports glasses, safety goggles | Vision correction and protection may coexist | Primary-function/evidence rule open | Prescription/custom Optics; certified sport/OHS owner otherwise | YES | P0 | Eligibility and dual metadata | NO |
| COL-C-022 | C — BOUNDARY AMBIGUITY | Saat & Takı | Elektronik / Çanta & Aksesuar | Smartwatch strap, decorative smart-chain | Device-specific accessory and jewelry form compete | Exact hybrid threshold open | Device functionality/compatibility first; passive jewelry to Saat & Takı | YES | P1 | Compatibility registry | NO |
| COL-D-001 | D — FACET-AS-CATEGORY | Giyim & Moda | Cross-domain discovery | Tesettür/modest | Style/coverage cuts across clothing forms | Batch 01 recommends facet/collection | Keep L2 list; use controlled facet/collection | YES | P0 | Prevent duplicate clothing leaves | YES |
| COL-D-002 | D — FACET-AS-CATEGORY | Müzik & Enstrüman | Internal structural families | Geleneksel Türk Müziği | Cultural/merchandising grouping overlaps instrument form | Separate L2 and exact registry are open | Owner chooses structural leaf or controlled exact registry | YES | P0 | L2 count and analytics | YES |
| COL-D-003 | D — FACET-AS-CATEGORY | Oyuncak & Hobi | Anne & Bebek | Bebek & Okul Öncesi | Age is usually facet but may carry safety schema | Proposed exception open | Keep only if owner accepts schema-bearing age exception | YES | P0 | L2 count, age policy | YES |
| COL-D-004 | D — FACET-AS-CATEGORY | Hediyelik & Parti | All L1s | “Gift” purpose | Any ordinary product can be a gift | Proposals reject duplication | Underlying product owner; only intrinsic keepsake may use gift L2 | YES | P1 | Global no-duplication rule | YES |
| COL-D-005 | D — FACET-AS-CATEGORY | Hediyelik & Parti | Giyim / Kitchen / Watches | Personalized mug, shirt, jewelry | Personalization is a capability, not product identity | Global rule proposed | Underlying product owner; personalization facet/capability | YES | P1 | Search, merchant capability | YES |
| COL-D-006 | D — FACET-AS-CATEGORY | Kitap | Discovery facets | Genre/subject | A book can have multiple genres | Proposal uses one shelf plus multi-value facets | Preserve one primary shelf; genres remain facets | YES | P2 | Analytics and filters | YES |
| COL-E-001 | E — SERVICE LEAKAGE | Gıda & İçecek | Merchant/Service scope | Restaurant meal, made-to-order food | Prepared product wording can imply service/order flow | Batch 01 excludes restaurant service | Packaged retail product only; service excluded | YES | P1 | Product/merchant separation | YES |
| COL-E-002 | E — SERVICE LEAKAGE | Ev & Yaşam | Hardware / Merchant services | Custom fixed cabinetry | Physical cabinet and design/install project are bundled | Product/service threshold open | Standalone SKU Home; custom project/service excluded | YES | P1 | Listing contract | YES |
| COL-E-003 | E — SERVICE LEAKAGE | Beyaz Eşya & Ev Aletleri | Merchant services | Installation, repair, maintenance | Appliance sale can bundle labor | Batch 02 excludes service nodes | Appliance product only; service capability separate | YES | P1 | Merchant capability and pricing | YES |
| COL-E-004 | E — SERVICE LEAKAGE | Hediyelik & Parti | Merchant services | Printing/engraving/personalization labor | Personalized physical item and labor can be conflated | Service excluded in proposals | Underlying physical product plus separate capability | YES | P1 | Offer model and search | YES |
| COL-E-005 | E — SERVICE LEAKAGE | Çiçek & Bahçe | Merchant services | Arrangement, landscaping, subscription, delivery-only | Physical bouquet can be confused with ongoing service | Batch 03 keeps physical arrangement only | Physical principal product in Flowers; service excluded | YES | P1 | Subscription/delivery scope | YES |
| COL-F-001 | F — POLICY OWNERSHIP ISSUE | Gıda & İçecek | Platform policy | Alcohol | Beverage category can imply permission to sell | Batch 01 recommends V1 exclusion | EXCLUDED pending explicit age/legal product decision | YES | P0 | Listing eligibility, age gate | NO |
| COL-F-002 | F — POLICY OWNERSHIP ISSUE | Anne & Bebek | Gıda / Health | Infant formula | Taxonomy owner and regulated launch status differ | Both batches leave decision open | Anne/Baby taxonomy only with legal/product gate | YES | P0 | Seller evidence, claims | NO |
| COL-F-003 | F — POLICY OWNERSHIP ISSUE | Sağlık & Medikal | Gıda / Cosmetics | Supplements and vitamins | Current Health L2 has no safe home for them | Separate scope required | Fail closed; do not force into existing nodes | YES | P0 | L2 scope, policy | NO |
| COL-F-004 | F — POLICY OWNERSHIP ISSUE | Kozmetik & Kişisel Bakım | Health / Home | Antiseptic, biosidal, medicated goods | Marketing form can hide regulated intended use | Open legal threshold | LEGAL_REVIEW_REQUIRED before taxonomy/listing | YES | P0 | Moderation and evidence | NO |
| COL-F-005 | F — POLICY OWNERSHIP ISSUE | Ayakkabı / Hardware | Health | PPE footwear and medical orthosis | Similar footwear form carries distinct certification/claims | Open evidence threshold | Owner plus exact certification/medical gate | YES | P0 | Eligibility and recall | NO |
| COL-F-006 | F — POLICY OWNERSHIP ISSUE | Yapı, Hırdavat & Tesisat | Home Appliances | Installer-only HVAC/gas | Category can expose high-risk installation systems | Batch 01 flags legal review | Fail closed unless retail SKU and lawful consumer scope verified | YES | P0 | Merchant authorization | NO |
| COL-F-007 | F — POLICY OWNERSHIP ISSUE | Otomotiv & Motosiklet | Electronics / Hardware | Battery, oil, fluid, aerosol, extinguisher | Real products have hazardous handling differences | Batch 03 requires matrix | LEGAL_REVIEW_REQUIRED by exact SKU | YES | P0 | Transport, waste, storage | NO |
| COL-F-008 | F — POLICY OWNERSHIP ISSUE | Oyuncak & Hobi / Spor & Outdoor | Platform policy | Airsoft, paintball, hunting, projectile goods | Toy/sport labels do not remove weapon-like risk | Fail-closed/exclusion proposed | Exact legal allowlist; firearms/ammunition/explosives excluded | YES | P2 | Age/legal policy | NO |
| COL-F-009 | F — POLICY OWNERSHIP ISSUE | Evcil Hayvan Ürünleri | Health | Veterinary medicine and pet supplements | Pet-store context can imply consumer eligibility | Batch 03 excludes ordinary assignment | Excluded/regulated veterinary channel pending legal scope | YES | P2 | Merchant and product authorization | NO |
| COL-F-010 | F — POLICY OWNERSHIP ISSUE | Gözlük & Optik | Health | Prescription optics/contact lens | Physical product family and legal eligibility differ | Fail-closed proposal | Optics taxonomy with legal/merchant/product gate | YES | P2 | Sensitive measurements, claims | NO |
| COL-F-011 | F — POLICY OWNERSHIP ISSUE | Sağlık & Medikal | Platform policy | Medical devices, professional-only goods | L2 approval can be mistaken for market access | Domain-wide fail-closed posture proposed | Exact risk/registration/seller matrix; high-risk excluded unless allowed | YES | P2 | Recall, traceability, moderation | NO |
| COL-F-012 | F — POLICY OWNERSHIP ISSUE | Çiçek & Bahçe / Hediyelik & Parti | Platform policy | Pesticides, fireworks, pressurized gas | Familiar retail context hides hazardous restrictions | Proposals recommend exclusion/fail closed | Pesticides/pyrotechnics excluded; other goods legal matrix | YES | P2 | Hazardous-goods controls | NO |
| COL-G-001 | G — FUTURE L3/L4 DEPENDENCY | Gıda & İçecek | Internal L2s | Canned ready meal | Packaging method and meal intent can both classify it | Two L2s retained | Primary intent rule between Konserve and Hazır & Pratik | YES | P1 | L3/leaf assignment | YES |
| COL-G-002 | G — FUTURE L3/L4 DEPENDENCY | Giyim & Moda | Internal L2s | Ferace/abaya | Product name does not always reveal dress versus outer layer | Batch 01 leaves leaf rule open | Physical form decides Elbise versus Dış Giyim; term is synonym/facet | YES | P1 | Search and leaf rule | YES |
| COL-G-003 | G — FUTURE L3/L4 DEPENDENCY | Ayakkabı | Anne & Bebek | Child/baby shoes | Age is both a proposed L2 and normal facet | Schema-bearing exception needs owner confirmation | Keep proposed L2 if owner accepts distinct sizing/safety schema | YES | P1 | Age attributes | YES |
| COL-G-004 | G — FUTURE L3/L4 DEPENDENCY | Müzik & Enstrüman | Computer / Electronics | MIDI keyboard/controller | Form and control function differ | Future leaf threshold open | Standalone performance instrument versus control surface rule | YES | P1 | Compatibility, L3 | YES |
| COL-G-005 | G — FUTURE L3/L4 DEPENDENCY | Oyuncak & Hobi | Internal L2s | Play figure versus collectible figure | Same form serves play or collection intent | Intent/schema rule open | Deterministic play versus collectibility fields | YES | P1 | L3/condition schema | YES |
| COL-G-006 | G — FUTURE L3/L4 DEPENDENCY | Kitap | Kırtasiye / Toys | Coloring/activity book | Bound published content can resemble activity kit | Primary-product rule open | Book if principal product is published content | YES | P1 | Leaf and bundle rule | YES |
| COL-G-007 | G — FUTURE L3/L4 DEPENDENCY | Kırtasiye & Ofis | Oyuncak & Hobi | Paint set, complete craft kit | Supplies and guided kit share components | Principal-activity rule open | Supplies Stationery; complete guided play/hobby kit Toys | YES | P1 | Kit attributes | YES |
| COL-G-008 | G — FUTURE L3/L4 DEPENDENCY | Kırtasiye & Ofis | Kitap | Notebook versus workbook | Blank substrate and published exercises look similar | Content threshold open | Blank writing Stationery; published instructional content Book | YES | P1 | ISBN/content metadata | YES |
| COL-G-009 | G — FUTURE L3/L4 DEPENDENCY | Saat & Takı | Elektronik | Watch battery versus generic button cell | Device compatibility may be primary or incidental | Accessory threshold open | Watch-specific accessory in Watches; generic battery Electronics | YES | P1 | Compatibility registry | YES |

## Registry metrics

| Metric | Count |
|---|---:|
| A — Exact duplicate | 0 |
| B — Semantic overlap | 12 |
| C — Boundary ambiguity | 22 |
| D — Facet-as-category | 6 |
| E — Service leakage | 5 |
| F — Policy ownership issue | 12 |
| G — Future L3/L4 dependency | 9 |
| **Total registered collisions** | **66** |
| P0 | 32 |
| P1 | 28 |
| P2 | 6 |
| Owner decision required | 66 |
| Auto-resolvable after a controlling owner/root decision | 48 |
| Requires additional direct policy/legal or product-specific follow-up | 18 |

## Highest-impact collision groups

1. Infant/baby nutrition and medical/supplement ownership (`COL-B-001`, `COL-B-002`, `COL-F-002`, `COL-F-003`).
2. Medical intended use across Cosmetics, Optics, Pet and Health (`COL-B-003`, `COL-F-004`, `COL-F-009`, `COL-F-010`, `COL-F-011`).
3. Fixed installation and hazardous household/building products (`COL-C-011`, `COL-C-013`, `COL-F-006`).
4. Technical sport/apparel/footwear/PPE boundaries (`COL-B-004`, `COL-B-005`, `COL-C-002`–`COL-C-005`, `COL-C-021`).
5. Generic versus domain-specific electronics/accessories (`COL-B-010`, `COL-C-014`–`COL-C-017`, `COL-C-022`).
6. Gift/personalization duplication and service leakage (`COL-D-004`, `COL-D-005`, `COL-E-004`).

No registry recommendation changes a proposal node. The owner decision and policy follow-up fields are gates for a later controlled finalization task.
