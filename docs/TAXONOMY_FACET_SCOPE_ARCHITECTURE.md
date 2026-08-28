# EsnaftaVar Facet Scope Architecture

**State:** `PROVISIONAL ARCHITECTURE — OWNER REVIEW REQUIRED`  
**Registry:** `TAXONOMY_GLOBAL_FACET_REGISTRY.md` (`88` concept IDs)  
**Runtime/schema:** Not designed or changed

## Purpose

A merchant-facing label, search alias or category-local wording must not create a
new attribute concept. For example, `renk`, `ürün rengi` and `ana renk` resolve to
the one concept `FACET-G-004`; UI labels may differ without fragmenting values,
analytics or search.

## Scope classes

| Class | Count | Meaning | Creation rule | Example |
|---|---:|---|---|---|
| `GLOBAL_SHARED` | 18 | Same semantic value across unrelated domains | Reuse unless units, evidence or cardinality differ semantically | color, material, condition |
| `DOMAIN_SHARED` | 30 | Reused by several related product families | One concept plus leaf applicability/profile rules | voltage, screen size, ingredient |
| `LEAF_SPECIFIC` | 16 | Useful only in a narrow technical/product family | Create only after real typed schema/search need | CPU socket, tire size |
| `COMPATIBILITY` | 10 | Structured relation/input/result, not descriptive text | Versioned entity references and explicit result state | vehicle fitment, compatible model |
| `POLICY_METADATA` | 10 | Evidence, restriction or eligibility context | Policy owner controls; category approval never populates it | certification, hazard class |
| `DERIVED` | 4 | Computed presentation/index value | Not merchant-editable; source provenance retained | normalized color family |

Counts are design inventory counts, not a runtime schema commitment.

## Canonical concept and alias model

Each concept has one immutable conceptual identity and may have three label layers:

1. `canonical_technical_key_proposal`: stable design key used in specifications;
2. `display_label_tr`: merchant/customer label, changeable by governed copy update;
3. `label_aliases`: historical, domain-local and UI wording mapped to the same concept.

| Canonical concept | Accepted label aliases | Must not become separate concepts | Boundary |
|---|---|---|---|
| `FACET-G-004` Renk ailesi | renk, ürün rengi, ana renk | `product_color`, `main_color` duplicates | Shade/finish stays `FACET-D-015`. |
| `FACET-D-001` Beden etiketi | beden, kıyafet bedeni, bebek bedeni | three generic size fields | Shoe/ring systems remain leaf-specific typed concepts. |
| `FACET-D-002` Fiziksel ölçüler | ölçü, ebat, ürün boyutları | string `en x boy x yükseklik` variants | Screen size, tire size and capacity are separate semantics. |
| `FACET-D-004` Kapasite | hacim kapasitesi, depolama kapasitesi label'i only in generic UI | one unitless `capacity` field | Storage and liquid concepts retain distinct unit families. |
| `FACET-D-021` Konnektör tipi | port, fiş, bağlantı ucu | per-domain USB/HDMI/XLR fields | Interface standard relation stays separate. |
| `FACET-C-002` Uyumlu model | uyumlu cihaz, model uyumu | free-text phone/printer/appliance compatibility | Device family and exact model references retain separate granularity. |
| `FACET-P-001` Sertifika kanıtı | uygunluk belgesi, standard kanıtı | boolean `sertifikalı` fields | Evidence issuer/type/expiry are structured. |

Alias matching is case/Unicode/spacing normalized. An alias maps to exactly one
concept only when meaning is invariant; ambiguous wording such as `boyut`, `model`,
`batarya`, `lens` and `kasa` requires domain context and cannot be a global
one-to-one alias.

## Reuse decision tree

1. Is the requested value actually a product type? If yes, send it to taxonomy
   review; do not create a facet.
2. Is it eligibility, warning, evidence or legal state? If yes, use policy metadata.
3. Is it a relationship between products/entities? If yes, use compatibility.
4. Does an existing concept have the same meaning, data type, cardinality and unit
   family? If yes, reuse it and add an alias/profile rule if necessary.
5. Does the difference concern only UI wording or locale? If yes, reuse.
6. Does it carry a genuinely different physical or business meaning? Propose a new
   concept with collision analysis and owner decision; do not silently fork.

## Applicability and requirement levels

Concept reuse does not imply universal requirement. A later typed leaf profile may
set one of:

- `REQUIRED`: product cannot be safely/meaningfully described without it;
- `RECOMMENDED`: materially improves discovery or comparison;
- `OPTIONAL`: useful but not needed for completeness;
- `NOT_APPLICABLE`: hidden and rejected for that leaf;
- `POLICY_CONDITIONAL`: required only when a claim/risk is present.

The requirement level belongs to a versioned profile, not the global facet itself.

## Duplication and conflict controls

- Technical keys are lowercase ASCII `snake_case`; display labels preserve Turkish.
- Unit is metadata, never embedded in key (`weight_kg` is forbidden).
- Brand-, model-, merchant- and campaign-specific facet definitions are forbidden.
- A data-type or unit-family mismatch cannot be resolved by aliasing values.
- A global concept may be narrowed by constraints, but its base meaning cannot be
  changed in one domain.
- Compatibility inputs and policy facts never downgrade into unbounded free text.
- Renaming a display label keeps concept identity and analytics continuity.
- Deprecation maps old concept/value IDs forward; deletion is not assumed.

## Category-confusion gate

Before promoting a facet value into L3/L4, owner review must show all of:

1. it describes a stable product type rather than a characteristic;
2. customers search/browse it as a distinct family;
3. merchant data requirements materially differ;
4. it preserves exactly one primary leaf and avoids cross-domain duplication;
5. facet-only discovery would be insufficient.

`gaming`, `kadın`, `128 GB`, `siyah`, `Bluetooth`, `organik`, `AM5`, `15,6 inç`,
`uyumlu` and `profesyonel` do not pass this gate by themselves.

## Owner-review boundaries

- The six scope classes and aliases are proposed architecture, not owner-final
  runtime entities.
- The 22 proposal-domain structures stay `PROPOSED FOR OWNER REVIEW`.
- Medical, legal, hazardous, age-restricted and seller-authorization rules stay
  fail-closed and require their respective owners.

`FACET_SCOPE_CLASSIFICATION: 88/88`

`DUPLICATE_CONCEPT_CREATION: FORBIDDEN`

`OWNER_FINALIZATION_PERFORMED: NO`
