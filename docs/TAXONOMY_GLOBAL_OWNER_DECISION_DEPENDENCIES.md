# EsnaftaVar Global Owner Decision Dependencies

**Wave:** 15 / Global L2 Cross-Batch Audit

**State:** Optimized owner-review plan; no decision is approved by this document.

## Compression model

The ownership matrix contains **66 raw owner-required scenario decisions**. Asking them independently would repeat the same principles. This graph reduces the queue to **18 root decisions**. A root answer can resolve **48 dependent decisions** when applied with the stated guardrails; policy/legal gates remain separate even after taxonomy ownership is selected.

## ROOT-01 — Medical intended-use rule

**ROOT ID:** `ROOT-01`

**QUESTION:** When does a food, cosmetic, optic, sport, pet or consumer device move to Sağlık & Medikal or a controlled medical scope?

**AFFECTED L1:** Gıda & İçecek; Kozmetik & Kişisel Bakım; Sağlık & Medikal; Gözlük & Optik; Spor & Outdoor; Evcil Hayvan Ürünleri; Anne & Bebek; Elektronik.

**AFFECTED PROPOSED L2:** Güneş Bakımı; Ağız & Diş Bakımı; nine Health L2s; Kontakt Lensler; Ortopedik Destekler & Kompresyon; Bebek Beslenme.

**DEPENDENT DECISION IDs:** `COL-B-002`, `COL-B-003`, `COL-C-001`, `COL-F-003`, `COL-F-011`.

**OPTION A:** Evidence-backed medical intended use/registration controls ownership; ordinary wellness/cosmetic/food products remain in their functional L1.
**OPTION B:** Any health association moves the product to Health.
**OPTION C:** Physical product form always controls, regardless of intended use.

**RECOMMENDED OPTION:** A.

**WHY:** It preserves one stable product owner while failing closed on regulated claims and eligibility.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `5`

**POLICY EFFECT:** Medical eligibility, claim, seller, traceability and recall remain mandatory separate gates.

**RUNTIME EFFECT LATER:** Typed intended-use/evidence attributes and a review state; no automatic inference from marketing copy.

## ROOT-02 — Baby/life-stage ownership rule

**ROOT ID:** `ROOT-02`

**QUESTION:** When does explicit baby/pregnancy life-stage purpose override ordinary food, cosmetic, clothing, shoe, bag or toy form?

**AFFECTED L1:** Anne & Bebek; Gıda & İçecek; Kozmetik & Kişisel Bakım; Giyim & Moda; Ayakkabı; Çanta & Aksesuar; Oyuncak & Hobi.

**AFFECTED PROPOSED L2:** Bebek Beslenme; Bebek Banyo, Bakım & Hijyen; Hamilelik & Lohusalık Ürünleri; Çocuk & Bebek Ayakkabıları; Bebek & Okul Öncesi Oyuncaklar.

**DEPENDENT DECISION IDs:** `COL-B-001`, `COL-C-006`, `COL-F-002`, `COL-G-003`.

**OPTION A:** Life-stage owner applies only when baby/pregnancy-specific function and schema are primary; ordinary form/size/marketing remains in the product L1.
**OPTION B:** Every baby-labeled product moves to Anne & Bebek.
**OPTION C:** Life stage is always only a facet.

**RECOMMENDED OPTION:** A.

**WHY:** It recognizes genuine feeding, care and safety contracts without duplicating all child-sized products.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `4`

**POLICY EFFECT:** Formula, child restraint, sleep, hygiene and used safety products retain stricter gates.

**RUNTIME EFFECT LATER:** Controlled intended-user/life-stage facet plus explicit owner rule.

## ROOT-03 — Technical sport product ownership

**ROOT ID:** `ROOT-03`

**QUESTION:** Should apparel/footwear keep product-form ownership when used for sport, and what threshold creates a specialist Sports product?

**AFFECTED L1:** Giyim & Moda; Ayakkabı; Spor & Outdoor; Gözlük & Optik.

**AFFECTED PROPOSED L2:** Spor & Performans Giyimi; Spor Ayakkabıları; Mayo & Plaj Giyimi; Outdoor, Kamp & Trekking; Su Sporları.

