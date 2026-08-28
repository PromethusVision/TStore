# Merchant App Critical Flows

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP67

| ID | Flow | Success gate | Failure gate |
|---|---|---|---|
| CF-01 | Auth and membership resolution | Correct authorized shop context | No role/shop fallback |
| CF-02 | Merchant/shop onboarding | Draft/review/active state explicit | Regulated/unknown fail closed |
| CF-03 | Shop profile/location update | Authoritative revision and preview | Conflict/policy actionable |
| CF-04 | Find canonical product | Correct product/variant | Ambiguity to review |
| CF-05 | Create/edit listing | Shop-scoped unique listing | No canonical fact mutation |
| CF-06 | Price update | Exact amount/revision saved | Unknown outcome reconciled |
| CF-07 | Availability update | Explicit state/freshness | Unknown not shown as in stock |
| CF-08 | Missing product candidate | Idempotent pending/status | No instant unauthorized publication |
| CF-09 | QR scan/confirm | Exactly one verified transaction | Expiry/wrong/replay fail closed |
| CF-10 | Review view/report | Eligible content and governed report | No merchant deletion |
| CF-11 | Staff invite/revoke | Scoped capability applied | No self-escalation/stale cache |
| CF-12 | Shop/account switch | Old scope cleared | In-flight/unknown work not migrated |

Every flow requires loading, empty, error, conflict, permission, policy and accessibility coverage proportional to risk.
