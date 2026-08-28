# Customer App Search Functional Audit

Status: PASS FOR CURRENT TAXONOMY

## Architecture

`CustomerSearchCubit` queries products, categories, and shops, caches stable category/shop dictionaries, ranks exact/prefix/contains matches, filters inactive entities, merges category-derived products by product ID, and emits a partial-result warning when one source fails. A monotonically increasing request ID prevents stale queries from overwriting the latest state.

Home suggestions use a short debounce and bounded price enrichment. The full all-products view cancels pending debounce on clear/dispose, records recent searches locally, and deliberately does not paginate the bounded unified search result.

## Result matrix

| Case | Result |
| --- | --- |
| Empty query | Initial/recent-search state; no remote search. |
| Rapid typing/stale request | Only latest request can publish. |
| Duplicate submit | Suppressed while same query is loading. |
| Duplicate entity | Products merged by ID; invalid/inactive results filtered. |
| Partial backend error | Successful sections remain visible with warning. |
| Total error | Safe retryable Turkish error. |
| No result | Explicit empty result with edit/all-products actions. |
| Result navigation | Typed category/product/shop identity; missing IDs blocked; double taps suppressed. |
| Case handling | Locale-agnostic lowercase/contains in client ranking; backend search remains authoritative. |
| Pagination | Product catalogue paginates; unified search is capped, documented behavior. |

## Deferred architecture

Canonical taxonomy synonyms/facets and Turkish locale-specific folding are future taxonomy/search integration work. Implementing provisional L3/L4-aware search now would encode unapproved runtime assumptions.

`SEARCH_FUNCTIONAL_AUDIT: PASS`  
`STALE_QUERY_PROTECTION: PASS`  
`TAXONOMY_SEARCH_DEFER: YES`
