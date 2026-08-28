# Merchant App Notification Priority Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP50

| Priority | Meaning | UX expectation | Example |
|---|---|---|---|
| P0_CRITICAL | Security/policy action needed now | Persistent, clear action, no silent bundling | Shop suspended, account compromise signal |
| P1_ACTION_REQUIRED | Operation blocked or correction needed | Inbox top, actionable deep link | Candidate correction, unresolved QR outcome |
| P2_OPERATIONAL | Completed/relevant operation | Normal inbox, deduplicated | QR verified, review report result |
| P3_INFORMATIONAL | Insight or periodic summary | Bundled/optional | Weekly metric summary |

## Rules

- Business priority is not push delivery urgency by itself.
- Same root event across channels shares one event identity.
- Merchant can mark read but cannot dismiss authoritative unresolved state.
- Shop context is explicit; cross-shop content is hidden from unauthorized users.
- Future ads cannot displace security/policy notifications.

Owner decisions: external channel matrix, quiet hours, mandatory security notifications and retention.
