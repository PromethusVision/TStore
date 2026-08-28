# EsnaftaVar Legacy Taxonomy Product Impact

**State:** STATIC REPOSITORY ANALYSIS ONLY — PRODUCTION/DEVELOPMENT NOT QUERIED

## 1. Evidence boundary

This analysis uses only tracked repository files. It does not assert what is
currently deployed, how many live products exist, or whether a historical seed was
ever executed. No database, Supabase project, runtime taxonomy, product, or seed
was modified.

Reviewed static evidence includes:

- `docs/data/esnaftavar_category_taxonomy_v1_final.json`;
- `tool/demo_seed/esenler_demo_v1.json` and its generator/SQL outputs;
- `supabase_sample_data.sql`;
- `supabase_seed_shops_shop_products.sql`;
- the canonical catalog migration and category/product repository/model code.

## 2. Runtime reference contract visible in the repo

The current catalog schema stores categories in `public.categories` with UUID
`id` and nullable UUID `parent_id`. `public.products.category_id` is a nullable
foreign key to that table. `shop_products` references a product, not a category,
so its taxonomy impact is indirect through the product.

The Flutter client:

- reads active categories from Supabase;
- loads a category and its children by UUID;
- filters products by exact `category_id` UUID;
- joins only the category `name` into product reads;
- has no visible runtime import of the 651-node documentation JSON;
- has no runtime alias/redirect or taxonomy-version resolver;
- does not visibly aggregate all descendant product IDs when filtering a parent.

Therefore the repository contains an active UUID-based catalog model, but no
static evidence binding those UUIDs to the legacy JSON slugs. A final tree
migration will need a deliberate stable-ID bridge and likely descendant-aware
query behavior; renaming files alone cannot accomplish it.

## 3. Direct references to the 651-node legacy source

| Question | Static result |
|---|---|
| Products carrying a legacy JSON slug/ID as their category reference | 0 observed |
| Exact legacy opaque IDs available for comparison | 0; the legacy JSON has no opaque IDs |
| Runtime import/seed of the final 651-node JSON | 0 observed |
| One-to-one safe stable-ID references | 0 |

Two modern demo slugs, `elektronik` and `ayakkabi`, lexically match legacy L1
slugs. Their demo rows use independently generated UUIDs, so this is not evidence
that the legacy taxonomy was deployed or that identity is shared.

## 4. Current Esenler demo fixture

`tool/demo_seed/esenler_demo_v1.json` is internally consistent and contains:

| Fixture object | Count |
|---|---:|
| Categories | 4 |
| Products | 20 |
| Shops | 57 |
| `shop_products` listings | 285 |

| Demo category slug | Demo UUID | Products | Listings | Canonical impact |
|---|---|---:|---:|---|
| `kirtasiye` | `0720c62d-d95b-53a9-b82c-7b977dd50f6e` | 5 | 70 | L1 becomes `Kırtasiye & Ofis`; lower target is provisional. |
| `elektronik` | `08fb71f3-472c-5395-b1e7-ef8124d9b78c` | 5 | 70 | Four products remain Electronics; the wireless mouse moves to Computer & Tablet. |
| `gida` | `99c4c6c8-6466-5313-a03d-f1b3ec68956d` | 5 | 70 | L1 becomes `Gıda & İçecek`; lower target is provisional. |
| `ayakkabi` | `f9fb8fdc-fc9a-5db1-9da9-a1b7770f54be` | 5 | 75 | L1 remains Ayakkabı; lower target is provisional. |

The five technology products can be placed at owner-final L2 boundaries from
their product type: charger, cable, and powerbank to
`Güç, Şarj & Bağlantı`; Bluetooth headset to `Ses & Kulaklık`; wireless mouse to
`Bilgisayar & Tablet > Klavye, Mouse & Çevre Birimleri`. This is a static
classification observation, not a product mutation.

The other 15 products depend on unapproved L2 proposals. All 20 still need a
canonical assignable leaf decision before a real leaf-only taxonomy launch.

## 5. Historical broad sample fixture

The older `supabase_sample_data.sql` contains a separate dataset:

| Fixture object | Count |
|---|---:|
| Categories | 5 |
| Products | 29 |
| Related `shop_products` rows in separate seed | 34 |
| Category-style banner paths | 4 |

Its categories are broad demo labels: Electronics, Clothing, Shoes, Furniture,
and Accessories. They are not a representation of the legacy 651-node tree. The
product population also proves that broad category-name mapping is unsafe:

- Electronics includes headphones and a phone case, but also laptops, a computer
  mouse, and a toaster that cross to Computer & Tablet or Home Appliances;
- Clothing includes a baseball cap that may move to Bags & Accessories;
- Accessories mixes a go-kart, luggage, handbag, tumbler set, and electric bike
  across several canonical domains;
- Shoes is L1-compatible, but each product still needs a leaf assignment;
- Furniture can bridge to Home & Living, whose L2 remains provisional.

The four `/category/electronics|clothes|shoes|furniture` banner strings are stale
fixture paths, not legacy taxonomy slugs and not proof of a current production URL
contract. They would still need redirect/deep-link validation in a future runtime
migration.

## 6. Product reassignment result

| Impact class | Static result |
|---|---|
| Exact stable-ID-preserving product references | 0 |
| Modern demo products with owner-final L2 placement evidence | 5 |
| Modern demo products whose L2 target is provisional | 15 |
| Modern demo products needing eventual assignable-leaf decision | 20 |
| Historical sample products needing eventual assignable-leaf decision | 29 |
| Production products affected | UNKNOWN |
| Development products affected | UNKNOWN |

The two fixture sets are independent and must not be summed as a live product
count. Static classification evidence also must not be treated as permission to
execute either seed or update any product.

## 7. Downstream impact

### Products

A product holds one category UUID. Rename/move can preserve that UUID only after a
real identity bridge exists. Split leaves require reclassification; assigning the
same product to several primary categories would violate the canonical single-leaf
principle.

### Shop products

Listings reference product IDs, so they do not require a separate category update
when the product's stable identity remains. They are still affected in discovery,
filters, analytics, ads, and merchant catalog views through the product category.

### Reviews and purchase history

Observed review/purchase contracts reference product/listing identity, not legacy
taxonomy slugs. Historical category analytics may nevertheless need taxonomy
version context. Product/review rows must not be rewritten merely to beautify a
display path.

### Demo data

Both demo fixtures need an explicit post-owner taxonomy update plan. The modern
demo's deterministic UUIDs are fixture IDs, not canonical stable IDs. A future
seed regeneration must preserve idempotency and cleanup safety while adopting
approved canonical nodes.

## 8. Unknowns

- Live Product/Development category and product counts are unknown.
- Whether either static seed was deployed is unknown.
- Current live UUID-to-category-name/path relationships are unknown.
- Saved filters, analytics payloads, external URLs, merchant imports, and ads that
  may embed category UUIDs or labels are unknown.
- Product attributes needed to deterministically classify split leaves are
  unknown.

These unknowns require a future authorized Development dry-run and read-only data
profile after owner finalization. They are not blockers to completing this static
audit, but they block an executable Production migration plan.
