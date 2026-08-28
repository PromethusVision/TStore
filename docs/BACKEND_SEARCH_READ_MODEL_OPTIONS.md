# Backend Search Read Model Options

**State:** PROPOSED OPTIONS — NO SEARCH INFRASTRUCTURE

## Option A — direct relational search

Use bounded normalized fields and current active product/listing/shop filters.
Lowest operational complexity; appropriate for the pilot while data is small.
Weak for typo tolerance, synonyms, facets and multi-entity ranking.

## Option B — database-maintained search projection — recommended next step

A rebuildable read model stores stable product/variant/listing/shop/taxonomy IDs,
normalized searchable text, facet values, locality, eligibility, source revisions
and index version. Domain tables remain authoritative. Updates are idempotent and
staleness is observable.

## Option C — external search engine

Useful only after measured scale/relevance needs justify dual-system operations,
outbox/replay, privacy controls and consistency monitoring. Not a V1 prerequisite.

## Invariants

Search never creates catalog truth, availability, purchase or ad eligibility.
Inactive/policy-blocked rows fail closed even when the index is stale. Sponsored
ranking is separately labelled and cannot replace organic relevance. Mutable names
are not identity. Raw query retention and personalization remain
`OWNER_DECISION_REQUIRED`.
