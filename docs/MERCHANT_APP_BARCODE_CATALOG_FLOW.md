# Merchant App Barcode Catalog Flow

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP17

## Principle

A barcode is an identity signal and search accelerator, not unconditional proof that two records are the same.

## Flow

```text
CAMERA_OR_MANUAL_CODE
 -> NORMALIZE_FORMAT
 -> EXACT_IDENTIFIER_LOOKUP
 -> ZERO / ONE / MULTIPLE MATCH HANDLING
 -> PRODUCT_AND_VARIANT_CONFIRMATION
 -> LISTING FLOW
```

## Outcomes

- **One eligible exact match:** show canonical identity and variant; merchant confirms selection.
- **Multiple/conflicting matches:** no auto-link; create exception/review case.
- **No match:** broaden product search, then candidate flow with barcode provenance.
- **Invalid/unsupported code:** allow text search; do not invent identifier.

## Guardrails

- Merchant/internal SKU is shop-private and never treated as global barcode.
- Reused, malformed, packaging-level or marketplace-specific codes require ambiguity handling.
- Barcode scanning cannot override policy-blocked/discontinued state.
- GTIN auto-link allowlist and confidence threshold remain `OWNER_DECISION_REQUIRED` (`CAT-03 P0`).
- Scan permission and raw frames are minimized; no camera media retained by default.
