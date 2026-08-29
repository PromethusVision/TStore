# Wave 35A-R — Live Schema Verification

**State:** `PASS — LIVE DEVELOPMENT SCHEMA PROFILED READ-ONLY`

## Authoritative live baseline

The exact Development project was Healthy after the owner-authorized resume.
Single `SELECT` statements inspected the migration ledger, system catalogs and
row counts; no business RPC or mutation was executed.

| Measure | Live result |
|---|---:|
| Postgres | 17.6 |
| Migration ledger entries | 9 |
| Canonical migration names present | `0001`–`0009` |
| Public tables | 23 |
| Public tables with RLS | 23 |
| Public policies | 52 |
| Public functions | 29 |
| Public table triggers | 23 distinct / 33 event rows |
| Realtime publication tables | 2 |
| Storage buckets / objects | 3 / 0 |

All 23 public application tables had zero rows. This includes categories,
products, listings, reviews, verified purchase evidence, wishlist, carts, QR,
chat, notifications, profiles and all other canonical tables.

## Taxonomy-facing schema

### `categories`

Live columns are `id`, `name`, `description`, `image_url`, `parent_id`,
`sort_order`, `is_active`, `created_at`, and `updated_at`. The UUID primary key
defaults to `gen_random_uuid()`. `parent_id` is nullable and references
`categories(id) ON DELETE SET NULL`. The name has a non-empty check.

### `products`

Live columns include the UUID identity, display/content fields, legacy base
price/stock fields, `category_id`, `brand_id`, media, rating aggregates,
featured/active flags, `attributes` JSONB and timestamps. `category_id` is
nullable and references `categories(id) ON DELETE SET NULL`. There is no live
taxonomy version, stable source key, lifecycle, assignability or policy column.

### Transitive product dependencies

The live schema contains the expected product/listing relationships in
`shop_products`, `wishlist`, `cart_items_v2`, `reviews`, `qr_session_items` and
`verified_transaction_items`. The durable `product_id` columns added by `0009`
are present in QR and verified transaction item snapshots. No row currently
exercises any dependency.

## Static-to-live comparison

The inspected table, column, key, index, policy, trigger, Realtime and Storage
outcomes agree with the tracked `0001`–`0009` application contract. Two lineage
differences must remain explicit:

1. ledger names match, but live version stamps for `0001`–`0008` differ from the
   current local migration filename prefixes; `0009` matches;
2. live `public.rls_auto_enable()` is an additional Supabase platform-managed
   event-trigger function, not an application migration/RPC.

No other material drift was found in the taxonomy-related inspected scope. This
is not a claim that every byte of every function body was normalized against
source; signatures, security-definer state and category/product references were
profiled without invoking functions.

## Additive gaps confirmed live

The current live schema has no explicit taxonomy level/depth, stable source key,
taxonomy version, assignability, lifecycle, policy class, professional-review
state, alias/redirect registry, lineage graph or category-tree/descendant RPC.
These remain future additive design requirements; no such object was created.

`LIVE_SCHEMA_VERIFICATION: PASS`

`MIGRATION_LEDGER_PROFILE: PASS`

`SCHEMA_DRIFT: KNOWN_LINEAGE_ONLY`

`BUSINESS_RPC_INVOKED: NO`

`REMOTE_SCHEMA_MUTATED: NO`
