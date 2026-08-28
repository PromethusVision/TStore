# Backend Current-to-Future Migration Map

**State:** CONCEPTUAL ROADMAP — NO EXECUTABLE MIGRATION

| Current | Future concept | Safe bridge | Retirement gate |
|---|---|---|---|
| `profiles.role`, `shops.owner_user_id` | organization + membership + capability | add org/membership; deterministic owner memberships; dual-read server facade | all merchant callers and ambiguous/null owners resolved |
| `shops` | physical shop/branch | preserve shop ID; attach organization | no retirement expected |
| `products` | canonical product | additive revision/provenance/lineage | compatibility columns only after caller audit |
| no variant | product variant | nullable variant identity; evidence-based mapping | no forced backfill |
| `shop_products` | shop listing | preserve ID; add variant/revision/freshness/SKU | old uniqueness changed only after data proof |
| product price/stock compatibility | listing price/availability authority | shadow comparison and explicit caller cutover | zero old reads/writes and reconciled data |
| QR tables/RPCs | hardened idempotent merchant membership flow | extend signatures compatibly; exact shop bridge | physical two-device and old-client gate |
| verified transaction items | richer immutable purchase snapshot | additive fields/backfill only from evidence | never delete historical source |
| reviews RPCs | revision/idempotency/lineage aware | additive RPC version/optional fields | all app versions migrated |
| direct chat parties | shop/member conversation context | nullable context and scoped projection | only if Merchant App requires it |
| notifications | multi-channel intent/delivery | keep in-app row; add optional delivery state | push not prerequisite |
| no ads/reward/reputation/ops/events | independent future domains | new isolated concepts after owner gates | none now |

Each row requires a per-wave migration owner, read/write compatibility test,
backfill counts, reconciliation and rollback/forward-fix plan.

