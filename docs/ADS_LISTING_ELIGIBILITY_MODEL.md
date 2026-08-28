# Sponsored Product and Listing Eligibility Model

**State:** PROPOSED — NO CATALOG OR AD RUNTIME

The preferred V1 sponsored object is one shop listing tied to one canonical
product/variant. Eligibility is stricter than ordinary catalog visibility when
advertising could amplify misleading or stale content.

## Required checks

| Dimension | Proposed serve requirement | Failure |
|---|---|---|
| Identity | Listing resolves to exact active canonical product/variant | Block |
| Ownership | Campaign merchant controls listing shop | Block/security review |
| Listing state | Active and not retired/review/temporarily unavailable | Block |
| Availability | Known in stock or explicit owner-approved unknown-stock posture | Block/conditional |
| Freshness | Availability/price within domain-approved freshness window | Block or refresh |
| Price | Present, current, truthful; same display truth as organic | Block |
| Taxonomy | Active assignable product leaf or compatible successor | Block unresolved split |
| Product policy | SKU, claims and ad context approved | Block/review |
| Shop | Active physical shop and geo-valid | Block |
| Media/content | Safe, attributable and non-misleading | Block/review |

## Stock semantics

`UNKNOWN` is not `KNOWN_IN_STOCK`. Owner may allow an “availability unknown / ask
shop” organic result, but paid amplification of unknown stock needs an explicit
decision. Recommended V1 posture is known-in-stock/fresh evidence for product ads.

## Lifecycle behavior

- Out-of-stock, retired, deleted or shop-inactive listing stops immediately.
- Reactivation may resume only after fresh checks and target revision compatibility.
- Product merge uses audited successor; split pauses until selected.
- Price change updates display from listing truth and may trigger review if the
  creative made a price claim.
- Immutable served snapshot preserves what customer saw.

## Prohibited shortcuts

- campaign copy standing in for a missing listing;
- merchant-entered product name without canonical target;
- stale cached price/stock used after source failure;
- banner that implies stock for every product in a category;
- policy eligibility inherited from merchant sector alone.

`NONEXISTENT_LISTING_CAN_SERVE: NO`

`RECOMMENDED_V1_STOCK_POSTURE: FRESH_KNOWN_IN_STOCK`

`LISTING_ELIGIBILITY_MODEL: READY_FOR_OWNER_REVIEW`
