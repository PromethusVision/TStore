# Operations Alerting Model

**State:** PROPOSED — NO ALERTING CONFIGURATION

## Alert only when action is needed

| Alert class | Examples | Expected action |
|---|---|---|
| PAGE / P0 | privileged credential exposure, cross-tenant access, destructive writes, broad privacy breach | immediate containment and incident lead |
| URGENT / P1 | sustained Auth/QR/core RPC outage, budget/ledger integrity, high-risk policy item serving | scoped kill switch/triage |
| QUEUE / P2 | rising verification/policy/appeal age, recurrent catalog write failures | assign work within internal target |
| DASHBOARD | traffic volume, ordinary conversion, low-risk trends | periodic review; no interruption |

## Alert contract

Each alert has name, purpose, owner/escalation, source query, denominator, threshold/window hypothesis, dedup/suppression, recovery condition, runbook, environment/release, and safe correlation. No raw PII/secret/content in title or payload.

## Anti-noise rules

Use sustained rates and error budgets where appropriate, group correlated symptoms, suppress downstream duplicates under a known parent incident, distinguish no-data from zero-error, test alert delivery, and review false positives. A dashboard metric does not become an alert because it is interesting.

## Security

Alert destinations and memberships are least-privilege. Links require authenticated consoles. Do not send tokens, customer identity, exact location, merchant documents, message/review content, or detection bypass details through email/chat notification.

## Open decisions

On-call coverage, escalation contacts, exact thresholds/windows, vendor/tool, retention, and non-working-hour posture. These are owner/operations decisions; no 24/7 promise is made.

`ALERT_THRESHOLDS_FINAL: NO`

`VANITY_ALERTS: REJECTED`
