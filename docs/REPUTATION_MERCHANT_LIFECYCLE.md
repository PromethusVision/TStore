# Merchant Reputation Lifecycle

**State:** PROPOSED — OWNER DECISION REQUIRED

| Merchant/shop event | Evidence handling | Public behavior |
|---|---|---|
| New shop | Start shop-scoped evidence | `Insufficient history`; never low-trust default. |
| Rename/profile edit | Identity unchanged | Name updates; badge meaning unchanged. |
| Branch transfer | Preserve branch event history; portability TBD | No automatic org-wide transfer. |
| Temporary closure | Retain audit; stop freshness accumulation | Show closure, not reputation punishment. |
| Permanent closure | Retire public active status | Historical review/rating integrity remains. |
| Suspension/fraud investigation | Freeze badge/reward operation, retain evidence | Clear non-defamatory pending/suspension state and appeal. |
| Reinstatement | Append decision; re-evaluate derived state | Do not pretend interruption never occurred. |
| Org merge/split | Preserve lineage and branch evidence | No blind score averaging/fan-out. |

Advertising and reward-program status never influences lifecycle reputation. Merchant cannot delete legitimate customer ratings through a lifecycle operation.
