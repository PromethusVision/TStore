# Legacy Product Migration Impact Analysis

Status: **OWNER REVIEW DRAFT — READ-ONLY, NO MIGRATION**
Wave: 16, Work Package 33

## Evidence baseline

Read-only Wave 15 reconciliation evidence inventories 651 legacy taxonomy nodes,
83 split-registry rows (69 still requiring owner decision), zero merge-registry rows,
29 historical sample products and 20 current demo products requiring eventual
assignable-leaf mapping. Live Production/Development product counts were not queried
for this task and are not inferred.

## Target mapping envelope

Each legacy product eventually needs:

- source record ID and source system/version;
- candidate canonical product ID or new product candidate;
- candidate variant/implicit default variant;
- canonical stable taxonomy leaf mapping and mapping confidence;
- brand/manufacturer/model, pack/measure and identifier assertions with provenance;
- existing shop listing mappings and collision report;
- review, wishlist/cart, QR/verified purchase and analytics impact;
- decision state, owner/reviewer and rollback/alias plan.

## Migration rules

1. Inventory read-only counts and dependency references before any write.
2. Normalize and generate candidates; never use title/category equality as automatic
   identity proof.
3. Reuse canonical product only when dedup confidence and conflicts meet an approved
   rule. Otherwise create a non-active candidate for review.
4. Preserve source IDs as typed aliases. Display rename or taxonomy move preserves
   product identity when semantics are unchanged.
5. Legacy taxonomy merge/split does not imply product merge/split. Evaluate physical
   identity independently.
6. On taxonomy split, map products one by one to a successor leaf; never redirect all
   products to an arbitrary child.
7. Convert product-level legacy price/stock only through an explicit listing mapping;
   do not declare them canonical facts.
8. Preserve review and verified purchase history. Product split needs immutable
   snapshot proof; ambiguous records remain historical and excluded from guessed
   successor aggregates.

## Risk gates

P0: unresolved taxonomy root decisions, duplicate/review collisions, identifier
conflict, ambiguous product split, policy-sensitive record, verified-history mapping,
and listing reassignment. P1: missing brand/pack/variant evidence and search aliases.
P2: canonical copy/media cleanup after identity is safe.

No source branch was merged; no legacy/canonical record, schema, demo data or remote
environment was changed.
