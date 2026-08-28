# EsnaftaVar Esenler Pilot — Monitoring Model

**State:** `LOW-COST/FREE-FIRST REQUIREMENTS — NO TOOL INSTALLED`

## Separation

Operational health, security/audit and business learning are different views.
Development, demo/test and Production must never mix by default. Every useful
signal carries environment and release/artifact identity where appropriate.

## Minimum pilot views

| View | Signals | Action owner |
|---|---|---|
| App health | startup/config, crash/nonfatal, auth/session, search/RPC/storage/realtime failures | Release/incident lead |
| Customer journey | qualified discovery failure, empty/stale supply, directions handoff, protected-action failure | Product/operations |
| Merchant journey | auth/capability, listing write/freshness, candidate queue, verifier path | Merchant operations |
| QR integrity | issued/attempted/expired/rejected/confirmed/replay/server error and reconciliation | QR/incident owner |
| Data quality | duplicate, invalid, late, missing, environment contamination, stale listings | Data/operations |
| Support | intake, severity, open age, reopen, handoff, unowned P0/P1 | Pilot lead |
| Release | exact artifact adoption, new error signatures, rollback/pause state | Release owner |

## Tooling principle

Begin with existing provider/runtime logs, privacy-safe structured events, one
privacy-reviewed crash/error tool if approved, and a small actionable dashboard.
Do not buy enterprise APM/SIEM/ticketing before a real requirement, retention/export
need and vendor privacy/cost review.

## Cadence

- launch window: live observation and named P0/P1 owner;
- daily: health, QR reconciliation, listing freshness and queue review;
- weekly: KPI/data quality, source cohorts, false positives and support burden;
- release change: before/after exact-artifact comparison;
- incident: event-driven containment and post-incident learning.

Do not set arbitrary alert thresholds before baseline; do define zero-tolerance
invariants such as cross-shop authority and duplicate durable QR facts.

`PILOT_MONITORING_IMPLEMENTED: NO`
