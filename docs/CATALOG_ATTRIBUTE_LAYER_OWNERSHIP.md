# Catalog Attribute Layer Ownership

Status: **OWNER REVIEW DRAFT — PROVISIONAL CONCEPT REGISTRY**
Wave: 16, Work Package 3

This classification consumes the Wave 15 facet/search architecture without
changing it. Every concept has one authoritative layer; other layers may index
or display a projection, not create a competing truth.

## Ownership classes

| Layer | Question answered |
| --- | --- |
| `PRODUCT` | What shared physical product/family is this? |
| `VARIANT` | Which independently selectable form of that product is this? |
| `LISTING` | How does this shop offer it now? |
| `COMPATIBILITY` | What other entity/system does it fit or work with? |
| `POLICY` | May/how may it be shown or sold under legal/product rules? |
| `DERIVED` | What can the system calculate without accepting a new source fact? |

## Concept registry

| Concept | Owner | Notes |
| --- | --- | --- |
| Canonical product ID | PRODUCT | Stable opaque identity. |
| Brand, manufacturer | PRODUCT | Governed entities; brand is not taxonomy. |
| Product family, model name | PRODUCT | Shared model identity. |
| Model/part number | PRODUCT or VARIANT | Variant when code selects a configuration. |
| Canonical title, description | PRODUCT | Governed shared content. |
| Primary taxonomy leaf | PRODUCT | Exactly one assignable leaf. |
| Product type/form factor | PRODUCT | Function-bearing shared fact. |
| Material | PRODUCT or VARIANT | Variant only when independently selected/sold. |
| Colour, pattern | VARIANT | Product-level only if no choice exists. |
| Size, width, fit | VARIANT | Includes apparel/shoe sizing systems. |
| Storage, RAM, capacity | VARIANT | When configuration is independently buyable. |
| Flavour, scent, shade | VARIANT | If independently packaged/sold. |
| Edition, language, format | VARIANT | Often different publication identity/ISBN. |
| Net content, retail pack | VARIANT or PRODUCT | Identity-bearing sellable pack; not listing quantity. |
| GTIN/EAN/UPC/ISBN | VARIANT or PRODUCT | Identifier assertion with provenance; usually sellable unit. |
| Manufacturer identifier | PRODUCT or VARIANT | MPN/model number, not merchant-controlled. |
| Merchant listing ID | LISTING | One shop's offer identity. |
| Merchant SKU/barcode | LISTING | Unique only in merchant namespace. |
| Price/campaign/previous price | LISTING | Timestamped merchant fact. |
| Stock quantity/state | LISTING | Canonical product has no stock. |
| Availability and shop relation | LISTING | Shop-specific lifecycle. |
| Shop description/title/photos | LISTING | Supplemental; cannot overwrite canonical identity. |
| Sell unit/minimum/increment | LISTING | Piece, kg, metre and merchant increments. |
| Lot, batch, expiry, freshness | LISTING | Inventory/batch sub-layer; never product identity. |
| Condition | LISTING | New/display/refurbished, policy-controlled where needed. |
| Vehicle/device/model fitment | COMPATIBILITY | Structured relation, not title stuffing. |
| Protocol/connector support | COMPATIBILITY or PRODUCT | Product fact when intrinsic; relation when target-specific. |
| Age restriction | POLICY | Permission gate, not category identity. |
| Regulated/legal status | POLICY | Authoritative evidence required; fail closed. |
| Excluded product class | POLICY | Product may retain history but not be assignable/sellable. |
| Dietary/allergen claim | POLICY or PRODUCT | Evidence-bearing fact; claim use can be policy-gated. |
| Rating/review count | DERIVED | Only eligible verified review aggregate. |
| Unit price | DERIVED | Listing price divided by declared comparable measure. |
| Discount percentage | DERIVED | Derived from valid timestamped price history. |
| Nearby seller count/min price | DERIVED | Query-time listing aggregate. |
| Search-normalized title | DERIVED | Deterministic index projection. |

## Ambiguity rule

When a concept could occupy two layers, decide by authority and change cadence:
shared manufacturer fact goes to product/variant; merchant-controllable and
time-varying fact goes to listing; relationship goes to compatibility; permission
goes to policy; reproducible calculation goes to derived. Unknown ownership is a
review finding, not permission to copy the field into every layer.

## Exhaustive Wave 15 provisional concept mapping

The following registry maps all **88** concepts from the read-only Wave 15
`TAXONOMY_PROVISIONAL_ATTRIBUTE_DICTIONARY.csv` source. `OWNER` is the default
source-of-truth layer for catalog design, not a runtime table decision. A future
owner-approved domain profile may declare a different product-versus-variant source
for an exceptional leaf, but one active profile can never give two mutable layers
authority over the same value.

### Global shared — 18

