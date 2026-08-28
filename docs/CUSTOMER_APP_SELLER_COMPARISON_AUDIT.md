# Customer App Seller Comparison Audit

Status: PASS

## Findings

- Seller rows originate from the current product's shop-product listings and retain product/listing/shop identity.
- Missing or inactive shops and invalid seller records are not presented as purchasable.
- Empty and repository-error states are distinct and retry the same seller request.
- Price, rating, and distance sorting are stable and customer-selected; no sponsored ranking is present or implied.
- Location-ready and saved-primary-location paths sort by real calculated distance; no-location mode preserves usable results.
- Opening a seller uses the matching shop entity. Adding to Cart uses the exact listing identity.
- Guest Cart/chat actions preserve product/shop context through login, clear abandoned pending context, and suppress rapid duplicates.
- A merchant cannot start a conversation with the same owned shop from the retained shared client surfaces.

Production demo evidence previously showed 14–15 sellers per product and deterministic price variation for all 20 products. This is discovery evidence only; demo shops have `owner_user_id = NULL` and cannot complete merchant QR confirmation.

`SELLER_COMPARISON_AUDIT: PASS`
`SPONSORED_RANKING_IMPLEMENTED: NO`
`MERCHANT_DEMO_LIMITATION: NOT_A_BUG`
