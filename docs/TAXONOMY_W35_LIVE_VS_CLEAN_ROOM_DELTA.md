# Wave 35A-R — Live Development vs Wave 35B Clean-Room Delta

**Live evidence:** `EsnaftaVar Development / tnipyxnvhgelwdpykyez`, read-only,
2026-08-29

**Clean-room source:**
`origin/agent2/w35-taxonomy-local-clean-room-rehearsal@aef1639eb7fc3ce9bebd7cc57695c2f2cbf35566`

**State:** `PASS — REPRESENTATIVE MODEL MATCHES LIVE STRUCTURE`

The source branch was read with `git show`; it was not merged. No local harness
or remote migration was rerun by this task.

## Reconciliation matrix

| Area | Wave 35B assumption/evidence | Live Development evidence | Classification | Consequence |
|---|---|---|---|---|
| Active migration chain | Canonical `0001`–`0009` replays to 23 public tables | 9 ledger entries by canonical name; 23 public tables | MATCH | Current schema base is representative. |
| Category shape | UUID PK, nullable self-parent `SET NULL`, active/order/timestamps | Exact columns and constraints present | MATCH | Additive category draft targets the correct table shape. |
| Product category FK | Nullable `products.category_id`, `SET NULL` | Exact FK present | MATCH | Product identity can survive reassignment. |
| Listing ownership | Listing references product; no category FK | `shop_products.product_id`; no direct category reference | MATCH | Listing impact remains transitive through product. |
| Customer/history dependencies | Review, wishlist, cart listing and verified item keep product/listing identity | All expected tables/FKs and durable `product_id` fields exist | MATCH | Reassignment must preserve product/listing IDs as rehearsed. |
| Existing taxonomy extensions | Future fields/tables absent before additive migration | Level/lifecycle/assignability/version/alias/lineage objects absent | MATCH | Draft is additive, not a replacement. |
| Alias model | `RESOLVED/AMBIGUOUS/TOMBSTONE/UNRESOLVED`; zero/one/many edges | No live alias schema yet | MATCH | Hardened design remains required; no conflicting live object. |
| Split safety | No arbitrary first-child mapping; ambiguous products quarantine | No live categories/products; 210/210 split locators unused | MATCH | Current-data mapping queue is empty; invariant still applies to imports. |
| RLS baseline | Canonical migrations replay; staged/admin tables denied in rehearsal | 23/23 public tables RLS; 52 policies | MATCH | Existing security base is present; future taxonomy grants still need implementation. |
| Storage/Realtime baseline | Canonical migration validator expects 3 buckets and two publication tables | 3 buckets/0 objects; `chat_messages`, `notifications` | MATCH | No hidden taxonomy media/data workload. |
| Data volume | Synthetic 11 categories, 13 products/listings for action coverage | Live categories/products/listings all 0 | BENIGN_DELTA | Synthetic workload is intentionally stricter than current empty data. |
| Database engine | PGlite PostgreSQL 18.3 plus SQLite cross-check | Managed PostgreSQL 17.6 | BENIGN_DELTA | Syntax/behavior must still be replayed against PostgreSQL 17-compatible local tooling before apply. |
| Platform object | Harness models application chain | Live also has platform `public.rls_auto_enable()` | BENIGN_DELTA | Exclude platform object from application migration ownership. |
| Ledger version stamps | Current migration filenames | Live `0001`–`0008` version stamps differ while names/outcomes match | BENIGN_DELTA | Preserve explicit ledger-to-file mapping; do not rewrite history. |
| Native rollback point | Local forward/rollback and 10/10 injection tests pass | Free plan has no backup, PITR or restore-to-new-project point | MIGRATION_BLOCKER | Requires supported backup or explicit empty-environment recreation decision. |
| Managed query plans/locks | Local query sanity only | Not measured remotely by this read-only task | UNKNOWN | Measure only in a separately authorized Development rehearsal. |
| Manual logical restore | Not part of local taxonomy harness | No dump/restore executed; restorability unproven | UNKNOWN | Must be proven or explicitly replaced by approved recreation strategy. |

## Totals

- `MATCH`: 10
- `BENIGN_DELTA`: 4
- `REHEARSAL_UPDATE_REQUIRED`: 0
- `MIGRATION_BLOCKER`: 1
- `UNKNOWN`: 2

The Wave 35B forward, rollback, idempotency, failure-injection and fail-closed
semantics remain representative. No schema-model correction is required before
the next local implementation rehearsal. Remote apply remains blocked by backup/
rollback authority and the still-future executable migration/import artifacts.

`CLEAN_ROOM_LIVE_PARITY: PASS`

`LOCAL_REHEARSAL_UPDATE_REQUIRED: NO`

`REMOTE_APPLY_AUTHORIZED: NO`
