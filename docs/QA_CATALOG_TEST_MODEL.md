# Canonical Catalog Test Model

**State:** PROPOSED — CATALOG RUNTIME NOT AUTHORIZED

| Concern | Required tests |
|---|---|
| Identity | immutable opaque ID; name/slug/path change does not change identity |
| Variant | owner-approved identity dimensions; no color/size double encoding as product and facet |
| Listing | merchant price/availability/SKU belongs to shop listing, not canonical product |
| Dedup | exact/high/manual signal classes, explainable provenance, no name-only merge |
| Merge | predecessor aliases, listing collision, reviews/purchases/search/analytics preservation |
| Split | deterministic assignment or manual reclassification; no arbitrary child redirect |
| Barcode | normalized format, validated source, conflict/pack/variable-measure handling |
| Custom/unbranded | repeatable versus one-off identity and merchant ownership boundaries |
| Variable measure | base unit, quantity, minimum/increment and price snapshot consistency |
| Lifecycle | draft/active/retired, revision conflict and reversible correction events |

## Test data

Use synthetic brands, identifiers and products. Include near-duplicate Turkish names, package-size variants, same barcode conflict, missing provenance, multiple merchant listings and policy-sensitive candidates. Production catalog rows are never mutated for test.

## Gate

Owner-final identity/variant/barcode/merge-split decisions precede schema tests. Until then, tests may validate proposed invariants but cannot certify runtime readiness.

`CATALOG_TEST_MODEL_READY_FOR_OWNER_REVIEW: YES`

`CATALOG_RUNTIME_READY: NO`
