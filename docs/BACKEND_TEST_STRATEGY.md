# Backend Test Strategy

**State:** DESIGN CONTRACT

| Layer | Required evidence | Environment |
|---|---|---|
| static contract | schema/RPC/RLS names, client call sites, no secret/client service-role | repo only |
| SQL/unit | constraints, state transitions, helpers, trigger behavior, explicit errors | disposable local clean-room |
| RLS | anon/customer/merchant/staff/operator allow/deny matrix and user switching | disposable principals |
| RPC | Auth, validation, idempotency, exact transaction result and safe errors | local/authorized Development |
| concurrency | two independent connections, lock/revision races, one-winner invariants | isolated database |
| integration | Customer N/N-1 plus Merchant N against candidate backend | local then Development |
| migration | 0001–current clean apply, upgrade snapshot, backfill, reconciliation, rollback/forward repair | restored/disposable data |
| physical QR | two physical devices, camera, expiry, wrong shop, replay, simultaneous confirmation | authorized Development first |
| Production acceptance | read-only preflight, authorized apply, exact postflight, smoke and monitoring | explicit release window |

## Non-negotiable assertions

- QR/review eligibility is produced only by authoritative database state.
- Direct role/capability, owner ID, aggregate and ledger mutation fails.
- Cross-user/cross-shop reads and writes are denied or hidden as contracted.
- Duplicate delivery/retry produces the same durable result.
- Product corrections preserve historical purchase/review references.
- Old Customer clients continue to read and act correctly during the compatibility
  window.

The committed stress matrices are design coverage, not substitutes for executable
database or physical-device acceptance.
