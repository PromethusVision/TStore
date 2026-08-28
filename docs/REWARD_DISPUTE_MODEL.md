# Reward Dispute Model

Status: **PROPOSED — OWNER/OPERATIONS REVIEW REQUIRED**
Wave: 18 / Workstream AL

| Case | Authoritative evidence | Safe outcome |
|---|---|---|
| Reward missing | Verified source, rule version, evaluator/ledger state | Earn, explain ineligibility, or pending investigation |
| QR failed | QR/verified transaction terminal state | No manual reward unless source correction is authoritative |
| Merchant disputes purchase | Immutable purchase and governed correction process | Merchant cannot directly reverse customer reward/source |
| Duplicate | Source/ledger idempotency keys | One earn; remove duplicate projection |
| Expiry confusion | Terms version and expiry event | Explain; exception policy TBD |
| Redemption timeout | Entitlement/redemption transaction state | Reconcile before retry |
| Fraud hold | Restricted integrity evidence | Neutral hold, authorized review/appeal |

## Requirements

Stable dispute ID, actor/scope, evidence links, safe reason, SLA/status and append-only resolution. Support cannot fabricate verified purchase, edit ledger balance directly or exchange reward for positive review.

Consumer exception, goodwill credit and appeal authority are owner/legal/economic decisions.
