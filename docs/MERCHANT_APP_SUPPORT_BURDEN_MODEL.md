# Merchant App Support Burden Model

Status: **PROPOSED — OPERATIONS REVIEW REQUIRED**
Wave: 17 / WP112

| Feature | Likely support burden | Reduction |
|---|---|---|
| Auth/device recovery | High | Clear secure recovery, session/device revoke runbook |
| Verification/policy | High | Allowlist, reason classes, evidence checklist, appeal ownership |
| Catalog candidate/duplicate | High | Search-first, strong suggestions, actionable status and SLA |
| QR expiry/wrong-shop/timeout | High | Plain terminal messages, regenerate/reconcile tooling |
| Staff invitation/permissions | Medium-high | Two presets, owner guard, expiry/revoke visibility |
| Price/availability | Medium | Recent items, validation, history, freshness reminders |
| Location/nearby mismatch | Medium | Pin preview, structured correction/review |
| Analytics definitions | Medium | Embedded glossary, freshness, no misleading rate |
| Reviews/reporting | Medium-high | Clear no-delete rule, report reasons and status |
| Multi-branch | High | Defer automation; always show active branch |
| Media | High | Constraints before upload and moderation feedback |
| Ads/rewards | Very high future | Do not expose before engine/billing/policy readiness |

## Support tooling boundary

Support may inspect safe audit/correlation and initiate governed recovery; it cannot forge QR evidence, manually grant reviews, bypass policy or edit immutable transactions. Every privileged action is scoped and audited.
