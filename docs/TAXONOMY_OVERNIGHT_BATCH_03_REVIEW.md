# EsnaftaVar — Overnight Taxonomy Batch 03 Review

**Wave:** 15 / Overnight Taxonomy Batch 03

**Audit tarihi:** 28 Ağustos 2026

**Audit durumu:** **COMPLETE — ALL PROPOSALS REMAIN PROPOSED FOR OWNER REVIEW**

## 1. Scope

Bu belge, aşağıdaki sekiz owner-final L1 için hazırlanan L2 proposal'larını birlikte
denetler:

1. Otomotiv & Motosiklet
2. Kitap
3. Kırtasiye & Ofis
4. Evcil Hayvan Ürünleri
5. Gözlük & Optik
6. Saat & Takı
7. Sağlık & Medikal
8. Çiçek & Bahçe

Audit; duplicate product family, contradiction, category/facet error, service
leakage, policy risk, L1 overlap, naming consistency, source integrity ve max-depth
uyumunu kapsar. Owner finalization, runtime taxonomy, DB, migration, Flutter/Figma
ve remote environment değişikliği yapmaz.

## 2. Proposal inventory

| L1 | Proposal | L2 count | Checkpoint commit | State |
|---|---|---:|---|---|
| Otomotiv & Motosiklet | [TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md](TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md) | 11 | `f0ea472` | PROPOSED FOR OWNER REVIEW |
| Kitap | [TAXONOMY_BOOKS_L2_PROPOSAL.md](TAXONOMY_BOOKS_L2_PROPOSAL.md) | 10 | `778f7f6` | PROPOSED FOR OWNER REVIEW |
| Kırtasiye & Ofis | [TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md](TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md) | 11 | `ef1b503` | PROPOSED FOR OWNER REVIEW |
| Evcil Hayvan Ürünleri | [TAXONOMY_PET_PRODUCTS_L2_PROPOSAL.md](TAXONOMY_PET_PRODUCTS_L2_PROPOSAL.md) | 7 | `c36936b` | PROPOSED FOR OWNER REVIEW |
| Gözlük & Optik | [TAXONOMY_OPTICS_L2_PROPOSAL.md](TAXONOMY_OPTICS_L2_PROPOSAL.md) | 7 | `28469f9` | PROPOSED FOR OWNER REVIEW |
| Saat & Takı | [TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md](TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md) | 11 | `2726f6f` | PROPOSED FOR OWNER REVIEW |
| Sağlık & Medikal | [TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md](TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md) | 9 | `f047f60` | PROPOSED FOR OWNER REVIEW |
| Çiçek & Bahçe | [TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md](TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md) | 11 | `2f364ed` | PROPOSED FOR OWNER REVIEW |

Toplam proposed L2: **77**. Owner-final L2: **0**.

Her proposal zorunlu 16 bölümün tamamını içerir. Her birinde Status, Sources,
exact list, inclusions/exclusions, cross-domain boundaries, facet rules, policy,
ambiguities, future L3/L4 examples, owner decisions ve validation bulunur.

## 3. Duplicate product-family audit

Sekiz `Exact L2 list` bölümü otomatik çıkarıldı ve küçük/büyük harf, Türkçe
diacritic ve noktalama normalize edilerek karşılaştırıldı.

- Exact/normalized duplicate L2 adı: **0**
- Aynı physical product family'nin iki L1'de primary ownership'i: **0 unresolved**
- Brand/model/material/color/size-as-category: **0**
- Bundle/kit-as-category: **0**
- Max-depth ihlali: **0**

Benzer kelime kullanımı (`bakım`, `aksesuar`, `ürünleri`) duplicate sayılmaz;
proposal'lardaki inclusion/exclusion ve ana-fonksiyon kuralıyla domain context'i
tanımlıdır.

## 4. Cross-domain boundary audit

