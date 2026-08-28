# Review Policy Test Model

**State:** PROPOSED — CANONICAL RULES PRESERVED

## Frozen invariants

- Only merchant-confirmed QR physical purchase evidence grants eligibility.
- At most one active review per customer and canonical product for life.
- Repeat purchase and quantity do not create additional active review rights.
- Delete/recreate follows durable evidence and cannot bypass uniqueness.
- Legacy booleans, rewards, ad interaction or merchant assertion are not evidence.
- Product merge/split never silently duplicates, deletes or guesses review identity.

## Matrix

| Layer | Cases |
|---|---|
| Unit/Cubit | eligibility state, duplicate submit/delete lock, stale pagination, sanitized errors |
| Repository | RPC mapping, not-found/idempotent delete, aggregate refresh, Storage proof |
| Widget | loading/empty/error/list, create/update/delete, narrow/text-scale behavior |
| Backend | customer ownership, evidence join, uniqueness, cross-user denial, aggregate correctness |
| Migration | legacy review isolation, durable product snapshot, backfill invariants |
| Catalog correction | merge collision and ambiguous split remain explicit review cases |

## Abuse and appeal

Merchant disagreement never removes a rating. Reports are evaluated against content policy; moderator actions preserve the verified-review audit chain. A corrected verified purchase may supersede eligibility only through the approved high-risk correction model.

`REVIEW_POLICY_REGRESSION_REQUIRED: YES`
