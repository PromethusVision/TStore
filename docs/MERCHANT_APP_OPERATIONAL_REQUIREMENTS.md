# Merchant App Operational Requirements

Status: **PROPOSED — OWNER/OPERATIONS REVIEW REQUIRED**
Wave: 17 / WP89

## Required ownership

| Function | Responsibility |
|---|---|
| Merchant verification | Validate application/evidence and revoke/suspend safely |
| Catalog moderation | Candidate, duplicate, merge/split and policy review |
| Policy/legal | Launch allowlist, regulated evidence, retention, appeal |
| Merchant support | Onboarding, access, catalog/QR result and device support |
| Security/abuse | Account takeover, QR fraud, listing/review abuse and incident response |
| Data/privacy | Analytics definitions, minimization, access and deletion/retention |
| Release | Environment config, signing, physical acceptance, rollback |

## Runbooks needed

- Lost/compromised merchant device and staff revoke.
- Wrong/unknown QR result reconciliation without manual evidence forgery.
- Shop suspension/appeal and customer projection.
- Catalog candidate backlog, identifier conflict and policy block.
- Price/listing incident and revision audit.
- Notification delivery failure and critical in-app action fallback.

## Blockers

Unowned moderation queue, undefined regulated allowlist, absent merchant verification/support capacity, or non-atomic QR backend prevents pilot launch regardless of UI completeness.