| Concept ID | Technical key | OWNER | Boundary note |
| --- | --- | --- | --- |
| FACET-G-001 | `brand` | PRODUCT | Governed shared entity; never taxonomy. |
| FACET-G-002 | `manufacturer` | PRODUCT | Responsible-party fact, separate from brand. |
| FACET-G-003 | `model_designation` | PRODUCT | Shared model/family designation. |
| FACET-G-004 | `color_family` | VARIANT | Choice-bearing colour on explicit/default variant. |
| FACET-G-005 | `material` | VARIANT | Variant authority avoids duplicate product/listing sources. |
| FACET-G-006 | `style` | PRODUCT | Shared descriptive facet, not a merchant offer. |
| FACET-G-007 | `pattern` | VARIANT | Variant when supplied item differs; controlled profile. |
| FACET-G-008 | `condition` | LISTING | Merchant's offered unit state. |
| FACET-G-009 | `country_region_of_origin` | PRODUCT | Shared evidence-bearing origin claim. |
| FACET-G-010 | `audience_presentation` | PRODUCT | Shared presentation facet; not product identity by itself. |
| FACET-G-011 | `age_or_life_stage` | PRODUCT | Shared target facet; separate from age policy. |
| FACET-G-012 | `package_count` | VARIANT | Fixed sellable pack identity, not cart quantity. |
| FACET-G-013 | `bundle_state` | PRODUCT | Composition type on bundle/product identity. |
| FACET-G-014 | `physical_form` | PRODUCT | Shared form/function fact. |
| FACET-G-015 | `use_environment` | PRODUCT | Shared intended environment facet. |
| FACET-G-016 | `care_instruction` | PRODUCT | Canonical care guidance with provenance. |
| FACET-G-017 | `warranty_type` | PRODUCT | Manufacturer warranty type; shop-specific term stays listing. |
| FACET-G-018 | `personalization_available` | LISTING | Merchant capability/offer, not universal product truth. |

### Domain shared — 30

| Concept ID | Technical key | OWNER | Boundary note |
| --- | --- | --- | --- |
| FACET-D-001 | `size_label` | VARIANT | Exact sellable size system/value. |
| FACET-D-002 | `dimensions` | VARIANT | Explicit/default variant physical dimensions. |
| FACET-D-003 | `net_weight` | VARIANT | Net product/pack measure, never shipping weight. |
| FACET-D-004 | `capacity` | VARIANT | Independently selectable capacity. |
| FACET-D-005 | `liquid_volume` | VARIANT | Sellable pack/variant volume. |
| FACET-D-006 | `diameter` | VARIANT | Choice-bearing dimension under a profile. |
| FACET-D-007 | `length` | VARIANT | Fixed supplied length; cut length remains listing/transaction. |
| FACET-D-008 | `fit` | VARIANT | Fit/width choice, not compatibility result. |
| FACET-D-009 | `material_composition` | PRODUCT | Shared construction/formulation fact. |
| FACET-D-010 | `ingredient_list` | PRODUCT | Shared formula label with source order. |
| FACET-D-011 | `allergen` | POLICY | Evidence-sensitive claim and safety gate. |
| FACET-D-012 | `dietary_property` | POLICY | Claim/certification semantics require evidence. |
| FACET-D-013 | `skin_type` | PRODUCT | Shared suitability facet, not diagnosis. |
| FACET-D-014 | `hair_type` | PRODUCT | Shared suitability facet. |
| FACET-D-015 | `shade_and_finish` | VARIANT | Independently supplied cosmetic/decor choice. |
| FACET-D-016 | `fragrance_family` | VARIANT | Independently supplied scent choice. |
| FACET-D-017 | `rated_power` | PRODUCT | Invariant technical specification. |
| FACET-D-018 | `voltage` | PRODUCT | Invariant technical specification. |
| FACET-D-019 | `current` | PRODUCT | Typed input/output technical fact. |
| FACET-D-020 | `battery_capacity` | PRODUCT | Product technical fact unless a profile explicitly variants it. |
| FACET-D-021 | `connector_type` | PRODUCT | Intrinsic physical interface fact. |
| FACET-D-022 | `wireless_protocol` | PRODUCT | Intrinsic protocol capability. |
| FACET-D-023 | `screen_size` | PRODUCT | Model technical specification. |
| FACET-D-024 | `resolution` | PRODUCT | Context-typed display/camera/print fact. |
| FACET-D-025 | `storage_capacity` | VARIANT | Common buyable configuration dimension. |
| FACET-D-026 | `memory_capacity` | VARIANT | Common buyable configuration dimension. |
| FACET-D-027 | `operating_system` | PRODUCT | Model baseline; version remains structured. |
| FACET-D-028 | `intended_species` | PRODUCT | Shared target-species facet, not pet navigation. |
| FACET-D-029 | `body_area` | PRODUCT | Shared intended-area facet, not medical claim. |
| FACET-D-030 | `precious_material` | POLICY | Material assertion also needs provenance/policy review. |

