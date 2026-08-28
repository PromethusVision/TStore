# Merchant Campaign Creation Flow

**State:** FUTURE MERCHANT APP REQUIREMENTS — NO FINAL UI OR IMPLEMENTATION

## Proposed simple flow

1. **Eligibility precheck:** identify active merchant/shop and explain unavailable
   advertising states without exposing security internals.
2. **Choose objective:** V1 candidate is `Yerel ürün keşfi`; no conversion promise.
3. **Choose target:** select an owned eligible shop listing; show canonical
   product/variant, current price, stock freshness and shop.
4. **Choose location:** bounded shop-centered radius/district; preview reach context,
   not guaranteed audience.
5. **Choose context:** exact product/category/search intents from governed targets;
   no arbitrary competitor or sensitive-person targeting.
6. **Choose duration/budget:** explicit zone, start/end, daily/total cap and pricing
   revision; show no-guaranteed-result statement.
7. **Preview:** render the real customer card including permanent `Sponsorlu`, price,
   availability, distance and advertiser/shop identity.
8. **Review summary:** target, geo, schedule, caps, policy notices and terms.
9. **Submit idempotently:** transition `DRAFT -> PENDING_REVIEW`; duplicate taps do
   not create two campaigns or reservations.
10. **Track status:** approved/active/paused/exhausted/ended/rejected/blocked with
    plain-language reason and safe next action.

## Regulated and unavailable cases

- Ineligible listing cannot be replaced with free-text product copy.
- Policy-signalled product/merchant stays pending or blocked until exact evidence.
- Out-of-stock/retired shop listing is disabled with refresh guidance.
- Listing/price change may update preview or require re-review.
- “Other product” becomes a catalog correction/request flow, not an ad target.

## Merchant controls

- pause/resume where policy permits;
- end campaign;
- revise budget/geo/time through versioned settings;
- inspect defined metrics and freshness;
- report/dispute invalid delivery or policy decision;
- never directly set approval, spend, badge or ranking position.

## UX safety

Progressive disclosure avoids bidding/ad-tech jargon. The flow must not promise
nearest, top position, impressions, clicks, visits, verified purchases or ROI.
Payment/billing screens are outside this design.

`MERCHANT_CAMPAIGN_FLOW: READY_FOR_OWNER_REVIEW`

`FINAL_UI_DESIGNED: NO`

`RUNTIME_IMPLEMENTATION: NO`
