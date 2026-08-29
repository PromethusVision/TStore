# Wave 34 — Taxonomy Data Impact Matrix

Status: **STATIC IMPACT ANALYSIS — NO DATA MUTATION**

| Data/surface | Direct key dependency | Planned impact | Identity/count invariant | Risk | Required verification |
|---|---|---|---|---|---|
| `categories` | Self-parented UUID graph | Add metadata; import staged canonical nodes; retire legacy only after mapping | Canonical UUID immutable; no hard delete during cutover | High | Count by version/level/state/policy; no cycles/orphans/duplicate source keys |
| `products` | Nullable `category_id` FK | Reassign only category FK from reviewed product map | Product UUID and all commercial fields unchanged | Very high | Every active product exactly one assignable target or explicit quarantine; before/after checksum |
| `shop_products` | `product_id`, no category FK | No row rewrite expected; taxonomy follows product | Listing UUID, shop/product pair, price, availability unchanged | High | Listing counts and product joins unchanged; public gating respects product/category state |
| Product reviews | Product UUID and verified evidence | No review rewrite | Review/evidence IDs, authorship, aggregate contract unchanged | Very high | Counts/hash by product; eligibility remains server-authoritative |
| QR sessions/items | Shop/listing/product plus immutable snapshot | No historical rewrite | Exact-shop/replay/price/name evidence unchanged | Very high | Product/listing IDs and snapshots identical before/after |
| Verified transactions/items | Transaction, shop, product snapshot | No historical rewrite | Immutable verified purchase history unchanged | Very high | Row counts and hashes unchanged; no category-derived evidence claim |
| Wishlist | Product UUID | No rewrite | Wishlist membership unchanged | Medium | Owner/product pair counts identical |
| Cart V2 | Listing UUID | No rewrite | Cart item, quantity, listing relationship unchanged | High | Active cart joins remain valid even if a product is quarantined; UI handling specified |
| Search | Product text and client category matching | Add canonical label/synonym/alias resolution and descendant search | Search synonym is not identity; old redirect distinct | High | Turkish normalization, aliases, inactive/policy exclusion, latency |
| Home/category browse | Flat active list and exact ID filter | Change to root/child tree plus descendant browsing | Navigation carries stable UUID, not path label | High | L1-only Home, L1–L4 navigation, back-stack, empty/error states |
| Product details | Joined `categories(name)` | Preserve compatible projection, add breadcrumb/version later | Product URL/identity unchanged | Medium | Existing serializer and new breadcrumb both pass |
| Shop/cart product projections | Nested product/category joins | Preserve response shape or add explicit adapter | Shop/listing identity unchanged | High | No null/category-shape parsing regression |
| Analytics | No active canonical taxonomy event contract | Future events use node UUID + taxonomy version | Historical label/path changes do not split identity | Medium | Test/demo traffic marked; no retrospective false remap |
| Deep links | Product/shop IDs primary; no current category link found | Keep product/shop links stable; future category links use UUID + alias | Slug/name never durable identity | Medium | Cold/warm old links, redirect, retired node behavior |
| Category images | Possible UUID-based storage path | Reuse canonical node ID; legacy asset copy/redirect only if evidence exists | No blind object deletion | Medium | Inventory referenced objects before migration |
| Static demo seed | 4 categories, 20 products, 57 shops, 285 listings | Replace/map in separate versioned seed change | Demo UUIDs never become canonical IDs | High | Manifest/generator/cleanup/tests reconcile; dependency-aware retirement |
| Migration contract test | Nine migrations and 23 tables hard-coded | Update with future active migration/table contract | Existing chain remains immutable | Medium | Clean-room replay; security/grant/function tests |

## Cross-cutting invariants

1. Taxonomy migration changes classification, not commercial identity.
2. Product, listing, review, wishlist, cart, QR, and verified transaction UUIDs
   are never regenerated for category movement.
3. Product rating and verified-review aggregates are not recomputed from
   taxonomy labels.
4. A moved or renamed category normally keeps one canonical UUID; old labels
   become redirects/aliases.
5. A merge preserves all predecessor references in lineage.
6. A split requires deterministic product reassignment or manual review; old
   identity cannot silently point to one child.
7. `is_assignable` and public visibility are separate. Containers may be public
   but may not accept product assignments.
8. Taxonomy eligibility is not permission to sell. Policy and professional
   gates remain authoritative and fail closed.

## Static demo impact

All 285 demo listings inherit category changes through their 20 products. This
is not 285 direct listing updates. The correct unit of reassignment is the 20
product rows; the correct verification scope still includes all 285 listing
joins. Two previously simulated shoe-product mappings require manual lower-node
evidence, and five Electronics/Computer products still sit at owner-final L2
anchors pending lower-node/assignability qualification. Wave 34A completes graph
materialization; it does not turn those anchor mappings into activation authority.

## Unknown live impact

This task did not query Development or Production. Therefore the following are
UNKNOWN until the authorized read-only preflight:

- actual categories/products/listings and active-customer dependency counts;
- manual or out-of-band rows not represented in static seeds;
- applied migration history and schema drift;
- category image objects and active category links;
- products created after the static demo baseline;
- actual query latency and policy performance.
