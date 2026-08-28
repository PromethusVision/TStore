# EsnaftaVar Analytics Catalog Correction Model

**State:** `PROPOSED`

Catalog corrections never rewrite raw historical events.

| Correction | Event-time view | Current harmonized view |
|---|---|---|
| Rename/update | Original revision remains | Same stable ID with current display fields |
| Merge A+B→C | Facts remain on A/B | Each fact rolls once to C through versioned edges |
| Split A→B+C | Facts remain on A | Map only with deterministic event evidence; otherwise predecessor/ambiguous bucket |
| Retire | Historical facts remain | Exclude from active inventory, retain history |
| Wrong listing/product link | Original link retained plus correction fact | Restated projection with correction version |

Every projection publishes catalog mapping version, event-time/current mode,
unmapped/ambiguous count and restatement timestamp. Merge does not duplicate facts;
split does not clone facts. Verified-purchase snapshots remain durable evidence.

Corrections to authoritative purchases/reviews require their own governed source
events; catalog lineage alone cannot change customer rights or ledger outcomes.

`HISTORICAL_CATALOG_REWRITE: FORBIDDEN`

