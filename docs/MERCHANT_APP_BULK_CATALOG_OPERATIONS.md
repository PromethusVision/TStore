# Merchant App Bulk Catalog Operations

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP21

## V1 recommendation

Include only low-risk, reversible bulk availability changes for explicitly selected listings in one shop. Defer bulk price, delete/retire and cross-branch synchronization.

## Required workflow

1. Filter/search listings.
2. Explicit selection; no hidden “all matching” default.
3. Show shop, operation and exact affected count.
4. Preflight per-row authorization, policy and revision.
5. Fail with per-row outcome; define atomicity before implementation.
6. Audit batch ID and each affected listing.

## Risk comparison

| Operation | Recommendation | Risk |
|---|---|---|
| Mark selected out of stock | SHOULD_HAVE | Low/reversible |
| Mark selected in stock | SHOULD_HAVE with freshness warning | Could assert unavailable items |
| Change many prices | DEFER | High financial/trust blast radius |
| Retire/delete many listings | DEFER | Discovery loss and linked-data risk |
| Copy listings to branches | DEFER/owner decision | Duplicate and wrong-price risk |

## Open decisions

- Batch atomicity: all-or-nothing vs per-row partial result (`CAT-BULK-01 P1`). Recommendation: explicit per-row result with no hidden success, except integrity-critical operations.
