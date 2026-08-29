# Wave 35A — Live Schema Verification

**State:** `NOT VERIFIED — DEVELOPMENT PROJECT PAUSED`

## Evidence boundary

The exact Development project was authenticated and identified, but live
database/catalog access was disabled while the project was paused. Therefore no
claim is made that the live schema currently equals the repository migrations.

## Static canonical expectation

The active repository chain contains nine migrations (`0001`–`0009`) and builds
23 public application tables. Current-main historical records say Development
previously reached that ledger and 23/23 RLS, but this wave could not refresh
that evidence.

| Domain | Static repository contract | Fresh live result |
|---|---|---|
| `categories` | UUID PK, nullable self-parent FK, active flag, sort order, timestamps | NOT VERIFIED |
| `products` | Nullable `category_id` FK with `ON DELETE SET NULL`; product ID survives reassignment | NOT VERIFIED |
| `shop_products` / listings | Product FK only; no direct category FK | NOT VERIFIED |
| `reviews` | Product FK plus verified transaction item evidence in `0009` | NOT VERIFIED |
| Verified purchases | Durable product/listing and immutable snapshots | NOT VERIFIED |
| `wishlist` | Product FK; taxonomy change indirect | NOT VERIFIED |
| Cart V2 | Cart items bind shop listings; taxonomy change indirect | NOT VERIFIED |
| Search/category RPCs | No canonical tree/descendant/alias RPC in current source chain | NOT VERIFIED |

## Static category gap

The current migration source has no taxonomy `source_key`, slug, explicit level,
maximum-depth/cycle enforcement, assignability, lifecycle state, policy class,
professional-review status, taxonomy version, alias registry or lineage table.
It also has no category-tree/descendant search RPC. Those are additive future
requirements, not evidence of live absence until catalog verification runs.

## Differences from static migrations

**UNKNOWN.** No table, column, constraint, function or ledger comparison was
possible. A zero-drift result must not be inferred from historical audits.

## Required read-only verification pack

After the project is resumed by separately authorized action, collect in one
read-only transaction:

1. migration ledger and server version;
2. public tables and exact row counts;
3. category/product/listing/review/verified evidence/wishlist/cart columns and
   constraints;
4. foreign keys, indexes, RLS flags, policies, grants, function signatures,
   triggers and Realtime publication membership;
5. a normalized comparison against the nine tracked migration files.

Business RPCs must not be invoked.

`LIVE_SCHEMA_VERIFICATION: FAIL`

`STATIC_SCHEMA_PROFILE: PASS`

`SCHEMA_DRIFT: UNKNOWN`
