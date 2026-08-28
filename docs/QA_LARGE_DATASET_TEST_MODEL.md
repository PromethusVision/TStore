# Large Dataset Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

Large-data tests use deterministic synthetic generators, not copied Production data.

## Target shapes

- products, variants, aliases, facets, and category depth/cardinality;
- shops/listings with skewed popular products and sparse local coverage;
- cart/reviews/QR history and account boundaries;
- operations queues, ads/rewards/events when runtime exists;
- pagination edges, deleted/retired records, merge/split history.

Validate stable ordering, pagination without loss/duplication, bounded memory, cancellation, indexes/query plans where available, and invariant counts. Scale tiers are small developer, CI representative, and scheduled stress; exact row counts follow observed capacity needs.

Data generation version, seed, schema, expected aggregates, and cleanup are recorded.

OWNER_DECISION_REQUIRED: set representative scale tiers after runtime baselines.
