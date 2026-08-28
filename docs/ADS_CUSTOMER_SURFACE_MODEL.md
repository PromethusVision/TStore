# Sponsored Customer Surface Model

**State:** PROPOSED PLACEMENT CONTRACT — NO FINAL UI OR FLUTTER CHANGE

Numeric density values below are safety candidates for owner/usability review, not
final commercial rules.

| Surface | Sponsored object | Customer intent | Disclosure | Ranking interaction | Proposed maximum | Failure/fallback |
|---|---|---|---|---|---:|---|
| Home | Listing card; shop card later | Broad discovery | Persistent `Sponsorlu` on card | Separate sponsored module; never rename organic featured content | 1 in first viewport | Omit module; organic Home unchanged |
| Search | Shop listing | Explicit query | Visible on every sponsored result | Eligible sponsor may precede nearer organic only after exact relevance/local gate | 1 in first 5; <=20% page | Return organic ranking unchanged |
| Category/product listing | Shop listing | Browse a product family | Visible on every sponsored card | Contextual interleave after category/product eligibility | 1 in first 5; <=20% page | Organic listing only |
| Product details / seller comparison | Exact listing for opened canonical product | Compare real nearby sellers | `Sponsorlu` next to seller identity | At most one sponsored seller row above unchanged organic seller order | 1 row | Remove row; show all organic sellers |
| Shop discovery | Shop-awareness card | Find a business type | Visible on merchant card | Future; sector relevance cannot replace geo eligibility | 1 in first 5 | Organic shops only |
| Nearby | Listing/shop card | Find genuinely nearby availability | Visible plus real distance | Future; strict physical-shop radius and density gate | 1 in first 6 | Organic distance ranking only |

## Universal surface rules

- `Sponsorlu` is textual, visible without opening details and not color-only.
- Scrolling, compact layouts, list/grid variants and accessibility modes retain it.
- Sponsored styling cannot imitate an organic recommendation or verified badge.
- Price, distance, availability and merchant identity use the same truth sources as
  organic cards.
- A sponsored card never receives a fake “nearest”, “best”, “recommended” or
  “discount” claim.
- Organic results remain available and internally ordered by the normal organic
  algorithm.
- Empty, timeout, policy-block and ad-service failure produce no blank slot.

## V1 recommendation

Pilot Search and Category listing cards first. Seller comparison is high-value but
high-trust-risk and needs an explicit P0 owner decision. Home, Nearby and shop
awareness should remain future candidates until density and geo acceptance are
tested.

`CUSTOMER_AD_SURFACE_MODEL: READY_FOR_OWNER_REVIEW`

`ORGANIC_FALLBACK_ON_ALL_SURFACES: REQUIRED`
