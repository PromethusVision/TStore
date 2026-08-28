# Current Contract Preservation Audit

**Result:** PASS — ADDITIVE EVOLUTION

| Current contract | Future treatment | Preservation result |
|---|---|---|
| Auth user → profile and legal consent | membership is additive; customer role guard remains | PASS |
| active public categories/products/shops/listings | query/read models retain public semantics | PASS |
| `shop_products` price/availability | remains listing-owned; variants do not absorb merchant truth | PASS |
| Customer addresses/saved locations/wishlist | existing owner RLS/RPCs remain | PASS |
| Cart V2 single-shop | no replacement; Merchant work cannot mutate customer cart | PASS |
| opaque expiring QR | exact-shop capability strengthens verification, token contract remains | PASS |
| one-winner verified purchase | same transaction invariant and durable snapshots | PASS |
| one active review per customer + canonical product | merge/split keeps evidence; repeat/quantity unchanged | PASS |
| shop rating from verified transaction | kept independent from future reputation | PASS |
| direct-party chat and trusted notifications | extend only for operation-critical Merchant flows | PASS |
| canonical Storage paths/policies | preserve buckets/paths; new write authority is separate | PASS |
| managed Realtime publication | no broad automatic publication | PASS |

Rejected replacement patterns: collapsing product/variant/listing, making analytics
the source of business truth, replacing QR with payment, migrating Customer Auth
to client-defined roles, introducing universal variants, or forcing an event
platform before consumers exist.

No A–CA document required correction in this audit.
