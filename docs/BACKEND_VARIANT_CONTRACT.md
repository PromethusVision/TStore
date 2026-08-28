# Backend Variant Contract

**State:** PROPOSED — VARIANT IS NOT IMPLEMENTED

A variant represents a customer-selectable identity-changing combination inside
one canonical product family, such as governed size/color/capacity where separate
offers must resolve to a precise sellable identity. It is not a free-form listing
attribute bag.

## Rules

- variant has stable ID and belongs to exactly one canonical product;
- a product with no meaningful variation may be listed without a variant;
- dimensions and values come from governed facet definitions;
- merchant cannot invent a canonical variant by writing listing text;
- listing references one exact variant or explicitly the unvaried product;
- purchase snapshot records variant ID when known and relevant;
- merge/split/correction preserves lineage and never guesses historical variant.

Current listings without variants remain valid. Backfill uses evidence; ambiguous
rows stay variant-null with an explicit resolution state.

Whether color always creates a variant and the first V1 domain set are
`OWNER_DECISION_REQUIRED`. Recommendation: introduce variants only in domains
where selection changes product identity or purchase correctness.