**DEPENDENT DECISION IDs:** `COL-B-004`, `COL-C-002`, `COL-C-003`, `COL-C-004`.

**OPTION A:** Wearable form stays in Clothing/Shoes; Sports owns equipment and explicitly approved integrated technical systems.
**OPTION B:** Any sport-marketed product moves to Sports.
**OPTION C:** Every product remains in form L1 with sport only as facet.

**RECOMMENDED OPTION:** A.

**WHY:** It preserves customer product identity while allowing safety/performance equipment to retain specialist schema.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `4`

**POLICY EFFECT:** PPE and medical claims still use ROOT-08 and ROOT-01.

**RUNTIME EFFECT LATER:** Sport/use facets and controlled specialist-system flag.

## ROOT-04 — Generic versus domain-specific carrying product

**ROOT ID:** `ROOT-04`

**QUESTION:** When does a bag/case stay in Çanta & Aksesuar, and when does integration make it part of Mother/Baby, Music, Sports or another device domain?

**AFFECTED L1:** Çanta & Aksesuar; Anne & Bebek; Müzik & Enstrüman; Spor & Outdoor; Bilgisayar & Tablet; Elektronik.

**AFFECTED PROPOSED L2:** Evrak, Laptop & Ekipman Çantaları; Sırt Çantaları; Bebek Arabaları & Taşıma; Enstrüman Aksesuarları; Outdoor equipment.

**DEPENDENT DECISION IDs:** `COL-C-007`, `COL-C-008`, `COL-C-022`.

**OPTION A:** Standalone carrying product stays in Bags; inseparable or schema-changing integrated technical module follows the specialist product.
**OPTION B:** Compatibility always moves the bag to the carried product's domain.
**OPTION C:** Every carrying product remains in Bags, including integrated systems.

**RECOMMENDED OPTION:** A.

**WHY:** Compatibility is normally a facet, while true integration can change product identity.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `3`

**POLICY EFFECT:** Weapon-carrying and counterfeit claims remain policy-gated.

**RUNTIME EFFECT LATER:** Compatibility plus integrated-system attributes.

## ROOT-05 — Fixed installation versus movable product

**ROOT ID:** `ROOT-05`

**QUESTION:** Should fixed/plumbed/building-integrated products route to Hardware while movable room/garden products stay in Home or Flowers/Garden?

**AFFECTED L1:** Ev & Yaşam; Yapı, Hırdavat & Tesisat; Çiçek & Bahçe; Beyaz Eşya & Ev Aletleri; Elektronik.

**AFFECTED PROPOSED L2:** Aydınlatma; Banyo Aksesuarları; Su Tesisatı & Armatürler; Elektrik Tesisatı Malzemeleri; Sulama Ürünleri; garden storage/furniture families.

**DEPENDENT DECISION IDs:** `COL-B-009`, `COL-C-011`, `COL-C-012`, `COL-C-013`.

**OPTION A:** Fixed building connection/installation routes to Hardware; movable/decorative or plant-primary product remains in its functional L1.
**OPTION B:** Room/location always controls.
**OPTION C:** All installable goods move to Hardware, even ordinary furniture/appliances.

**RECOMMENDED OPTION:** A.

**WHY:** Installation and infrastructure create a stable schema boundary without turning rooms into categories.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `4`

**POLICY EFFECT:** Mains, gas, plumbing and licensed installation remain fail-closed where required.

**RUNTIME EFFECT LATER:** Installation type and connection requirements as typed attributes.

## ROOT-06 — Manual versus powered household product

**ROOT ID:** `ROOT-06`

**QUESTION:** Should powered appliance identity override kitchen/home/cosmetics usage context?

**AFFECTED L1:** Beyaz Eşya & Ev Aletleri; Züccaciye & Mutfak; Ev & Yaşam; Kozmetik & Kişisel Bakım.

**AFFECTED PROPOSED L2:** Küçük Mutfak Aletleri; Temizlik Cihazları; Elektrikli Kişisel Bakım Cihazları; Çay & Kahve Demleme Gereçleri; Ev Temizliği & Çamaşır Bakımı.

