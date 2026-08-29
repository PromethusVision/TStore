# Wave 35C — Customer Client Category Contract

**Durum:** `BACKWARD-COMPATIBLE LOCAL PREPARATION — RUNTIME NOT ACTIVATED`

**Base:** `origin/main@737cadd0a662b338a63ab51412c87b1520282d26`

## Amaç ve güvenlik sınırı

Bu wave, Customer App'e Canonical Taxonomy V1'in variable-depth kavramlarını saf
domain modelleri olarak ekler. Mevcut `CategoryEntity`, `CategoryModel`, repository,
PostgREST sorguları, Cubit wiring'i ve navigation davranışı değiştirilmedi.

Dolayısıyla uygulama halen yalnız mevcut kolonları okur. `level`, lifecycle,
assignability, taxonomy version, alias veya descendant RPC çağrısı yapmaz. Yeni
katman backend capability sunulana kadar runtime'a bağlanmaz.

## İki katmanlı sınır

```text
Current runtime transport (unchanged)
CategoryModel -> CategoryEntity -> existing Home/search/SubCategoryView

Future canonical capability (prepared, pure/local)
TaxonomyCategoryNode -> TaxonomyCategoryHierarchy
  -> breadcrumb / roots / children / descendants
  -> TaxonomyCategoryNavigationDecision
  -> TaxonomyProductQueryScope
  -> TaxonomyCategorySearchContext
```

Canonical modelin legacy transporttan ayrı tutulması iki riski engeller:

1. olmayan backend kolonlarının istemeden sorgulanması;
2. `parent_id` varlığından leaf, level veya assignability tahmin edilmesi.

## Domain sözleşmesi

| Kavram | Kod | Sözleşme |
|---|---|---|
| Level | `TaxonomyCategoryLevel` | Yalnız L1, L2, L3, L4. |
| Structural kind | `TaxonomyCategoryKind` | `container` veya `leaf`; depth'ten türetilmez. |
| Lifecycle | `TaxonomyCategoryLifecycle` | `staged`, `active`, `retired`. Current `is_active` ile farazî olarak eşlenmez. |
| Assignability | `TaxonomyCategoryAssignability` | Yalnız active leaf `assignable` olabilir. Structural leaf otomatik assignable değildir. |
| Node | `TaxonomyCategoryNode` | Stable ID, display name, parent, level, kind, lifecycle, assignability, order ve optional version. |
| Graph | `TaxonomyCategoryHierarchy` | Root/child/descendant/path işlemleri; duplicate, orphan, leaf-parent ve level-skip fail-closed. |
| Breadcrumb | `TaxonomyBreadcrumb` | L1'den current node'a contiguous L1–L4 data model; path presentationdır, identity değildir. |
| Query scope | `TaxonomyProductQueryScope` | `exactLeaf` ve `descendants` açıkça ayrıdır; bu wave network çağrısı yapmaz. |
| Navigation | `TaxonomyCategoryNavigationDecision` | Active container → deeper; active assignable leaf → exact listing; gated node → unavailable. |
| Search context | `TaxonomyCategorySearchContext` | Matched node, canonical breadcrumb ve leaf/container navigation evidence taşır. |

## Canonical invariants

- L1 root'tur, parent taşımaz ve Canonical V1'de leaf olamaz.
- L2 veya L3 leaf ya da container olabilir.
- L4 leaf olmak zorundadır; L5 üretilemez.
- L2–L4 node exactly one parent taşır.
- Child, parent'ın tam bir alt level'ında olmalıdır.
- Leaf child taşıyamaz.
- Yalnız active leaf assignable olabilir; staged/retired/policy-gated leaf fail-closed kalır.
- Node ID trimlenmiş, non-empty ve graph içinde unique olmalıdır.
- Sort tie; `sortOrder`, display name ve ID ile deterministik çözülür.
- Display name, breadcrumb ve taxonomy version stable identity değildir.

## Current-runtime fallback

`TaxonomyCategoryNavigationDecision.resolve` canonical node verilmezse explicit
`currentRuntimeFallback` üretir:

- destination: existing product listing;
- category ID: current `CategoryEntity.id`;
- transport-equivalent query: current exact category filter;
- `hasCanonicalHierarchyEvidence: false`.

Bu işaret önemlidir: fallback mevcut davranışı korur fakat legacy row'un canonical
leaf olduğunu iddia etmez. Canonical node verildiğinde legacy ve canonical ID farklıysa
resolver sessizce birini seçmez; hata verir.

Mevcut Home/search/SubCategoryView bu wave'de resolver'a bağlanmadığı için shipping
binary'nin davranışı byte-for-byte aynı data path'te kalır. Cutover wiring'i ancak
versioned backend capability ve compatibility testleri hazır olduğunda yapılır.

## Home, browse ve search hazırlığı

### Home

`TaxonomyCategoryHierarchy.activeRoots` 24-root projection'ı deterministik sırada
sunabilecek saf seam'dir. Current `getCategories()` çağrısı değiştirilmedi; backend
support yokken Home'u aniden 24 root'a zorlamaz.

### Subcategory/browse

`TaxonomyCategoryNavigationDecision` recursive view'in kararını UI'dan ayırır.
Container child navigation, leaf product listing açar. Mevcut `SubCategoryView`
exact-category product view olarak kalır; migration-time generic browse shell bu
kararı tüketir.

### Search

`TaxonomyCategorySearchContext` matched node'u full path ve navigation evidence ile
taşıyabilir. Current client-side category search ve first-exact-category merge
değişmedi; speculative RPC eklenmedi.

## Test evidence

Yeni unit testler şunları kapsar:

- mixed-depth L2/L3/L4 leaf ve container siblings;
- root, ordered children, descendants ve max depth;
- contiguous L4 breadcrumb;
- 24/24 owner-final L1 name fixture;
- 48-character lower-node fixture;
- L1 leaf, L4 container, duplicate, orphan, skipped level ve leaf-parent rejection;
- container/leaf navigation ve gated node fail-closed;
- explicit `EXACT_LEAF`/`DESCENDANTS` concepts;
- current-runtime fallback ve ID mismatch guard;
- future search result path/context.

Home widget regression'ı 390 px genişlikte üç gerçek uzun canonical label'ın crash,
RenderFlex exception veya erişilemez tap action üretmediğini kanıtlar. Wrapping/icon/
visual density kararı final UI Kit phase'inde kalır.

## Bu wave'de değişmeyenler

- Supabase schema, migration, RLS, RPC ve remote data;
- `CategoryModel` JSON select/parse şekli;
- category/product repository network sorguları;
- Home'un current category source'u;
- `SubCategoryView` product query'si;
- CustomerSearchCubit backend/source davranışı;
- Cart V2, QR, wishlist, reviews ve seller comparison;
- canonical manifest, demo seed ve Figma/UI Kit.

`VARIABLE_DEPTH_CLIENT_CONTRACT: PREPARED`

`CURRENT_RUNTIME_NETWORK_CONTRACT: UNCHANGED`

`REMOTE_RUNTIME_TOUCHED: NO`
