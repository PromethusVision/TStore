# Production Demo Seed Safety Review

## Scope and decision boundary

- Review date: 2026-08-22
- Production project: `EsnaftaVar Production`
- Production ref: `mefhfvrgkwciubeajjeb`
- Development ref excluded from all remote access: `tnipyxnvhgelwdpykyez`
- Dataset: `esenler_demo_v1`
- Production seed applied: **YES — owner-authorized Phase C exact artifact**
- Production cleanup applied: **NO**
- Production database writes: **YES — only the exact four-table demo seed transaction**
- Production Auth/Storage/config writes: **NO**

Phase B used authenticated Supabase Dashboard access only for read-only `SELECT`
queries. Phase C repeated every just-in-time safety gate and then executed the tracked
`supabase/seeds/esenler_demo_v1.sql` artifact once as one transaction. No cleanup,
migration, schema change, Auth operation, Storage mutation, configuration change, or
other DML was executed remotely.

## Authoritative Production pre-apply baseline

The fresh Production query returned the following exact counts:

| Domain | Relation | Count |
| --- | --- | ---: |
| Catalog | `categories` | 0 |
| Catalog | `products` | 0 |
| Catalog | `shops` | 0 |
| Catalog | `shop_products` | 0 |
| Auth | `auth.users` | 0 |
| Auth | `auth.identities` | 0 |
| Auth | `auth.sessions` | 0 |
| Customer | `profiles` | 0 |
| Customer | `legal_consents` | 0 |
| Customer | `addresses` | 0 |
| Customer | `customer_saved_locations` | 0 |
| Customer | `wishlist` | 0 |
| Cart V2 | `carts` | 0 |
| Cart V2 | `cart_items_v2` | 0 |
| Legacy order | `orders` | 0 |
| Legacy order | `order_items` | 0 |
| Trust | `reviews` | 0 |
| Trust | `qr_sessions` | 0 |
| Trust | `qr_session_items` | 0 |
| Trust | `verified_transactions` | 0 |
| Trust | `verified_transaction_items` | 0 |
| Trust | `shop_ratings` | 0 |
| Communication | `chat_messages` | 0 |
| Communication | `notifications` | 0 |
| Other catalog | `brands` | 0 |
| Other catalog | `banners` | 0 |
| Storage | buckets | 3 |
| Storage | objects | 0 |

The three buckets are the canonical public-read contract:

| Bucket | Public | File limit | MIME types | Objects |
| --- | --- | ---: | --- | ---: |
| `product-images` | YES | 8 MiB | JPEG, PNG, WebP | 0 |
| `category-images` | YES | 2 MiB | JPEG, PNG, WebP | 0 |
| `banner-images` | YES | 5 MiB | JPEG, PNG, WebP | 0 |

The current Production business baseline is therefore empty. This conclusion
comes from fresh exact counts, not an older report or Dashboard estimate.

## Deterministic manifest and collision preflight

The manifest contains 366 unique UUIDv5 identifiers under the fixed namespace
`7a4f4b88-9d89-4a34-a226-5bc9807c7392`:

- 4 category IDs
- 20 product IDs
- 57 shop IDs
- 285 listing IDs

All 366 IDs were compared against their corresponding Production relations in
one read-only manifest-backed query. For every ID intersection, the query was
also prepared to compare the same controlled fields used by the seed collision
preflight. There were no intersections, so there were no rows requiring a
field-level difference classification.

| Entity | ID intersections | Exact existing demo rows | Same ID/different content |
| --- | ---: | ---: | ---: |
| Categories | 0 | 0 | 0 |
| Products | 0 | 0 | 0 |
| Shops | 0 | 0 | 0 |
| Listings | 0 | 0 | 0 |

Natural/business-key checks also returned zero for:

- category name with a different ID;
- product name with a different ID;
- product name/category pair with a different ID;
- shop name, address, or exact coordinate with a different ID;
- listing `(shop_id, product_id)` pair with a different ID;
- unexpected products under demo category IDs;
- unexpected listings touching a demo shop or product ID;
- existing product `esenler_demo_v1` markers; and
- existing `[DEMO]` shop names.

Classification: **NO COLLISION**. `EXACT EXISTING DEMO ROW` count is `0`.

## Seed SQL safety

`supabase/seeds/esenler_demo_v1.sql` has the following properties:

- one `BEGIN`/`COMMIT` transaction with local lock and statement timeouts;
- four session-local staging tables, all `ON COMMIT DROP`;
- persistent inserts only into `categories`, `products`, `shops`, and
  `shop_products`;
