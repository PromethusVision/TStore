# Wave 35A — Taxonomy Database Dependency Profile

**State:** `STATIC PROFILE COMPLETE — LIVE METADATA NOT VERIFIED`

## Static dependency graph

`categories.id` is the opaque category identity. Direct and transitive runtime
dependencies are:

```text
categories.id
  <- categories.parent_id
  <- products.category_id
       <- shop_products.product_id
            <- cart_items_v2.shop_product_id
       <- wishlist.product_id
       <- reviews.product_id
       <- qr_session_items.product_id (0009)
       <- verified_transaction_items.product_id (0009)
```

Orders and verified purchase rows preserve historical product/listing evidence;
taxonomy migration must not recreate those identities or rewrite immutable
snapshots.

## Static metadata inventory

| Area | Repository source-of-truth | Live status |
|---|---|---|
| Category RLS | Enabled in `0001` | NOT VERIFIED |
| Category policy | `categories_read_active` permits anon/auth reads only for active rows | NOT VERIFIED |
| Product RLS | Enabled in `0001` | NOT VERIFIED |
| Product policy | `products_read_active` checks product active state, not category policy/activation | NOT VERIFIED |
| Category index | `categories_parent_sort_idx(parent_id, sort_order)` | NOT VERIFIED |
| Product category index | `products_category_idx(category_id)` | NOT VERIFIED |
| Category self-FK | `parent_id -> categories.id ON DELETE SET NULL` | NOT VERIFIED |
| Product category FK | `category_id -> categories.id ON DELETE SET NULL` | NOT VERIFIED |
| Category triggers | shared `set_updated_at` trigger | NOT VERIFIED |
| Category/tree RPC | none in tracked `0001`–`0009` | NOT VERIFIED |
| Realtime | tracked publication membership is only `chat_messages` and `notifications` | NOT VERIFIED |

## Query and client coupling

Static client evidence shows active categories are currently loaded as a flat
list; product filtering uses one exact `category_id`; category label/description
matching is partly client-side; and no alias, breadcrumb, descendant or taxonomy
version read contract exists. A full 1,563-node activation would therefore be
unsafe before compatible root/child/descendant reads exist.

## Missing live questions

Because system catalogs were unavailable, Wave 35A could not verify:

- unexpected indexes or foreign keys;
- policy/grant drift;
- function body/signature drift;
- extensions and server capabilities;
- Realtime membership drift;
- category image object references;
- out-of-band tables/views/functions using `category_id`.

These remain mandatory before migration authoring or Development write
authorization.

`RLS_FUNCTION_INDEX_PROFILE: PARTIAL_STATIC_ONLY`

`BUSINESS_RPC_INVOKED: NO`

`REMOTE_METADATA_MUTATED: NO`
