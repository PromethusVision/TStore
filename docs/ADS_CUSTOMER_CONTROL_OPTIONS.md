# Customer Sponsored-Advertising Control Options

**State:** CONCEPTUAL OPTIONS — NO FINAL UI OR PRIVACY IMPLEMENTATION

## Recommended controls

| Control | Purpose | V1 posture |
|---|---|---|
| `Neden Sponsorlu?` | Explain payment, current context/local criteria and limits | MUST HAVE candidate |
| Report ad | Misleading, irrelevant, unsafe, impersonation or other concern | MUST HAVE candidate |
| Hide this ad | Remove current target from immediate experience | SHOULD HAVE |
| See fewer from merchant | Merchant-level frequency preference | SHOULD HAVE; privacy review |
| Ad/privacy preferences | Control optional personalized/behavioral use | MUST precede any such targeting |
| Ads-free purchase option | Commercial product decision | DEFER/TBD |

## Behavior

- Hiding/reporting does not remove organic access to a legitimate product/shop.
- Report reason is not treated as proven violation; it enters triage with
  anti-report-abuse controls.
- Merchant never receives reporter identity or raw customer context.
- A hidden ad is not replaced instantly by another from the same merchant/product.
- Preferences cannot remove mandatory `Sponsorlu` disclosure.
- No dark pattern: close/hide/report and privacy choices are reachable and honest.
- If optional personalization is refused, organic and privacy-minimizing contextual
  behavior remains available.

## Candidate report reasons

Irrelevant product, item not sold/out of stock, wrong price, misleading claim,
unsafe/restricted content, shop/location incorrect, impersonation, disclosure issue,
other. Exact moderation taxonomy and SLA are owner decisions.

`WHY_SPONSORED_CONTROL: REQUIRED_CANDIDATE`

`REPORTER_IDENTITY_TO_MERCHANT: NO`

`CUSTOMER_CONTROLS_FINALIZED: NO`