- deterministic UUIDv5 IDs, timestamp, coordinates, records, and prices;
- only the price variations `-8%, -5%, -3%, +3%, +5%, +8%, +10%`;
- no `UPDATE`, persistent `DELETE`, standalone/persistent `DROP`, `TRUNCATE`,
  migration, Auth write, Storage object write, or service-role dependency;
- full controlled-field ID collision checks before persistent inserts;
- natural-key and unexpected-relation collision checks;
- four `ON CONFLICT (id) DO NOTHING` clauses, used only after the fail-closed
  collision preflight; and
- postflight cardinality and five-listings-per-shop assertions.

Any exception before `COMMIT` rolls back the entire persistent change. A
partial four-table seed is therefore not committed. The apply operation should
still be run as a single controlled writer: the transaction does not take an
exclusive catalog lock, so an unrelated concurrent writer racing between the
preflight and insert/postflight is an avoidable operational risk.

Classification: **PASS for a controlled, single-writer apply**.

## Cleanup SQL safety and lifecycle boundary

`supabase/seeds/esenler_demo_v1_cleanup.sql` is also one transaction. It uses
the exact 4/20/57/285 deterministic ID arrays and requires the expected row
counts plus explicit product, shop, and listing demo markers before deletion.
It does not use a broad name, category, location, featured, or
`owner_user_id IS NULL` delete criterion.

The exact delete order is:

1. `shop_products`
2. `shops`
3. `products`
4. `categories`

Before any delete, the cleanup fails closed if it detects:

- an unexpected listing touching a demo shop/product;
- an unexpected product under a demo category;
- an unexpected child category;
- wishlist, legacy order item, review, cart, Cart V2 item, QR session/item,
  verified transaction/item, or shop-rating relationships.

This protects both restrictive foreign keys and references implemented as
durable snapshots rather than foreign keys. `chat_messages` and
`notifications` do not have direct catalog/shop foreign keys in canonical
0001-0009, so deleting the four demo entity sets cannot cascade-delete those
tables. Storage objects are not touched by cleanup.

The cleanup is safe for the current pre-launch zero-user/zero-object baseline.
It is intentionally not a general post-launch eraser. After customer or admin
activity, JSON notification payloads, media URLs/objects, historical snapshots,
or newly introduced relations may exist outside the current guards. In that
state the exact dependency inventory must be repeated and destructive cleanup
must not be run blindly.

Classification: **PASS for pre-launch exact cleanup; not pre-authorized after
user activity**.

## Customer effect and owner-less shop boundary

A successful seed would expose through current public-read policies:

- 4 active demo categories;
- 20 active and featured products;
- 57 active demo shops;
- 285 active/available listings;
- 14-15 sellers per product; and
- multiple deterministic prices per product.

`featured` is used only for demo discovery. It is not evidence of sponsorship,
advertising, paid ranking, or an advertising engine.

All 57 shops use `owner_user_id = NULL`. This does not block category/product,
shop detail, nearby shop, listing, or seller-comparison reads because those
policies depend on active/available state rather than ownership. It does block
merchant ownership mutations and merchant QR verification, because canonical
merchant/QR functions require `shops.owner_user_id = auth.uid()`.

Consequently a customer can discover and compare demo listings, and may reach
ordinary cart/customer surfaces, but a QR generated for a demo shop cannot be
confirmed by a real merchant and cannot produce a verified transaction. That
is an explicit limitation of this customer-discovery dataset, not a schema bug
to change in this phase.

## Geography review

- 57/57 coordinates are unique.
- Latitude range: `41.0267887` to `41.0940099`.
- Longitude range: `28.8504216` to `28.8962928`.
- Every coordinate is within valid latitude/longitude ranges and its manifest
  neighborhood bounding box.
- The three points per neighborhood are 50-70 metres from the recorded center.
- The first 17 neighborhoods retain OSM polygon-inside evidence.
- Şehitler and Yeşil Vadi retain the documented locality-point limitation.

All locations remain `NEIGHBORHOOD_CENTER` synthetic inputs. They must not be
presented as exact business addresses. No obvious outside-Esenler outlier was
found.

## Local clean-room replay

The current `origin/main` artifacts were replayed from a clean in-memory
PostgreSQL-compatible database:

| Stage | Categories | Products | Shops | Listings |
| --- | ---: | ---: | ---: | ---: |
| Canonical migrations 0001-0009 | 0 | 0 | 0 | 0 |
| First seed | 4 | 20 | 57 | 285 |
| Second seed | 4 | 20 | 57 | 285 |
| Representative active customer reads | 4 | 20 | 57 | 285 |
| Cleanup | 0 | 0 | 0 | 0 |

Additional results:

