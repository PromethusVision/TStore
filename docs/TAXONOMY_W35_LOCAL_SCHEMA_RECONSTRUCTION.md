# Wave 35 — Local Schema Reconstruction

Status: **LOCAL REHEARSAL ONLY — ZERO SUPABASE REMOTE ACCESS**

## 1. Environment selection

The host had no local Supabase CLI, Docker, Podman, native PostgreSQL
server/client, or WSL installation. A previously cached, local PGlite package
was available, so no package installation or network access was needed.

Primary clean room:

- Node.js `24.19.0` from the bundled Codex runtime;
- PGlite `0.5.5`;
- PostgreSQL `18.3` compiled to WASM;
- in-memory disposable PostgreSQL database;
- harness: `tool/taxonomy_rehearsal/w35_pglite_rehearsal.mjs`.

Independent compatibility cross-check:

- Python `3.12.13`;
- SQLite `3.53.1`;
- disposable foreign-key/transaction/check/trigger/recursive-CTE database;
- harness: `tool/taxonomy_rehearsal/w35_clean_room_rehearsal.py`.

The PostgreSQL-WASM run proves the hardened draft's PostgreSQL syntax,
`plpgsql` hierarchy trigger, UUID/FK/check/partial-index behavior, RLS role
visibility, full import, idempotency, rollback, and failure injection. PGlite
is not the managed Supabase service and its local timings are not remote
performance evidence.

## 2. Current repository migration chain

The active repository chain contains nine migrations:

1. core auth/catalog;
2. shops/listings;
3. Cart V2;
4. QR verified purchases;
5. verified shop ratings;
6. chat/notifications/account;
7. storage/realtime;
8. profile role-guard correction;
9. verified product reviews/storage.

The rehearsal reconstructed taxonomy-sensitive portions rather than attempting
to translate unrelated PostgreSQL/Auth/Storage statements into SQLite.

Separately, the repository's existing PGlite canonical-migration validator ran
all nine active migrations successfully and reported:

- 23 public tables;
- expected banner/category/product storage buckets;
- verified product-review RPC lifecycle;
- durable product snapshot and legacy-review isolation guards.

The active migration files were unchanged between the Wave 34 and Wave 35 base.

## 3. Reconstructed current tables

### `categories`

Reconstructed from migration 0001:

- UUID-shaped opaque text primary key in the fallback engine;
- non-empty `name`;
- nullable self-referencing `parent_id` with `ON DELETE SET NULL`;
- `description`, `image_url`, `sort_order`, `is_active`, timestamps;
- parent/sort index.

The primary PGlite run used native PostgreSQL `uuid`. The secondary SQLite run
stored the same rehearsal concept as text. Every UUIDv4 was ephemeral and
remained only inside the disposable databases.

### `products`

- primary key;
- nullable `category_id -> categories.id ON DELETE SET NULL`;
- non-negative price/stock;
- active flag and synthetic attributes;
- category index.

### Shop/listing dependencies

- `shops` with active state;
- `shop_products.shop_id -> shops.id ON DELETE CASCADE`;
- `shop_products.product_id -> products.id ON DELETE RESTRICT`;
- unique `(shop_id, product_id)`;
- price, availability, and active checks.

There is no listing category FK; category impact propagates through the
preserved product ID.

### Historical and customer dependencies

The rehearsal retained representative constraints for:

- `reviews.product_id -> products.id`;
- `wishlist.product_id -> products.id`;
- `cart_items_v2.shop_product_id -> shop_products.id ON DELETE RESTRICT`;
- `verified_transaction_items.product_id -> products.id ON DELETE RESTRICT`
  plus immutable name/price snapshots.

These tables verify that taxonomy reassignment does not recreate commercial or
verified-evidence identities.

## 4. Representative current data

The disposable current-state seed contained:

- 11 legacy/synthetic categories;
- 13 products and 13 shop listings;
- one shop;
- one review, wishlist row, cart row, and verified transaction item.

Product roles covered:

`KEEP`, `RENAME`, `MOVE`, `RENAME_AND_MOVE`, `MERGE`, exact decided `SPLIT`,
undecided `SPLIT`, `RETIRE`, `OUT`, `UNRESOLVED`, policy review, and two
demo-like product/listing rows.

All identities and user locators are synthetic. No real email, phone, user ID,
merchant ID, project ref, or remote data was used.

## 5. Additive rehearsal schema

The local migration added the proposed category fields:

- `source_key`;
- `slug`;
- `level` constrained to 1–4;
- `lifecycle_state`;
- `is_assignable`;
- `policy_class`;
- `professional_review_status`;
- `taxonomy_version`.

It also added:

- partial unique indexes for source key and slug;
- hierarchy/order/public-tree indexes;
- parent-level and cycle rejection triggers;
- ephemeral planning-key allocation ledger;
- predecessor/successor relationship table;
- alias locator table;
- separate many-to-many alias-target edge table;
- product mapping snapshot, decision, and quarantine tables used only by the
  rehearsal.

## 6. Important alias-model correction

The previous draft required every alias to have one non-null target. The source
contract contains:

- 210 ambiguous split aliases with multiple successors;
- 24 unresolved aliases;
- 7 out-of-product-taxonomy tombstones;
- 1 retired tombstone.

A single mandatory target would force data loss or a blind redirect. The
rehearsed model instead uses:

- one alias locator row;
- `RESOLVED`, `AMBIGUOUS`, `TOMBSTONE`, or `UNRESOLVED` state;
- nullable direct target only for an exact resolved alias;
- zero/one/many target edges in `taxonomy_alias_targets`.

Controlled `SEARCH_SYNONYM` rows use a separate alias kind and never inherit
redirect behavior automatically.

## 7. PostgreSQL/RLS evidence and remaining limits

PGlite validated:

- the nine-file current migration chain;
- the guard-removed local copy of the hardened docs-only draft;
- native UUID, FK, check, unique/partial/expression index, `plpgsql` trigger,
  recursive CTE, and transaction behavior;
- anon RLS visibility of exactly 313 safely activated rehearsal nodes;
- denial of direct anon access to the allocation/administrative tables;
- two complete forward/rollback cycles.

Still unproven until a separately authorized live preflight/rehearsal:

- exact managed Supabase PostgreSQL version/extensions and schema drift;
- remote execution plans, locks, and data volume;
- complete future product/listing public projection/RPC policy;
- actual Development grants and migration ledger;
- backup/restore evidence and real product classification workload.

No remote environment was used to substitute for these remaining checks.
