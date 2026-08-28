# EsnaftaVar Global Taxonomy Policy Boundary Audit

**Wave:** 15 / Global L2 Cross-Batch Audit

**State:** Policy decision preparation; not legal advice, owner approval, or listing authorization.

## Classification method

Each row has exactly one `PRIMARY CLASS` so totals reconcile. `ADDITIONAL GATE` records stricter evidence, age, legal or operational requirements without double-counting the row. Classification precedence for this audit is:

1. `EXCLUDED` when the proposals explicitly keep the family outside V1/ordinary consumer taxonomy.
2. `LEGAL_REVIEW_REQUIRED` when authoritative product/seller/market-access status cannot be safely inferred.
3. `AGE_RESTRICTED` when age gating is the primary unresolved control.
4. `REGULATED` when the family is potentially in scope but requires defined safety/compliance evidence.
5. `NORMAL` when the proposal evidence identifies no special taxonomy-policy gate beyond ordinary product safety and content rules.

Taxonomy placement never grants permission to list, advertise or sell a product. If source evidence is incomplete, this audit fails closed.

## Cross-domain policy groups

| POLICY ID | PRODUCT / RISK FAMILY | SOURCE EVIDENCE IN PROPOSALS | TAXONOMY OWNER / SCOPE | PRIMARY CLASS | ADDITIONAL GATE | AUDIT POSTURE | OWNER / POLICY ACTION REQUIRED | CROSS-DOMAIN EFFECT |
|---|---|---|---|---|---|---|---|---|
| POL-001 | Ordinary packaged food without restricted claim | Gıda proposal ordinary retail inclusions | Gıda & İçecek | NORMAL | Standard food labeling/safety | In scope as ordinary food | No special taxonomy decision | Pet, baby and medical-intended products remain separate. |
| POL-002 | Ordinary apparel without protective/medical claim | Giyim proposal | Giyim & Moda | NORMAL | General product safety | In scope | No special taxonomy decision | PPE and orthosis use separate rules. |
| POL-003 | Lawful physical books and ordinary stationery | Book and Stationery proposals | Kitap or Kırtasiye by content/function | NORMAL | Copyright/content moderation | In scope | Preserve physical-product and legal-copy rules | Illegal copies and restricted content are not covered by NORMAL. |
| POL-004 | Passive home/kitchen goods without chemical/electrical hazard | Home and Kitchen proposals | Ev & Yaşam or Züccaciye & Mutfak | NORMAL | General product safety/food-contact rule if applicable | In scope | Apply ownership boundary only | Powered, plumbed and hazardous products use other rows. |
| POL-005 | Classic low-value watch and ordinary fashion jewelry | Watches proposal | Saat & Takı | NORMAL | Authentic description | In scope | Preserve smart-wearable boundary | Precious/high-value and body-jewelry risks use stricter rows. |
| POL-006 | Alcohol | Food proposal explicitly omits Alcohol from current L2 and recommends V1 exclusion | No active proposed L2 | AGE_RESTRICTED | LEGAL_REVIEW_REQUIRED; current recommendation is V1 exclusion | Do not launch through Alkolsüz İçecekler or another food node | Owner plus authoritative legal/product decision before any scope change | Auth age gate, merchant eligibility, discovery and moderation. |
| POL-007 | Adult-only/restricted physical publication or collectible content | Books/Toys reviews keep content policy orthogonal to category | Underlying Book/Toy family if lawful | AGE_RESTRICTED | Content-policy and legal review by exact item | Fail closed until allowed-content and age-gate rule exists | Owner/content-policy matrix | Books, collectibles and party goods must use one common policy. |
| POL-008 | Infant formula and regulated baby feeding products | Food and Mother/Baby proposals both expose the boundary | Anne & Bebek taxonomy candidate | REGULATED | LEGAL_REVIEW_REQUIRED, seller/product/claim evidence | Taxonomy recommendation does not authorize launch | Resolve owner and exact legal eligibility | Food, Health and Mother/Baby. |
| POL-009 | Child restraint, sleep-safety and used baby safety goods | Mother/Baby proposal | Anne & Bebek | REGULATED | Standards, recall/history, condition and seller evidence | New compliant product only after matrix; used critical items fail closed | Owner defines used/new allowlist and evidence | Automotive child seats, Home sleep products and platform condition policy. |
| POL-010 | Certified PPE and protective footwear/clothing/eyewear | Shoes, Clothing, Hardware, Sports, Optics and Health proposals | Primary OHS/Sport/Health owner by intended use | REGULATED | Certification, claim and traceability | No ordinary-apparel shortcut | Owner approves precedence; policy owner defines evidence | Six L1s share the same certification vocabulary. |
| POL-011 | Contact-lens care products and ready optical products | Optics proposal | Gözlük & Optik | REGULATED | Exact product/merchant eligibility; lens itself uses stricter row | Fail closed where status is uncertain | Optics policy matrix | Cosmetics/fashion intent cannot bypass optical controls. |
| POL-012 | Mains-powered appliances and ordinary electrical products | Appliances, Hardware and Electronics proposals | Primary function owner | REGULATED | Electrical conformity, voltage, installation and recall data | In scope only with required evidence | Define shared electrical evidence profile | Appliances, Hardware, Electronics and Automotive. |
| POL-013 | Vehicle battery, fluid, aerosol and extinguisher products | Automotive proposal | Otomotiv & Motosiklet | REGULATED | Hazardous handling, labeling, storage, transport and waste review | Product family may remain; SKU eligibility is fail closed | Exact matrix per family | Electronics batteries and Hardware chemicals need shared controls. |
| POL-014 | Food-contact storage, cookware and serving products | Kitchen proposal | Züccaciye & Mutfak | REGULATED | Material/food-contact evidence | In scope after ordinary conformity checks | Define attribute/evidence profile later | Separates kitchen storage from general home organization. |
| POL-015 | Live plants, seeds, fertilizer and plant nutrients | Flowers/Garden proposal | Çiçek & Bahçe | REGULATED | Registration, traceability, species, labeling and fulfilment | Fail closed until product-class matrix exists | Owner/policy approval per family | Food plants, pet aquatics and logistics. |
| POL-016 | Claim-sensitive sunscreen, baby cosmetic and ordinary cosmetic-risk families | Cosmetics and Mother/Baby proposals | Cosmetics or Mother/Baby by intended user | REGULATED | Ingredient, claim, age-stage and product-status evidence | Keep category separate from claim permission | Shared cosmetics/baby policy | Health boundary remains fail closed. |
| POL-017 | Supplement, vitamin and medical-nutrition scope | Food and Health proposals; current Health L2 deliberately omits supplements | No approved current L2; likely controlled Health scope | LEGAL_REVIEW_REQUIRED | Product classification, claim, seller and advertisement rules | Do not force into Gıda or current Health L2 | Dedicated owner/legal scope decision | Food, Health, Mother/Baby, Pet and Cosmetics. |
| POL-018 | Prescription/custom optical product and contact lens | Optics proposal | Gözlük & Optik taxonomy candidate | LEGAL_REVIEW_REQUIRED | Merchant authorization, product status, prescription/custom data and advertising | Fail closed | Owner plus authoritative optics/legal matrix | Health and sensitive-measurement handling. |
| POL-019 | Medical devices, professional-only, invasive, sterile or diagnostic goods | Health proposal | Sağlık & Medikal if consumer-eligible | LEGAL_REVIEW_REQUIRED | Risk class, registration, seller, intended use, traceability, recall | Professional/high-risk goods remain excluded unless an exact allow rule exists | Domain launch decision and eligibility matrix | Optics, PPE, connected health and B2B scope. |
| POL-020 | Dermocosmetic, medicated cosmetic, antiseptic and biosidal intended use | Cosmetics proposal | Health/controlled policy scope if not ordinary cosmetic | LEGAL_REVIEW_REQUIRED | Authoritative product classification and claims | Fail closed; marketing label cannot decide | Owner/legal intended-use rule | Cosmetics, Health, Home cleaning and Pet hygiene. |
| POL-021 | Installer-only HVAC, gas and high-risk hot-water systems | Hardware and Appliances proposals | Hardware or Appliances by product function | LEGAL_REVIEW_REQUIRED | Retail eligibility, licensed installation, warnings and merchant qualification | Do not expose project/installer-only systems as ordinary products | Exact retail allowlist | Home, Appliances, Hardware and Merchant Services. |
| POL-022 | Precious/high-value jewelry, investment gold and loose stones | Watches/Jewelry proposal | Saat & Takı only for consumer-eligible finished product | LEGAL_REVIEW_REQUIRED | Seller authorization, authenticity, assay/provenance, fraud and secure fulfilment | Finished jewelry stays fail closed until controls exist; investment/loose scope open | Owner/legal/commercial scope decision | Gift, payment/fraud and fulfilment policy. |
| POL-023 | Protected animal/plant material in instruments, jewelry or accessories | Music proposal and cross-domain material risk | Underlying product L1 | LEGAL_REVIEW_REQUIRED | Provenance/species/material legality | Do not rely on material facet alone | Global provenance rule | Music, Jewelry, Bags and collectible goods. |
| POL-024 | EV wallbox, vehicle charging infrastructure and hybrid electrical systems | Automotive/Hardware/Electronics boundaries | Automotive for vehicle-specific device; Hardware for fixed building infrastructure | LEGAL_REVIEW_REQUIRED | Installation, mains, interoperability and product status | Fail closed at boundary until exact rule/evidence exists | Cross-domain owner/legal decision | Automotive, Hardware and Electronics. |
| POL-025 | Airsoft, paintball, archery, hunting knives and weapon-like goods | Toys and Sports proposals | Potential Toys/Sports owner only if explicitly allowed | LEGAL_REVIEW_REQUIRED | Exact legal allowlist, age, transport and merchant controls | Fail closed; no normal toy/sport inference | Owner/legal matrix | Bags, Hardware and content moderation. |
| POL-026 | Pet supplements and non-medicine veterinary health products | Pet and Health proposals | Controlled Pet/Health scope | LEGAL_REVIEW_REQUIRED | Veterinary product status, seller and claims | Fail closed | Dedicated veterinary policy decision | Pet food/hygiene and human Health separation. |
| POL-027 | Prescription/restricted human medicine | Health proposal explicitly excludes ordinary consumer assignment | Outside current Product Taxonomy/ordinary channel | EXCLUDED | Any future change requires separate legal/product authorization | Excluded | No launch under current proposal | Food/supplement/cosmetic claims must not provide a bypass. |
| POL-028 | Veterinary medicine and live animals | Pet proposal/review | Outside ordinary Pet Product L2s | EXCLUDED | Separate regulated/live-commerce decision | Excluded in V1 proposal | No ordinary listing | Pet supplies and veterinary services remain distinct. |
| POL-029 | Pesticides and regulated plant-protection products | Flowers/Garden review records fail-closed online exclusion | Outside ordinary Garden L2 eligibility | EXCLUDED | Any exception requires authoritative re-verification | Excluded | Preserve exclusion | Hardware/Home chemical ingestion cannot bypass it. |
| POL-030 | Firearms, ammunition and explosives | Sports/Toys review | Outside current consumer Product Taxonomy | EXCLUDED | Separate owner/legal decision would be required to revisit | Excluded | Preserve exclusion | Weapon-like non-firearm products remain POL-025. |
| POL-031 | Fireworks, sparklers, pyrotechnics and ordinary party-gas listing | Gifts/Party proposal | Outside normal party assortment | EXCLUDED | Hazardous-goods/legal review for any future exception | Excluded in V1 recommendation | Owner confirms blanket posture | Hardware/industrial gas scope remains separate. |
| POL-032 | Tobacco and nicotine products | Food scope excludes tobacco/nicotine from ordinary grocery taxonomy | No proposed L2 | EXCLUDED | AGE_RESTRICTED and LEGAL_REVIEW_REQUIRED for any future reconsideration | Excluded | No current taxonomy expansion | Prevents leakage through food, personal-care or gift nodes. |

