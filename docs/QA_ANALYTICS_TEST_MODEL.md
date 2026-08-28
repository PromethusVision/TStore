# Analytics and Event Test Model

**State:** PROPOSED — ANALYTICS SOURCE AVAILABLE, RUNTIME NOT IMPLEMENTED

## Contract tests

| Concern | Required proof |
|---|---|
| Event authority | client-reported, server-derived, server-authoritative, audit and soft signals never collapse |
| Envelope/version | required IDs/time/environment/release/schema present; unsupported versions quarantine |
| Idempotency | duplicate delivery does not duplicate purchase, reward, billing or projection |
| Ordering | late/out-of-order events resolve by domain rule, not arrival-time guess |
| Metric semantics | numerator, denominator, eligibility window and unknown state match registry |
| Correction | superseding/invalidation restates projection without rewriting raw evidence |
| Privacy | allowlisted fields; no tokens, raw QR, chat/review content or precise unnecessary location |
| Environment | Development/demo/test traffic marked at trusted source and excluded from business metrics |

## Reconciliation

Authoritative ledgers require exact source-to-projection reconciliation. Soft funnels publish missing/duplicate/quarantine/freshness rates and do not claim sales. Test traffic remains observable in a separate health view so synthetic monitoring can be debugged without contaminating commercial dashboards.

## Release dimension

Every accepted event should carry bounded app/service identity, semantic version, immutable build/commit, environment and relevant schema/rule version. Unknown release is explicit, never guessed.

`ANALYTICS_BRANCH_READ: YES`

`ANALYTICS_RUNTIME_TESTED: NO`
