# Catalog Attribute Layer Ownership

Status: **OWNER REVIEW DRAFT — PROVISIONAL CONCEPT REGISTRY**
Wave: 16, Work Package 3

This classification consumes the Wave 15 facet/search architecture without
changing it. Every concept has one authoritative layer; other layers may index
or display a projection, not create a competing truth.

## Ownership classes

| Layer | Question answered |
| --- | --- |
| `PRODUCT` | What shared physical product/family is this? |
| `VARIANT` | Which independently selectable form of that product is this? |
| `LISTING` | How does this shop offer it now? |
| `COMPATIBILITY` | What other entity/system does it fit or work with? |
| `POLICY` | May/how may it be shown or sold under legal/product rules? |
| `DERIVED` | What can the system calculate without accepting a new source fact? |

## Concept registry

| Concept | Owner | Notes |
| --- | --- | --- |
| Canonical product ID | PRODUCT | Stable opaque identity. |
| Brand, manufacturer | PRODUCT | Governed entities; brand is not taxonomy. |
| Product family, model name | PRODUCT | Shared model identity. |
| Model/part number | PRODUCT or VARIANT | Variant when code selects a configuration. |
| Canonical title, description | PRODUCT | Governed shared content. |
| Primary taxonomy leaf | PRODUCT | Exactly one assignable leaf. |
| Product type/form factor | PRODUCT | Function-bearing shared fact. |
| Material | PRODUCT or VARIANT | Variant only when independently selected/sold. |
| Colour, pattern | VARIANT | Product-level only if no choice exists. |
| Size, width, fit | VARIANT | Includes apparel/shoe sizing systems. |
| Storage, RAM, capacity | VARIANT | When configuration is independently buyable. |
| Flavour, scent, shade | VARIANT | If independently packaged/sold. |
| Edition, language, format | VARIANT | Often different publication identity/ISBN. |
| Net content, retail pack | VARIANT or PRODUCT | Identity-bearing sellable pack; not listing quantity. |
| GTIN/EAN/UPC/ISBN | VARIANT or PRODUCT | Identifier assertion with provenance; usually sellable unit. |
| Manufacturer identifier | PRODUCT or VARIANT | MPN/model number, not merchant-controlled. |
| Merchant listing ID | LISTING | One shop's offer identity. |
| Merchant SKU/barcode | LISTING | Unique only in merchant namespace. |
| Price/campaign/previous price | LISTING | Timestamped merchant fact. |
| Stock quantity/state | LISTING | Canonical product has no stock. |
| Availability and shop relation | LISTING | Shop-specific lifecycle. |
| Shop description/title/photos | LISTING | Supplemental; cannot overwrite canonical identity. |
| Sell unit/minimum/increment | LISTING | Piece, kg, metre and merchant increments. |
| Lot, batch, expiry, freshness | LISTING | Inventory/batch sub-layer; never product identity. |
| Condition | LISTING | New/display/refurbished, policy-controlled where needed. |
| Vehicle/device/model fitment | COMPATIBILITY | Structured relation, not title stuffing. |
| Protocol/connector support | COMPATIBILITY or PRODUCT | Product fact when intrinsic; relation when target-specific. |
| Age restriction | POLICY | Permission gate, not category identity. |
| Regulated/legal status | POLICY | Authoritative evidence required; fail closed. |
| Excluded product class | POLICY | Product may retain history but not be assignable/sellable. |
| Dietary/allergen claim | POLICY or PRODUCT | Evidence-bearing fact; claim use can be policy-gated. |
| Rating/review count | DERIVED | Only eligible verified review aggregate. |
| Unit price | DERIVED | Listing price divided by declared comparable measure. |
| Discount percentage | DERIVED | Derived from valid timestamped price history. |
| Nearby seller count/min price | DERIVED | Query-time listing aggregate. |
| Search-normalized title | DERIVED | Deterministic index projection. |

## Ambiguity rule

When a concept could occupy two layers, decide by authority and change cadence:
shared manufacturer fact goes to product/variant; merchant-controllable and
time-varying fact goes to listing; relationship goes to compatibility; permission
goes to policy; reproducible calculation goes to derived. Unknown ownership is a
review finding, not permission to copy the field into every layer.