## Count reconciliation

| Primary class | Count |
|---|---:|
| NORMAL | 5 |
| AGE_RESTRICTED | 2 |
| REGULATED | 9 |
| LEGAL_REVIEW_REQUIRED | 10 |
| EXCLUDED | 6 |
| **Total policy groups** | **32** |

## Unresolved policy groups

The following root areas require Product Owner direction and, where indicated, authoritative legal/policy verification before a later taxonomy finalization or launch:

1. Alcohol and adult-only content age posture.
2. Infant formula and baby-safety/used-product controls.
3. Supplements, vitamins and medical nutrition.
4. Medical intended use across Health, Cosmetics, Pet and Optics.
5. PPE and protective product evidence across Apparel, Shoes, Hardware, Sports, Optics and Health.
6. Installer-only gas/HVAC and fixed electrical/EV charging infrastructure.
7. Vehicle hazardous products and platform-wide hazardous-goods handling.
8. Weapon-like goods, hunting/airsoft/paintball and excluded firearm/explosive scope.
9. Precious/high-value goods and protected-material provenance.
10. Live plants/seeds/fertilizers, pesticides and live-animal/veterinary scope.

## Fail-closed conclusions

- Missing evidence never implies `NORMAL`.
- An approved category never implies an approved seller, claim, fulfilment method or product.
- A future policy relaxation must be explicit; it cannot be inferred from an L2 owner decision.
- The audit does not modify Auth, merchant eligibility, moderation, DB, migration, runtime or remote state.
