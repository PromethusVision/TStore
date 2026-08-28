# Deterministic Fixture Model

**State:** PROPOSED

## Where deterministic IDs help

- static catalog/taxonomy relationships;
- migration before/after comparisons;
- seed idempotency and exact cleanup manifests;
- stable expected snapshots and cross-client contract fixtures;
- repeatable merge/split/predecessor graphs.

Use a test-only namespace plus semantic fixture key and documented algorithm. IDs must be visibly scoped to the fixture package and must never be copied from or guessed to match Production entities.

## Where unique run IDs are required

Remote accounts, mutable shop/listing/QR/review/event rows and parallel CI runs need a run suffix to avoid cross-run collision. Deterministic base data may coexist with run-unique transactional children.

## Clock and randomness

Inject a fixed clock and seeded pseudo-random generator for unit/property scenarios. Expiry/concurrency tests also include boundary times and real overlapping transactions. Do not freeze time in a way that bypasses server trusted-time behavior.

## Safety

- No real email, phone, business, barcode or credential.
- Same ID with different payload is a fixture conflict, not an upsert overwrite.
- Cleanup consumes an exact manifest and verifies ownership/expected counts.
- Namespace/algorithm changes are versioned; existing fixture identity is not silently regenerated.

`PRODUCTION_IDS_REUSED: NO`
