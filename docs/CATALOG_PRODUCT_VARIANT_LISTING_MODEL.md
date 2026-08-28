# Product / Variant / Shop Listing Formal Model

Status: **OWNER REVIEW DRAFT — NOT A DATABASE DESIGN**
Wave: 16, Work Package 2

## Three-layer model

| Layer | Meaning | Owns | Must not own | Merchant editability |
| --- | --- | --- | --- | --- |
| Canonical product | Shared real-world product family or identity root used for discovery and continuity. | Stable ID, canonical name, responsible brand/manufacturer, family/model, primary leaf, shared facts, lifecycle. | Shop price, stock, shop SKU, local availability, merchant-only claims. | Suggest corrections; no unilateral overwrite of governed fields. |
| Product variant | Buyable identity choice beneath a product when a material selection changes the supplied item. | Variant ID, dimensions such as size/colour/capacity/formulation/edition/fitment, variant identifiers and lifecycle. | Shop price/stock, campaign, shelf lot, arbitrary title prose. | Select existing; propose missing variant with evidence. |
| Shop listing | A shop's offer for exactly one product/variant. | Shop relationship, merchant SKU, current price, availability/stock knowledge, local photos/description, timestamps and sell unit. | Canonical brand/model/category, global identifier ownership, review aggregate. | Merchant-owned within validation and policy boundaries. |

An implementation may temporarily store a single-SKU product without a separate
variant row. Conceptually it still has one implicit default variant; references
must not confuse the family identity with the merchant listing.

## Domain examples

| Domain | Product | Variant | Listing |
| --- | --- | --- | --- |
| Electronics | Headphone model family | Colour or memory/capacity configuration | Nearby shop price, stock state, shop SKU |
| Clothing | T-shirt style/model | Size + colour | Shop price, availability, local photo |
| Shoes | Shoe model | Size + colour/width | Per-shop size availability and price |
| Food | Branded pasta line | 500 g sellable pack; recipe/flavour where distinct | Price, stock, lot/expiry state |
| Books | Work/publication family | Edition, language and physical format identified by ISBN | Shop copy condition and price |
| Cosmetics | Product line | Shade, volume, formulation | Price, tester/availability, lot state |
| Hardware | Tool model | Capacity/diameter/voltage or compatible fit | Shop price and local SKU |
| Pet | Feed line | Species/life-stage/formulation and pack | Price, stock and expiry batch |
| Automotive | Part family | Intrinsic vehicle fitment/model number | Shop offer and local stock |

## Boundary rules

- Create a variant when the customer must choose an identity-bearing dimension
  before the correct physical item can be supplied and shops can sell those
  choices independently.
- Create a different product when function, model, edition, formulation, form or
  fixed retail pack is commercially distinct beyond a shared family choice.
- Keep merchant price, stock, availability, campaign state, merchant SKU and
  shop-specific media on the listing even when all merchants agree.
- Keep compatibility as a governed relationship/facet unless it is an intrinsic
  identity dimension of a model-specific part.
- Keep policy classification orthogonal: a product can be correctly identified
  yet blocked from sale.

## Lifecycle and references

Product, variant and listing lifecycle are independent. A retired product is not
assignable but remains resolvable historically; a discontinued variant does not
retire sibling variants; an inactive shop listing does not deactivate the shared
product. Reviews attach to canonical product under the existing one-active-review
policy. Verified purchase evidence records product, variant when known, listing
snapshot, merchant, quantity, price and time so later corrections do not erase
the event.
