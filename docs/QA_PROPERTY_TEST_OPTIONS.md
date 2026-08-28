# Property Test Options

**State:** PROPOSED — NO IMPLEMENTATION

Property-based tests generate varied inputs while checking stable invariants.

## Strong candidates

- taxonomy tree: unique stable IDs, one parent, level/depth, no cycle, alias resolution;
- idempotency: same operation/payload has one effect, changed payload conflicts;
- state machines: only permitted QR/review/listing/account transitions;
- price/quantity: non-negative, bounded precision, immutable purchase snapshot;
- serialization: encode/decode round-trip and unknown-field tolerance;
- identity: rename/move cannot alter immutable identity;
- pagination/order: no duplicate/lost record under stable snapshot.

Generators need deterministic seeds, shrinking, domain-valid/invalid partitions and reproducible failure output. They complement example tests and never generate traffic against Production.

Recommendation: adopt first for pure taxonomy/state/serialization logic after concrete runtime APIs exist.

OWNER_DECISION_REQUIRED: none before implementation; engineering selects tooling within approved dependency policy.
