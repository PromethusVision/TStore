# Product Availability and Stock Semantics

Status: **OWNER REVIEW DRAFT — NO INVENTORY IMPLEMENTATION**
Wave: 16, Work Package 20

Canonical existence and merchant sellability are independent.

## Layered states

| Layer | State | Meaning |
| --- | --- | --- |
| Product | active/retired/policy-blocked | Shared identity is assignable, historical only, or not sellable. |
| Variant | active/discontinued/review | This configuration lifecycle; siblings are unaffected. |
| Listing | active/temporarily unavailable/out of stock/retired | Shop relationship lifecycle. |
| Stock knowledge | `KNOWN_IN_STOCK`, `KNOWN_OUT_OF_STOCK`, `UNKNOWN` | Evidence quality; unknown is not zero. |
| Shop | active/inactive | Inactive shop suppresses all its offers without retiring products. |

## Rules

- Canonical products and variants have no universal stock count.
- Listing `active` means merchant relationship is valid, not necessarily in stock.
- `UNKNOWN` stock may still permit “ask shop” discovery; it must not display a
  fabricated positive quantity.
- `TEMPORARILY_UNAVAILABLE` preserves listing identity and history while excluding
  current purchasability; `RETIRED` ends normal reuse unless reactivated by policy.
- State carries source and observed/effective timestamp. Stale stock becomes unknown
  according to an owner-defined freshness window rather than silently remaining true.
- Customer ordering/cart checks listing, shop and product/variant policy at action
  time; search cards use an explicitly timestamped projection.

The existing runtime booleans and product-level stock are current compatibility
facts, not proof that the target model should keep canonical stock.
