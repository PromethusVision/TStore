# W52K-A canonical Production RC — BLOCKED at Phase 2

The authorized discovery completed on main `c02186873ff7939de7007794bcbe14b141450e33`. Production's normal publishable-key client cannot read the staged canonical dataset through an existing preview path. Per the explicit Phase 2 STOP instruction, no client changes, version bump, tests/build/signing or device install followed. Production remains unchanged and public activation is OFF.

## Actual runtime selection and client trace

This trace was read from current source, not inferred from historical release documents. Local Development source was inspected to identify the existing mechanism; no Development backend was accessed.

| Source / symbol | Observed behavior |
| --- | --- |
| `lib/main_production.dart:25` — `main` | Explicit TaxonomyDependencyConfiguration.legacy(AppEnvironment.production); no Production canonical or preview dart-define. |
| `lib/core/supabase/supabase_config.dart:34` — `SupabaseConfig` | Only SUPABASE_PRODUCTION_URL and SUPABASE_PRODUCTION_ANON_KEY select Production credentials; environment-specific values have no cross-environment fallback and the Development project is rejected in Production. |
| `lib/main_development.dart:32` — `createDevelopmentTaxonomyConfiguration` | ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY enables Development-only acceptance after a fresh capability proof, with previewRequested=true. Source inspection only; no Development backend access. |
| `lib/core/dependency_injection/taxonomy_dependency_configuration.dart:85` — `TaxonomyDependencyPlanner.resolve` | Non-legacy requests outside Development throw; canonical support also requires a compatible authoritative proof and customer-visible roots. |
| `lib/core/dependency_injection/service_locator.dart:157` — `setupServiceLocator` | Registers the RPC adapter only when registerDevelopmentRpcAdapter is true, and canonical repositories/scoped products only when requiresCanonicalBindings is true; categories and search receive the selected capability. |
| `lib/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart:114` — `TaxonomyBackendContractProof.supportsCanonicalV1` | Requires taxonomy-client-v1, taxonomy-rpc-v2, RPC generation 2, previewSupported, and exact-leaf-visible-assignable-policy-eligible product scope. Production v1 proof does not satisfy this contract. |
| `lib/features/shop/data/services/supabase_canonical_taxonomy_rpc_adapter.dart:93` — `SupabaseCanonicalTaxonomyRpcAdapter` | Uses taxonomy_capabilities_v2, taxonomy_roots_v2, taxonomy_children_v2, taxonomy_descendants_v2, taxonomy_exact_leaf_v2, taxonomy_breadcrumb_v2, taxonomy_resolve_alias_v2, taxonomy_search_context_v2; forwards p_preview from previewRequested. |
| `lib/features/shop/data/repositories/category_repository_impl.dart:22` — `CategoryRepositoryImpl.getCategories` | Legacy reads categories where is_active=true ordered by sort_order; legacy children filter parent_id. |
| `lib/features/shop/data/repositories/canonical_taxonomy_repository_impl.dart:9` — `CanonicalTaxonomyRepositoryImpl` | Delegates roots, children, descendants, breadcrumb, alias and search to the canonical adapter and validates DTO/hierarchy data. |
| `lib/features/shop/presentation/cubit/categories_cubit.dart:24` — `CategoriesCubit.getCategories / _emitCanonicalRoots` | Legacy uses GetCategoriesUsecase; canonical uses repository.getRoots and requires exactly 24 discoverable root nodes. Failure never substitutes legacy roots. |
| `lib/features/shop/presentation/widgets/home_categories.dart:35` — `HomeCategories.maxHomeCategories / _openAllCategories` | Home shows up to eight unique actual roots; Tüm kategoriler reuses the same CategoriesCubit and shows every supplied root. It does not switch runtime or fabricate categories. |
| `lib/features/shop/presentation/helpers/taxonomy_category_destination.dart:9` — `buildCanonicalTaxonomyDestination` | Routes discoverable parents to TaxonomyBrowseView and eligible leaves to SubCategoryView with taxonomyQueryScope; rejects missing capability/repository/breadcrumb. |
| `lib/features/shop/presentation/cubit/taxonomy_browse_cubit.dart:16` — `TaxonomyBrowseCubit.load` | Loads breadcrumb then direct children; validates matching parent, next hierarchy level, taxonomy version and discoverability. |
| `lib/features/shop/presentation/views/sub_category_view.dart:34` — `SubCategoryView` | Carries canonical query scope into product loading and deeper product-list navigation. |
| `lib/features/shop/presentation/cubit/products_cubit.dart:168` — `ProductsCubit._loadProductsPage` | Canonical hierarchy evidence routes to GetProductsByTaxonomyScopeUsecase; missing adapter fails closed. |
| `lib/features/shop/data/repositories/canonical_taxonomy_scoped_product_repository_impl.dart:32` — `CanonicalTaxonomyScopedProductRepositoryImpl.getProductsByTaxonomyScope` | Resolves canonical IDs with the Development adapter, then filters products.category_id by those IDs. Production preserves legacy category_id and uses shadow assignments plus production_taxonomy_products_v1; simple RPC renaming is insufficient. |
| `lib/features/shop/presentation/cubit/customer_search_cubit.dart:156` — `CustomerSearchCubit._loadCategoryMatches` | Legacy searches legacy categories; canonical calls repository.searchTaxonomy, validates discoverability/version, and retains canonical search context. |
| `lib/features/shop/data/repositories/product_repository_impl.dart:78` — `ProductRepositoryImpl.getProductById` | Product details keep the products/categories/brands legacy join by product ID. |
| `lib/features/shop/data/repositories/shop_repository_impl.dart:250` — `ShopRepositoryImpl.getShopProductsByProduct` | Seller comparison reads shop_products by stable product_id; shop details/listings remain on shops/shop_products legacy relations. |
| `lib/features/shop/presentation/views/shop_profile_view.dart:71` — `ShopProfileView` | Shop profile loads products with GetShopProductsByShopUsecase and existing shop ID. |
| `supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql:7714` — `_production_taxonomy_assert_contract_v1` | Checks production-taxonomy-client-v1 / production-taxonomy-rpc-v1 / generation 1; preview_supported must be false; every p_preview=true request raises W38_PREVIEW_DISABLED. |
| `supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql:8443` — `_production_taxonomy_visible_v1 (final definition)` | Requires p_preview=false, public_enabled=true, active node and ancestors, matching taxonomy version, and PASS policy/professional gates. |
| `supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql:8479` — `production_taxonomy_runtime_v1` | Advertises preview_enabled=false and Production shadow-mapping product scope. |
| `supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql:8488` — `production_taxonomy_products_v1` | Reads product_canonical_assignments under RLS and calls descendants with preview=false; no product preview parameter exists. |

