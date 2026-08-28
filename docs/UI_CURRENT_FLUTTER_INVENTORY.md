# Current Flutter UI Inventory

> Wave 27 · static inventory at `origin/main@fca935fdbe3053d2d9aa4bbb7a10b1f928007b63`
> No runtime file was changed.

## Executive inventory

| Measure | Count |
|---|---:|
| Presentation view files | 38 |
| Public view widget classes | 40 |
| Primary Customer rollout view files | 33 |
| Merchant-adjacent view files | 3 |
| Legacy/unreferenced view files | 2 |
| Core/feature component widget files | 93 |
| Component widget classes | 157 |
| All visual widget classes, including view-local private classes | 405 |
| UI Dart lines in views and widget directories | 35,440 |

“Screen count” means a Dart presentation view, not every state or route alias. The
legal document file exposes two public views, which is why 38 files contain 40
public view classes.

## View inventory by feature

| Feature | View files | Lines | Public classes | Private/local classes | Rollout note |
|---|---:|---:|---:|---:|---|
| Auth | 10 | 2,301 | 11 | 24 | Launch, login/signup, recovery, legal and onboarding |
| Cart | 1 | 583 | 1 | 10 | Merchant QR scanner; Merchant-adjacent |
| Chat | 2 | 1,819 | 2 | 17 | Authenticated customer surface |
| Notifications | 1 | 902 | 1 | 8 | Authenticated customer surface |
| Personalization | 8 | 4,114 | 8 | 40 | Settings, profile, addresses, help/privacy/coupons |
| Purchases | 2 | 2,294 | 2 | 27 | Verified purchase history and rating entry |
| Shop | 14 | 10,795 | 15 | 120 | Discovery, product, merchant, Cart V2 and adjacent legacy/merchant views |
| **Total** | **38** | **22,808** | **40** | **246** | — |

## Primary customer rollout surfaces

### Entry, auth and legal — 10 files

- `customer_launch_gate.dart`
- `on_boarding_view.dart`
- `login_view.dart`
- `sign_up_view.dart`
- `verify_email_view.dart`
- `forget_password_view.dart`
- `invalid_password_recovery_view.dart`
- `reset_password_view.dart`
- `update_password_view.dart`
- `legal_document_views.dart`

### Discovery and local commerce — 10 files

- `home_view.dart`
- `nearby_view.dart`
- `all_products_view.dart`
- `sub_category_view.dart`
- `product_details_view.dart`
- `product_reviews_view.dart`
- `shop_profile_view.dart`
- `cart_v2_view.dart`
- `wishlist_view.dart`
- `recently_viewed_products_view.dart`

### Account and support — 8 files

- `settings_view.dart`
- `profile_view.dart`
- `user_addresses_view.dart`
- `add_new_addresses_view.dart`
- `customer_saved_locations_view.dart`
- `privacy_and_permissions_view.dart`
- `help_and_support_view.dart`
- `customer_coupons_view.dart`

### Communication and verified activity — 5 files

- `conversations_view.dart`
- `chat_view.dart`
- `customer_notifications_view.dart`
- `purchases_view.dart`
- `customer_ratings_view.dart`

### Excluded from the Customer visual rollout baseline — 5 files

| File | Classification | Reason |
|---|---|---|
| `my_shop_view.dart` | Merchant-adjacent | Merchant role route |
| `my_shop_form_view.dart` | Merchant-adjacent | Merchant edit/form route |
| `merchant_qr_scanner_view.dart` | Merchant-adjacent | Opened from My Shop |
| `orders_view.dart` | Legacy | `LegacyOrdersView`; guarded by architecture test |
| `store_view.dart` | Unreferenced legacy candidate | No current route/call-site reference found |

Exclusion means “not owned by this Customer rollout,” not permission to delete.

## Current five-destination shell

| Index | Destination | Guest behavior | Visual risk |
|---:|---|---|---|
| 0 | Home | Public | Preserve discovery and location prompt states |
| 1 | Nearby | Public shell; personalized action may gate | Preserve internal location/login policy |
| 2 | Cart V2 | Login gate, then resume | Preserve single-store/cart state |
| 3 | Wishlist | Login gate, then resume | Preserve optimistic and signed-out states |
| 4 | Settings/Profile | Login gate, then resume | Preserve unread refresh and account routes |

The current custom bottom bar uses raw sizing and colors but also owns critical
semantics, unread badges and Cart V2 count. It is a component migration, not a
simple replacement.

## Largest composition files

| File | Lines | Main rollout risk |
|---|---:|---|
| `all_products_view.dart` | 1,879 | Search, discovery, pagination and many local UI states in one file |
| `purchases_view.dart` | 1,726 | Verified activity, filters and rating entry coupling |
| `cart_v2_view.dart` | 1,580 | Cubit states, confirmation dialogs, QR sheet and totals |
| `nearby_view.dart` | 1,240 | Location/auth, map/list intent and empty/error states |
| `customer_saved_locations_view.dart` | 1,168 | Location forms, permissions and async states |
| `product_reviews_view.dart` | 1,159 | Review eligibility, editor and display states |
| `shop_profile_view.dart` | 1,123 | Shop identity, directions, chat, products and rating |
| `chat_view.dart` | 1,036 | Realtime lifecycle, composition and message states |
| `customer_notifications_view.dart` | 902 | Read/unread, list lifecycle and navigation |
| `recently_viewed_products_view.dart` | 870 | Product cards and persistence state |

These files must not be rewritten simultaneously. First extract canonical
presentational components behind compatibility-preserving APIs, then migrate one
state slice at a time.

## Critical pilot to current Flutter mapping

| Pilot surface | Current runtime source | Important child sources | Functional contract to preserve |
|---|---|---|---|
| Home | `home_view.dart` | `home_*`, promo banner, bottom navigation | Guest discovery, location gate, categories, products, nearby shops |
| Category/Product Listing | `all_products_view.dart`, `sub_category_view.dart` | product cards, search, category widgets | Dynamic data, pagination, query/category navigation |
| Product Details | `product_details_view.dart` | image slider, metadata, description, seller summary/section | Product identity and seller comparison |
| Seller Comparison | `product_sellers_section.dart` | seller rows and shop navigation | Price/rating/distance/availability; no checkout |
| Shop Details | `shop_profile_view.dart` | shop header, actions, product tiles | Directions, chat/auth guard, shop products/reputation |
| Cart V2 | `cart_v2_view.dart` | QR bottom sheet and many private state widgets | Single-store rule, quantities, total, verified purchase path |
| Guest AuthGuard | `navigation_menu.dart`, `login_view.dart` | auth form/listeners | Cancel/resume destination and session correctness |

## State coverage inventory

Current code contains local implementations for loading, empty, error, retry,
success, unavailable, image fallback, auth-required, wrong-store/confirmation,
unread and async-action states. Coverage is uneven: some screens have dedicated
private state widgets, while others compose ad-hoc `Center`, `CircularProgress`,
`SnackBar` or dialog structures. Wave 27 defines a unifying state contract without
changing their triggers or business rules.

## Inventory boundary

The count intentionally excludes Cubits, repositories, models, SQL, generated
files and tests. Those remain functional dependencies and regression targets, not
visual implementation ownership.