**DEPENDENT DECISION IDs:** `COL-B-008`, `COL-C-009`, `COL-C-010`.

**OPTION A:** Powered finished appliance follows Home Appliances; manual utensil/consumable remains Kitchen/Home/Cosmetics.
**OPTION B:** Usage room/function always controls.
**OPTION C:** Any electrically assisted accessory follows Electronics.

**RECOMMENDED OPTION:** A.

**WHY:** Device lifecycle, safety and compatibility differ from manual products; smart connectivity does not change appliance ownership.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `3`

**POLICY EFFECT:** Electrical/health claims remain separate gates.

**RUNTIME EFFECT LATER:** Powered-device and principal-device compatibility fields.

## ROOT-07 — Generic versus fitment/device-specific electronics

**ROOT ID:** `ROOT-07`

**QUESTION:** When should electronics/accessories follow Automotive, Hardware, Computer or a specific device family instead of owner-final generic Electronics?

**AFFECTED L1:** Elektronik; Bilgisayar & Tablet; Otomotiv & Motosiklet; Yapı, Hırdavat & Tesisat; Saat & Takı.

**AFFECTED PROPOSED L2:** Araç Elektroniği; Akü & Araç Elektriği; tool accessories; Saat Kayışları & Aksesuarları. Owner-final Electronics/Computer nodes remain fixed.

**DEPENDENT DECISION IDs:** `COL-B-010`, `COL-C-014`, `COL-C-016`, `COL-C-017`.

**OPTION A:** Verified vehicle/device/tool/building fitment and primary function control; otherwise generic product remains in owner-final Electronics/Computer owner.
**OPTION B:** Electrical form always means Electronics.
**OPTION C:** Marketing context always decides.

**RECOMMENDED OPTION:** A.

**WHY:** It extends the canonical generic/specific accessory rule without reopening final Electronics/Computer structures.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `4`

**POLICY EFFECT:** Battery, mains and vehicle hazardous-goods controls remain separate.

**RUNTIME EFFECT LATER:** Versioned compatibility/fitment relationships.

## ROOT-08 — PPE and certified protection ownership

**ROOT ID:** `ROOT-08`

**QUESTION:** Should certified protective function override clothing, footwear or eyewear form?

**AFFECTED L1:** Yapı, Hırdavat & Tesisat; Giyim & Moda; Ayakkabı; Spor & Outdoor; Gözlük & Optik; Sağlık & Medikal.

**AFFECTED PROPOSED L2:** İş Güvenliği & Koruyucu Donanım; İş & Güvenlik Ayakkabıları; Spor/technical apparel; Kişisel Koruyucu Medikal Ürünler.

**DEPENDENT DECISION IDs:** `COL-B-005`, `COL-C-021`, `COL-F-005`.

**OPTION A:** Certified occupational protection follows Hardware/OHS; medical PPE follows Health; sport protection follows Sports; ordinary form remains Clothing/Shoes/Optics.
**OPTION B:** Physical form always controls.
**OPTION C:** Every protective product moves to Health.

**RECOMMENDED OPTION:** A.

**WHY:** Intended use and certification schema distinguish protection systems from ordinary products.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `3`

**POLICY EFFECT:** Certification/claim/traceability gate required.

**RUNTIME EFFECT LATER:** Intended-use and certification profiles shared across domains.

## ROOT-09 — Gift purpose and personalization no-duplication rule

**ROOT ID:** `ROOT-09`

**QUESTION:** Can gift purpose or personalization ever change the primary product owner?

**AFFECTED L1:** Hediyelik & Parti and every product L1.

**AFFECTED PROPOSED L2:** Hatıra & Hediyelik Objeler; Hediye Paketleme & Sunum; ordinary food, jewelry, toy, flower, apparel and kitchen L2s.

**DEPENDENT DECISION IDs:** `COL-D-004`, `COL-D-005`, `COL-E-004`.

**OPTION A:** Underlying product retains ownership; personalization/gift/occasion is facet or merchant capability; only intrinsic keepsake is candidate Gift product.
**OPTION B:** Any gift-marketed item moves to Hediyelik & Parti.
**OPTION C:** Remove all physical keepsake/party product scope.

