# Merchant Advertising Economics Simulation

**State:** SYNTHETIC OPTION ANALYSIS — NO REAL PRICE, ROI PROMISE OR BILLING

## Assumptions

The scenarios compare understandable exposure/risk, not forecast actual revenue.
Traffic, price, click rate and downstream action rates are illustrative normalized
indices. Verified purchase is not assumed observable or caused by advertising.

## Merchant/product scenarios

| Scenario | Demand pattern | Flat daily promotion | CPC | CPM | Auction | Main concern |
|---|---|---|---|---|---|---|
| Small merchant / high-frequency item | Repeated local searches, small margin | Predictable cap; good pilot fit if delivery floor exists | Click cost can exceed margin; competitor/self-click risk | Awareness measurable but abstract | Bidding skill disadvantages merchant | Simplicity and hard spend cap |
| Small merchant / low-frequency item | Few qualified searches | Under-delivery credit essential | Sparse clicks may be efficient but statistically noisy | Pays for weak exposure | Little real competition | Do not promise reach/ROI |
| Medium merchant / high-frequency item | Many listings and contexts | Needs merchant/product density cap | Better optimization signal; fraud control burden | Stable awareness budget | Could dominate without fairness caps | Catalog size must not buy the page |
| Medium merchant / low-frequency item | Specialist high-intent queries | Flat window may be understandable | CPC aligns with explicit opens but click value unknown | Low volume weakens CPM value | Thin auction creates arbitrary prices | Exact relevance more valuable than bid |

## Normalized example

Assume a merchant authorizes `100 budget units` for a period. This is not currency.

| Model | Potential charge basis | Merchant uncertainty | Platform burden | V1 suitability |
|---|---|---|---|---|
| Flat daily | Eligible delivery day under declared floor | Under-delivery | Credit/dispute and pacing | HIGH CANDIDATE |
| CPC | Qualified open | No sale/visit guarantee | Invalid clicks and event billing | MEDIUM/FUTURE |
| CPM | 1,000 qualified impressions | Value difficult at low scale | Visibility measurement | LOW-MEDIUM |
| CPA/verified purchase | Attributed outcome | False causal certainty | QR gaming/privacy/disputes | NOT RECOMMENDED |
| Auction | Bid-cleared event | Price volatility | Auction, fraud, explainability | DEFER |

## Required pilot outputs

- eligible opportunity and qualified delivery, not guaranteed inventory;
- budget authorized/spent/credited and freshness;
- invalid traffic separately;
- shop opens/directions as non-sale signals;
- no ROAS label unless a future model defines attributable value with caveats;
- comparison of advertiser retention/disputes and customer trust, not revenue alone.

## Conclusion

Small-pilot economics favor a capped flat non-auction promotion experiment or even
subscription-only launch over a complex auction. Real price and commercial terms
require Product Owner, finance, tax, payment and legal decisions.

`ECONOMICS_SIMULATION_SCENARIOS: 4`

`ROI_PROMISED: NO`

`REAL_PRICING_FINALIZED: NO`
