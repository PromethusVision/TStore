# Wave 36C — Customer Taxonomy Client Cutover Execution Plan

**Durum:** `LOCAL WIRING PREPARED — LEGACY RUNTIME REMAINS DEFAULT`

**Base:** `origin/main@b3cc14ebed42ab66d689fe6688c2e75e23c43e68`

Bu belge bir Development aktivasyon emri değildir. Wave 36C yalnız local Flutter
contract, adapter, Cubit ve navigation seam'lerini hazırlar. Development/Production
okunmadı; schema, RPC, data, RLS ve DI activation değiştirilmedi.

## Uygulanan client sınırı

```text
CURRENT BUILD (default)
TaxonomyRuntimeCapability.currentDefault
  -> LEGACY_RUNTIME
  -> CategoryRepository / CategoryModel / current PostgREST queries

FUTURE DEVELOPMENT CUTOVER (explicit only)
verified capability payload
  -> CanonicalTaxonomyCapabilityDto
  -> TaxonomyBackendContractProof
  -> CANONICAL_V1_RUNTIME
  -> CanonicalTaxonomyContractAdapter
  -> CanonicalTaxonomyRepositoryImpl
  -> strict canonical DTOs
  -> CategoriesCubit / CustomerSearchCubit / TaxonomyBrowseCubit
  -> Home roots / recursive browse / typed product scopes
```

Canonical mode; timeout, missing-column error, empty table, remote flag veya project
name tahminiyle açılamaz. Yalnız exact `taxonomy-client-v1` contract version, non-empty
taxonomy version ve tüm zorunlu feature'ları taşıyan bir proof nesnesi ile üretilebilir.

## Versioned DTO sözleşmesi

`CanonicalTaxonomyCategoryDto.fromRpcPayload` aşağıdaki alanları strict okur:

- `id`, `parent_id`, `name`, `slug`;
- `level` (`1..4`);
- `lifecycle_state` (`staged`, `active`, `retired`);
- `is_assignable`;
- `policy_class`;
- `professional_review_status`;
- `taxonomy_version`;
- `has_children` veya ters anlamlı `is_leaf`;
- optional `sort_order`.

Leaf/container bilgisi `parent_id`, depth veya boş child response'tan tahmin edilmez.
İki shape sinyali birlikte gelirse birbiriyle tutarlı olmak zorundadır. Eksik/unknown
enum, boş identity/version, L1 leaf, L4 container veya invalid assignability fail-closed
olur.

Policy ile görünürlük ve ürün ataması ayrıdır:

- active, non-`EXCLUDED` node discoverable olabilir;
- container discoverable fakat assignable değildir;
- normal + `not_required` + active + explicit assignable leaf ürün listing'i açabilir;
- inactive, retired, excluded, non-assignable veya policy/professional-review blocked
  leaf normal ürün listing'i gibi davranamaz.

## Repository ve adapter kontratı

`CanonicalTaxonomyRepository` şunları tanımlar:

1. `getRoots()`
2. `getChildren(id)`
3. `getDescendants(id)`
4. `getBreadcrumb(id)`
5. `resolveAlias(...)`
6. `searchTaxonomy(...)`

`CanonicalTaxonomyRepositoryImpl`, future RPC/view response'larını
`CanonicalTaxonomyContractAdapter` üzerinden alır ve strict DTO'lara map eder. Adapter
şu an network implementation taşımaz. Böylece bilinmeyen endpoint/column adı source'a
yazılmamıştır ve current Supabase client hiçbir canonical alan sorgulamaz.

Alias resolution `RESOLVED`, `AMBIGUOUS`, `TOMBSTONE`, `UNRESOLVED` durumlarını korur.
Yalnız `RESOLVED` tek direct target taşıyabilir. Split/tombstone/unresolved için first
child veya nearest-name fallback yoktur.

## Runtime/Cubit wiring

### Home

- Legacy capability: `GetCategoriesUsecase` ve mevcut state/UI davranışı aynıdır.
- Canonical capability: `CategoriesCubit` yalnız canonical repository'yi çağırır.
- Canonical Home projection tam 24 discoverable L1 ve proof ile aynı taxonomy version
  olmak zorundadır.
- 23/25 root, lower-level leakage, version mismatch veya missing repository error
  üretir; legacy source'a sessiz fallback yapmaz.

### Recursive browse

`TaxonomyBrowseCubit/View` container için reviewed `getChildren` ve
`getBreadcrumb` contracts kullanır. Child parent/level/version/duplicate/discoverability
doğrulaması client'ta da fail-closed uygulanır.

- container → yeni recursive browse route;
- L2/L3/L4 active, assignable, policy-cleared leaf → typed exact product listing;
- blocked node → disabled/unavailable;
- native route stack → deterministic back navigation;
- breadcrumb → L1'den current node'a kadar versioned response path'i.

### Search

- Legacy capability mevcut client-side category matching/cache ve first-category
  product enrichment davranışını korur.
