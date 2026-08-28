# EsnaftaVar Analytics Root Fix Opportunities

**State:** `RECOMMENDED IMPLEMENTATION BACKLOG — NO RUNTIME AUTHORIZATION`

| Priority | Root fix | Prevents |
|---|---|---|
| P0 | Server-authoritative outcome + durable idempotency/outbox boundary | Missing/duplicate purchase, ledger and audit facts |
| P0 | Strict environment/test/demo source classification | Production KPI contamination |
| P0 | Event field allowlist and pre-transport secret/PII redaction | Privacy/security leakage |
| P0 | Immutable event/metric registries with authority and versions | Silent semantic/authority drift |
| P0 | Source-to-projection reconciliation for QR/review/ledger/audit | Hidden authoritative inconsistency |
| P1 | Catalog/taxonomy/sector lineage service and event-time/current modes | Merge/split/history corruption |
| P1 | Consumer idempotency, revision ordering and bounded replay tooling | Duplicate/out-of-order inflation |
| P1 | Privacy purpose/consent/retention/access decision package | Unlawful or unnecessary analytics |
| P1 | Metric definition fixtures and generated event→metric mapping checks | Denominator/filter/version errors |
| P1 | Invalid/bot filter with reason/rule version and restatement | Soft metric pollution |
| P1 | Release/environment/correlation dimensions across health signals | Slow incident diagnosis |
| P1 | Pilot critical-journey health, alerts and runbooks | Startup/auth/QR outage blind spots |
| P2 | Daily aggregate layer with freshness/late correction | Expensive raw scans and stale dashboards |
| P2 | Minimum cohort and export controls | Merchant/customer re-identification |
| P2 | Producer-consumer usage audit/deprecation workflow | Event spam and long-term cost |

The recommended sequence is governance/privacy decisions → protected authoritative
paths → minimum pilot health → bounded product analytics → ads/reward/reputation
only after their owner contracts. Tool/vendor selection follows requirements.

`ROOT_FIXES_IMPLEMENTED: NO`
