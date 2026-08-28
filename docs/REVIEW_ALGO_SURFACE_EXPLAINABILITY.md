# Review and Reputation Surface Explainability

**State:** PRODUCT COPY REQUIREMENTS — COPY NOT FINAL

## Customer-facing separation

| Surface | Required meaning |
|---|---|
| product detail | product rating/text from eligible product reviews |
| shop feed | product review projected from this shop-origin purchase, separately labeled shop answers |
| shop profile summary | dimension-specific shop evidence with count/window; no hidden product-star mixing |
| search/seller comparison | narrow badge meaning plus `Nasıl kazanılır?`; no platform guarantee |
| review form | one journey, explicit product and shop sections |

## Merchant-facing explanation

Merchant App should eventually show effective sample count, response distribution, freshness,
ineligible/held contribution counts by reason class, badge lifecycle and appeal route. It must not
reveal individual customer identity or fraud-detection methods.

## Prohibited impressions

- `Doğrulanmış` does not mean payment, receipt, product authenticity or platform endorsement.
- A badge does not guarantee every visit, legal compliance or merchant solvency.
- A bad product score cannot be covered by a friendliness badge.
- Sponsored placement never appears as earned reputation.
- Missing history cannot be displayed as poor performance.

`PUBLIC_SINGLE_MERCHANT_STAR: NOT_RECOMMENDED_FOR_V1`
`BADGE_METHOD_LINK: REQUIRED_IF_LAUNCHED`
