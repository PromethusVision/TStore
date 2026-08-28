# EsnaftaVar Merchant ↔ Product Taxonomy Decoupling Audit

**State:** 100-SCENARIO DESIGN AUDIT — NO RUNTIME IMPLEMENTATION

## 1. Contract under test

Merchant-sector identity must remain usable when Product Taxonomy L2/L3/L4 names,
parents, leaves or proposal states change.

Required invariants:

1. merchant sector IDs are opaque and never derived from product node IDs/paths;
2. a merchant can list products from many Product L1s;
3. each product retains exactly one independent canonical product leaf;
4. merchant→product mapping is advisory many-to-many metadata, not a foreign-key
   ownership constraint;
5. product rename/move with stable identity normally requires no merchant assignment
   change;
6. product split/merge may refresh suggestions/reports, never silently reclassify the
   merchant;
7. services do not become products;
8. policy eligibility stays separate from both taxonomies.

## 2. Scenario matrix

`MAPPING_MAINTENANCE=REFRESH` means descriptive suggestions/analytics mappings may
need review. It does not mean the merchant's sector changes.

| TEST_ID | MERCHANT_SECTOR | PRODUCT_TAXONOMY_CHANGE_OR_SCENARIO | EXPECTED_MERCHANT_EFFECT | MAPPING_MAINTENANCE | RESULT |
|---|---|---|---|---|---|
| MPD-001 | Market, Bakkal & Süpermarket | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-002 | Kasap | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-003 | Şarküteri | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-004 | Manav | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-005 | Fırın | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-006 | Pastane & Tatlıcı | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-007 | Kuruyemişçi | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-008 | Aktar | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-009 | İçecek & Su Bayii | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-010 | Giyim Mağazası | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-011 | Ayakkabı Mağazası | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-012 | Çanta & Aksesuar Mağazası | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-013 | İç Giyim Mağazası | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-014 | Telefoncu & GSM Mağazası | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-015 | Elektronik Mağazası | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-016 | Bilgisayarcı | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-017 | Beyaz Eşya & Ev Aletleri Mağazası | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-018 | Mobilya Mağazası | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-019 | Ev Tekstili Mağazası | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-020 | Züccaciye & Mutfak Gereçleri Mağazası | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-021 | Halı & Kilim Mağazası | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-022 | Perdeci | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-023 | Nalbur & Hırdavatçı | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-024 | Yapı Malzemeleri Satıcısı | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-025 | Elektrik Malzemeleri Satıcısı | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-026 | Tesisat Malzemeleri Satıcısı | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-027 | Boya & Dekorasyon Malzemeleri Satıcısı | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-028 | Oto Yedek Parçacı | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-029 | Oto Aksesuar Mağazası | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-030 | Lastikçi | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-031 | Motosiklet Mağazası | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-032 | Motosiklet Yedek Parça & Aksesuar Mağazası | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-033 | Bisiklet Mağazası | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-034 | Kozmetik & Kişisel Bakım Mağazası | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-035 | Parfümeri | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-036 | Erkek Berberi | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-037 | Kadın Kuaförü | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-038 | Güzellik Salonu | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-039 | Anne & Bebek Mağazası | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-040 | Oyuncakçı | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-041 | Hobi & El Sanatları Mağazası | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-042 | Müzik & Enstrüman Mağazası | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-043 | Kitapçı | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-044 | Kırtasiye | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-045 | Ofis Malzemeleri Mağazası | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-046 | Spor Malzemeleri Mağazası | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-047 | Outdoor & Kamp Mağazası | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-048 | Balıkçılık & Av Malzemeleri Mağazası | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-049 | Pet Shop | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-050 | Akvaryumcu | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-051 | Pet Kuaförü | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-052 | Optik Mağazası | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-053 | Kuyumcu | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-054 | Saatçi | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-055 | Medikal Ürün Mağazası | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-056 | Çiçekçi | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-057 | Bahçe & Yetiştirme Ürünleri Mağazası | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-058 | Hediyelik Eşya Mağazası | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-059 | Parti Malzemeleri Mağazası | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-060 | Telefon & Elektronik Teknik Servisi | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-061 | Bilgisayar Teknik Servisi | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-062 | Beyaz Eşya Teknik Servisi | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-063 | Terzi & Giyim Tadilatı | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-064 | Ayakkabı Tamircisi | Two proposed Product leaves are owner-reviewed and merge or change proposal boundary. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-065 | Anahtarcı | Likely Product L2 display name is renamed while its stable ID remains. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-066 | Kuru Temizleme & Çamaşırhane | A Product L3 moves to a different Product L2 with semantic identity preserved. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | NONE | PASS |
| MPD-067 | Bisiklet Servisi | A broad Product leaf splits into multiple successors requiring SKU reclassification. | Keep merchant sector/primary-secondary assignments unchanged; re-resolve product nodes independently. | REFRESH | PASS |
| MPD-068 | Market, Bakkal & Süpermarket | Pet Product L2 changes from species-first to product-family architecture. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-069 | Kasap | Hediyelik product proposal removes gift-intent duplicates and keeps underlying owners. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-070 | Şarküteri | Supplement products receive a new owner-approved controlled Product L2. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-071 | Manav | Vehicle-fitment electronics move from generic Electronics to Automotive successors. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-072 | Fırın | Technical bags split between generic bags and domain-specific integrated systems. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-073 | Pastane & Tatlıcı | PPE products move across apparel, footwear, sport and hardware by intended use. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-074 | Kuruyemişçi | Live plants and cut arrangements gain separate final Product leaves. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-075 | Aktar | Printer toner boundary becomes final under Computer printer/supplies. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-076 | İçecek & Su Bayii | Pet hygiene and veterinary products split under policy-aware successors. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-077 | Giyim Mağazası | Optical products split prescription/custom from ready consumer products. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-078 | Ayakkabı Mağazası | Medical-device leaves split consumer/home from professional-only scope. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-079 | Çanta & Aksesuar Mağazası | Party/gift Product L2s are simplified after owner review. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-080 | İç Giyim Mağazası | Baby food ownership moves between proposal targets after owner decision. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | REFRESH | PASS |
| MPD-081 | Telefoncu & GSM Mağazası | Elektronik Product L2 label changes but stable ID remains. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-082 | Elektronik Mağazası | Computer component Product L4 gets a display-name correction. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-083 | Bilgisayarcı | A phone-accessory leaf moves parent with the same stable product identity. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-084 | Beyaz Eşya & Ev Aletleri Mağazası | A classic-watch Product L2 moves within Saat & Takı without semantic change. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-085 | Mobilya Mağazası | A shoe-care Product leaf is renamed without scope change. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-086 | Ev Tekstili Mağazası | A book genre Product L2 is renamed while books remain physical products. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-087 | Züccaciye & Mutfak Gereçleri Mağazası | A stationery Product L3 moves under another L2 with unchanged SKU population. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-088 | Halı & Kilim Mağazası | A cookware Product leaf slug changes and retains redirect. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-089 | Perdeci | A furniture Product L3 changes sort order only. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-090 | Nalbur & Hırdavatçı | A cosmetics Product L2 gets a clearer Turkish display label. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-091 | Yapı Malzemeleri Satıcısı | An appliance accessory Product node moves parent with stable ID. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-092 | Elektrik Malzemeleri Satıcısı | An automotive product facet changes from free text to typed compatibility. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-093 | Tesisat Malzemeleri Satıcısı | A clothing size facet vocabulary changes without category mutation. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-094 | Boya & Dekorasyon Malzemeleri Satıcısı | A food allergen facet schema changes without Product Taxonomy movement. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-095 | Oto Yedek Parçacı | A computer compatibility relation changes without product-path change. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-096 | Oto Aksesuar Mağazası | A merchant starts stocking products from a newly added Product L1. | Keep merchant sector; allow the new Product L1 independently. | NONE | PASS |
| MPD-097 | Lastikçi | A merchant stops selling every product from its likely primary Product L1. | Keep merchant sector unless the real business identity changes; inventory absence alone is insufficient. | NONE | PASS |
| MPD-098 | Motosiklet Mağazası | A service-only merchant has no product catalog at all. | Keep service merchant sector; product catalog remains optional. | NONE | PASS |
| MPD-099 | Motosiklet Yedek Parça & Aksesuar Mağazası | A mixed merchant sells a repair part whose Product leaf is retired. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |
| MPD-100 | Bisiklet Mağazası | A chain branch sells a different Product L1 mix from sister branches. | Keep merchant sector identity and assignments; apply Product Taxonomy change only to products/mapping metadata. | NONE | PASS |

## 3. Result

- Scenarios: **100**
- Merchant-sector identity changes required: **0**
- Merchant→product advisory mapping refresh cases: **46**
- No-refresh cases: **54**
- Product Taxonomy ownership inferred from merchant sector: **0**
- Product path used as merchant stable ID: **0**

The mapping CSV is a research aid. A future implementation should version mappings
by Product Taxonomy version and tolerate unknown/new product nodes without breaking
merchant profiles.

`MERCHANT_PRODUCT_DECOUPLING: PASS`

`RUNTIME_IMPLEMENTATION: NO`
