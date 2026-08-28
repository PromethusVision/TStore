# Backend Barcode Contract

**State:** PROPOSED — SCAN IS EVIDENCE, NOT PROOF

## Barcode classes

- governed GTIN-like identifier with type, normalized value, issuer/provenance and
  verification state;
- merchant/internal barcode scoped to merchant/shop;
- unknown scanned candidate requiring resolution.

## Invariants

- a barcode never replaces internal product/variant/listing ID;
- duplicate/conflicting GTIN claims create a candidate/conflict, not auto-merge;
- checksum/format validity does not prove product match;
- reuse/retirement history is preserved;
- merchant barcode cannot resolve globally outside its namespace;
- scan input is normalized and bounded before lookup;
- policy-sensitive products may require stronger evidence.

Automatic canonical creation or merge from one scan is prohibited. The exact
evidence threshold is `OWNER_DECISION_REQUIRED`.
