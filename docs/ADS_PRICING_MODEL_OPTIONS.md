# Sponsored Advertising Pricing Options

**State:** OPTIONS AND V1 RECOMMENDATION — NO FINAL PRICE OR BILLING

EsnaftaVar has physical discovery, no shipping/online checkout and no reliable
platform conversion for every purchase. Pricing must therefore avoid pretending
that a direction request, shop open or attributed QR event is a guaranteed sale.

## Options

| Model | Advantages | Disadvantages | Fraud exposure | Merchant clarity | Complexity |
|---|---|---|---|---|---|
| CPC | Pays for explicit card/shop open | Click is not store visit or sale; volatile | Self/competitor/bot clicks | Medium-high | Medium-high |
| CPM / qualified impression | Supports awareness and pacing | Merchant may distrust unseen value | View inflation, refresh loops | Medium-low | Medium |
| CPV-like view | Charge after a defined visible duration | Mobile visibility semantics are fragile | Scroll/dwell automation | Low-medium | Medium-high |
| Flat daily promotion | Predictable small-merchant cost; no auction | Needs delivery floor/credit for low traffic | Campaign cycling, fake eligibility | High | Low-medium |
| Fixed sponsored slot | Easy to explain and operate | Scarce slots create fairness/manual sales risk | Side deals, under-delivery | High | Medium |
| Hybrid flat + CPC | Balances access/delivery | Hard to explain and reconcile | Both flat/CPC risks | Low | High |
| CPA | Aligns with outcome in theory | No online checkout; offline causality weak | QR/purchase gaming | Misleadingly simple | Very high |

Google and Amazon use CPC/auction concepts as comparison, but their checkout/search
scale does not make that model automatically suitable here:

- [Google Ads bid and relevance concepts](https://support.google.com/google-ads/answer/2472731?hl=en)
- [Amazon Sponsored Products CPC model](https://advertising.amazon.com/en-us/solutions/products/sponsored-products)

## Recommended V1 candidate — not final

Pilot a **non-auction flat daily promotion credit with a hard total cap**, contextual
and local eligibility, paced rotation and a disclosed qualified-delivery floor.
Charge/consume the day only under the owner-approved delivery contract; zero
eligible delivery must not silently consume the full fee and should generate a
credit/no-charge outcome.

Record CPC, qualified impressions and downstream actions as non-billable shadow
metrics during the pilot. This tests demand and invalid-traffic exposure before an
auction or click billing commitment.

## Decisions still required

- currency/tax/invoice/payment provider and refund authority;
- daily price, minimum/maximum budget and qualified-delivery definition;
- partial-day/under-delivery credits;
- whether CPC is tested after the pilot;
- merchant dispute evidence and SLA;
- policy for paused/rejected campaigns and invalid traffic.

`ADS_V1_PRICING_CANDIDATE: NON_AUCTION_FLAT_DAILY_PROMOTION`

`CPA_V1: NOT_RECOMMENDED`

`PRICING_FINALIZED: NO`
