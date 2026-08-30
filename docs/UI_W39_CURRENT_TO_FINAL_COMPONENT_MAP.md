# W39A Current-to-Final Component Map

## Scope

This map records the customer-app foundation and Home decisions made in Wave 39A. The wave changes presentation only. Existing Cubit, repository, AuthGuard, taxonomy, search, navigation, Cart V2, QR, review, wishlist and seller-comparison behavior remains authoritative.

Classifications:

- `KEEP_LOGIC_RESTYLE`: preserve behavior and public inputs while moving presentation to the final foundation.
- `REUSABLE_NEW_COMPONENT`: a bounded W39A primitive intended for later screens.
- `REMOVE_VISUAL_DEBT`: replace scattered visual values with a semantic primitive.
- `DEFER_TO_NEXT_SCREEN_WAVE`: outside the Home pilot and must migrate in its rollout wave.

## Foundation map

| Current area | Classification | W39A final destination | Decision |
| --- | --- | --- | --- |
| Scattered Home colors, spacing, radius and shadows | `REMOVE_VISUAL_DEBT` | `EsnaftaVarColors`, `EsnaftaVarSpacing`, `EsnaftaVarRadii`, `EsnaftaVarElevation` | One semantic light-mode source under `lib/core/ui/foundation`. |
| Mixed customer text styles | `REMOVE_VISUAL_DEBT` | `EsnaftaVarTheme.light.textTheme` | Poppins-only type ramp; weights 400/500/600/700. |
| Per-widget button/input/card styling | `REMOVE_VISUAL_DEBT` | Theme component styles plus shared primitives | Minimum interactive size is 44 px; preferred control height is 48 px. |
| `CustomerHomeV1Tokens` | `KEEP_LOGIC_RESTYLE` as compatibility facade | Semantic W39A token aliases | Avoids an unsafe mass rewrite. New code imports the final foundation directly. |
| Global light theme | `KEEP_LOGIC_RESTYLE` | `TAppTheme.lightTheme -> EsnaftaVarTheme.light` | Final light foundation is active. A new dark palette was not invented. |
| Legacy dark theme | `DEFER_TO_NEXT_SCREEN_WAVE` | Future product-approved dark foundation | Preserved without claiming W39A parity. |

## Home component map

| Current component | Classification | Final role/result |
| --- | --- | --- |
| `HomeView` | `KEEP_LOGIC_RESTYLE` | Existing data loads and destinations; composed inside `EsnaftaVarScaffold`. |
| `HomeAppBar` | `KEEP_LOGIC_RESTYLE` | Compact brand/greeting hierarchy, shared 48 px notification action, existing login/notification flow. |
| `HomeLocationBar` | `KEEP_LOGIC_RESTYLE` | Auth-aware location surface; guest copy explains the login gate without changing it. |
| `HomeSearchBar` | `KEEP_LOGIC_RESTYLE` | Existing query/recent-search behavior; final light input treatment and 48 px control. |
| `HomeCategories` | `KEEP_LOGIC_RESTYLE` | Dynamic horizontal root-category entry; no fixed count, three-line Turkish overflow protection. |
| `PromoBannerCarouselSlider` | `KEEP_LOGIC_RESTYLE` | Existing live banner behavior; responsive height for 320–430 px and scaled text. |
| `HomeProductsSection` | `KEEP_LOGIC_RESTYLE` | Existing product/favorite/detail behavior; compact final card hierarchy and shared section/state primitives. |
| `HomeNearbyShopsSection` | `KEEP_LOGIC_RESTYLE` | Existing nearby-shop load/detail behavior; compact merchant discovery cards and shared states. |
| `CustomerBottomNavigation` | `KEEP_LOGIC_RESTYLE` | Same five destinations, AuthGuards and Cart V2 center action; final selected/unselected treatment. |
| Home loading/empty/error blocks | `REUSABLE_NEW_COMPONENT` | `EsnaftaVarStateCard` | One reusable state surface; no fabricated domain content. |
| Repeated title / “Tümünü Gör” rows | `REUSABLE_NEW_COMPONENT` | `EsnaftaVarSectionHeader` | Consistent hierarchy and minimum touch target. |
| Repeated circular surface actions | `REUSABLE_NEW_COMPONENT` | `EsnaftaVarSurfaceIconButton` | Shared semantics, radius, border and 44/48 px sizing. |
| Home screen background/safe composition | `REUSABLE_NEW_COMPONENT` | `EsnaftaVarScaffold` | Final light theme, warm background and safe-area ownership. |
| Reward visual slot | `REUSABLE_NEW_COMPONENT` | `RewardProgressSlot` + `RewardProgressCard` | Runtime off by default; contract only, no economy or backend. |

## Deferred customer surfaces

The following retain their current UI until their listed rollout waves: category/listing, product detail and seller comparison, shop detail, Cart V2/QR, wishlist, reviews, profile/settings, auth and onboarding. Their logic is covered by W39A regression tests; visual migration is deliberately not pulled into Home.

## Functional preservation evidence

- Home keeps the same category destination resolution, exact search flow, saved-location login gate, nearby-tab destination, product/shop detail routes and favorite behavior.
- Bottom navigation keeps Home, Nearby, Cart V2, Favorites and Profile semantics and existing AuthGuards.
- No backend, migration, taxonomy content, reward economics, production data or Figma source was changed.
- Targeted behavior matrix: 525 tests passed.
- Full repository suite: 1316 tests passed; 6 existing environment/condition-dependent tests skipped; no failures.
