# Custom, Handmade and Unbranded Product Model

Status: **OWNER REVIEW DRAFT**
Wave: 16, Work Package 23

Canonical identity must work without a brand, model number or global barcode.
Local bakeries, florists, makers, textile sellers, furniture workshops and hardware
shops can still share a repeatable product identity when the supplied physical item
has stable defining facts.

## Identity patterns

| Pattern | Product treatment | Listing treatment |
| --- | --- | --- |
| Repeatable maker product | Canonical product scoped to responsible maker, recipe/design/form and measure | Shop price, availability, lot and local SKU. |
| Common unbranded commodity | Shared canonical identity only when function/material/specification/measure are sufficiently standardized | Each shop's source, grade, price and availability. |
| Configurable made-to-order item | Base product/design plus governed options; material identity changes may create variants/candidates | Quote/price semantics and fulfillment remain listing/future service concerns. |
| One-off unique physical piece | Distinct product identity or merchant-scoped candidate with uniqueness flag | Exact offered object, price and availability. |
| Merchant arrangement/set | Merchant-created bundle/listing with component/composition snapshot | No automatic global promotion. |

## Minimum identity evidence

- clear functional/product-type name;
- responsible maker/merchant when material to repeatability;
- physical form, material/composition and normalized measure;
- stable variant dimensions and customization boundary;
- primary assignable taxonomy leaf;
- source photos/provenance where rights permit;
- explicit `UNBRANDED`, `MAKER_IDENTIFIED` or `BRAND_UNKNOWN` state.

No-barcode status is ordinary, not low quality by itself. Dedup uses maker, recipe or
design, material, measure, form, location-independent naming and provenance. Two
shops' generic titles are not merged merely because both say “el yapımı bileklik” or
“somun ekmek”.

Custom text, engraving, selected fabric or dimensions belong to a controlled option
or transaction snapshot when they do not change the reusable base identity. A fully
unique composition remains its own identity. Which made-to-order configurations are
listable physical products versus future service/booking scope is a P0 owner decision.