**RECOMMENDED OPTION:** A.

**WHY:** It eliminates global duplication while retaining genuine keepsake and party products.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `3`

**POLICY EFFECT:** High-value, food, child and hazardous goods retain original policy gates.

**RUNTIME EFFECT LATER:** Occasion/personalization facets and merchant capabilities, not extra primary leaves.

## ROOT-10 — Product versus service boundary

**ROOT ID:** `ROOT-10`

**QUESTION:** How should physical products bundled with preparation, installation, repair, personalization, subscription or delivery be classified?

**AFFECTED L1:** Gıda; Home; Appliances; Hardware; Flowers/Garden; Gifts/Party; Merchant/Service scope.

**AFFECTED PROPOSED L2:** Hazır & Pratik Gıda; Mobilya; appliance families; Kesme Çiçek & Fiziksel Aranjmanlar; personalized gift families.

**DEPENDENT DECISION IDs:** `COL-E-001`, `COL-E-002`.

**OPTION A:** Classify a separately sellable principal physical product; keep labor/time/subscription outside Product Taxonomy.
**OPTION B:** Bundle service and product in the same taxonomy node.
**OPTION C:** Exclude every product that can include service.

**RECOMMENDED OPTION:** A.

**WHY:** It preserves the canonical Product/Merchant/Service separation without losing real physical products.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `2`

**POLICY EFFECT:** Service authorization/pricing is a separate future capability.

**RUNTIME EFFECT LATER:** Principal-product relation and separate service capability model.

## ROOT-11 — Weapon-like and hazardous recreation posture

**ROOT ID:** `ROOT-11`

**QUESTION:** What is the V1 posture for alcohol, airsoft/paintball, hunting/weapon-like goods, fireworks, pressurized party gas and excluded weapons/explosives?

**AFFECTED L1:** Gıda & İçecek; Oyuncak & Hobi; Spor & Outdoor; Hediyelik & Parti; Hardware; Bags.

**AFFECTED PROPOSED L2:** Balıkçılık & Avcılık; toy vehicle/role-play families; party accessory families; no proposed alcohol/tobacco L2.

**DEPENDENT DECISION IDs:** `COL-F-001`, `COL-F-008`, `COL-F-012`.

**OPTION A:** Preserve explicit exclusions; use exact legal allowlist for any non-excluded weapon-like family.
**OPTION B:** Age gate alone makes all products eligible.
**OPTION C:** Permit ordinary listing based on merchant category selection.

**RECOMMENDED OPTION:** A.

**WHY:** Familiar toy/sport/party labels cannot be treated as legal eligibility evidence.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `3`

**POLICY EFFECT:** High; owner decision does not replace authoritative legal review.

**RUNTIME EFFECT LATER:** Fail-closed allowlist/denylist and age/merchant gates.

## ROOT-12 — Live and biological product scope

**ROOT ID:** `ROOT-12`

**QUESTION:** What live plant/seed/animal/aquatic product families are in V1, and which traceability/fulfilment controls are mandatory?

**AFFECTED L1:** Çiçek & Bahçe; Evcil Hayvan Ürünleri; Gıda & İçecek.

**AFFECTED PROPOSED L2:** Canlı Saksı Bitkileri; Tohum, Fide & Bitki Soğanları; Akvaryum & Balık Ürünleri.

**DEPENDENT DECISION IDs:** `POL-028`, `POL-029`.

**OPTION A:** Live animals and prohibited plant-protection products remain excluded; allowed live plants/seeds use exact traceability/fulfilment gates.
**OPTION B:** All live goods are ordinary products.
**OPTION C:** Exclude every live plant/seed as well.

**RECOMMENDED OPTION:** A.

**WHY:** Product families differ materially in legal status, welfare, seasonality and fulfilment risk.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `2`

**POLICY EFFECT:** Authoritative product/seller/transport evidence remains mandatory.

**RUNTIME EFFECT LATER:** Live-goods eligibility, location/season and traceability fields.

## ROOT-13 — Facet or controlled category exception

**ROOT ID:** `ROOT-13`

**QUESTION:** What evidence permits a cross-cutting attribute/audience/collection to remain an L2 instead of a facet or browse projection?

