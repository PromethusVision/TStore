# Merchant App Product Filter and Sort Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP54

## V1 filters

- Active shop/branch (global context).
- Listing state: active, unavailable, out of stock, retired.
- Stock knowledge: known in, known out, unknown.
- Catalog status: canonical linked, candidate pending, needs correction, policy blocked.
- Taxonomy category and optional governed brand.
- Listing health: missing/stale price or availability.

## Sorts

- Recently updated.
- Name A–Z.
- Action required first.
- Price only within comparable unit/currency semantics.
- Product views/verified purchase only when metric definition is available and labeled.

## Rules

- Filters are shop-scoped and encoded as safe IDs, not arbitrary query fragments.
- Empty result distinguishes no listings from permission/network/error.
- Facets are attributes, not taxonomy nodes; merchant cannot invent governed values.
- Sponsored/paid ordering is excluded from this operational search.
- Saved filters and organization-wide views are deferred.