The only canonical build opt-in is `ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY`. Production reads `SUPABASE_PRODUCTION_URL` and `SUPABASE_PRODUCTION_ANON_KEY` but has no canonical/preview compile define or external config selector. GetIt deliberately omits the canonical RPC/repository bindings for Production legacy mode. The external Production client configuration was read privately; no key value is included here.

Home already limits actual roots to eight and offers **Tüm kategoriler** for the full root list. The canonical CategoriesCubit requires 24 real discoverable roots and fails closed. A client-only flag cannot make the server's empty staged projection pass that contract.

## Live read-only access evidence

At 2026-09-19T00:24:51.327Z, 19 HTTPS GET requests targeted only `mefhfvrgkwciubeajjeb.supabase.co`, using the external publishable key. No Auth session, privileged key, SQL write, migration, flag update, Storage mutation or Development request was used. RPC definitions were inspected as STABLE read functions before probing. Only status, safe error tags, row counts and capability metadata were retained.

| Probe | HTTP | Rows | Safe error |
| --- | --- | --- | --- |
| legacy_categories | 200 | 4 | — |
| production_runtime | 200 | 1 | — |
| production_capabilities | 200 | 1 | — |
| current_flutter_capabilities | 404 | — | PGRST202 |
| roots_public | 200 | 0 | — |
| roots_preview | 400 | — | W38_PREVIEW_DISABLED |
| children_public | 200 | 0 | — |
| children_preview | 400 | — | W38_PREVIEW_DISABLED |
| descendants_public | 200 | 0 | — |
| descendants_preview | 400 | — | W38_PREVIEW_DISABLED |
| breadcrumb_public | 200 | 0 | — |
| breadcrumb_preview | 400 | — | W38_PREVIEW_DISABLED |
| exact_leaf_public | 200 | 0 | — |
| exact_leaf_preview | 400 | — | W38_PREVIEW_DISABLED |
| alias_public | 200 | 0 | — |
| alias_preview | 400 | — | W38_PREVIEW_DISABLED |
| search_public | 200 | 0 | — |
| search_preview | 400 | — | W38_PREVIEW_DISABLED |
| product_scope | 200 | 0 | — |

Production reports `production-taxonomy-client-v1`, `production-taxonomy-rpc-v1`, generation **1**, `preview_support=false`, `preview_enabled=false`, and zero public/pilot/preview visible roots. Its runtime reports `public_enabled=false`. The four legacy categories remain readable (HTTP 200), proving that the key and host work. Preview rejection is intentional fail-closed behavior, not a missing key or an empty canonical database.

The existing Flutter client instead expects `taxonomy-client-v1`, `taxonomy-rpc-v2`, generation **2**, preview support and a different product-scope contract. Its capability RPC returns HTTP 404 / PGRST202 on Production. Production metadata being readable is not a passing canonical application contract.

