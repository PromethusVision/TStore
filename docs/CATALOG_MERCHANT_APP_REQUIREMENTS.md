# Merchant App Catalog Requirements

Status: **OWNER REVIEW DRAFT — NO SCREEN IMPLEMENTATION**
Wave: 16, Work Package 42

## Functional requirements

| ID | Requirement | Acceptance boundary |
| --- | --- | --- |
| MCA-01 | Search existing product by name, model, identifier and shop history | Results grouped by product with explainable match facts. |
| MCA-02 | Select canonical product and exact variant | No canonical field is copied into a merchant-owned duplicate. |
| MCA-03 | Attach own shop listing | Shop, product/variant, price, availability/stock state and timestamp required. |
| MCA-04 | Set merchant SKU/local barcode | Identifier is merchant-namespaced and cannot trigger global merge by itself. |
| MCA-05 | Propose missing variant | Only identity dimensions/evidence captured; sibling dedup runs first. |
| MCA-06 | Propose missing product | Minimal physical identity, pack/measure, optional maker/barcode and source captured. |
| MCA-07 | Support custom/unbranded products | No brand/GTIN requirement; explicit maker/unbranded state. |
| MCA-08 | Support variable measure | Sell unit, minimum, increment and unit price semantics captured. |
| MCA-09 | Manage price and availability | Listing-only edits with observed time; unknown stock differs from zero. |
| MCA-10 | Add shop-specific photos/description | Supplemental and attributed; cannot overwrite canonical media/identity. |
| MCA-11 | Resolve duplicate suggestions | Merchant can compare facts, select existing or submit evidence for review. |
| MCA-12 | View candidate/review state | Draft, needs-review, approved/reused, rejected-with-reason; no silent disappearance. |
| MCA-13 | Retire/reactivate listing | Shared product/variant unaffected; history and verified purchases preserved. |
| MCA-14 | Policy-safe submission | Sensitive/ambiguous candidates fail closed; merchant cannot self-approve. |

## Non-functional requirements

- Autosave/idempotency prevents double candidate/listing creation.
- Concurrency uses entity revision and produces a resolvable conflict, not last-write
  loss.
- Suggestions explain identifier/model/pack differences in plain language.
- Catalog operations record actor, provenance, before/after and decision reason.
- Bulk import follows identical dedup/policy gates and is not a shortcut around them.
- Merchant sees only necessary governance information; other merchants' private SKUs,
  inventory quantities or operational provenance are not exposed.

Screen layout, navigation, scanner, inventory, promotion, payment and upload systems
are outside this requirement set.
