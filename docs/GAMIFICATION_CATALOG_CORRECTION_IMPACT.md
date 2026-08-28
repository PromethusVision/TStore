# Gamification Catalog Correction Impact

**State:** PROPOSED CORRECTION CONTRACT — NO RUNTIME

Historical reward/reputation evidence links to immutable verified-purchase item snapshots and stable lineage. Current catalog presentation may change; history must not silently rewrite, duplicate or disappear.

| Catalog change | Reward history | Customer badges | Merchant reputation | Verified-purchase evidence | Analytics |
|---|---|---|---|---|---|
| Product merge | Deduplicate derived canonical identity; no re-earn | Recompute distinct-product/category projections once | Preserve shop/listing facts; no volume duplication | Keep original product snapshot + merge lineage | Backfill versioned aggregates; disclose series break if needed |
| Product split | Do not fan one event into every child | Hold ambiguous explorer credit; deterministic mapping only | No fabricated child accuracy | Keep original identity; add explicit mapping only when provable | Separate mapped/unmapped cohorts |
| Variant correction | Adjust future grouping; no new earn | Recalculate only rule-dependent derived state | Preserve original listing/variant snapshot | Append correction lineage | Version aggregation |
| Listing replacement | New listing identity for future; shop/product lineage preserved | No new badge event | Listing accuracy correction is append-only | Historical listing snapshot unchanged | Link replacement without double count |
| Catalog retire | Economic history remains redeemable under terms | Badge may retain historical evidence unless policy revokes | Do not erase merchant history | Immutable evidence remains | Exclude from active discovery, include historical cohort |

## Failure policy

Unknown/ambiguous mappings are quarantined from new derived credit. Replay is idempotent by source event + rule version. Corrections never create another lifetime review right or alter review text/rating. If policy status changes, apply prospective rules and an explicit linked adjustment rather than category-name inference.
