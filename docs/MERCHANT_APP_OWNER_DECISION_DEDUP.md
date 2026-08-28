# Merchant App Owner Decision Deduplication

Status: **PROPOSED — NO OWNER SELECTION**
Wave: 17 / WP91

The 42 raw questions reduce to 18 root decisions: P0 = 9, P1 = 7, P2 = 2.

| Root | Priority | Theme | Raw count | Resolves |
|---|---|---|---:|---|
| RD-01 | P0 | Merchant/catalog policy and verification gate | 3 | ID-01, ID-02, CAT-10 |
| RD-02 | P0 | Organization/shop/branch topology | 3 | ID-03, ID-04, ID-05 |
| RD-03 | P0 | Staff and permission launch model | 3 | ID-06, ID-07, ID-08 |
| RD-04 | P0 | Canonical product/variant/listing identity roots | 10 | CAT-01–06, 11, 12, 15, 16 |
| RD-05 | P0 | Candidate/custom activation | 2 | CAT-07, CAT-08 |
| RD-06 | P0 | QR expiry/consume/session/shop-lifecycle semantics | 4 | QR-01–04 |
| RD-07 | P0 | Variable-measure verified snapshot | 1 | CAT-09 |
| RD-08 | P0 | Service/mixed/booking boundary | 1 | SVC-01 |
| RD-09 | P0 | Analytics launch/privacy scope | 3 | AN-01–03 |
| RD-10 | P1 | Review interaction/moderation | 2 | REV-01, REV-02 |
| RD-11 | P1 | Availability freshness | 1 | AV-01 |
| RD-12 | P1 | Bulk operation scope | 1 | BULK-01 |
| RD-13 | P1 | Listing media rights/promotion | 2 | CAT-13, MEDIA-01 |
| RD-14 | P1 | Notification channels/mandates | 1 | NOTIF-01 |
| RD-15 | P1 | Client architecture and sharing | 2 | ARCH-01, ARCH-02 |
| RD-16 | P1 | Price history | 1 | CAT-14 |
| RD-17 | P2 | V1 navigation/dashboard composition | 1 | UX-01 |
| RD-18 | P2 | Future-engine Merchant surfaces | 1 | FUT-01 |

## Dedup rule

A root may be decided in stages, but child questions cannot receive conflicting selections. Catalog source decisions remain open even when this Merchant App architecture recommends a safe default.