## Exact blockers and minimum separate next gate

1. Production startup explicitly chooses legacy; TaxonomyDependencyPlanner rejects canonical acceptance for any non-Development environment.
2. Production preview is not implemented: the assertion always raises W38_PREVIEW_DISABLED for preview=true. The final visibility helper requires preview=false, public_enabled=true, active nodes/ancestors and valid review gates. Changing preview_enabled alone does nothing; setting preview_supported=true also violates the current capability assertion.
3. Product scope differs materially. Flutter's existing canonical repository filters products.category_id using canonical IDs. Side-by-side Production keeps that field legacy and exposes canonical scope through product_canonical_assignments and production_taxonomy_products_v1, whose implementation currently has no preview path. Renaming RPC constants alone would not fix product scope.

The smallest separate work package must provide a **server-authorized private Production preview contract**, with public_enabled still false and legacy/canonical lifecycle state preserved. It must cover capability checks, tree/breadcrumb/alias/search reads and the shadow-mapping product projection consistently, while retaining RLS and policy/professional-review restrictions. Preview access must be authorized by the server for permitted normal client identities; an APK flag and the shared publishable key are not a private access boundary. No privileged credential belongs in the app.

After that server contract exists under separate authorization, a Production-specific capability/adapter and opt-in must select it and consume its product mapping projection. This exceeds selecting an already supported preview mode, so it was not implemented in this task. No proposed SQL or flag change was executed.

`PUBLIC_CANONICAL_ACTIVATION_REQUIRED_FOR_RC=YES` describes the unchanged current backend's only visible-data path. It is neither approval nor advice to activate: public_enabled alone also cannot reveal staged/inactive rows. A separately implemented private preview can avoid public activation entirely.

## Build, UI and validation status

Repository version is **1.0.0+1**, package **com.esnaftavar.app**. No RC version was selected. The requested 1.0.0+2 remains a candidate only; later release/device versions were not audited after the Phase 2 stop. No signing file was opened, certificate checked, APK/AAB created or release artifact frozen.

Application and UI source is unchanged: light-only pilot, Home eight-category limit, Tüm kategoriler, Category Icon V1, contrast fixes, Cart V2 and Reward V1 were preserved by making no code changes. The custom 24-category visual pack remains deferred. No new visual/runtime acceptance is claimed.

Targeted Flutter tests, full Flutter suite, analyzer and physical installation are **NOT_RUN — Phase 2 STOP**. The historical 2094 PASS / six skips is not a current test result. No new skip or weakened assertion was introduced. Source discovery, the 19 live read-only probe expectations, evidence consistency, secret/PII/path scanning and git diff --check passed. The FAIL flags below describe blocked canonical RC acceptance; no Flutter artifact exists to test.

## Task result

```text
W52K_A_CANONICAL_PRODUCTION_RC: BLOCKED
AUTHORITATIVE_MAIN: c02186873ff7939de7007794bcbe14b141450e33
CANONICAL_CLIENT_OPT_IN_MECHANISM: NONE_FOR_PRODUCTION; Development-only ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY + capability proof + previewRequested=true
PUBLIC_CANONICAL_ACTIVATION_REQUIRED_FOR_RC: YES
PRODUCTION_WRITE_PERFORMED: NO
DEVELOPMENT_ACCESSED: NO
CANONICAL_PRODUCTION_READ_CONTRACT: FAIL
HOME_CANONICAL_ROOTS: FAIL
RECURSIVE_L2_L3_L4: FAIL
PRODUCT_SCOPE: FAIL
SEARCH_ALIAS: FAIL
FULL_FLUTTER: NOT_RUN_PHASE_2_STOP
ANALYZER: NOT_RUN_PHASE_2_STOP
VERSION_NAME: NOT_SELECTED
VERSION_CODE: NOT_SELECTED
APK_PATH: NOT_BUILT
APK_SHA256: NOT_BUILT
AAB_PATH: NOT_BUILT
AAB_SHA256: NOT_BUILT
SIGNING_CERT_SHA256: NOT_VERIFIED_NO_BUILD
PRODUCTION_PROJECT_VERIFIED: PASS
DEVELOPMENT_FALLBACK: NONE
PHYSICAL_INSTALL: NOT_RUN
PUBLIC_CANONICAL_ACTIVATION_PERFORMED: NO
READY_FOR_PHYSICAL_CANONICAL_PRODUCTION_SMOKE: NO
```

Machine-readable evidence: [w52k_a_canonical_production_rc_validation.json](data/w52k_a_canonical_production_rc_validation.json). Only these two sanitized evidence documents are committed on `astra-release/w52k-a-canonical-production-rc`; no main merge, force push or APK/AAB upload.