| Potansiyel çakışma | Canonical precedence | Audit sonucu |
|---|---|---|
| Vehicle-fitment electronics vs generic Electronics | Vehicle electrical system/fitment primary ise Otomotiv; generic consumer device Elektronik. Starting/power distribution `Akü & Araç Elektriği`, information/recording/control device `Araç Elektroniği`. | PASS |
| Vehicle first-aid kit vs generic first aid | Araç mevzuatı/taşıma amacıyla paketlenmiş kit Otomotiv; generic home/medical kit Sağlık & Medikal. | PASS |
| Printer/toner vs paper/office supply | Yazıcı/scanner/toner/kartuş/device-specific print sarfı Bilgisayar & Tablet; paper/label/thermal roll Kırtasiye & Ofis. | PASS — owner-final rule preserved |
| Physical book vs stationery | Okunmak için yayımlanmış içerik Kitap; boş yazım/planlama/dosyalama ürünü Kırtasiye & Ofis. | PASS |
| Pet care vs veterinary medicine/human health | Pet physical supply Evcil Hayvan; veterinary medicine normal consumer taxonomy'de excluded/regulated channel; human device Sağlık & Medikal. | PASS |
| Optics vs general medical | Eyewear/contact-lens product family Gözlük & Optik; medical/prescription status policy gate. Other medical device Sağlık & Medikal. | PASS |
| Classic watch/jewelry vs smart wearable | Classic timepiece Saat & Takı; smartwatch/smart ring Elektronik → Giyilebilir Teknoloji. | PASS |
| Jewelry vs fashion accessory | Jewelry form primary ise Saat & Takı; textile/hair/general clothing accessory Giyim & Aksesuar. | PASS |
| Medical vs cosmetics/wellness/sport | Registered medical intended use/support primary ise Sağlık & Medikal; beauty/grooming, consumer wellness wearable veya sport performance kendi L1'inde. | PASS — legal thresholds open |
| Garden hand tool vs power tool | Main-use manual garden hand tool Çiçek & Bahçe; powered/industrial tool Yapı Market. | PASS |
| Garden decor vs furniture | Plant-growing/garden-specific ornament/edging/trellis Çiçek & Bahçe; seating/table/general decor Ev & Yaşam. | PASS |
| Live edible plant vs grocery | Growing/live-plant intent Çiçek & Bahçe; immediate food consumption Gıda & Market. | PASS — owner precedence open |
| Aquarium plant/product | Aquarium hardware/pet ecosystem Evcil Hayvan; general live garden plant Çiçek & Bahçe. Live aquatic plant remains explicit owner/policy decision. | PASS — intentionally unresolved product class documented |
| Generic bag/box vs domain accessory | Primary carried/stored object and dedicated fit determine ownership; general carry bag Çanta & Aksesuar, general decor/storage Ev & Yaşam. | PASS — owner thresholds open |

Unresolved hybrid products are not silently assigned. Each is listed in the relevant
proposal's `Ambiguous products` and `Owner decisions` sections.

## 5. Category vs facet audit

| Domain | Category architecture | Facets kept out of depth | Result |
|---|---|---|---|
| Otomotiv | Product function + vehicle system | Make/model/year/engine/OEM/fitment, tire size, oil spec | PASS |
| Kitap | Single primary shelf | Multi-value genre/subject, language, author, publisher, ISBN, class/exam | PASS |
| Kırtasiye | Physical office/stationery function | Paper size/weight, ink, color, school level, character/license | PASS |
| Evcil Hayvan | Species-first L2 + function-first future L3 | Required species, breed, life stage, size, flavor, compatibility | PASS |
| Gözlük & Optik | Physical optical product form | Brand, gender, shape, material, prescription measurements, lens attributes | PASS |
| Saat & Takı | Watch/jewelry product form | Material, precious/fashion class, gender, stone, karat, value | PASS |
| Sağlık & Medikal | Medical-support function | Risk/classification, intended use, body area, size, measurement, registration | PASS |
| Çiçek & Bahçe | Live/cut/artificial + growing function | Species/cultivar, size, season, color, climate, composition | PASS |

Special findings:

- `genre` is multi-value discovery metadata; a book still receives one primary
  shelf.
- Pet `species` can be both navigation axis and required facet without creating two
  canonical leaves. Truly multi-species products use the strict common-accessory
  rule; it is not a catch-all.
- Compatibility states remain `compatible / incompatible / conditional / unknown`;
  they never add taxonomy depth.
- Health risk class, optical prescription and jewelry material/value are policy or
  typed attributes, not category branches.

## 6. Service, digital and non-product leakage audit

No service is proposed as L2.

- Automotive repair/labor, rental, insurance, inspection and vehicle sale: excluded.
- E-book, audiobook, online course and subscription: physical V1 boundary outside.
- Printing/binding/shipping service: excluded; physical supplies remain classified.
- Veterinary visit, grooming, training, walking and pet hotel: excluded.
- Eye exam, refraction, custom fitting labor and optical repair: excluded.
- Watch/jewelry repair, valuation, engraving, insurance and rental: excluded.
- Medical consultation, lab service, therapy session, rental and care service:
  excluded.
- Floristry/landscape/gardening/installation/subscription/delivery-only service:
  excluded; delivered physical flower arrangement remains a product.

`SERVICE_LEAKAGE: 0`

## 7. Policy/compliance audit

| Risk family | Proposed posture | Audit result |
|---|---|---|
| Vehicle batteries, oils, fluids, aerosols and fire extinguishers | LEGAL_REVIEW_REQUIRED; hazardous fulfilment/label/waste review | PASS — not auto-eligible |
| Book copyright/illegal copies/adult or prohibited content | Normal books may be NORMAL; illegal copies EXCLUDED; content policy separate | PASS |
| Cutters, solvents, adhesives and art chemicals | AGE_RESTRICTED/REGULATED/LEGAL_REVIEW_REQUIRED by exact SKU | PASS |
| Live animals and veterinary medicines | Live animals EXCLUDED in V1; veterinary medicines excluded/regulated channel | PASS |
| Prescription optics/contact lens/lens care | LEGAL_REVIEW_REQUIRED; optician/product eligibility separate | PASS |
| Precious/high-value jewelry and body jewelry | LEGAL_REVIEW_REQUIRED; authorization, disclosure, authenticity and secure fulfilment | PASS |
| Human medicines and supplements | Medicines EXCLUDED/regulated pharmacy channel; supplements have no L2 and require owner/legal decision | PASS |
| Medical devices/supplies/PPE | Fail-closed LEGAL_REVIEW_REQUIRED; registration, seller, claim and traceability verification | PASS |
| Live plants/seeds/fertilizers | LEGAL_REVIEW_REQUIRED; registration/passport/traceability/fulfilment | PASS |
| Plant-protection/pesticide products | EXCLUDED ONLINE under cited current rule | PASS |

