# Backend Lifecycle and Retirement Model

**State:** PROPOSED — NO DELETE/MIGRATION

Use hard delete only for never-used, legally removable, dependency-free data under
an explicit contract. Use retirement, suspension, revocation, cancellation or
superseding history when an identity has customer, financial, trust, policy or
audit dependencies.

| Subject | Normal end state | Why not blind delete |
|---|---|---|
| Shop/listing/product/variant | Retired | Purchases, reviews, ads and discovery history |
| Membership | Revoked/expired | Actor and delegation audit |
| QR session | Used/expired/cancelled | Replay and purchase proof |
| Verified purchase | Valid with correction state | Review/reward/reputation evidence |
| Review | Customer-deleted/moderated lifecycle | Aggregate and appeal history |
| Campaign | Ended/retired | Budget/serve/audit reconstruction |
| Reward entry | Reversed/redeemed/expired by entries | Economic integrity |
| Ops case | Closed/reopened | Evidence and decision accountability |
| Customer private data | Purpose-specific delete/pseudonymize | Legal/audit rights require review |

Retirement blocks new use while preserving authorized historical projections.
Cascade impact is previewed; no status name alone determines every downstream
effect. Retention periods and customer deletion treatment are
`OWNER_DECISION_REQUIRED` with policy/legal review.