- Canonical capability yalnız `searchTaxonomy` server contractını kullanır.
- Result matched node, full path, leaf/container decision, optional alias context ve
  taxonomy version taşır.
- Canonical mode'da speculative client-side first-match product enrichment yapılmaz.

### Product query scope

`TaxonomyScopedProductRepository` ve `GetProductsByTaxonomyScopeUsecase`:

- `EXACT_LEAF`;
- `DESCENDANTS`

scope'larını typed olarak taşır. `ProductsCubit` canonical evidence taşıyan scope için
canonical usecase ister; dependency yoksa mevcut product repository'ye düşmeden hata
verir. Yalnız explicit `hasCanonicalHierarchyEvidence=false` compatibility scope'u
current exact `category_id` davranışına gider. Nonexistent descendant RPC çağrısı yoktur.

## Exact future cutover sequence

### 1. Backend contract available

**Giriş:** reviewed additive migration/RPC/view artifactı ve exact response examples.

**İşlem:** `contract_version`, taxonomy version, feature list, field types, nullability,
errors, RLS/grants ve pagination contractını dondur.

**PASS:** payload DTO testsinin gerçek fixture kopyalarıyla eşleşmesi.

**STOP:** nullable canonical gate, undocumented enum/field veya security-definer risk.

### 2. Schema imported staged

**Giriş:** backup/rollback owner ve migration preflight PASS.

**İşlem:** canonical rows staged/inactive import edilir; old client active projectionı
değişmez.

**PASS:** stable IDs, 24 roots, hierarchy ve policy checks; current app unchanged.

**STOP:** partial import, duplicate/orphan/cycle, product identity drift.

### 3. RPC/query version verified

**Giriş:** staged schema complete.

**İşlem:** root/child/descendant/breadcrumb/alias/search/product-scope endpoints ve
capability response Development'ta read-only contract testsle doğrulanır.

**PASS:** proof tüm zorunlu features'ı ve exact taxonomy version'ı bildirir.

**STOP:** client-side full-tree scan, sibling leakage, RLS bypass, ambiguous redirect.

### 4. Canonical capability enabled in Development build

**Giriş:** concrete adapter implementations ve scoped product adapter tests PASS.

**İşlem:** Development-only DI composition'a canonical repository, product-scope
repository ve verified proof enjekte edilir. Global default değiştirilmez.

**PASS:** runtime mode açıkça `CANONICAL_V1_RUNTIME`; Production/legacy build açıkça
`LEGACY_RUNTIME` kalır.

**STOP:** environment fallback, remote flag guess veya missing adapter.

### 5. 24-root smoke

**PASS:** exact 24 ordered discoverable L1; lower-node leakage zero; long names usable.

**STOP:** count/version mismatch veya root dışı node.

### 6. Recursive browse

**PASS:** L2/L3/L4 mixed leaf/container, breadcrumb ve back navigation; blocked nodes
disabled.

**STOP:** depth assumption, dead end inferred as leaf veya stale-version mixing.

### 7. Search

**PASS:** matched node/path/type/alias/version server resultından gelir; no first-match
shortcut.

**STOP:** raw full taxonomy scan, alias ambiguity collapsed, policy-blocked leaf opens.

### 8. Product listing scopes

**PASS:** exact leaf and descendant endpoints complete, paged, deduplicated,
sibling-isolated and policy-cleared.

**STOP:** current `.eq(category_id, ...)` descendant yerine kullanılıyor veya adapter
missing.

### 9. Regression

**PASS:** Home, browse, search, product listing ile Cart V2, QR, wishlist, reviews,
seller comparison ve auth aynı artifactta PASS.

**STOP:** taxonomy-independent P0 regression.

### 10. Rollback to legacy capability if necessary

Canonical activation ayrı DI/config commitinde geri alınır; capability explicit
`LEGACY_RUNTIME` yapılır. Cache varsa environment+taxonomy-version namespace temizlenir.
Product/listing/customer IDs ve current repository sorguları değişmediği için rollback
data rewrite gerektirmemelidir. Gerçek schema rollback ayrı backend owner kararıdır.

## Bu branchte bilinçli olarak yapılmayanlar

- Supabase/Development/Production erişimi;
- migration, SQL, RLS, RPC veya remote feature flag;
- canonical remote adapter endpoint adları;
- `service_locator.dart` activation;
- final UI Kit styling;
- taxonomy node/owner karar değişikliği;
- legacy fallback silme.

## Readiness

Client-side contract, state ve navigation wiring'i backend adapter injection'ına hazırdır.
Fakat gerçek Development endpointleri mevcut olmadığı ve concrete remote adapters/DI
activation bu branchte yapılmadığı için canonical mode bugün çalıştırılmamalıdır.

`LEGACY_RUNTIME_DEFAULT: PRESERVED`

`CANONICAL_REMOTE_QUERIES: ZERO`

`DEVELOPMENT_ADAPTER_BINDING: REQUIRED_AFTER_BACKEND_CONTRACT`

`READY_FOR_DEVELOPMENT_CANONICAL_MODE_AFTER_BACKEND_APPLY: NO`
