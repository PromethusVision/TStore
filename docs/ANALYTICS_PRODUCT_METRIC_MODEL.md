# EsnaftaVar Product Metric Model

**State:** `PROPOSED`

| Metric | Numerator/source | Scope | Interpretation |
|---|---|---|---|
| Product views | Valid `product_viewed` events | Canonical product, optionally listing/shop | Discovery interest |
| Seller comparisons | Valid `seller_comparison_opened` | Canonical product | Purchase-research intent |
| Wishlist adds | Idempotent persisted add transitions | Customer/product aggregate | Soft intent; remove tracked separately |
| Cart intent | Idempotent Cart V2 add transitions | Listing/product/shop aggregate | Soft intent; no checkout implication |
| Directions intents | Valid `directions_requested` attributed to a product/listing context | Product/listing/shop | Local visit intent |
| Verified purchases | Distinct authoritative verified-purchase facts containing product/variant/listing snapshot | Event-time and governed lineage projections | Strong platform commerce outcome, not payment |

Every metric declares entity identity, event version, environment, quality filter,
time window and taxonomy/catalog projection. A product merge aggregates predecessor
facts through explicit lineage without duplicating events. A split keeps historical
facts at the predecessor unless evidence maps them to a child.

Views, comparison, wishlist and cart are never combined into a synthetic sale.
Rates need a precisely defined denominator and same eligibility/filter window;
otherwise publish counts side by side.

`PRODUCT_METRIC_REGISTRY_FINALIZED: NO`
