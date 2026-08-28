# Merchant App Metric Registry

Status: **PROPOSED — DEFINITIONS REQUIRE OWNER REVIEW**
Wave: 17 / WP39

| ID | Metric | Unit | Source/evidence | V1 |
|---|---|---|---|---|
| M-01 | Verified physical purchases | Count | Successful server-authoritative QR transaction | MUST |
| M-02 | Verified purchase items | Count | Immutable verified transaction items | SHOULD |
| M-03 | Shop views | Deduplicated event count | Customer shop detail telemetry | SHOULD |
| M-04 | Product views | Deduplicated event count | Customer product detail telemetry | SHOULD |
| M-05 | Direction intents | Count | Customer direction action | SHOULD |
| M-06 | Wishlist signals | Privacy-safe aggregate | Eligible wishlist events | OWNER_DECISION |
| M-07 | Active listings | Current count | Eligible shop listings | MUST |
| M-08 | Unavailable listings | Current count | Listing state | MUST |
| M-09 | Stale availability | Current count | Freshness rule | OWNER_DECISION |
| M-10 | Review count | Current/evidence-based count | Eligible customer reviews | SHOULD |
| M-11 | Rating aggregate | Aggregate | Canonical eligible rating contract | SHOULD |
| M-12 | QR failure classes | Operational count | QR audit result classes | OWNER/SECURITY only |

## Exclusions

- Revenue, profit, conversion, unique customer and retention are not claimed without complete evidence and privacy definitions.
- Customer intent does not equal purchase.
- Repeat purchase count does not create repeat review entitlement.
