# Merchant Listing Moderation Model

**State:** PROPOSED FOR OWNER/POLICY REVIEW

## Problem classes

| Problem | Evidence focus | Proportionate action |
|---|---|---|
| FAKE_LISTING | nonexistent product/shop/ownership, fabricated media | restrict listing; merchant fraud review |
| INCORRECT_PRODUCT | listing linked to wrong canonical product/variant | pause/relink through catalog review |
| MISLEADING_PRICE | bait, hidden unit/condition, stale snapshot | request correction/restrict; preserve price history |
| UNAVAILABLE_ITEM | persistent false availability | pause listing/freshness review |
| PROHIBITED_ITEM | policy class/evidence | immediate scoped restriction and policy case |
| SPAM/DUPLICATE | repeated low-value/keyword-stuffed listings | dedup/rate control; no canonical merge by assumption |
| MISLEADING_CLAIM | unsupported authorized/medical/safety/discount claim | remove claim/restrict listing and evidence review |
| MALICIOUS_MEDIA | harmful/rights-violating/unsafe upload | media restriction and security/moderation review |

## Workflow

Report/system signal → exact listing/shop/product resolution → current snapshot/version → evidence → merchant/catalog/policy checks → proportionate decision → communication/appeal → recheck → audit.

## Boundaries

Moderator may restrict the listing but does not rewrite canonical product truth, merchant verification, verified purchase history, review rating, or audit. A price disagreement alone is not fraud; compare timestamped listing evidence. Availability changes normally belong to merchant lifecycle, while repeated deception becomes moderation.

## State effects

Prefer `VISIBLE`, `LIMITED`, `PENDING_CORRECTION`, `POLICY_HOLD`, `REMOVED`, and `RESTORED` history over hard delete. Product/customer discovery and ads consume current eligibility server-side.

`LISTING_MODERATION_FINAL: NO`

`HARD_DELETE_DEFAULT: NO`
