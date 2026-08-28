# Search Index Identity Model

Status: **OWNER REVIEW DRAFT — NO SEARCH ENGINE IMPLEMENTATION**
Wave: 16, Work Package 19

Search retrieves identity and then nearby offers. The default customer result is
one canonical product group, not one card per merchant listing.

## Indexed documents

| Document | Role | Grouping |
| --- | --- | --- |
| Product | Canonical name, brand/model, taxonomy, aliases and shared facts | Primary result group. |
| Variant | Variant label, identifiers and choice facts | Nested choices or separate result only when intent is variant-specific. |
| Shop listing | Price/availability/distance/shop SKU and local text | Seller child of product/variant; not a duplicate product result. |
| Category | Navigation intent | Returned only when query clearly targets a taxonomy concept. |

## Query behavior

1. Resolve identifiers, normalized title/aliases, model numbers, facets and
   compatibility with provenance-aware confidence.
2. Retrieve active/assignable products and policy-safe projections.
3. Group successor aliases after merge; never blend bundle with component.
4. Rank identity relevance first, then use available nearby listings for utility.
5. Display one product card with nearby seller count/price range when compatible.
6. Expand variants when a query names a size, colour, capacity, edition, pack or
   fitment; otherwise keep them as selectable children.
7. Expand shop listings only in seller comparison or a clearly shop-specific query.

## Safeguards

- Price, stock and distance can rank listings but cannot change product identity.
- Search aliases are typed and versioned; a split predecessor cannot arbitrarily
  redirect to one child.
- Merchant title spam has lower authority than canonical structured data.
- Inactive listings do not hide an active product when other nearby offers exist;
  no-offer products may be retained or suppressed according to owner discovery scope.
- Regulated/excluded policy is applied before display, not inferred from ranking.
- Analytics records product, variant and chosen listing IDs separately to preserve
  grouping performance and commercial attribution.
