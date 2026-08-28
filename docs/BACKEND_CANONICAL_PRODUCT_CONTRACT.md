# Backend Canonical Product Contract

**State:** PROPOSED FROM CATALOG FOUNDATION — NO RUNTIME

Canonical product is the platform-governed shared identity for what the customer
recognizes across shops. It owns stable ID, canonical naming, brand/manufacturer
facts where applicable, taxonomy assignment, policy/provenance state and shared
media. It does not own merchant price, availability, shop SKU or local offer text.

Current `products` remains the compatibility entity. Existing product IDs and
customer reads must be preserved. Compatibility price/stock fields cannot be
removed or redefined until a separate migration proves all callers use listing
truth.

## Invariants

- canonical activation requires evidence and governed status;
- candidate or merchant text is not automatically canonical;
- mutable name/slug/category path is not identity;
- merge/split/retire preserves predecessor history;
- verified purchase and review reference durable product identity;
- Ads, rewards and analytics may reference but cannot create product truth.

**Recommendation:** extend `products` additively with provenance/revision/lineage
when needed. Exact governance workflow remains `OWNER_DECISION_REQUIRED`.
