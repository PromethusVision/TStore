# Gamification Catalog Dependencies

Status: **PROPOSED MAPPING — CATALOG OWNER DECISIONS OPEN**
Wave: 18 / Workstream AR
Catalog source: read-only `origin/agent3/w16-canonical-product-catalog-foundation@b654e680ca72a79c109a098a237b9813b24516cc`

## Stable anchors

Canonical product, optional material variant, shop listing snapshot, verified transaction/item and catalog lineage. Merchant SKU, barcode scan, mutable title and listing price are not badge identity.

## Dependencies

- Product merge/split successor rules and collision handling.
- Variant identity and discontinued/retired lifecycle.
- Bundle/pack/variable-measure snapshot semantics.
- Catalog policy eligibility for reward/challenges.
- Listing retirement/reassignment and merchant/shop continuity.

## Invariants

Rename/taxonomy move does not reset achievement. Merge cannot re-award predecessor evidence. Split never duplicates progress to every child. Listing deletion/price change does not erase earned history. Current catalog cannot rewrite immutable purchase snapshot.
