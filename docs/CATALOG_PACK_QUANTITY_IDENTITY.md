# Pack Size / Quantity Identity

Status: **OWNER REVIEW DRAFT**
Wave: 16, Work Package 6

Pack identity answers “what sealed or fixed retail unit is supplied?” Listing
quantity answers “how many units does this shop/customer transact?” They must not
be collapsed.

## Decision matrix

| Example | Catalog treatment | Reason |
| --- | --- | --- |
| 500 ml and 1 L of same line | Separate variants or closely related products | Net content changes the independently sellable unit and commonly its GTIN. |
| 2 × 500 ml manufacturer-wrapped pack | Fixed multipack variant/product | Physical retail pack has defined component count and possibly own GTIN. |
| Customer adds two 500 ml units | Listing/cart quantity | No new catalog identity. |
| Single piece versus factory 6-pack | Separate sellable pack identities | Packaging/count and unit-price basis differ. |
| Merchant “buy six singles” grouping | Listing quantity or promotion | Not a canonical bundle unless physically fixed and persistently offered as one item. |
| Family pack | Variant/product only when net content/composition is fixed | Marketing phrase alone is not identity. |
| Assorted fixed pack | Bundle/set when component identities/composition matter | Requires explicit component declaration. |

## Normalized measure

Retain declared value and unit, normalized comparable quantity, component count,
per-component measure, package level and evidence source. Unit price is derived
from the shop listing price and a compatible normalized measure; it is not a
canonical price.

`1 L` and `1000 ml` may normalize to the same measure but are not auto-merged if
their packaging, GTIN, formula, market presentation or provenance conflicts.
Likewise `2 × 500 ml` has the same aggregate volume as `1 L` but is not the same
physical retail unit.

## Boundary rules

- Stable factory packaging belongs to product/variant identity.
- Merchant transaction count, minimum order and increment belong to listing.
- Open/variable measure uses a base product plus listing sell unit; a weighed bag
  is a transaction/batch snapshot, not a new canonical product.
- Gift composition and multiple unlike items use bundle/kit modeling.
- Pack corrections can require product split; historical purchases preserve their
  displayed pack snapshot.
