# Wave 34C — Customer Taxonomy Regression Plan

**Amaç:** Canonical V1 runtime migration'ı ile Customer App'in mevcut çalışan
local-commerce akışlarını korumak. Bu belge test hazırlığıdır; remote smoke veya
taxonomy activation yapılmamıştır.

## Gate seviyeleri

- `P0`: migration/cutover öncesi otomatik PASS zorunlu.
- `P1`: Customer release öncesi otomatik PASS zorunlu.
- `P2`: UI Kit visual acceptance veya gelecekteki content-link işi.

## Regression matrix

| Flow | Test cases | Expected invariant | Class | Gate |
|---|---|---|---|---|
| Home | Yalnız 24 ordered L1/projection; all-tree node sızıntısı yok; loading/empty/error/retry; duplicate tap; long labels. | Home generic all-active query kullanmaz; display adı identity olmaz. | `MUST_CHANGE_WITH_MIGRATION` + `UI_KIT_PHASE` | P0/P1 |
| Category browse | Root→children; branch→children; leaf→products; each level error/empty; deterministic sibling order. | L1/L2/L3/L4 variable-depth; depth leaf varsayımı değildir. | `MUST_CHANGE_WITH_MIGRATION` | P0 |
| Variable depth | L2 leaf, L2 branch, L3 leaf, L3 branch, L4 leaf, structural non-assignable leaf fixtures. | Yalnız active+assignable leaf exact product destination olur. | `MUST_CHANGE_WITH_MIGRATION` | P0 |
| Product listing | Exact leaf, descendant branch, pagination, stable sort, no sibling leakage, inactive products. | Branch scope açık; leaf exact; max-20 presentation sınırı backend correctness'i gizlemez. | `MUST_CHANGE_WITH_MIGRATION` | P0 |
| Product details | Migrated product opens; image/brand/stock preserved; optional path handles long names. | Product UUID unchanged; missing category relation safe; sellers load. | Functional `NO_CHANGE`; path `SAFE_PRE_MIGRATION` | P0/P1 |
| Seller comparison | Same product across active listings; price/availability/shop status. | Taxonomy change listing veya seller identity üretmez/değiştirmez. | `NO_CHANGE` | P0 |
| Shop | Shop profile and shop products after product leaf backfill; product/sector boundary. | Product category, merchant sector yerine kullanılmaz. | `NO_CHANGE` + data-contract regression | P0 |
| Search | L1 and deep leaf, aliases, Turkish casing, duplicate leaf paths, branch/leaf selection, no-result, partial failure, stale query. | Bounded/versioned results; first-category exact-ID shortcut yok. | `MUST_CHANGE_WITH_MIGRATION` | P0 |
| Filters | Selected leaf/branch scope reset/restore; category vs brand/size/fitment separation. | Category ID facet gibi kullanılmaz; provisional full facet engine gerekmez. | Minimum `SAFE_PRE_MIGRATION`; full engine `DEFER` | P1 |
| Wishlist | Existing favorite products after FK migration; add/remove; category relation missing/renamed. | Wishlist `product_id` stable; no item loss. | `NO_CHANGE` | P0 |
| Cart V2 | Existing cart listing; totals, availability, remove/update; category relation refreshed. | Cart `shop_product_id` stable; classic checkout eklenmez. | `NO_CHANGE` | P0 |
| QR verified purchase | QR issue/scan/verify after category backfill; replay guards. | Category analytics signal değildir; verified purchase authority unchanged. | `NO_CHANGE` | P0 |
| Reviews | Eligibility, create/read/update; category rename/move. | Review `product_id` stable; rights değişmez. | `NO_CHANGE` | P0 |
| Deep links | Auth cold/warm callbacks unchanged; future category stale ID/alias tests separately disabled until content-link contract. | Taxonomy routing Auth callback'ini genişletmez. | Auth `NO_CHANGE`; content links `DEFER` | P0/P2 |
| Back navigation | L1→L2→L3→L4→product then back; refresh/rotation; stale route. | Önceki node/path state'i korunur; duplicate route yok. | `MUST_CHANGE_WITH_MIGRATION` | P0 |
| Inactive/retired category | Direct stale ID, moved alias, retired no-successor, inactive ancestor, unknown ID. | Redirect authoritative ise bir kez; aksi halde safe unavailable; root/sibling fallback yok. | `MUST_CHANGE_WITH_MIGRATION` | P0 |
| Category media | Legacy HTTPS; controlled old/new path; invalid value; failed image. | Resolver fail-closed; wrong node image erişimi yok; placeholder korunur. | Migration-dependent mapping | P0 |
| Demo mapping | 4/4 L1 bridge, 20 product final leaf, 285 listing relation; product/shop category equality removed/redefined. | Demo UUID'leri stable taxonomy ID olmaz; Product/Merchant separation korunur. | `MUST_CHANGE_WITH_MIGRATION` | P0 |
| Analytics | No runtime emitter today; future rename/move/split contract. | Display name tek identity değildir; environment/demo traffic separation. | `DEFER` | P2 |

