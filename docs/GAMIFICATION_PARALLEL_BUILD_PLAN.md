# Future Parallel Build Plan

**State:** PROPOSED — FUTURE RUNTIME ONLY

## Safe worktree boundaries

| Role | Primary scope | May not own concurrently |
|---|---|---|
| Agent 1 — Reward backend | Event intake adapter, immutable reward ledger, policy evaluation, reconciliation | Customer UI, merchant reputation derivation, shared migrations without coordination |
| Agent 2 — Customer experience | Reward/badge read models, customer UI/state, explainability/accessibility tests | Authoritative earning, privileged ledger writes, merchant reputation |
| Agent 3 — Merchant reputation | Signal registry/derivation, fairness, merchant/customer reputation surfaces | Reward economics, review policy, ads ranking |
| Fraud/Test agent | Idempotency/concurrency, scenario harnesses, authorization/fairness/load/security tests | Product decisions or Production writes |
| Integration/Release | Shared schema/migration sequence, conflict resolution, combined gates, Development then explicit Production release | Inventing owner decisions |

## Shared-file protocol

Freeze event/identity/API contracts before parallel coding. Assign one writer for migration chain, shared models, app bootstrap, navigation and dependency files. Other agents publish integration requirements rather than edit a live shared file. Each task branch commits/pushes only owned scope; integration runs full invariant and scenario suites.

## Cross-agent invariants

Review rights, verified-purchase atomicity, ads separation, policy fail-closed behavior and server authority are test fixtures shared read-only across workstreams.

