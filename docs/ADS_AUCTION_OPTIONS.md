# Sponsored Advertising Auction Options

**State:** OPTIONS — AUCTION NOT ASSUMED OR FINAL

## Comparison

| Model | Benefits | Risks/complexity | Local-pilot fit |
|---|---|---|---|
| First-price auction | Simple clearing concept; predictable winning bid relation | Bid shading, volatility, merchant confusion, fraud/billing load | LOW |
| Second-price-like auction | Incentive concept can reduce shading | Reserve/quality/position mechanics and explanations are complex | LOW |
| Fixed ranking boost | Easy to implement conceptually | Paid boost can overpower relevance/fairness without strict floor | MEDIUM-LOW |
| Non-auction flat promotion | Understandable; predictable cap; no bidding expertise | Rotation/under-delivery/fair access rules still required | **HIGH V1 CANDIDATE** |
| Fixed sponsored slot sale | Commercially simple | Scarcity, side-deal/fairness risk, weak self-service | MEDIUM |

Google combines bid, quality, thresholds and context in auctions; Amazon Sponsored
Products uses CPC bidding. These are comparison evidence, not a recommendation to
copy their scale or checkout economics:

- [Google Ads auction overview](https://support.google.com/google-ads/answer/142918?hl=en-EN)
- [Google Ads Ad Rank thresholds](https://support.google.com/google-ads/answer/7634668?hl=en)
- [Amazon Sponsored Products](https://advertising.amazon.com/en-us/solutions/products/sponsored-products)

## V1 recommendation

**Do not build an auction for V1.** Use non-auction flat daily promotion with hard
eligibility/relevance/locality thresholds, transparent caps and paced fair rotation.
Collect shadow demand/traffic data before deciding whether bids add customer or
merchant value.

Money remains downstream of hard gates in every future model. No bid can purchase
policy approval, product match, distance truth, badge or organic position.

## Gate before any future auction

- enough eligible advertisers per local context to create real competition;
- approved billing/refund/tax/payment architecture;
- invalid-traffic and dispute evidence;
- merchant comprehension/usability evidence;
- quality/fairness/new-merchant thresholds;
- auction explainability and auditability;
- proof that simpler subscription/fixed promotion is insufficient.

`ADS_V1_AUCTION: NO`

`ADS_V1_SELECTION: ELIGIBILITY_PLUS_PACED_ROTATION`

`FUTURE_AUCTION_OWNER_DECISION_REQUIRED: YES`
