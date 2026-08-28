# EsnaftaVar Event Failure Registry

**State:** `PROPOSED — SEVERITY/RUNBOOK OWNERS TO BE ASSIGNED`

Severity is impact-based: P0 threatens integrity/security/privacy or broad critical
availability; P1 materially degrades critical journeys; P2 is bounded quality/
operability; P3 is low-impact hygiene.

| ID | Failure | Severity | Detection | Required response |
|---|---|---|---|---|
| EVF-001 | Duplicate verified-purchase outcome | P0 | Semantic-key reconciliation | Stop affected confirmation path; preserve evidence; repair by domain correction |
| EVF-002 | Reward/ad-billing ledger duplicate | P0 | Ledger-source uniqueness | Stop ledger consumer; no analytics-based manual patch |
| EVF-003 | Cross-shop QR authorization succeeds | P0 | QR invariant/security check | Contain, investigate, protect rights/data |
| EVF-004 | Production receives Development/demo/test event | P0 | Environment purity check | Quarantine, stop producer, restate aggregates |
| EVF-005 | Secret/raw token in telemetry | P0 | Field/redaction scan | Stop ingestion/export, rotate if exposed, privacy/security response |
| EVF-006 | Customer PII/private content exposed to merchant | P0 | Access/export tests | Revoke path, preserve audit, privacy response |
| EVF-007 | Authoritative event missing after committed outcome | P0 | Source/outbox reconciliation | Halt dependent projections; recover traceably |
| EVF-008 | Audit event gap or mutable audit history | P0 | Sequence/integrity reconciliation | Restrict operator action and investigate |
| EVF-009 | Unsupported schema accepted as latest | P1 | Consumer version telemetry | Quarantine and roll back/upgrade consumer |
| EVF-010 | Same revision has conflicting payload | P1 | Revision uniqueness | Reject, alert producer/domain owner |
| EVF-011 | Authority downgraded/upgraded silently | P1 | Registry-versus-envelope check | Reject authoritative use; correct producer policy |
| EVF-012 | Replay duplicates review/badge/reputation projection | P1 | Semantic dedup check | Pause consumer and rebuild idempotently |
| EVF-013 | Event-time/current taxonomy mixed | P1 | Projection-version audit | Stop comparison, restate with explicit mode |
| EVF-014 | Ad event treated as causal/billable without contract | P1 | Metric/billing lineage audit | Stop report/billing projection and correct labels |
| EVF-015 | Raw query/precise location retained without approval | P1 | Privacy field/retention scan | Disable producer, delete under policy, review |
| EVF-016 | Delivery backlog exceeds declared freshness | P1 | Recorded→processed lag | Backpressure/scale/repair and disclose staleness |
| EVF-017 | Dead-letter replay bypasses validation | P1 | Replay audit | Stop replay and revalidate batch |
| EVF-018 | Late event not restated in event-time metric | P2 | Window reconciliation | Recompute bounded window |
| EVF-019 | Duplicate transport deliveries spike but dedup holds | P2 | Duplicate delivery rate | Diagnose producer/broker; no business incident |
| EVF-020 | Missing optional correlation | P2 | Coverage scorecard | Improve producer; retain uncorrelated fact |
| EVF-021 | Unknown release/environment bucket grows | P2 | Dimension completeness | Fix release config/instrumentation |
| EVF-022 | Soft event bot filter drifts | P2 | Invalid-traffic trend | Version filter and restate soft metrics |
| EVF-023 | Client clock skew exceeds tolerance | P2 | occurred/recorded delta | Use trusted time and flag quality |
| EVF-024 | Deprecated producer still emits old supported version | P3 | Version adoption report | Schedule migration; do not break valid data |
| EVF-025 | Unused event type remains registered/emitted | P3 | Producer-consumer audit | Deprecate and remove after retention-safe window |

P0/P1 events require named runbook and owner before Production instrumentation.
No response invents or edits authoritative facts outside the owning domain.

`EVENT_FAILURE_REGISTRY_FINALIZED: NO`