### Leaf specific — 16

| Concept ID | Technical key | OWNER | Boundary note |
| --- | --- | --- | --- |
| FACET-L-001 | `cpu_family` | PRODUCT | Model baseline. |
| FACET-L-002 | `gpu_family` | PRODUCT | Model/component baseline. |
| FACET-L-003 | `cpu_socket` | PRODUCT | Intrinsic component fact; compatibility consumes it. |
| FACET-L-004 | `memory_standard` | PRODUCT | Intrinsic component specification. |
| FACET-L-005 | `refresh_rate` | PRODUCT | Display technical fact. |
| FACET-L-006 | `print_technology` | PRODUCT | Printer physical technology. |
| FACET-L-007 | `consumable_yield` | PRODUCT | Standard-condition product fact. |
| FACET-L-008 | `lens_mount` | PRODUCT | Intrinsic mount fact; compatibility consumes it. |
| FACET-L-009 | `focal_length` | PRODUCT | Lens technical identity. |
| FACET-L-010 | `tire_size` | VARIANT | Exact independently supplied size. |
| FACET-L-011 | `oil_viscosity` | PRODUCT | Formula/specification fact. |
| FACET-L-012 | `shoe_size_system` | VARIANT | Exact shoe size system/value. |
| FACET-L-013 | `ring_size_system` | VARIANT | Exact ring size system/value. |
| FACET-L-014 | `publication_language` | VARIANT | Edition/language sellable identity. |
| FACET-L-015 | `author_and_publisher` | PRODUCT | Structured publication roles. |
| FACET-L-016 | `instrument_type` | PRODUCT | Product type; future L3 review remains separate. |

### Compatibility — 10

| Concept ID | Technical key | OWNER | Boundary note |
| --- | --- | --- | --- |
| FACET-C-001 | `compatible_device_family` | COMPATIBILITY | Structured target-family relation. |
| FACET-C-002 | `compatible_model` | COMPATIBILITY | Versioned target-model relation. |
| FACET-C-003 | `vehicle_fitment` | COMPATIBILITY | Vehicle/body/engine/year relation. |
| FACET-C-004 | `interface_standard` | COMPATIBILITY | Interoperability relation, separate from connector form. |
| FACET-C-005 | `accessory_system` | COMPATIBILITY | Ecosystem relation, not a brand alias. |
| FACET-C-006 | `battery_platform` | COMPATIBILITY | Platform relation; voltage alone is insufficient. |
| FACET-C-007 | `printer_consumable_fit` | COMPATIBILITY | Consumable-to-printer relation. |
| FACET-C-008 | `appliance_accessory_fit` | COMPATIBILITY | Accessory-to-appliance relation. |
| FACET-C-009 | `mounting_standard` | COMPATIBILITY | Mount relation plus physical constraints. |
| FACET-C-010 | `compatibility_state` | DERIVED | Rules-engine output; no merchant source. |

### Policy metadata — 10

| Concept ID | Technical key | OWNER | Boundary note |
| --- | --- | --- | --- |
| FACET-P-001 | `certification_evidence` | POLICY | Authorized evidence, never automatic listing permission. |
| FACET-P-002 | `safety_class` | POLICY | Evidence-backed safety class. |
| FACET-P-003 | `hazard_classification` | POLICY | Safety/legal classification, not search boost. |
| FACET-P-004 | `medical_intended_use` | POLICY | Authoritative intended use, not merchant prose. |
| FACET-P-005 | `medical_device_class` | POLICY | Legal class with jurisdiction/evidence. |
| FACET-P-006 | `seller_authorization` | POLICY | Derived listing gate still owned by policy. |
| FACET-P-007 | `age_restriction` | POLICY | Permission gate, separate from target age. |
| FACET-P-008 | `claim_evidence_state` | POLICY | Claim review outcome. |
| FACET-P-009 | `traceability_identifier` | POLICY | Controlled traceability evidence with minimization. |
| FACET-P-010 | `installation_requirement` | POLICY | Safety/authorization requirement, not service category. |

### Derived — 4

| Concept ID | Technical key | OWNER | Boundary note |
| --- | --- | --- | --- |
| FACET-R-001 | `normalized_color_family` | DERIVED | Projection from raw/controlled colour. |
| FACET-R-002 | `normalized_size_band` | DERIVED | Projection; original size remains authoritative. |
| FACET-R-003 | `compatibility_confidence` | DERIVED | Rules/evidence confidence, not merchant input. |
| FACET-R-004 | `normalized_unit_display` | DERIVED | Locale display projection; raw numeric value remains. |

Reconciliation: global 18 + domain 30 + leaf 16 + compatibility 10 + policy 10
+ derived 4 = **88 concepts**. Ownership distribution is PRODUCT **39**, VARIANT
**20**, LISTING **2**, COMPATIBILITY **9**, POLICY **13**, DERIVED **5**.
