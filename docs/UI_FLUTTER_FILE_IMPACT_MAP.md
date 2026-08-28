# Flutter File Impact Map

## Boundary

Wave 27 changes none of these runtime files. The companion
`UI_FLUTTER_FILE_IMPACT_MATRIX.csv` is the exact 131-file static inventory used to
plan future rollout ownership. It covers 38 presentation view files and 93
reusable/component widget files.

## Impact labels

| Label | Meaning |
|---|---|
| MIGRATE | Expected visual migration while preserving existing behavior |
| ADAPT | Keep behavior/data API; wrap or delegate rendering to canonical component |
| REVIEW | Audit after primitives exist; change only if inconsistency remains |
| DEFER | Outside Customer rollout or safe post-pilot polish |
| EXCLUDE | Legacy/unreferenced; do not activate or redesign as part of rollout |

## Wave/file ownership summary

| Wave | Primary owned files | Shared dependencies | Conflict rule |
|---:|---|---|---|
| 1 | future theme/token files; existing theme/constants when implementation is authorized | `t_store.dart` only if dark-mode decision requires it | One foundation owner only |
| 2 | core buttons/fields/navigation/app-bar/state primitives; auth login/signup/launch | auth/navigation tests | No screen agent edits primitive implementation |
| 3 | `home_view.dart`, `home_*`, banners, category/product/merchant cards | primitives read-only | Home owner owns all Home composition |
| 4 | `all_products_view.dart`, `sub_category_view.dart`, listing/search widgets | ProductCard/CategoryRow APIs | One owner per large view |
| 5 | `product_details_view.dart`, product detail widgets, seller section | ProductCard/Status/Rating APIs | Seller and details migrated together |
| 6 | `shop_profile_view.dart` and shop-private composition | MerchantCard/ProductCard/Button | CTA owner verifies directions/chat behavior |
| 7 | `cart_v2_view.dart`, QR sheet and quantity presentation | Dialog/State/Button | Cart behavior files cannot be refactored incidentally |
| 8 | product reviews, purchases, customer ratings and trust widgets | VerifiedBadge/Review APIs | Review eligibility remains domain-owned |
| 9 | Nearby, wishlist, recent, chat, notifications, profile/settings/location/auth secondary | shared primitives stable/frozen | Split by feature directories |
| 10 | no broad rewrites; defect-only file set from acceptance failures | golden/a11y fixtures | Freeze exceptions require triage |

## Shared/global files requiring serialized ownership

- `lib/t_store.dart`
- `lib/core/utils/theme/theme.dart`
- `lib/core/utils/theme/widget_themes/*`
- `lib/core/utils/constants/colors.dart`
- `lib/core/utils/constants/sizes.dart`
- `lib/core/utils/constants/customer_home_v1_tokens.dart`
- `lib/core/common/widgets/navigation_menu.dart`
- `lib/core/common/widgets/customer_bottom_navigation.dart`

These are not to be edited in parallel by multiple rollout agents. `pubspec.yaml`,
runtime models, Cubits, repositories, service locator and navigation architecture
remain outside visual ownership unless a separately scoped integration task proves
the need.

## High-risk composition boundaries

| File | Lines | Planned seam |
|---|---:|---|
| `all_products_view.dart` | 1,879 | Extract presentational card/status/search sections without moving pagination/query logic |
| `purchases_view.dart` | 1,726 | Extract verified activity cards; retain filtering and review navigation |
| `cart_v2_view.dart` | 1,580 | Extract header/item/state views; retain Cubit branching, totals, dialogs and QR lifecycle |
| `nearby_view.dart` | 1,240 | Extract location/result states; retain permission/auth policy |
| `customer_saved_locations_view.dart` | 1,168 | Extract fields/rows/states; retain persistence and permissions |
| `product_reviews_view.dart` | 1,159 | Extract card/editor/state; retain eligibility and mutation behavior |
| `shop_profile_view.dart` | 1,123 | Extract header/actions/products; retain directions/chat/auth callbacks |
| `chat_view.dart` | 1,036 | Extract bubbles/composer/states; retain realtime lifecycle and dedup |

## Change-control requirement

Every implementation PR must declare its exact rows from the companion matrix,
show that no EXCLUDE/DEFER file was changed, and run the functional regression
suite named for that wave. Large file splitting is not a visual acceptance goal;
it is allowed only where it creates a stable component seam with equivalent tests.
