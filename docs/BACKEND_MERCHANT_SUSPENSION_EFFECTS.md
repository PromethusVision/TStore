# Backend Merchant Suspension Effects

**State:** PROPOSED — OWNER_DECISION_REQUIRED FOR CUSTOMER VISIBILITY

Suspension is an organization/shop policy state, not deletion. It immediately
blocks privileged merchant mutations, QR confirmation, new campaigns and new
customer interaction that would create risk.

## Recommended effects

| Surface | Effect |
|---|---|
| Merchant login/private reads | Bounded status/reason and appeal access only |
| Listing writes/media uploads | Block |
| QR issue/confirmation | Block new operations; existing sessions terminally reject |
| Public discovery | Hide or label based on suspension reason and customer safety |
| Purchases/reviews/ratings | Preserve historical customer access and rights |
| Chat | Allow only policy-approved support/closure path; no new solicitation |
| Ads | Pause immediately; no paid bypass |
| Rewards/reputation | Freeze new qualifying effects; do not erase history |
| Audit/ops | Preserve case, evidence and appeal trail |

Suspension scope (organization vs shop), customer messaging and existing chat
behavior are `OWNER_DECISION_REQUIRED`. Reinstatement is a new audited decision
and revalidates listing/media/policy freshness; it does not erase the suspension.

