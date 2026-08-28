# Operational Retention Options

**State:** OPTIONS — NO FINAL PERIOD OR LEGAL DETERMINATION

## Data classes

| Class | Retention driver | Proposed posture |
|---|---|---|
| Support case metadata | service continuity, appeal, defect trend | bounded short/medium window |
| Moderation/verification decision | policy consistency, appeal, enforcement history | decision lifecycle + defined review window |
| Merchant documents | verification validity and legal need | minimize fields; delete/redact after purpose unless required |
| Catalog provenance/merge/split | durable identity/history | long-lived immutable reference, minimal PII |
| QR/verified purchase evidence | review/reputation/history integrity | durable domain rule; privacy/legal review |
| Security/privacy incident | investigation, obligations, recurrence | protected schedule/legal hold |
| Audit of privileged action | accountability and reversal | risk-tier duration; tamper-resistant |
| Raw application logs/traces | diagnosis/security | short default, sampled/aggregated longer |
| Derived aggregate metrics | trend without identity | longer if re-identification risk controlled |
| Attachments/media evidence | case need/appeal | shortest necessary; safe deletion |
| Export files | delivery only | very short with access/expiry |

## Options

- fixed schedule by data class;
- lifecycle/event-based expiry;
- risk-tier schedule;
- legal hold that pauses disposal for exact scope;
- anonymized aggregate after raw expiry;
- periodic deletion/restriction with verification report.

Recommended: hybrid class + lifecycle + legal-hold model. Do not select exact periods here.

## Rules

Retention is not “keep forever just in case.” Deletion is not merely hiding UI. Backups, indexes, exports, vendors, and derived datasets need documented handling. Holds are scoped, approved, expiring/reviewed, and audited. Policy version and reason accompany every retention decision.

`RETENTION_PERIODS_FINALIZED: NO`

`INDEFINITE_RAW_PII_DEFAULT: NO`
