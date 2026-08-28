# EsnaftaVar Facet Quality & Anti-Pattern Guide

**State:** `PROVISIONAL QUALITY GUIDE`
**Scope:** Design/review examples; no runtime validator

## Core test

- Category: **What is the product?**
- Facet: **What characteristics does it have?**
- Search: **How might the customer say it?**
- Compatibility: **What does it work with?**
- Policy: **Can/how may it be listed?**
- Listing: **How/where does this shop offer it?**

If one field tries to answer more than one question, stop and separate the concepts.

## Anti-patterns

### 1. Category encoded as facet

**Bad:** a global free-text `product_type=telefon kılıfı`, while products sit in a
generic accessory leaf.
**Risk:** category analytics and exactly-one-primary-leaf assignment disappear.
**Good:** assign the owner-final phone-case leaf; use material/color/model fit as facets.

### 2. Facet encoded as category

**Bad:** `Kadın Çanta`, `Siyah Telefon`, `128 GB Telefon`, `Bluetooth Hoparlör`,
`AM5 İşlemci`, `Organik Gıda`.
**Risk:** combinatorial tree, duplicate products, unstable analytics.
**Good:** one product-type leaf plus audience/color/capacity/protocol/socket/claim facets.

### 3. Duplicate facet concepts

**Bad:** `renk`, `ürün rengi`, `ana renk`; `ebat`, `ölçü`, `boyut` as independent
technical keys.
**Risk:** fragmented filters and contradictory product facts.
**Good:** one concept ID, UI/import aliases, separate concepts only for genuinely
different meanings such as screen diagonal vs physical dimensions.

### 4. Free-text abuse

**Bad:** compatibility, certification, ingredients, sizes, voltage or medical
intended use in one notes field.
**Risk:** unfilterable dirty data, unsafe claims and impossible validation.
**Good:** typed values/references/evidence; free text only for bounded safe display notes.

### 5. Unit in field name

**Bad:** `weight_kg`, `screen_inches`, `volume_ml`, then new fields for other units.
**Risk:** duplicate facts and conversion errors.
**Good:** stable concept + numeric value + governed unit family + locale display.

### 6. Brand-specific facet

**Bad:** `brand_x_connector`, `brand_y_phone_model`, or manufacturer name as a
category synonym.
**Risk:** vendor lock-in, endless schema growth, biased search.
**Good:** brand/manufacturer/model references and neutral connector/device relations.

### 7. Model-specific facet definition

**Bad:** one boolean field per phone/printer/vehicle model.
**Risk:** unbounded schema and stale compatibility.
**Good:** product ↔ model/vehicle relation with versioned compatibility evaluation.

### 8. Boolean explosion

**Bad:** `is_black`, `is_blue`, `is_usb_c`, `is_gaming`, `is_organic`.
**Risk:** contradictions, missing-value-as-false and poor evolution.
**Good:** controlled enum/set/reference; claim booleans require evidence and unknown state.

### 9. Attribute overload

**Bad:** ask every merchant all 88 concepts, or create `details` JSON/free text for
anything not understood.
**Risk:** abandonment and fabricated values.
**Good:** leaf/profile applicability, 5–8 ordinary required inputs after canonical
match, progressive optional groups and policy-conditional evidence.

### 10. Locale inconsistency

**Bad:** separate enum values `Siyah`, `siyah`, `Black`; English casing applied to
Turkish `I/İ`.
**Risk:** broken filters and search.
**Good:** Turkish-aware normalization, stable value identity, locale display and aliases.

### 11. Unbounded enum

**Bad:** merchants can add arbitrary colors/materials/species/standards to a
filterable enum.
**Risk:** thousands of near-duplicates and policy leakage.
**Good:** quarantine/review unknown values; preserve source without promoting it.

### 12. Merchant-entered dirty values

**Bad:** `128gb`, `128 GB`, `128 gb` as unrelated strings; comma-separated compatible
models; `yes/no/-` mixed.
**Risk:** false comparisons and false compatibility.
**Good:** unit-aware input, governed references and explicit unknown/not-applicable.

### 13. Search synonym as product fact

**Bad:** query `smartphone` sets OS/device facets, or `ortopedik` sets medical claim.
**Risk:** incorrect facts and policy bypass.
**Good:** synonyms retrieve candidates; only verified source fields populate attributes.

### 14. Compatibility by text/size alone

**Bad:** `18 V` batteries or `15.6-inch` bags are marked universally compatible.
**Risk:** damage, returns and safety failure.
**Good:** structured target/system relations, hard constraints and four-state result.

### 15. Policy as category depth

**Bad:** `Sertifikalı Kask`, `Medikal Onaylı`, `18+ Ürünler` as nodes.
**Risk:** category placement appears to authorize a claim/listing.
**Good:** product-type category plus policy evidence/eligibility metadata.

### 16. Listing facts as facets

**Bad:** price, stock, discount, shop distance and `featured` in global attribute
dictionary.
**Risk:** time-varying shop state contaminates product identity.
**Good:** keep them on shop listing/search ranking layers.

### 17. `Other` catch-all as a permanent model

**Bad:** broad `Diğer`, `Genel`, `Çeşitli` node/enum absorbs unmapped products.
**Risk:** hidden taxonomy gaps and unusable filters.
**Good:** bounded review queue with product examples and explicit owner decision.

### 18. Bundle creates duplicate categories

**Bad:** CPU with included cooler assigned to both CPU and cooler; gift usage moves a
toy into gifts.
**Risk:** multi-primary identity and stock duplication.
**Good:** principal product leaf plus bundle/occasion metadata.

### 19. Derived value becomes merchant source

**Bad:** merchant edits normalized color, compatibility confidence or policy result.
**Risk:** provenance loss and gaming.
**Good:** merchant supplies source fact/evidence; system/reviewer derives status.

### 20. Silent semantic mutation

**Bad:** change an existing numeric facet to free text, change unit family or reuse a
concept ID for a new meaning.
**Risk:** corrupted history, filters, compatibility and analytics.
**Good:** immutable meaning/type; versioned successor/migration and impact review.

## EsnaftaVar review checklist

Before accepting a facet/profile/value change, confirm:

- exactly one primary leaf remains possible;
- an existing concept was not duplicated under new wording;
- concept type/unit/cardinality are explicit;
- category, facet, compatibility, policy and listing layers remain separate;
- value normalization and unknown behavior are defined;
- merchant input burden is scoped by leaf;
- search collision and analytics impact were reviewed;
- no brand/model/value became a schema concept;
- no medical/safety/legal claim gained implicit approval;
- proposal/final owner state is unchanged unless explicitly approved.

## Fast examples

| Bad input/model | Diagnosis | Safe direction |
|---|---|---|
| `gaming_laptop=true` plus Gaming Laptop category | facet/category duplication | Laptop leaf + use-case facet |
| `compatible_models="all phones"` | unbounded compatibility claim | governed model/device relations; unknown until verified |
| `beden="42 / L / büyük"` | mixed systems/free text | declared size system/value/profile |
| `sertifikali=true` | evidence-free boolean | structured certification evidence + review state |
| `shop_type=optik` proves lens eligibility | merchant/product/policy collapse | exact product + authorized seller/policy gate |
| `hediye=true` moves any product to Gifts | occasion-as-category | retain product owner; occasion facet/search |

`FACET_ANTI_PATTERN_COUNT: 20`

`CATEGORY_FACET_COLLAPSE_ALLOWED: NO`

`FREE_TEXT_AS_COMPATIBILITY_OR_POLICY: NO`