## Test katmanları

### Unit

- Category node/model: full depth/lifecycle/path/version parsing and malformed data.
- Repository query builder: ROOT, CHILDREN, PATH, EXACT_LEAF, DESCENDANTS.
- Turkish matching/alias/path ranking veya server response mapper.
- Taxonomy version cache invalidation and retired-successor resolution.
- Product model/equality: category path update observable, IDs unchanged.

### Widget

- `HomeCategories`: complete 24 L1 fixture at 320/390/430 and text-scale matrix.
- Generic browse view: all branch/leaf combinations, loading/empty/error/retry.
- Search suggestions/results: same-name path disambiguation and long labels.
- Breadcrumb/back: L4 path, restored state, inaccessible node.
- Existing product, seller, wishlist, Cart V2 and review suites with migrated leaf fixture.

### Repository/contract

- Root read never returns lower nodes.
- Child read never leaks siblings/inactive nodes.
- Descendant products are unique, paged and stable ordered.
- Product assignment is exactly one active/assignable primary leaf.
- Alias/retire behavior matches executable bridge and taxonomy version.
- Category image object path owner matches stable node mapping.

### Controlled environment only

- Deterministic migration dry-run counts and no orphan product FK.
- Demo 20/285 mapping and merchant-sector separation.
- RLS guest discovery reads; customer cannot mutate taxonomy.
- Cold/warm app after manifest version change.
- Rollback/partial-apply resume behavior.

Production write/smoke requires ayrı yetki; bu görev böyle bir erişim yapmadı.

## Existing tests to preserve

- `test/widget/shop/home_categories_test.dart`
- `test/widget/shop/sub_category_view_test.dart`
- `test/widget/shop/home_search_bar_test.dart`
- `test/widget/shop/all_products_view_test.dart`
- `test/unit/shop/customer_search_cubit_test.dart`
- `test/unit/shop/media_model_resolution_test.dart`
- `test/unit/supabase/public_media_source_resolver_test.dart`
- `test/unit/demo_seed/esenler_demo_v1_contract_test.dart`
- `test/live/production_demo_functional_smoke_test.dart` (yalnız açık yetkiyle)

Mevcut testler loading/error/empty, duplicate tap, stale search, price loading ve
basic exact-ID davranışını korumalıdır. Eski English/Market/`category-1` fixture'ları
tek başına Canonical V1 kabul kanıtı sayılmaz.

## Go / stop

**GO for implementation support** ancak backend response/version/lifecycle ve
descendant query sözleşmesi dondurulduktan sonra. Client model/repository/navigation
ve test işi bu matrise göre parçalanabilir.

**STOP runtime activation** şu koşullardan biri varsa:

- Home root projection all-tree query'den ayrılmadı;
- branch/leaf ve exact/descendant semantics belirsiz;
- stable IDs veya product FK bridge incomplete;
- inactive/retired behavior tanımsız;
- demo shop/product taxonomy ayrımı unresolved;
- Cart V2/QR/review regression suite fail;
- media owner path veya taxonomy-version cache transition belirsiz.

`REGRESSION_PLAN: PASS`

`REMOTE_RUNTIME_TOUCHED: NO`
