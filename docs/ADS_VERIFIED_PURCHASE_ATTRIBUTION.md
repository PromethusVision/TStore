# Sponsored Ads and Verified Purchase Attribution

**State:** CONCEPTUAL DECOUPLING — NO QR, REVIEW OR BILLING CHANGE

## Independent source of truth

Verified purchase remains the server-authoritative QR transaction contract. Its
eligibility, immutable item/price snapshot, merchant confirmation, replay controls
and review rights cannot depend on advertising state.

## Permitted future uses

- aggregated reporting that a verified purchase occurred after a qualifying
  sponsored interaction under a declared model;
- campaign quality research with minimum sample/privacy controls;
- merchant reporting as an observed signal, not guaranteed conversion;
- fraud investigation comparing ad traffic with independently valid transactions.

## Prohibited coupling

- no billable CPA by default;
- no ad click/view required for purchase verification or review eligibility;
- no paid campaign grants verified badge/reputation;
- no merchant/ad system can create or rewrite QR purchase evidence;
- no ad target can alter immutable purchased product/listing/price snapshot;
- no review suppression/boost based on advertising spend;
- no QR fixture/gaming accepted as campaign effectiveness proof.

## Attribution join

A future read model may link campaign interaction and purchase through customer,
shop, canonical product/variant/listing and bounded event time only under approved
privacy/retention rules. The raw purchase record does not receive mutable campaign
ownership. Multiple candidate interactions use a versioned deterministic reporting
rule and preserve `UNATTRIBUTED/UNKNOWN`.

## Customer/merchant wording

Use “doğrulanmış alışveriş sinyali” or “sponsorlu etkileşim sonrası gözlemlendi”
only when exact criteria pass. Do not state the ad caused the sale or calculate ROI
without a defined denominator, cost and attribution caveat.

`VERIFIED_PURCHASE_INDEPENDENT_OF_ADS: YES`

`AD_SPEND_BUYS_REVIEW_ELIGIBILITY: NO`

`VERIFIED_PURCHASE_AS_BILLING_EVENT: NOT_APPROVED`
