# Customer App Category and Listing Audit

Status: PASS FOR CURRENT RUNTIME TAXONOMY

## Current behavior

- Active categories are ordered by backend `sort_order` and rendered from real state.
- Empty, loading, error/retry, and invalid-ID behavior are distinct.
- Category selection passes a typed category entity/ID to the listing view.
- Product cards refuse to navigate with a missing identity and suppress rapid double taps.
- Listing pagination exists for the all-products path; category-specific views use bounded current-dataset queries.
- Sorting/filtering options operate on the current product/listing contract and do not claim to implement the owner-final future taxonomy.
- Inactive/invalid search categories and products are filtered before navigation.
- Seller-price failures do not hide valid product results, and late prices from a previous category are ignored.

## Taxonomy boundary

The owner-final canonical taxonomy documentation is not the runtime taxonomy. No JSON, schema, migration, category data, filter architecture, or L3/L4 navigation was changed. Future runtime work must preserve category identifiers, map legacy/demo products explicitly, and decide variable-depth traversal before replacing the present category model.

## Risks

- Large catalogues will require a unified pagination/filter contract for category lists rather than relying on current bounded data size.
- Deleted/inactive nodes are backend-authoritative; the client already avoids navigation for invalid identities but cannot substitute for RLS/query filters.

`CATEGORY_LISTING_AUDIT: PASS`
`CURRENT_TAXONOMY_ONLY: YES`
`TAXONOMY_RUNTIME_IMPLEMENTED: NO`
`TAXONOMY_DEFER: YES`
