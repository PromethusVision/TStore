# Variable Measure Product Model

Status: **OWNER REVIEW DRAFT — NO INVENTORY OR SCANNER IMPLEMENTATION**
Wave: 16, Work Package 24

Variable-measure products use one stable base product identity and a shop listing
that declares how quantity is measured and priced. Every weighed/cut transaction is
not a new canonical product.

## Examples and semantics

| Product | Canonical identity | Listing sell unit | Purchase snapshot |
| --- | --- | --- | --- |
| Cheese/olives/nuts/produce | Type, variety/recipe, producer/grade when identity-bearing | kilogram or gram; minimum/increment | actual measured weight and unit price |
| Fabric | material, weave/design/width where identity-bearing | metre; cut increment | actual length, width basis and unit price |
| Cable/rope | specification, conductor/material/diameter/rating | metre | actual length and exact specification |
| Flowers by stem | species/grade/colour when selectable | stem/bunch | actual count/composition |

## Listing contract

Conceptually retain measure dimension, canonical unit, display unit, minimum sale,
increment/precision, tare treatment where applicable, current price per unit,
availability and observation time. `stock known` may be quantity in the same unit or
unknown; a piece-count field cannot stand in for kilograms/metres.

## Identity rules

- Fixed sealed packs (`500 g`) follow pack identity; open product sold by weight uses
  a variable-measure listing. They are related but not the same sellable form.
- Grade, variety, formulation, cable rating or fabric width can be product/variant
  identity when customers must choose them and they change the supplied item.
- Cut length or weighed amount is transaction quantity, not variant.
- Merchant PLU/price-embedded barcode is local evidence. Parse only under a trusted
  merchant/region rule and snapshot measured quantity/price server-side.
- Unit-price comparison requires compatible product form, grade and units; aggregate
  quantity normalization alone does not justify product merge.

QR verified purchase evidence must record base product/variant, listing, actual
quantity, measure unit, unit price and line total. Review entitlement remains one per
customer and canonical product regardless of weight purchased.
