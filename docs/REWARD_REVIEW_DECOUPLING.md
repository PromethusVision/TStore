# Reward and Review Decoupling

Status: **NON-NEGOTIABLE CURRENT CONTRACT PRESERVED**
Wave: 18 / Workstream L

## Independent decisions

Verified purchase evidence may independently support review eligibility and reward evaluation. Reward outcome never becomes review evidence and review content/rating never determines economic reward.

## Frozen review rules

- Only merchant-confirmed QR physical purchase unlocks review.
- One active review per customer + canonical product for life.
- Repeat purchase does not grant a second active review.
- Quantity does not multiply review rights.
- Delete/recreate relies on immutable verified evidence.
- Legacy boolean alone is not evidence.

## Reward implications

- Repeat purchases may earn rewards only if owner-approved; review rights remain unchanged.
- Multiple quantity may affect reward only after a separate trusted-quantity decision; no review multiplication.
- Reward reversal/expiry/redemption does not remove review right.
- Review deletion/recreation does not re-award reward.
- Reward cannot depend on positive rating or coerce review creation.
- A review-created gamification badge uses canonical unique review evidence and never pays for sentiment.

`REWARD_REVIEW_DECOUPLING: REQUIRED`
