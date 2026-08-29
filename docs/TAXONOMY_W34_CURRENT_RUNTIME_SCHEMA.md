# Wave 34 — Current Taxonomy Runtime Schema

Status: **STATIC INVENTORY — NO REMOTE DATABASE READ OR WRITE**
Base: `origin/main@6415f09c8b84d3ef1c72d642c1908c433b534994`

## 1. Scope and evidence boundary

This inventory describes the schema reconstructed from the nine canonical files
in `supabase/migrations/`, the repository clients, tests, and static demo seed.
It does not assert that Development or Production has the same row counts or
migration state. A read-only remote profile is a prerequisite of the next,
separately authorized Development task.

The historical root-level SQL files are not treated as the current migration
source of truth. `supabase/seed/README.md` and the canonical migration contract
identify `supabase/migrations/` as the active chain.

## 2. Categories table

Source: `supabase/migrations/20260812000100_0001_core_auth_catalog.sql`.

| Column | Current contract | Canonical V1 observation |
|---|---|---|
| `id` | `uuid` primary key, default `gen_random_uuid()` | Can serve as the immutable opaque node identity; a second stable-ID column is unnecessary. |
| `name` | non-null text; trimmed non-empty check | Display label only; it must not become identity. |
| `description` | nullable text | Optional presentation content. |
| `image_url` | nullable text | Presentation asset reference. |
| `parent_id` | nullable self-FK; `ON DELETE SET NULL` | Represents adjacency, but depth, cycle, and parent-level correctness are not enforced. |
| `sort_order` | non-null integer, default `0` | Sibling presentation order. |
| `is_active` | non-null boolean, default `true` | Current public visibility gate; insufficient as the only lifecycle/policy gate. |
| `created_at` / `updated_at` | non-null timestamptz | Audit timestamps, with the shared update trigger. |

Current constraints and indexes:

- primary key on `id`;
- self-FK from `parent_id` to `categories.id`;
- non-empty `name` check;
- `categories_parent_sort_idx(parent_id, sort_order)`;
- no sibling-name uniqueness, slug, source key, level, maximum-depth, cycle,
  assignability, lifecycle, policy, review-status, or taxonomy-version constraint.

RLS is enabled. `categories_read_active` grants anonymous and authenticated
clients read access when `is_active = true`. Client roles have `SELECT`, not
category mutation authority. There is no current distinction between a visible
container and an assignable leaf.

## 3. Product and listing relationships

### `products`

`products.category_id` is a nullable UUID FK to `categories.id` with
`ON DELETE SET NULL`; `products_category_idx` supports direct category filters.
The product public-read policy checks only `products.is_active = true`. It does
not require its category to be active or policy-cleared.

This mismatch matters: retiring or staging a category does not, by itself,
prevent an active product from being returned through generic product queries.
The Dart `ProductModel` currently expects a non-null string `category_id`, so
the nullable database contract also has a pre-existing client mismatch.

### `shop_products`

Source: `supabase/migrations/20260812000200_0002_shops.sql`.

- `shop_products.product_id` is non-null and references `products.id` with
  `ON DELETE RESTRICT`;
- there is no category FK on the runtime listing row;
- `(shop_id, product_id)` is unique;
- public listing visibility requires an active/available listing and active
  shop, but not an active product or publishable category.

Taxonomy therefore propagates to listings through:

`shop_products.product_id -> products.category_id -> categories.id`.

The demo manifest includes category fields beside listing fixtures for
validation convenience; those fields are not columns of `shop_products`.

## 4. Other dependent data

| Area | Static dependency | Migration consequence |
|---|---|---|
| Wishlist | `wishlist.product_id -> products.id` | Preserve product UUIDs; no direct category rewrite. |
| Cart V2 | `cart_items_v2.shop_product_id -> shop_products.id` | Preserve listing UUIDs; category changes are indirect. |
| Product reviews | Reviews bind to product UUID and verified-purchase evidence | Never recreate products just to change taxonomy. |
| QR session items | Durable product/listing and immutable price/name snapshots | Taxonomy is not evidence identity; do not rewrite snapshots. |
| Verified transaction items | Durable `product_id` plus immutable purchase snapshot | Product category reassignment must not alter verified history. |
| Storage | Category image object paths can include category UUID | Reusing category IDs avoids needless asset-path churn; legacy paths need an explicit decision if present. |
| Analytics | No active taxonomy analytics schema was found | Future events must carry stable node ID and taxonomy version, not label/path identity. |

## 5. Query, RPC, and search contract

No category-tree or descendant-search RPC exists in the canonical migration
chain. Current reads are PostgREST-based:

- the category repository selects all active categories ordered by
  `sort_order`;
- parent and child repository methods exist, but the active
  `GetCategoriesUsecase` requests the flat all-active list;
- Home renders that flat list, so activating roughly 1,500 nodes would expose
  every node as a Home category card;
- product browsing filters on one exact `category_id`; selecting an L1/L2
  container would not include descendant products;
- customer search matches category `name`/`description` client-side, then
  queries one exact category ID;
- product and shop queries join `categories(name)`, so display-name shape is
  embedded in serializers;
- no alias, redirect, breadcrumb, canonical path, or taxonomy-version lookup
  exists;
- no category-specific deep-link contract was found; current durable links are
  primarily product/shop identities.

Several presentation helpers contain legacy/demo label mappings. These are
presentation compatibility debt, not canonical identity and must not drive the
migration mapping.

## 6. Demo and test dependencies

The static Esenler demo contains four deterministic demo categories, 20
products, 57 shops, and 285 listings. The four category names are `Kırtasiye`,
`Elektronik`, `Gıda`, and `Ayakkabı`. Their deterministic UUIDv5 values belong
to the demo namespace and must not be promoted to canonical stable IDs.

Important dependencies:

- demo generator, manifest, seed, cleanup, and contract test assume exactly
  4/20/57/285;
- live demo smoke checks use the four legacy names and exact category filters;
- cleanup is deliberately fail-closed and ID-scoped. It must not be run after
  reassignment without a new collision/activity review;
- the canonical migration contract test currently hard-codes nine migration
  filenames and 23 public tables. A future active taxonomy migration and new
  tables require an explicit test update.

## 7. Canonical input state

The owner-final 22-domain resolved tree contains 1,487 materialized rows:
22 L1, 224 L2, 1,078 L3, and 185 L4, with 1,199 leaves. It contains labels,
paths, states, and policy/review metadata, but no production UUID allocation or
runtime slugs.

The complete commercial architecture has 24 L1. Wave 34A now materializes
`Elektronik` and `Bilgisayar & Tablet` with all `9 + 11` L2 anchors and the two
owner-final detailed subtrees, so structural graph coverage is complete. However,
the earlier L2 source documents did not owner-finalize exact leaf/assignability for
the remaining `8 + 10` anchor-only L2 nodes. Their Wave 34A terminal/assignable
flags remain planning candidates and must not be treated as remote activation
authority until the combined reconciliation gate is closed.

The legacy reconciliation inventory covers 651 historical nodes, including 24
unresolved rows and 210 split actions. It supplies mapping evidence, not final
runtime UUIDs.

## 8. Current-state conclusion

The database already has the correct primitive—an opaque UUID category primary
key and an adjacency parent FK—but only supports a flat public catalog
contract. The critical work is not replacing that key. It is adding explicit
canonical lifecycle, assignability, policy, alias/lineage, hierarchy validation,
and staged client compatibility while preserving all existing product/listing
and verified-evidence UUIDs.
