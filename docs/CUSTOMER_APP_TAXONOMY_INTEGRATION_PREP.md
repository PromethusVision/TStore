# Customer App Taxonomy Integration Preparation

Status: **PREPARED — IMPLEMENTATION NOT STARTED**

## Likely code/data interfaces

- `lib/features/shop/domain/entities/category_entity.dart`
- category/product repository interfaces and Supabase implementations
- `GetCategoriesUsecase`, `GetProductsUsecase`, search aggregation and filters
- Home category section, sub/category listing and breadcrumb/header widgets
- Product Details category presentation and any category deep-link parser
- demo seed manifest/generator/validator and canonical migration chain
- category/product fixtures across unit, widget, live-controlled and smoke tests

## Required contract additions

- stable taxonomy node id, parent id, path/depth, active/order and version;
- leaf/descendant product filtering semantics;
- owner-approved Turkish label, synonym and facet mapping;
- deterministic old-category→canonical-node backfill with counts;
- redirect/compatibility behavior for stored links and historical data.

## Migration and rollback

Runtime code must not ship before the schema/data contract is forward-compatible.
The migration requires local clean-room replay, deterministic data analysis,
Production read-only collision/count preflight and separately authorized apply.
Rollback must preserve product/listing UUIDs and be explicit about writes made
after cutover; a blind down migration is not acceptable.

## Test plan

Variable-depth L1–L4 traversal, breadcrumb/back navigation, leaf and descendant
queries, no leakage, synonym search, facet/category separation, inactive nodes,
deep links, demo mapping, large-tree performance and rollback compatibility.

Risk: **HIGH** because taxonomy crosses data, queries and navigation. It must not
be merged with final UI-kit rollout or Production seed changes.