**AFFECTED L1:** Giyim & Moda; Oyuncak & Hobi; Müzik & Enstrüman; Books and other future collection candidates.

**AFFECTED PROPOSED L2:** Bebek & Okul Öncesi Oyuncaklar; Geleneksel Türk Müziği Enstrümanları; proposed non-L2 tesettür collection.

**DEPENDENT DECISION IDs:** `COL-D-001`, `COL-D-003`.

**OPTION A:** Permit only when a stable, non-overlapping product schema and deterministic registry exist; otherwise facet/projection.
**OPTION B:** Popular browse term is enough for L2.
**OPTION C:** Never allow any exception.

**RECOMMENDED OPTION:** A.

**WHY:** It prevents marketing dimensions from duplicating product leaves while allowing rare schema-bearing exceptions.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `2`

**POLICY EFFECT:** Age/safety controls remain separate even for an approved exception.

**RUNTIME EFFECT LATER:** Controlled registries and projections, not merchant free text.

## ROOT-14 — Published content, supply and kit principal-product rule

**ROOT ID:** `ROOT-14`

**QUESTION:** How should books/workbooks, blank stationery, art supplies, educational kits and puzzles choose one owner?

**AFFECTED L1:** Kitap; Kırtasiye & Ofis; Oyuncak & Hobi.

**AFFECTED PROPOSED L2:** Children/Education books; Defter, Ajanda & Planlayıcılar; Sanat & Çizim Malzemeleri; Eğitici, Bilim & Keşif Oyuncakları; Puzzle & Zeka Oyunları.

**DEPENDENT DECISION IDs:** `COL-G-006`, `COL-G-007`, `COL-G-008`.

**OPTION A:** Published readable/instructional content → Books; blank/general supplies → Stationery; complete guided play/experiment object → Toys.
**OPTION B:** Any included activity component moves the product to Toys.
**OPTION C:** Format alone (paper/book binding) always controls.

**RECOMMENDED OPTION:** A.

**WHY:** Principal product and user activity are more reliable than component count or ISBN alone.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `3`

**POLICY EFFECT:** Child safety, chemicals and copyright remain separate.

**RUNTIME EFFECT LATER:** Principal-product and content-type fields.

## ROOT-15 — Pet nutrition and veterinary-health rule

**ROOT ID:** `ROOT-15`

**QUESTION:** How should pet food, pet supplements, hygiene and veterinary medical products be separated from human Food/Health/Cosmetics?

**AFFECTED L1:** Evcil Hayvan Ürünleri; Gıda & İçecek; Sağlık & Medikal; Kozmetik & Kişisel Bakım.

**AFFECTED PROPOSED L2:** Species-first Pet L2s; no approved veterinary medicine/supplement L2.

**DEPENDENT DECISION IDs:** `COL-B-011`.

**OPTION A:** Animal-intended ordinary supplies/food stay Pet; medical/supplement/biosidal families require controlled veterinary scope and may remain excluded.
**OPTION B:** Product form routes pet goods to human Food/Health/Cosmetics.
**OPTION C:** Everything sold by a pet shop is ordinary Pet product.

**RECOMMENDED OPTION:** A.

**WHY:** Intended species is primary, while veterinary status remains a separate legal gate.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `1`

**POLICY EFFECT:** High for medicines, supplements and biosidal claims.

**RUNTIME EFFECT LATER:** Required species/intended-use attributes and policy review.

## ROOT-16 — Precious/high-value and protected-material provenance

**ROOT ID:** `ROOT-16`

**QUESTION:** Can ordinary product-form taxonomy remain stable while precious/high-value/protected-material eligibility is handled separately?

**AFFECTED L1:** Saat & Takı; Müzik & Enstrüman; Çanta & Aksesuar; Hediyelik & Parti.

**AFFECTED PROPOSED L2:** Jewelry form L2s; traditional/structural instruments; accessories/collectibles.

**DEPENDENT DECISION IDs:** `COL-B-012`.

**OPTION A:** Keep product-form owner; apply provenance, authenticity, seller and secure-commerce gates.
**OPTION B:** Material/value creates a new taxonomy owner.
**OPTION C:** Permit normal listing based on merchant text.

