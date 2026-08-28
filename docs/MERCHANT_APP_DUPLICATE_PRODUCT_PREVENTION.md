# Merchant App Duplicate Product Prevention

Status: **PROPOSED — OWNER REVIEW REQUIRED**  
Wave: 17 / WP25

## Prevention layers

1. Search-first canonical flow with Turkish synonyms and typo tolerance.
2. Exact governed identifier lookup where available.
3. Normalized brand/model/name and material attribute comparison.
4. Existing shop listing uniqueness check.
5. Likely-match confirmation before candidate submit.
6. Idempotency key and candidate fingerprint for retry duplicates.
7. Human/governed review for ambiguous merge or split.

## Never use as sole global identity

- Merchant SKU.
- Similar display name.
- Same photo.
- Same price.
- Category or merchant sector.
- A weak compatibility alias.

## Outcomes

- `EXACT_MATCH`: continue listing flow.
- `LIKELY_MATCH`: require explicit selection or review.
- `NO_CONFIDENT_MATCH`: candidate flow.
- `IDENTIFIER_CONFLICT`: fail closed and exception queue.
- `EXISTING_SHOP_LISTING`: edit existing listing rather than duplicate.

Merge/split authority, review evidence movement and barcode auto-link remain catalog owner decisions.

