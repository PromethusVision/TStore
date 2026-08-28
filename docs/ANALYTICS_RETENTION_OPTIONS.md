# EsnaftaVar Analytics Retention Options

**State:** `OPTIONS — NO LEGAL/POLICY DURATION FINALIZED`

Retention is selected by data class and purpose, not one global period.

| Class | Design posture | Decision factors |
|---|---|---|
| Authoritative domain/ledger | Preserve per business/legal lifecycle with correction lineage | Rights, dispute, accounting/policy |
| Audit/security | Restricted, integrity-protected, potentially longer than product telemetry | Investigation, legal hold, abuse windows |
| Essential operational telemetry | Short raw window; aggregate health longer if non-identifying | Incident diagnosis/release comparison |
| Product analytics | Short raw/pseudonymous window; governed aggregates | Experiment/seasonality vs privacy |
| Ad measurement | Separate window matching approved attribution/contract | Consent, billing, dispute and policy |
| Optional research | Shortest practical, explicit expiry | Study purpose and participant choice |

Candidate patterns are event-based expiry, rolling windows and tiered raw→daily
aggregate→deletion. Exact days/months require Product Owner and privacy/legal input;
this document deliberately does not state durations.

Deletion, account closure, legal hold, backups, exports and downstream copies must
be included in the chosen policy. Retention expiry cannot break idempotency for an
irreversible ledger without an alternative durable key.

`RETENTION_PERIODS_FINALIZED: NO`
