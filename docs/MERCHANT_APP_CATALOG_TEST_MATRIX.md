# Merchant App Catalog Test Matrix

Status: **PROPOSED — OWNER DECISIONS OPEN**
Wave: 17 / WP83

| Area | Positive | Negative/adversarial |
|---|---|---|
| Search | Name/synonym/barcode finds right canonical identity | Alias collision, malformed/reused barcode |
| Variant | Select material buyable choice | Missing/discontinued/ambiguous variant |
| Listing | Create/edit one shop offer | Duplicate, wrong shop, protected-field mutation |
| Price | Valid amount/revision/audit | Negative, precision, stale revision, timeout retry |
| Availability | All semantic states/freshness | Unknown shown as stock, upstream block bypass |
| Candidate | Idempotent submit/status/correction | Duplicate spam, policy block, bulk bypass |
| Custom | Unbranded/handmade without fake barcode | Existing canonical lookalike, service-as-product |
| Variable measure | Unit/minimum/increment/actual snapshot | Unit mismatch, invalid precision, review multiplication |
| Media | Allowed local media lifecycle | Rights/MIME/size/cross-shop/object path abuse |
| Bulk | Explicit selection/per-row result | Hidden select-all, cross-shop, partial ambiguity |
| Lifecycle | Product/variant/listing/shop combination | Retired/policy-blocked state override |
| Concurrency | Revision conflict and idempotent retry | Two editors, old cache, duplicate request payload |

Tests include other merchant, revoked staff, anon and server-only secret absence.