**RECOMMENDED OPTION:** A.

**WHY:** Material/value are attributes and policy risks, not stable product identity.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `1`

**POLICY EFFECT:** Legal/commercial controls remain fail closed.

**RUNTIME EFFECT LATER:** Provenance/evidence and high-value review state.

## ROOT-17 — Same-L1 primary-intent rule for future L3/L4

**ROOT ID:** `ROOT-17`

**QUESTION:** When adjacent L2s within one L1 both plausibly fit, should physical form, use intent or packaging control the future leaf?

**AFFECTED L1:** Gıda; Giyim; Toys; Music; Watches and other domains with internal overlaps.

**AFFECTED PROPOSED L2:** Konserve & Kavanoz / Hazır & Pratik; Elbise & Tulum / Dış Giyim; play figure / collectible; instrument/control surface; watch accessory.

**DEPENDENT DECISION IDs:** `COL-G-001`.

**OPTION A:** Use domain-specific deterministic primary-intent tests; keep synonyms/facets separate and forbid dual primary leaves.
**OPTION B:** Allow multi-primary assignment.
**OPTION C:** Merge every adjacent L2.

**RECOMMENDED OPTION:** A.

**WHY:** It preserves current L2 architecture while making later L3/L4 assignment testable.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `1`

**POLICY EFFECT:** None by itself; affected product policies still apply.

**RUNTIME EFFECT LATER:** Versioned assignment rules and review queue for unresolved products.

## ROOT-18 — Exact L2 structure and naming acceptance

**ROOT ID:** `ROOT-18`

**QUESTION:** After root boundaries are answered, which of the 22 exact L2 lists/names require owner edits before canonical lock?

**AFFECTED L1:** All 22 proposed L1s.

**AFFECTED PROPOSED L2:** All 224 proposed L2; naming audit highlights 40 candidates without changing sources.

**DEPENDENT DECISION IDs:** None; this is the final direct structural review gate.

**OPTION A:** Review high-impact structural/naming findings, then approve or explicitly revise each L1 list.
**OPTION B:** Approve all 224 names without boundary review.
**OPTION C:** Rewrite all proposals.

**RECOMMENDED OPTION:** A.

**WHY:** Root decisions should be applied before the owner spends time on local editorial choices.

**NUMBER OF CHILD DECISIONS AUTO-RESOLVED:** `0`

**POLICY EFFECT:** L2 approval still does not authorize policy-sensitive products.

**RUNTIME EFFECT LATER:** Only after separate owner-finalization; stable IDs/runtime remain out of scope.

## Optimized owner-review order

1. `ROOT-01` — Medical intended use.
2. `ROOT-02` — Baby/life-stage ownership.
3. `ROOT-08` — PPE/certified protection.
4. `ROOT-05` — Fixed installation versus movable product.
5. `ROOT-03` — Technical sports product ownership.
6. `ROOT-07` — Generic versus fitment/device-specific electronics.
7. `ROOT-04` — Generic versus domain-specific carrying product.
8. `ROOT-09` — Gift/personalization no-duplication.
9. `ROOT-11` — Weapon-like/hazardous recreation posture.
10. `ROOT-06` — Manual versus powered household product.
11. `ROOT-15` — Pet nutrition/veterinary health.
12. `ROOT-12` — Live/biological goods.
13. `ROOT-14` — Published content/supply/kit.
14. `ROOT-10` — Product versus service.
15. `ROOT-13` — Facet/category exceptions.
16. `ROOT-16` — Precious/provenance.
17. `ROOT-17` — Same-L1 future leaf rule.
18. `ROOT-18` — Exact per-domain L2 structure/naming acceptance.

## Dependency metrics

| Metric | Count |
|---|---:|
| Raw owner-required scenario decisions | 66 |
| Root decisions | 18 |
| Dependent decisions | 48 |
| Decisions potentially auto-resolved by roots | 48 |
| Standalone root review gates | 18 |

`48` is derived from the sum of each root's declared child count. It is an audit planning estimate: policy/legal evidence can still prevent runtime assignment after the taxonomy rule is selected.
