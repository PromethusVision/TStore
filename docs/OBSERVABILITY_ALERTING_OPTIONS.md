# EsnaftaVar Observability Alerting Options

**State:** `OPTIONS — EXACT THRESHOLDS REQUIRE BASELINE`

| Class | Candidate use | Response |
|---|---|---|
| P0/PAGE | Data/security integrity or broad critical-flow outage | Immediate operator incident |
| P1/URGENT | Sustained major failure/degradation | Prompt staffed response |
| P2/QUEUE | Bounded quality/regression needing investigation | Work queue/business hours |
| Dashboard only | Trend/capacity/product context | Periodic review |

Immediate invariant examples need no traffic baseline: duplicate verified purchase,
cross-environment ingestion, secret detection, cross-shop authorization breach and
ledger imbalance. Rate/latency thresholds use burn/trend over multiple windows,
minimum volume and recent baseline; arbitrary percentages are not selected.

Every alert names owner, service, environment, release, signal/formula, runbook,
dedup/silence policy and recovery criteria. Alerts contain no sensitive payloads.

`ALERT_THRESHOLDS_FINALIZED: NO`
