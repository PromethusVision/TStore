# Review, Evaluation and Shop Identity Lifecycle

**State:** CONCEPTUAL LINEAGE MODEL

## Identity layers

- `ProductReview`: stable review ID; customer + canonical product uniqueness.
- `ShopEvaluationSubmission`: stable response-set ID; exact purchase/shop/question-set evidence.
- `EffectiveShopContribution`: derived customer-capped contribution for one scoring window.
- `MerchantFeedItem`: rebuildable projection keyed by review and origin shop.
- `BadgeEvaluation`: versioned derived decision; never source truth.

## Scope recommendation

Customer experience evidence attaches first to the exact **shop/branch** that confirmed the QR.
Merchant organization may receive a later explainable roll-up, but cannot overwrite branch variation.

## Lifecycle rules

- Rename preserves stable identity.
- Relocation preserves historical evidence and binds future region eligibility from an effective date.
- Temporary closure pauses freshness/new evidence; it is not a bad score.
- Permanent closure retires active badges while preserving historical review/evaluation interpretation.
- Ownership transfer preserves shop history but does not silently transfer personal/organization
  quality claims; post-transfer scoring and badge continuity are owner decisions.
- Organization merge/split preserves branch evidence and lineage; no blind average or fan-out.
- Product merge/split follows immutable purchase snapshot and controlled successor mappings.

## Historical correction

Every correction records subject, old/new state, evidence, reason, actor, policy version, effective
time and impacted projections. Derived aggregates rebuild; source reviews and verified purchases are
not rewritten.

`SHOP_FIRST_REPUTATION: RECOMMENDED_FOR_REVIEW`
`ORGANIZATION_ROLLUP: DEFERRED`
