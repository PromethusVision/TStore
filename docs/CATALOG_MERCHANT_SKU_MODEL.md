# Merchant SKU and Inventory Identifier Model

Status: **OWNER REVIEW DRAFT**
Wave: 16, Work Package 22

| Identifier | Namespace | Purpose |
| --- | --- | --- |
| Canonical product ID | EsnaftaVar global | Stable shared product continuity. |
| Variant ID | EsnaftaVar global within product | Exact selectable configuration. |
| Shop listing ID | EsnaftaVar global | Shop-to-product/variant offer relation. |
| Merchant SKU | One merchant/shop or merchant organization | Local inventory/accounting lookup. |
| GTIN/ISBN | External global allocation system | Trade-item/publication identity evidence. |
| Merchant barcode/PLU | One merchant/system | Local scan lookup; may encode variable measure. |

Merchant SKU need not and must not be assumed globally unique. Its uniqueness scope,
case sensitivity and reuse policy are merchant configuration decisions; the safe
default is normalized uniqueness among active listings within one shop plus retained
historical aliases.

## Rules

- Merchant may attach one or more local aliases to a listing, with effective dates.
- Reusing a retired SKU for a different product should warn or be prevented while
  historical purchase/inventory interpretation could be ambiguous.
- A scanned local code first resolves inside the authenticated merchant namespace;
  it never enters global dedup as a GTIN without explicit validated type.
- Variant-aware inventory uses separate listing/variant references even if a merchant
  groups them under a family SKU.
- SKU corrections do not rename or merge the canonical product.
- Verified purchases snapshot listing, product/variant and commercial facts; the
  merchant SKU may be retained as optional context but is not the durable proof key.
