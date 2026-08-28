# Customer App Taxonomy Runtime Dependencies

Status: **DEPENDENCY MAP — TAXONOMY NOT IMPLEMENTED**
Wave: **16 — Customer App Commercialization Closeout**

## Current assumptions

The active app uses a flat category identity (`Product.categoryId`) and current
category reads/navigation. The four-category Production demo proves this
contract, but it is not the final multi-level canonical taxonomy. Products,
shops and listings keep stable UUID identities independent from future display
labels.

| Surface | Current coupling | Required future change | Main risk |
|---|---|---|---|
| Category entity/model | Flat id/name/active presentation | Add canonical node identity, parent/path/depth and ordering without losing stable ids | Accidental label-as-identity coupling |
| Category repository/query | Flat active category list | Fetch root/children/path efficiently and preserve fail/empty states | N+1 queries or broad eager tree load |
| Product query | One `category_id` filter | Decide leaf assignment plus descendant filtering contract | Products disappear or leak between branches |
| Product FK | Stable category UUID assumption | Migrate/backfill atomically with explicit old→new mapping | Orphan/misclassified catalog records |
| Home discovery | Current flat category cards | Render owner-final L1 nodes and curated discovery independently | Featured confused with sponsored ranking |
| Category navigation | One-level destination | Carry canonical node/path and support variable L3/L4 depth | Back-stack/deep-link mismatch |
| Search | Localized flat category match | Index canonical labels, breadcrumbs and approved synonyms | Duplicate results or facet terms treated as categories |
| Filters/facets | Category-specific filters are limited | Bind facet schemas to canonical leaves/branches | Brand/color/protocol incorrectly become nodes |
| Product Details | Displays one category reference | Render stable breadcrumb while product id remains canonical | Historical links break after label moves |
| Deep links | Product/shop identity is primary | Add category-path links only with stable node ids and redirects | Slug rename breaks links |
| Demo seed | Four deterministic category ids | Version or replace demo mapping explicitly; never silently overwrite | Demo assumptions leak into real catalog |
| Tests | Flat fixtures common | Add variable-depth fixtures, boundary products, breadcrumb/filter/search tests | False confidence from one-level fixtures |
| Analytics (future) | No active analytics engine | Emit stable node id/path version, never display name alone | Reports split on rename/reparent |

## Required implementation sequence

1. Freeze owner-final taxonomy and versioned manifest.
2. Design database mapping/migration and rollback with data counts.
3. Extend domain entities and repository contracts behind compatibility tests.
4. Implement tree/path queries and deterministic search synonyms/facets.
5. Update navigation and screen presentation.
6. Migrate demo/Production data only in a separately authorized change window.
7. Run functional, performance, deep-link and physical regression.

## Non-coupling rules

- Product, shop and listing UUIDs remain durable identities.
- Brand, color, connector, capacity and compatibility remain facets.
- Sponsored placement and gamification must not be encoded in taxonomy nodes.
- Current taxonomy proposal documents were not modified and no runtime taxonomy
  code or migration was introduced in Wave 16.
