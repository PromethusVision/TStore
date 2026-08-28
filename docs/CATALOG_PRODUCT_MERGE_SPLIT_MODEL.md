# Product Merge / Split Model

Status: **OWNER REVIEW DRAFT — NO DATA MIGRATION**
Wave: 16, Work Package 10

## Duplicate merge

A merge declares several erroneous duplicate records to be predecessors of one
surviving canonical identity. It is not a destructive delete.

1. Freeze new edits/listing attachments to the candidates.
2. Compare identifiers, variants, policy and provenance; block if any unresolved
   identity conflict remains.
3. Choose or create the survivor by evidence quality, not oldest ID alone.
4. Reassign active shop listings only after duplicate listing collision rules.
5. Add permanent typed predecessor aliases and an immutable merge event.
6. Recompute derived search/review aggregates while preserving source rows.
7. Keep old IDs resolvable for deep links, analytics and historical evidence.

Reviews under the existing rule become at most one active review per customer and
surviving canonical product. If a customer reviewed both duplicates, neither row
is silently discarded: one visible result requires an owner-approved collision
policy and the other remains immutable history pending resolution.

## Wrong merge split

A split creates two or more successor identities from one incorrectly broad
record. There is no safe arbitrary redirect from predecessor to one child.

- Classify every variant, identifier, listing and media assertion to a successor.
- Historical reviews and verified purchases move only when their stored snapshots
  prove the successor. Ambiguous history remains attached to a retired predecessor
  history node and is excluded from successor aggregates until reviewed.
- Wishlist/cart active references require customer-visible reassignment or a safe
  invalidation; no guessed variant selection.
- Analytics preserves predecessor event facts and introduces an explicit mapping
  with confidence/effective time rather than rewriting old events.

## Listing collision rules

If a shop has two listings that would converge after a merge, do not create two
active offers for the same product/variant. Compare merchant SKU, price, lifecycle
and inventory semantics. The merchant or a deterministic owner-approved rule must
choose the surviving active listing; the other becomes historical/redirected.

## Reversibility and gates

Merge/split events record actor, reason, evidence, mapping, affected counts,
ruleset version and rollback link. Search indexing and derived aggregates can be
rebuilt; historical snapshots cannot be overwritten. P0 review is required when
verified purchase, reviews, policy class or ambiguous variants are affected.
