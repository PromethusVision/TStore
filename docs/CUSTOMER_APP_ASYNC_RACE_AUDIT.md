# Customer App Async Race Audit

Status: PASS WITH LEGACY/LOW-RISK DEBT

## Protected critical paths

- Auth submit methods reject a second request while loading/recovery verification is active.
- Root Auth session handling uses customer identity and clears old customer state before new loads.
- Search increments request IDs on query/reset; late queries and price enrichments cannot overwrite current results.
- Nearby coalesces location/shop requests and ignores late superseded/disposed results.
- Cart V2 uses data generation and exclusive mutation locks; QR Cubits lock create/confirm/status transitions.
- Wishlist generation invalidates former-user load/add/remove completions; widgets suppress duplicate actions.
- Reviews prevent parallel submit/load-more and invalidate stale refreshes.
- Notifications combine request generation and realtime revision maps.
- Chat merges/deduplicates realtime and paginated messages and cancels subscriptions on close.
- Async navigation call sites with delayed work generally check `mounted` and/or per-entity opening locks.

## Findings

- The unreachable legacy postal `AddressesCubit` uses fire-and-forget refreshes without generation/close guards. Because no active route imports it, this is `DEAD_CODE/FUNCTIONAL_DEBT`, not a current customer blocker. Reviving it requires lifecycle remediation first.
- Several large views manage local operation flags. Existing double-tap/stale-response tests provide evidence, but future refactors should centralize these contracts rather than remove them casually.

No active deterministic emit-after-close, double-write, or late-response overwrite was reproduced. No broad async refactor was justified.

`ASYNC_RACE_AUDIT: PASS`  
`ACTIVE_P0_P1_RACE_FOUND: NO`
