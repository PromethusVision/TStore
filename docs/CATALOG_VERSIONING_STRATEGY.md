# Catalog Versioning Strategy

Status: **OWNER REVIEW DRAFT — MINIMAL V1 APPROACH**
Wave: 16, Work Package 32

Every product does not need a customer-visible semantic version. V1 needs stable
opaque identity, timestamps, field assertion history and a monotonic revision token
for concurrency/cache invalidation.

## Recommended layers

| Version | Purpose |
| --- | --- |
| Entity revision | Increments when the resolved product/variant/listing projection changes; supports optimistic concurrency and indexing. |
| Ruleset version | Identifies normalization, dedup, policy and projection logic used for a decision. |
| Taxonomy version/stable IDs | Records the placement vocabulary while stable leaf identity survives display rename. |
| Evidence/assertion version | Append-only source history with effective interval and supersession. |

Historical purchases and reviews store immutable event identities/snapshots and do not
join to “version N” to recover their original meaning. Rename or description correction
increments revision but preserves ID. Identity correction uses merge/split lineage,
not a large in-place version jump.

## Avoided complexity

- no full copy of every product for every edit;
- no user-facing `v1.2.3` for catalog records;
- no mutable audit rows;
- no requirement that all projections update in one distributed transaction;
- no rewriting analytics events to the latest catalog state.

If regulated traceability later requires complete point-in-time reconstruction, field
assertions and audit events can build a temporal projection without changing the V1
identity contract.
