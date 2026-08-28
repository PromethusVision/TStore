# Merchant App Variable Measure Flow

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP23

## Examples

Products sold by kilogram, gram, litre, metre or another governed measure.

## Proposed model

- Canonical product describes stable identity.
- Variant is used only if a material buyable choice exists; unit alone does not automatically create a variant.
- Shop listing owns sell unit, unit price, minimum quantity and permitted increment.
- Customer intent may be estimated; merchant confirmation snapshots actual measured quantity and price context when supported.

## Rules

- Units come from governed vocabulary with conversion/precision rules; free-text units are not silently accepted.
- Display always pairs amount and unit (`price per kg`, not ambiguous price).
- Minimum/increment must be positive and consistent with unit precision.
- QR confirmation cannot rewrite canonical identity; actual quantity snapshot must not multiply review rights.
- One active review per customer + canonical product for life remains unchanged.

## Open decisions

- `CAT-09 P0`: Whether customer QR contains requested quantity, merchant enters actual quantity, or both.
- `CAT-01 P0`: Whether unit choice belongs to listing or certain variants.
