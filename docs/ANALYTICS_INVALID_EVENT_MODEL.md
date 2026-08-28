# EsnaftaVar Invalid Event and Abuse Filtering Model

**State:** `PROPOSED`

An event may be structurally invalid, unauthorized, duplicate, test/demo,
impossible, bot-like, fraud-suspected or quality-ineligible. These states are
separate; suspicion is not proof.

| Outcome | Handling |
|---|---|
| Schema/version invalid | Reject/quarantine with bounded reason |
| Duplicate delivery | Deduplicate; retain delivery-quality count |
| Wrong environment/test/demo | Exclude from Production business metrics |
| Impossible entity/time/revision | Quarantine and data-quality alert |
| Obvious automation/bot pattern | Exclude from soft engagement using versioned rule |
| Fraud/security suspicion | Preserve restricted evidence; no automatic business sanction |
| Later invalidation | Append invalidation/supersession; recompute affected metrics |

Rules and model versions are attached to every filtered projection. Raw evidence
within approved retention remains reconcilable. Filters never remove a server-
authoritative verified purchase, reward or billing fact merely because a heuristic
dislikes it; authoritative reversal follows the owning domain.

`ABUSE_FILTER_EQUALS_GUILT: NO`
