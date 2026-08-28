# Backend Seller Comparison Query Model

**State:** PROPOSED — PRESERVES CURRENT CUSTOMER SEMANTICS

Input is one stable canonical product ID and, when selected, one exact variant ID.
Output is a bounded public projection of eligible shop listings joined to their
active shops.

## Required fields

- canonical product/variant and listing IDs;
- shop ID, safe display/location summary and activity state;
- price, currency, unit/basis and price freshness/provenance;
- availability state and observation time;
- merchant-local offer/media fields allowed for public display;
- deterministic order keys and read-model freshness.

## Rules

- never compare different canonical products or incompatible variants by name;
- listing price/availability belongs to the exact listing/shop;
- inactive/retired/policy-blocked product, listing or shop is excluded;
- `UNKNOWN` availability is not silently in stock;
- sort ties use stable listing/shop ID after approved price/distance/relevance key;
- one listing must not duplicate through media/facet joins;
- sponsored placement is a distinct labelled surface, not hidden seller order;
- pagination preserves all eligible sellers without offset drift.

Whether unavailable/unknown listings appear and default sort are
`OWNER_DECISION_REQUIRED`. The current 14–15 demo sellers per product remain a
useful query-contract fixture, not a production cardinality promise.
