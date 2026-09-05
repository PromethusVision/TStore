# W45B — All Products + Search active-surface map

Task branch: `astra-ui/w45b-all-products-search-final-ui`  
Required and verified base: `4287972429d9befe4ef2637a565ea6d8a2393a5e`  
First observed clock: 2026-09-05 03:01:02 Europe/Istanbul (00:01:02 UTC).

## Scope and authority

WP-02 has **two conversion units**, FS-15 and FS-16. W44 actually classifies
both as Tier A / FIGMA_HEAVY, rather than B/C. This task explicitly authorizes
the complete direct implementation from integrated Flutter Final UI and forbids
Figma except exact FIGMA_LIGHT evidence. That instruction supersedes the older
prototype/owner-gate workflow for this package. No scoped LIGHT surface exists;
Figma access is forbidden and no Figma calls are planned.

## Independently verified reachable surfaces

| Unit | Entry / implementation | Reachable compositions and states |
|---|---|---|
| FS-15 catalog | `HomeProductsSection` view-all, `PromoBannerCarouselSlider`, `RecentlyViewedProductsView` empty action → `AllProductsView()` | Initial/loading; loaded two-column catalog; incremental page loading; page error/retry with retained products; empty; error/retry; product-only query/loading/results/no-result; seller-price loading/success/unavailable; image fallback; wishlist/auth detour; product detail/back |
| FS-16 search route | `HomeView._openAllProductsSearch` → `AllProductsView(isSearchMode: true, initialQuery: query)` | Empty query uses catalog plus real local recent searches; initial supplied query; debounce/loading; category, shop and product result sections; partial warning; no results; error/retry; query edit/clear; recent select/remove/clear; category/shop/product navigation/back |
| FS-16 inline entry | `CustomerHomeV1Content` → `HomeSearchBar` | Focused empty query with history loading/list; minimum-two-character debounce; suggestions loading/loaded/empty/error; category/product/shop rows; view-all submit; local history select/remove/clear; existing price loading/fallback |

Variants above remain part of their parent unit. W44 has **no separate scoped
modal/sheet/menu ID** for this package. The inline suggestions/history card is
in flow, not an invented modal. MD-14 is the already-final **category Product
Listing** sort popup, outside the conversion scope; it will be regression-tested.

### Runtime contracts checked in code

- Catalog gets its own `ProductsCubit`, preserving the parent Home featured list.
  Page loading remains exclusive to the empty-query catalog (including search's
  initial catalog). Product-only results are not paginated.
- Unified search continues to call `CustomerSearchCubit`; existing backend
  product query, legacy/category expansion, canonical capability and shop matching
  are untouched. No query reconstruction or new backend behavior.
- Catalog and unified search currently expose **no sort/filter control**. The
  repository's optional sort parameters are not an existing control here; no new
  sorting, filters, pagination of search, or taxonomy activation will be added.
- Search canonical destinations use `buildCanonicalTaxonomyDestination` and
  existing capability/context; category guards and duplicate-tap locks remain.
- Product and shop destinations retain entity/local context; wishlist retains
  `ProductFavoriteButton` and its existing AuthGuard. No auth requirement for search.
- Product prices come from purchasable shop listings, never `ProductEntity.price`
  or its discount. No shipping/payment/marketplace claims.
- Pushed discovery routes return to the existing shell; they do not own a second
  bottom navigation bar. Navigation shell changes are outside scope.

## Implementation ownership and checkpoints

1. This map + architecture/contracts checkpoint.
2. Catalog/core composition and responsive product cards; targeted regressions.
3. Unified results/history and inline suggestion states; targeted regressions.
4. Responsive/accessibility, long content, local goldens and interaction tests.
5. Combined analyzer/full suite, scope/secret checks, final report and clean push.

Runtime allowlist: `all_products_view.dart`, search-only parts of
`home_search_bar.dart`, and new package-owned test/evidence files. Existing private
catalog/search product presentation remains a single implementation for these
two modes. Consume shared scaffold/section/state/icon components and semantic
tokens; do not copy them or alter `core/ui`, theme, global navigation, Product
Listing/Details, Home composition, shared product/shop widgets, Cubits,
repositories, backend, taxonomy, dependencies or bootstrap.

`home_search_bar.dart` is a visible Home consumer: any search-only change must be
explicitly reported and checked against Home search and Home golden regressions.
No shared-component change is currently required. Other task worktrees exist for
Tier A prototype work and Auth/Startup; no ownership of their files is assumed.

## Acceptance matrix

Both modes and inline entry: 320/390/430 px at 100% and 130% text, long Turkish
query/product/category/shop/history strings, keyboard, actual loading/empty/error/
partial/loaded states, image and price fallback, minimum 44 px controls. Keep all
existing tests and skips unchanged; add functional tests for any uncovered paths.
Final gate: `flutter analyze --no-pub`, `flutter test --no-pub`,
`git diff --check`, changed-file secret/PII scan. Production/backend/Figma remain
unaccessed. All checkpoints push only the assigned branch; worker never merges.