Taxonomy does not replace legal advice or grant listing eligibility. Policy classes
remain orthogonal to category depth.

## 8. Naming consistency audit

Applied conventions:

- Exact owner-final L1 names are unchanged.
- L2 names are customer-facing Turkish noun/product-family phrases.
- `&` is used for tightly related co-browse families; commas enumerate parallel
  product forms.
- Brands, genders, materials, seasons and technical values are absent from L2 names.
- Singular/plural use follows the displayed family name rather than mechanical
  suffix replacement.

Batch-audit corrections applied before final checkpoint:

1. `Araç İçi Aksesuarlar` → `Araç İçi Aksesuarları` for parallel family naming.
2. Vehicle security L2 now owns mechanical locks/emergency equipment; electronic
   alarm/immobilizer remains `Araç Elektroniği` by primary function.
3. `Paketleme, Postalama & Organizasyon` → `Paketleme & Postalama Ürünleri` to
   remove overlap with `Masaüstü Ofis Gereçleri` and `Dosyalama & Arşivleme`.
4. `Solunum & Evde Bakım Cihazları` explicitly excludes general measurement,
   mobility and disposable patient-care products.
5. `Bitki Bakım & Yetiştirme` is plant/pot-level support; `Sera & Yetiştirme` is
   multi-plant enclosure/system infrastructure.

After correction, normalized duplicate L2 remains **0**.

## 9. Source integrity audit

- All 8 proposals include Google Product Taxonomy/Merchant Center comparison and
  explicitly record that the currently served public taxonomy file carries the
  `2021-09-21` header.
- All 8 use Türkiye-facing marketplace language where accessible; platform trees
  are not copied.
- Domain-specific authoritative sources are used for vehicle environmental risks,
  veterinary products/live animals, optician/medical devices, jewelry trade,
  medical-device sales and plant/passport/pesticide/fertilizer controls.
- Unavailable 2026 full public marketplace trees are marked `Source limitation`;
  missing structure is not invented.
- Source URLs, titles and observed claims were reviewed; legal sources are used to
  justify fail-closed review, not to issue a legal-compliance conclusion.

`SOURCE_INTEGRITY: PASS`

## 10. Owner review priorities

Cross-batch decisions with highest downstream impact:

1. Exact L2 names/order/count for all eight proposals.
2. Vehicle EV-charging and hybrid electronic precedence.
3. Book magazine/periodical scope, comics primary shelf and education-vs-exam rule.
4. School-specific stationery eligibility, label-printer ownership and bag boundary.
5. Pet species-first/common-accessory rule; live product and veterinary-health matrix.
6. Prescription optics merchant/product eligibility and sport/safety eyewear boundary.
7. High-value jewelry authorization/secure fulfilment; investment gold/loose stone
   scope; hybrid smartwatch rule.
8. Medical-device/supply eligibility matrix; supplement scope; professional-device
   threshold and health-data follow-up.
9. Live plant/seed/fertilizer eligibility and fulfilment; edible/aquatic plant
   precedence; plant-first electronics boundary.
10. Runtime reconciliation and stable IDs only after owner-final L2 decisions.

No item above was silently finalized.

## 11. Final validation

- Proposal files present: **8/8**
- Required sections per proposal: **16/16**
- Total proposed L2: **77**
- Exact/normalized duplicate L2: **0**
- Unresolved cross-domain duplicate ownership: **0**
- Category/facet contract violations: **0 found after correction**
- Service/digital leakage: **0**
- Policy-sensitive product auto-eligibility: **0**
- Max future depth: **L1→L2→L3→L4**
- Proposal states: **8/8 PROPOSED FOR OWNER REVIEW**
- Owner finalization performed: **NO**
- Runtime/DB/remote changes: **NONE**

`OVERNIGHT_BATCH_03_ARCHITECTURE: PASS`

`AUTOMOTIVE_MOTORCYCLE_READY_FOR_OWNER_REVIEW: YES`

`BOOKS_READY_FOR_OWNER_REVIEW: YES`

`STATIONERY_OFFICE_READY_FOR_OWNER_REVIEW: YES`

`PET_PRODUCTS_READY_FOR_OWNER_REVIEW: YES`

`OPTICS_READY_FOR_OWNER_REVIEW: YES`

`WATCHES_JEWELRY_READY_FOR_OWNER_REVIEW: YES`

`HEALTH_MEDICAL_READY_FOR_OWNER_REVIEW: YES`

`FLOWERS_GARDEN_READY_FOR_OWNER_REVIEW: YES`

`CROSS_DOMAIN_AUDIT: PASS`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`

`INTEGRATION_REQUIRED: YES`
