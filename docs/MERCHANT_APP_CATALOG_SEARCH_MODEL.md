# Merchant App Catalog Search Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP53

## Search modes

- **Canonical discovery:** product name, brand/model, governed synonym, barcode and taxonomy context.
- **My listings:** merchant SKU, canonical display, listing state and shop scope.
- **Candidates/exceptions:** request ID, status and correction reason.

## Ranking principles

Exact identifier where unambiguous, exact normalized name/model, strong synonym, compatible taxonomy/facet match, then fuzzy candidates. Merchant sector may be a weak prior only; it never changes identity/category authority.

## Safeguards

- Search result labels canonical product, variant and existing local listing distinctly.
- Potential duplicate suggestions require confirmation/review.
- Other merchants' private SKU, price history, stock notes and provenance are not searchable.
- Policy-blocked results are not selectable for bypass.
- “No result” offers candidate flow after query refinement.

## Turkish UX

Diacritics and common synonyms support discovery while preserving exact display names. Alias collision prompts disambiguation; synonym does not create canonical identity.