- migrations applied: 9/9;
- canonical public tables after cleanup: 23;
- featured products visible: 20;
- seller range: 14-15 per product;
- every product has multiple prices;
- unique valid shop coordinates: 57/57; and
- Auth/order/review/rating/QR/verified/chat/notification trust rows: 0.

## Production apply and authoritative postflight

Product-owner authorization was granted for the exact deterministic seed only. The
single-writer gate found zero other active write statements and zero other target-table
write locks. Immediately before apply, the exact baseline remained empty, all 366
manifest IDs had zero intersections, all natural-key collision counts were zero, and
there were no existing demo rows. The tracked artifact hash and clean-room replay were
unchanged from Phase B.

| Relation | Pre-apply | Applied delta | Authoritative postflight |
| --- | ---: | ---: | ---: |
| `categories` | 0 | +4 | 4 |
| `products` | 0 | +20 | 20 |
| `shops` | 0 | +57 | 57 |
| `shop_products` | 0 | +285 | 285 |

Auth users/profiles, customer/trust rows, Storage buckets, and Storage objects
had delta `0`. At `2026-08-22T17:56:01.453527Z`, Production returned exact
`4/20/57/285`, Auth users/profiles/merchant profiles `0`, three canonical buckets and
Storage objects `0`.

Manifest-backed postflight matched all `366/366` deterministic IDs and returned zero
controlled-field mismatches and zero non-manifest rows. Product demo markers were
`20/20`, `[DEMO]` shop names and null owners were `57/57`, and listing markers were
`285/285`. Coordinates were valid and unique `57/57`; all 19 neighborhoods contained
three shops. The observed shop distribution was Ayakkabı 15, Elektronik 14, Gıda 14,
Kırtasiye 14.

A separate read-only transaction executed under the actual database `anon` role. It
could see 4 active categories, 20 active and featured products, 57 active shops, and
285 active/available listings. All 20 products had 14–15 sellers and multiple prices.
This is an RLS/grant-enforced anonymous customer-read proof, not an admin-only result.

## Cleanup policy recommendation

### A. Pre-launch cleanup

While authoritative Production remains free of user-generated relationships,
the exact-ID and explicit-marker cleanup is the recommended clean deletion
model. Run a fresh dependency/count gate immediately before any separately
authorized cleanup.

### B. Post-user-activity cleanup

Once carts, favorites, reviews, QR/verified history, ratings, messages,
notifications, or media can refer to demo entities, do not run destructive
cleanup blindly. Prefer a future owner decision for soft retirement/deactivation
that preserves history and hides demo discovery rows. Any later hard cleanup
requires a new complete dependency and data-retention analysis.

## Gate result

All Phase C apply and postflight gates completed without an unauthorized write:

- exact Production ref confirmed;
- fresh baseline known;
- unsafe deterministic ID collisions: 0;
- destructive natural-key collisions: 0;
- seed SQL controlled-apply safety: PASS;
- pre-launch exact cleanup safety: PASS;
- expected delta known;
- clean-room replay: PASS;
- exact owner-authorized seed transaction: PASS;
- authoritative Production counts and manifest identity: PASS;
- anonymous customer read: PASS; and
- cleanup: not authorized and not run.

`PRODUCTION_DEMO_COLLISION_CHECK: PASS`

`DEMO_SEED_SQL_SAFETY: PASS`

`DEMO_CLEANUP_SQL_SAFETY: PASS`

`READY_FOR_OWNER_DEMO_SEED_DECISION: COMPLETED — PHASE C`

`READY_FOR_OWNER_DEMO_SEED_AUTHORIZATION: COMPLETED — PHASE C`

`OWNER_DEMO_SEED_AUTHORIZATION: GRANTED_AND_CONSUMED_FOR_EXACT_SEED`

`PRODUCTION_DEMO_SEED_APPLIED: YES`

`PRODUCTION_DEMO_COUNTS: PASS`

`PRODUCTION_DEMO_CUSTOMER_READ: PASS`

`PRODUCTION_DEMO_CLEANUP_RUN: NO`

This document now records the Phase B safety evidence and the Phase C controlled
Production apply. It does not authorize cleanup or any future Production write.

Phase C final integration accepted the Agent 1 evidence without any Production or
Development remote access. The seed was not reapplied, cleanup was not run, and no
Auth, Storage, migration, schema, or configuration operation was performed during
integration. Local generator, targeted `284/284`, full Flutter `1210` PASS with `5`
explicit opt-in live skips, and analyzer gates passed.

`WAVE_12_PHASE_C_INTEGRATION: PASS`

`PRODUCTION_DEMO_DATASET_LIVE: YES`

`PRODUCTION_DEMO_SEED_REAPPLIED: NO`

`READY_FOR_PRODUCTION_DEMO_VISUAL_SMOKE: YES`
