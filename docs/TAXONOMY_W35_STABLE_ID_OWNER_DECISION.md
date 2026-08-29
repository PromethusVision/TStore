# Wave 35A — Stable Taxonomy Identity Owner Decision

**State:** `CONFIRMED — PRODUCT OWNER FINAL`

**Scope:** Canonical Product Taxonomy identity semantics only. This record does
not allocate an ID, authorize a migration, activate a node, or change a remote
environment.

## Final contract

1. An existing `categories.id` UUID remains the canonical stable identity when
   the semantic category identity survives.
2. A genuinely new canonical node receives a new opaque UUIDv4 from a trusted,
   backend-controlled allocation process.
3. A rename that preserves semantic identity preserves the UUID.
4. A move that preserves semantic identity preserves the UUID.
5. A split does not silently make the predecessor UUID the identity of an
   arbitrary child. Genuinely new successors receive new UUIDs where required;
   the predecessor remains lineage evidence.
6. A merge keeps an explicit predecessor/successor graph and preserves history.
   No predecessor identity is silently reused for a different meaning.
7. A retired UUID becomes a historical tombstone and is never reused.
8. `CANONICAL-xxxxxx` values are planning/import-reconciliation keys only. They
   are never runtime IDs.
9. Barcode, slug, display name, Turkish label, full path and parent path never
   determine taxonomy identity.

## Separation of decisions

The following remain separate future gates:

- Development live UUID-preservation classification;
- trusted UUIDv4 allocation ledger design and review;
- actual ID allocation;
- migration creation and local rehearsal;
- Development write/apply authorization;
- assignability, professional review and pilot activation;
- any Production planning or authorization.

Canonical existence is not runtime assignability, and runtime assignability is
not publication or sales permission. Policy and professional-review metadata
remain fail-closed.

`STABLE_ID_OWNER_DECISION: FINAL`

`PRODUCTION_IDS_ALLOCATED: NO`

`REMOTE_WRITE_AUTHORIZED: NO`

