# Wave 35A-R — Taxonomy Database Dependency Profile

**State:** `PASS — LIVE RLS/FUNCTION/INDEX PROFILE COMPLETE`

## Live dependency graph

```text
categories.id
  <- categories.parent_id
  <- products.category_id
       <- shop_products.product_id
            <- cart_items_v2.shop_product_id
       <- wishlist.product_id
       <- reviews.product_id
       <- qr_session_items.product_id
       <- verified_transaction_items.product_id
```

All live tables in this graph contain zero rows, so the future taxonomy import
has no current user/catalog data to reclassify. The constraints still matter for
the migration design and local rehearsal.

## Category/product metadata

| Area | Live result |
|---|---|
| Category RLS | Enabled |
| Product RLS | Enabled |
| Category public-read policy | `categories_read_active`, anon/auth, `is_active = true` |
| Product public-read policy | `products_read_active`, anon/auth, `is_active = true` |
| Category indexes | PK; `categories_parent_sort_idx` |
| Product indexes | PK; category; brand; partial active; partial featured |
| Category self-FK | `parent_id -> categories.id ON DELETE SET NULL` |
| Product category FK | `category_id -> categories.id ON DELETE SET NULL` |
| Category/product triggers | one `BEFORE UPDATE` timestamp trigger each |
| Category/tree RPC | None |
| Realtime | only `chat_messages`, `notifications` |

The product read policy does not check category lifecycle or policy status. A
future staged import must therefore keep canonical nodes inactive and avoid
assigning visible products until compatible fail-closed reads/policies are
deliberately designed and tested.

## Function and trigger profile

- public functions: **29**;
- security-definer functions: **24**;
- function definitions mentioning product identity: **14**;
- function definitions mentioning category text: **1**;
- distinct public table triggers: **23**;
- category/product trigger event rows: **2**.

Product-coupled functions include QR issue/verification/confirmation, verified
snapshot guards, product review eligibility/read/mutation, product rating refresh
and active media validation. They were inspected by signature/definition text
only and were not invoked. The sole category-text match is the media storage
contract; there is no current category traversal/search RPC.

The 29-function total includes known platform `rls_auto_enable()` alongside 28
application functions from the canonical chain. The platform function is not a
taxonomy migration candidate.

## Storage profile

| Bucket | Public | Limit | MIME allowlist |
|---|---|---:|---|
| `banner-images` | yes | 5 MiB | JPEG, PNG, WebP |
| `category-images` | yes | 2 MiB | JPEG, PNG, WebP |
| `product-images` | yes | 8 MiB | JPEG, PNG, WebP |

All three buckets contain zero objects. No Storage operation was performed.

`RLS_FUNCTION_INDEX_PROFILE: PASS`

`CATEGORY_PRODUCT_DEPENDENCY_PROFILE: PASS`

`BUSINESS_RPC_INVOKED: NO`

`REMOTE_METADATA_MUTATED: NO`
