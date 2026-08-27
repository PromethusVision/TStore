# Wave 15 Overnight Taxonomy Batch 02 — Cross-Domain Review

## Status

**COMPLETE — EIGHT PROPOSALS READY FOR OWNER REVIEW**

- Review date: **2026-08-28**
- Scope: Eight canonical L1 domains, L2 architecture only
- Proposal state: **PROPOSED FOR OWNER REVIEW**
- Owner finalization performed: **NO**
- Runtime implementation performed: **NO**

This audit validates proposal consistency. It does not approve any L2, resolve owner decisions, or change the owner-final 24-L1 registry.

## Reviewed artifacts

| Canonical L1 | Proposal | L2 count | Required sections | Proposal state |
|---|---|---:|---:|---|
| Ayakkabı | `TAXONOMY_SHOES_L2_PROPOSAL.md` | 8 | 16/16 | PROPOSED FOR OWNER REVIEW |
| Çanta & Aksesuar | `TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` | 10 | 16/16 | PROPOSED FOR OWNER REVIEW |
| Beyaz Eşya & Ev Aletleri | `TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` | 10 | 16/16 | PROPOSED FOR OWNER REVIEW |
| Anne & Bebek | `TAXONOMY_MOTHER_BABY_L2_PROPOSAL.md` | 9 | 16/16 | PROPOSED FOR OWNER REVIEW |
| Oyuncak & Hobi | `TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` | 11 | 16/16 | PROPOSED FOR OWNER REVIEW |
| Müzik & Enstrüman | `TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` | 10 | 16/16 | PROPOSED FOR OWNER REVIEW |
| Spor & Outdoor | `TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` | 10 | 16/16 | PROPOSED FOR OWNER REVIEW |
| Hediyelik & Parti | `TAXONOMY_GIFTS_PARTY_L2_PROPOSAL.md` | 9 | 16/16 | PROPOSED FOR OWNER REVIEW |

Total proposed L2 nodes: **77**.

## Architecture contract audit

| Contract | Result | Evidence |
|---|---|---|
| Owner-final L1 names unchanged | PASS | All eight titles and scope records match the locked 24-L1 registry. |
| L2-only scope | PASS | No complete L3/L4 tree, runtime node, ID, slug or migration was created. |
| Variable depth, maximum L4 | PASS | Lower-level entries are explicitly non-final expansion examples. |
| Exactly one primary leaf | PASS WITH OWNER DECISIONS | Deterministic boundary rules exist; five specialized-product boundaries remain openly owner-gated before runtime. |
| Product vs merchant taxonomy | PASS | Store type and sales channel do not assign product category. |
| Category vs facet separation | PASS | Brand, color, size, age, compatibility, material, occasion and technical values remain facets. |
| Services excluded | PASS | Repair, installation, course, rental, organization, consultancy and digital subscription do not become product nodes. |
| Policy classification remains separate | PASS | Risk does not become taxonomy; risky products are fail-closed or excluded. |
| Owner-finalization absent | PASS | Every proposal has exactly one `PROPOSED FOR OWNER REVIEW` status and explicitly records no finalization. |

## Source integrity audit

The proposals triangulate rather than copy one marketplace:

- [Google Product Taxonomy](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) supplies broad product-family boundaries. Its public file header is `2021-09-21`; it is not represented as a 2026-fresh taxonomy.
- [Google Merchant Center category guidance](https://support.google.com/merchants/answer/6324436?hl=tr) supports single, specific product classification but is not treated as EsnaftaVar navigation.
- Current marketplace surfaces from [n11](https://www.n11.com/) and [Amazon Türkiye](https://www.amazon.com.tr/b?node=21034466031), plus relevant Hepsiburada category/content surfaces, provide Turkish customer-language signals. Their merchandising structures are not copied wholesale.
- [ISO 20345:2021](https://www.iso.org/standard/73222.html), [UNECE Regulation No. 129](https://unece.org/transport/vehicle-regulations-wp29/standards/addenda-1958-agreement-regulations-121-140), and [European Commission product-safety material](https://commission.europa.eu/topics/business-and-industry/product-safety_en) are used only for safety/policy evidence, not as category trees.

Source limitations are stated inside each affected proposal. No source is claimed to resolve Turkish law or owner policy automatically.

## Duplicate-family audit

Exact L2 heading duplicate across the 77 proposed nodes: **0**.

Semantic overlaps were reviewed as follows:

| Product family | Candidate owners | Audit resolution |
|---|---|---|
| Sports footwear | Ayakkabı / Spor & Outdoor | Ayakkabı owns the product; sport/use remains facet or future lower node. |
| Child/baby footwear | Ayakkabı / Anne & Bebek | Ayakkabı owns the product; age and size remain facets. |
| Technical carrying bags | Çanta & Aksesuar / specialist L1 | General independent carrying product defaults to Çanta & Aksesuar; an integrated technical system may route to specialist L1. Exact threshold remains owner-gated. |
| Baby-care bag | Çanta & Aksesuar / Anne & Bebek | Open owner decision; both proposals expose the same unresolved boundary and do not claim two owners. |
| Robot vacuum, smart climate and coffee machine | Beyaz Eşya & Ev Aletleri / Elektronik | Home task determines ownership; connectivity is a facet. |
| Baby monitor | Anne & Bebek / Elektronik | Elektronik → Akıllı Ev & Güvenlik owns the connected monitoring device. |
| Baby formula | Anne & Bebek / Gıda & İçecek | Open owner and policy decision; no runtime owner asserted. |
| Toy instrument | Oyuncak & Hobi / Müzik & Enstrüman | Real tune/performance capability routes to Music; role-play toy routes to Toys. |
| Traditional Turkish instrument | Traditional Music L2 / structural instrument family | Proposed exact-name registry would give one primary leaf. Whether the carve-out exists remains owner-gated. |
| Camera drone / toy drone | Elektronik / Oyuncak & Hobi | Camera/flight-imaging device goes to Fotoğraf & Kamera; toy-class play product goes to Toys. |
| Sports protection / medical orthosis | Spor & Outdoor / Sağlık & Medikal | Performance/impact protection remains Sports; treatment/rehabilitation claim routes to Health. |
| Camping stove / kitchen appliance | Spor & Outdoor / Beyaz Eşya & Ev Aletleri | Specialist portable outdoor equipment remains Sports; general home kitchen appliance remains Home Appliances. |
| Party tableware / general tableware | Hediyelik & Parti / Züccaciye & Mutfak | Occasion-specific coordinated/disposable party product remains Party; generic reusable product remains Kitchenware. |
| Gifted product / intrinsic keepsake | Product's own L1 / Hediyelik & Parti | “Gift” is not ownership. Only intrinsically commemorative physical objects are candidate keepsakes. |
| Costume footwear | Hediyelik & Parti / Ayakkabı | Costume-only object goes to Party; normally wearable footwear remains Shoes. |

Result: **no hidden duplicate assignment was accepted**. Five owner decisions must be resolved before runtime: baby-care bags, instrument bags, traditional-instrument registry, baby formula, and integrated technical/hydration bags.

## Contradiction audit

The same representative edge cases were compared in every document where they appear:

- Trekking/sports shoes consistently route to Ayakkabı.
- Hidrasyon/technical bags consistently use the integrated-system threshold.
- Baby monitors consistently route to Elektronik.
- Toy versus real instruments consistently use tune/performance capability.
- Toy versus camera drones consistently use primary imaging/product capability.
- Camping stoves consistently route to specialist outdoor equipment.
- Party games consistently remain Oyuncak & Hobi.
- Costume-only footwear consistently differs from normal wearable footwear.
- “Gift” consistently remains a facet/purpose, not a duplicate product family.

Contradictory final ownership claims: **0**. Open questions are labelled as open rather than silently resolved.

## Service-leakage audit

No L2 name represents a service. The following are expressly excluded wherever relevant:

- shoe repair/lostra and product personalization labor;
- appliance installation, maintenance, repair and salon services;
- childcare, consultation, training and child-seat installation;
- game venue, course, event and rental;
- music lesson, studio rental, concert, repair and digital subscription;
- sports course, membership, guide, tour and rental;
- party organization, animator, catering, rental, print/design and personalization labor.

Physical personalized products retain their underlying product identity. A service bundled around a product is not a product-category node.

## Facet/category audit

No brand is proposed as a category. Cross-batch facet rules consistently keep these outside L2:

- brand/model and licensed character;
- color, pattern and material;
- gender presentation, age, size, shoe number and capacity;
- device/vehicle compatibility and connector type;
- power, protocol, smart connectivity and performance tier;
- sport/occasion/theme when they do not change product identity;
- personalization capability, package quantity and condition.

Two deliberate exceptions are justified as schema-bearing product families rather than raw facets:

1. `Çocuk & Bebek Ayakkabıları` — distinct sizing, developmental and safety contract.
2. `Bebek & Okul Öncesi Oyuncaklar` — distinct developmental and toy-safety contract.

Both remain owner-review decisions and are not silently finalized.

## Policy-risk audit

| Domain | High-signal risk | Proposed fail-closed treatment |
|---|---|---|
| Ayakkabı | Safety certification and medical/orthopedic claims | Evidence required; unsupported medical claims route to policy review. |
| Çanta & Aksesuar | Weapon-carrying products, counterfeit brand claims | Legal review or exclusion; no automatic placement. |
| Beyaz Eşya & Ev Aletleri | Gas/fixed installation, sterilization/health claims, electrical safety | Installation warning and claim review; services excluded. |
| Anne & Bebek | Feeding regulation, sleep claims, child restraint and used safety products | Standards/evidence required; formula and medical claims owner/policy-gated. |
| Oyuncak & Hobi | Magnets, batteries, chemistry, projectile/weapon-like products | Age/safety data required; firearms/explosives excluded; weapon-like items reviewed. |
| Müzik & Enstrüman | Protected animal/plant material, radio frequency, high-power stage equipment | Provenance/compliance review before assignment. |
| Spor & Outdoor | Weapons, ammunition, projectiles, diving/climbing/water safety and compressed fuel | Firearms/ammunition/explosives excluded; uncertain products legal-review gated. |
| Hediyelik & Parti | Pyrotechnics, pressurized gas, flame/electrical decoration and choking risk | Pyrotechnics excluded for V1 proposal; gas not admitted as normal party product. |

Category presence is never treated as permission to list a regulated product.

## Turkish naming audit

- All L2 display names are customer-facing and readable in Turkish.
- English-derived terms retained in display names (`Fitness`, `Outdoor`, `Trekking`, `Puzzle`, `DJ`) are common Turkish marketplace/search terms and are paired with Turkish scope/synonyms.
- Owner may prefer `Yapboz` over `Puzzle` or `Doğa Sporları` over `Outdoor`; this is naming review, not an architectural blocker.
- Audit normalized short/English boundary labels to exact owner-final L1 names such as `Giyim & Moda`, `Gıda & İçecek`, `Kırtasiye & Ofis`, `Yapı, Hırdavat & Tesisat`, and `Otomotiv & Motosiklet`.
- One wording typo in the Home Appliances open questions was corrected without changing product scope.

Turkish naming readiness: **PASS FOR OWNER REVIEW**.

## Existing canonical L1 conflict audit

All eight proposals were compared with the locked 24-L1 table in `ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md`.

- Existing L1 names/order were not changed.
- Elektronik and Bilgisayar & Tablet owner-final L2 decisions were treated as fixed boundaries.
- Phone-specific accessories, generic charging, camera, wearable and smart-home decisions remain consistent with the final Electronics architecture.
- PC-first peripherals/components remain in Bilgisayar & Tablet.
- Other adjacent final L1 names are referenced exactly after audit normalization.
- No runtime taxonomy JSON or historical full-tree artifact was edited.

Canonical L1 conflict count: **0**.

## Consolidated owner review queue

Architecture decisions with the highest cross-domain impact:

1. Decide default ownership of baby-care bags and instrument-specific bags.
2. Decide whether `Geleneksel Türk Müziği Enstrümanları` remains L2; if yes, approve an exact non-overlapping instrument registry.
3. Decide baby formula ownership and policy between Anne & Bebek and Gıda & İçecek.
4. Decide the exact technical threshold that moves a general bag into Spor & Outdoor.
5. Decide E-bike/e-scooter ownership between Spor & Outdoor and Otomotiv & Motosiklet.
6. Approve exact V1 allow/exclude/legal-review matrices for airsoft, paintball, archery, hunting knives and other weapon-like products.
7. Confirm blanket V1 exclusion for fireworks, sparklers and all pyrotechnics, and exclusion/routing of helium cylinders.
8. Confirm the intrinsic-keepsake test for `Hatıra & Hediyelik Objeler` so “gift” never duplicates ordinary products.
9. Decide appliance/Health thresholds for massage, oral care and therapeutic claims.
10. Decide whether common borrowed terms such as `Puzzle`, `Outdoor` and `Fitness` remain in customer display names.

These decisions do not block document review. They do block safe owner-finalization or runtime assignment for the affected edge cases.

## Final validation summary

- Eight unique proposal documents present: **PASS**
- Each document has all 16 required sections: **PASS**
- Total proposed L2 count 77; exact heading duplicates 0: **PASS**
- Duplicate-family review: **PASS — unresolved edges explicitly owner-gated**
- Contradiction review: **PASS**
- Service leakage: **PASS**
- Facet/category separation: **PASS**
- Policy risk handling: **PASS**
- Turkish naming: **PASS FOR OWNER REVIEW**
- Existing owner-final L1 conflicts: **0 / PASS**
- Owner finalization performed: **NO**
- Runtime/Figma/backend/DB changes: **NONE**

`OVERNIGHT_BATCH_02_ARCHITECTURE: PASS`

`SHOES_READY_FOR_OWNER_REVIEW: YES`

`BAGS_ACCESSORIES_READY_FOR_OWNER_REVIEW: YES`

`HOME_APPLIANCES_READY_FOR_OWNER_REVIEW: YES`

`MOTHER_BABY_READY_FOR_OWNER_REVIEW: YES`

`TOYS_HOBBY_READY_FOR_OWNER_REVIEW: YES`

`MUSIC_INSTRUMENTS_READY_FOR_OWNER_REVIEW: YES`

`SPORTS_OUTDOOR_READY_FOR_OWNER_REVIEW: YES`

`GIFTS_PARTY_READY_FOR_OWNER_REVIEW: YES`

`CROSS_DOMAIN_AUDIT: PASS`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`

`INTEGRATION_REQUIRED: YES`
