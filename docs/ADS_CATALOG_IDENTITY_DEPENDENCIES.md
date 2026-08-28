# Advertising Dependencies on Catalog Identity

**State:** READ-ONLY CATALOG CONTRACT — NO CATALOG OR AD RUNTIME

Source reference: read-only
`origin/agent3/w16-canonical-product-catalog-foundation@b654e680ca72a79c109a098a237b9813b24516cc`.

## Required identity chain

`CAMPAIGN -> SPONSORED TARGET -> SHOP LISTING -> PRODUCT VARIANT -> CANONICAL PRODUCT`

The listing also references the physical shop/merchant. The preferred V1 sponsored
object is the listing because canonical product/variant does not own merchant price,
stock or local availability.

## Catalog dependencies

- immutable canonical product, variant and listing IDs;
- exactly one listing target for the advertised offer;
- active/retired/needs-review lifecycle;
- merchant/shop ownership;
- current price and availability/stock knowledge with source timestamp;
- canonical product's active assignable Product Taxonomy leaf;
- policy/content/media provenance;
- merge/split/predecessor/successor history;
- verified purchase snapshot independence.

## Change behavior

| Catalog event | Advertising response |
|---|---|
| Product/variant rename | Keep IDs; refresh display metadata |
| Taxonomy move | Re-evaluate context; campaign identity unchanged |
| Product merge | Audited compatible successor; review target |
| Product split | Pause until exact successor listing selected |
| Listing out of stock/inactive/retired | Stop serving immediately |
| Shop inactive/relocated | Stop or geo revalidate |
| Price/availability update | Use source truth; invalidate stale snapshot |
| Policy/recall block | Stop regardless of budget/campaign state |

## Forbidden coupling

- campaign ID derived from product/listing slug;
- ad-created parallel product/listing/price/stock record;
- canonical product sponsored without real shop listing in V1;
- campaign status treated as catalog availability;
- campaign deletion erasing product/purchase/review history.

`CATALOG_IDENTITY_REQUIRED_BEFORE_AD_RUNTIME: YES`

`SPONSORED_TARGET_STABLE_ID: REQUIRED`

`CATALOG_RUNTIME_CHANGED: NO`
