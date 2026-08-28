# Brand / Manufacturer / Model Identity Architecture

Status: **OWNER REVIEW DRAFT**
Wave: 16, Work Package 5

## Concepts

| Concept | Meaning | Identity rule |
| --- | --- | --- |
| Brand | Customer-facing mark under which a product is offered. | Governed entity with aliases; never a category. |
| Manufacturer | Legal/operational producer responsible for making the item. | May produce many brands; may differ from brand owner. |
| Responsible party | Entity accountable for product data/market placement when manufacturer is not visible. | Evidence-bearing relation, especially regulated domains. |
| Product family | Stable grouping of related models/variants. | Discovery grouping, not necessarily a sellable unit. |
| Model | Manufacturer-defined product design identity. | Usually canonical product root. |
| Model number / MPN | Identifier within manufacturer namespace. | Manufacturer + normalized code; not global alone. |
| Variant | Independently selectable configuration of a model. | Size/colour/capacity/formulation/fitment as applicable. |

## Representation rules

- Brand, manufacturer and responsible party are separate relations even when the
  same organization fills all roles.
- Brand names support canonical display, normalized matching and permanent
  aliases. Rename/rebranding does not automatically merge organizations or products.
- Product title may project brand/model, but title text never replaces structured
  identity relations.
- Manufacturer + model number is a strong composite signal. A reused model number
  across manufacturers or generations remains distinct.
- Taxonomy describes what a product is; brand describes who presents it. Brand
  storefronts and filters are projections, not taxonomy branches.

## Special cases

| Case | Treatment |
| --- | --- |
| Private label | Retailer/contract brand is the brand; actual manufacturer may be known, confidential or provenance-only. |
| Unbranded/generic | Explicit `UNBRANDED` state, not a fake brand named “Generic”; identity uses function/form/material/measure and provenance. |
| OEM component | Keep manufacturer and OEM part number; compatibility is a separate relation. |
| Licensed brand | Record displayed licensed brand plus manufacturer/licensee roles; do not conflate entities. |
| Multi-brand manufacturer | One manufacturer relates to multiple distinct governed brands. |
| Handmade/local maker | Maker may be responsible party and optional brand; absence of registered brand is valid. |
| Unknown | Use an explicit unknown state with confidence, not invented data. |

Entity merges and splits require aliases, provenance and audit history. A change in
brand ownership does not rewrite historical product or purchase evidence.
