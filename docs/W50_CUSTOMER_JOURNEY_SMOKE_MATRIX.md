# W50 Customer journey and failure matrix

Evidence level: local unit/widget/golden/checked-in contract tests. This matrix
does not assert a connected Android or live backend E2E run. Each test path below
is in the final full suite; its final count and source revision are recorded in
[W50 result](W50_CUSTOMER_V1_RELEASE_GATE_RESULT.md).

## Supported journeys

| Domain | Current runtime entry / supported behavior | Local evidence under `test/` | Gate |
|---|---|---|---|
| Startup | `TStore` → launch gate → first-run onboarding or Home; local preference read failure does not trap discovery | `widget/auth/customer_launch_gate_test.dart`, `w45c_auth_startup_final_ui_test.dart` in the same directory | PASS |
| Auth / guest | Login, signup/legal consent, confirmation/resend, recovery, session restore/expiry and logout; protected tabs return through Login | `unit/auth/`, `widget/auth/`, `integration/auth_flow_test.dart`, `widget/navigation/` | PASS |
| Home | Real Cubits and repository-backed discovery; Reward and Home experiment disabled | `widget/shop/w39a_home_visual_review_golden_test.dart`, `unit/core/w50_customer_runtime_defaults_test.dart` | PASS |
| Category browse | Existing recursive hierarchy and leaf product listing | `widget/shop/home_categories_test.dart`, `widget/shop/sub_category_view_test.dart`, `unit/shop/taxonomy_category_hierarchy_test.dart` | PASS |
| Search | Debounced query, suggestions/recent searches, result selection and query preservation | `widget/shop/home_search_bar_test.dart`, `widget/shop/w45b_inline_search_final_test.dart`, `unit/shop/customer_search_cubit_test.dart` | PASS |
| All Products | Home/search/catalog entries, loading/empty/error/sort/filter and return navigation | `widget/shop/all_products_view_test.dart` | PASS |
| Product Details | Supplied canonical product, real seller data, favorite/review handoffs; missing media now neutral | `widget/shop/product_details_view_layout_test.dart`, `widget/shop/w42a_r2_product_details_final_test.dart`, `widget/shop/w50_missing_product_media_test.dart` | PASS |
| Seller comparison | Active embedded `ProductSellersSection`, sorting and seller/Cart handoff. Standalone historical `SellerComparisonView` is UNBOUND and remains so | `widget/shop/product_sellers_section_test.dart`; standalone visual tests do not imply a runtime route | PASS — supported embedded flow |
| Shop Details | Real shop products, contact/directions, message/login resume and product return | `widget/shop/shop_profile_view_test.dart`, `widget/shop/w45a_shop_profile_prototype_test.dart` | PASS |
| Nearby / location | Consent before one-shot location; denied/permanent denial/service-off/timeout; saved default fallback | `widget/shop/nearby_view_test.dart`, `unit/shop/nearby_shops_cubit_test.dart`, `widget/personalization/wave2b_nearby_saved_locations_handoff_test.dart` | PASS |
| Cart V2 | Single-shop physical preparation, quantity/removal/clear, refreshed totals consent, QR initiation | `widget/cart/cart_v2_view_test.dart`, `widget/cart/w45a_cart_prototype_test.dart`, `unit/cart/` | PASS |
| Account Hub | Guarded account entries and route return; logout session cleanup | `widget/personalization/settings_cart_navigation_test.dart`, `widget/personalization/w46_account_final_test.dart`, `widget/auth/customer_session_listener_test.dart` | PASS |
| Profile | Current customer fields, validation/save failure, duplicate action lock and deletion confirmation | `widget/personalization/customer_profile_view_test.dart`, `widget/personalization/w46_account_final_test.dart` | PASS |
| Saved Locations | List/add/default/delete; Nearby refreshes or clears stale default without automatic GPS | `widget/personalization/customer_saved_locations_view_test.dart`, `wave2b_nearby_saved_locations_handoff_test.dart` in the same directory | PASS |
| Wishlist | Guest gate, real list/empty/error, product open and removal | `widget/shop/wishlist_view_test.dart`, `widget/wishlist/`, `widget/w48/w48_activity_final_test.dart` | PASS |
| Recently Viewed | Per-customer local storage, product navigation, menu/clear and storage failure | `widget/shop/recently_viewed_products_view_test.dart`, `unit/shop/shared_preferences_recently_viewed_products_storage_test.dart` | PASS |
| Notifications | Typed target parsing, read status/pagination, unavailable target fallback and one-shot navigation | `widget/notifications/customer_notifications_view_test.dart`, `widget/w49/w49_integration_handoffs_test.dart`, `unit/notifications/` | PASS |
| Coupons | Truthful unavailable/empty experience; no fake amount or coupon/Reward economy | `widget/personalization/customer_coupons_view_test.dart`, `widget/w48/w48_activity_final_test.dart` | PASS — deferred functionality stays explicit |
| Purchases | QR/notification targets, verified history and delayed-arrival recovery; refund creation is a preparation state | `widget/purchases/purchases_view_test.dart`, `widget/w49/`, `unit/purchases/` | PASS |
| Shop Ratings | Verified transaction rating, selection, submit lock, failure retry and rated history | `widget/purchases/customer_ratings_view_test.dart`, `unit/reviews/shop_rating_cubit_test.dart`, `widget/w49/w49_integration_handoffs_test.dart` | PASS |
| Product Reviews | Canonical product eligibility, create/edit/delete, own/other state and immutable evidence | `widget/shop/product_reviews_view_test.dart`, `unit/reviews/`, `architecture/review_client_security_contract_test.dart` | PASS |
| Messaging | Shop/notification/Inbox entry, pending-login resume, composer, send failure, pagination and background/resume | `widget/chat/`, `unit/chat/`, `widget/w49/w49_integration_handoffs_test.dart` | PASS |
| Help / privacy | Help shortcuts and FAQ, selectable support address, versioned KVKK/Terms and permission explanation; back navigation | `widget/personalization/help_and_support_view_test.dart`, `privacy_and_permissions_view_test.dart`, `w46_account_final_test.dart` in the same directory | PASS — technical reachability only |

## Release-critical failure coverage

| Failure | Proven local outcome | Evidence |
|---|---|---|
| No network / timeout / backend failure | Error is mapped to customer copy; retry remains available; no invented offline synchronization | `unit/core/customer_error_message_test.dart`, repository/Cubit tests, Shop/Cart/Chat/Notifications widget states |
| Session expiry / unauthorized | Existing session listener clears customer-specific state and returns to a valid destination | `widget/auth/customer_session_listener_test.dart`, Auth and ownership unit contracts |
| Empty data | Real empty states in discovery, account utilities, purchases and messaging | Domain widget suites above |
| Malformed / foreign auth URI | Exact environment scheme/host/root path validation; rejected URI never invokes PKCE exchange | `unit/auth/auth_callback_contract_test.dart`, recovery/confirmation tests; W50 Android single-handler metadata |
| Invalid/unavailable notification target | Missing chat target falls back to Inbox; purchases retain bounded target resolution; malformed data does not construct an arbitrary route | `widget/notifications/customer_notifications_view_test.dart`, `widget/w49/w49_integration_handoffs_test.dart` |
| Invalid route argument | Customer navigation uses typed widget constructors, not a public arbitrary named-route map. External Auth URI and notification payload boundaries are validated above | `lib/t_store.dart`, `AuthCallbackContract`, notification destination builder |
| Location denied / disabled | Customer keeps discovery and explicit retry/settings/saved-location options; no background location or automatic permission escalation | Nearby tests and `GeolocatorCustomerLocationService` |
| Message send failure | Draft remains editable; duplicate sends stay locked during a request | `widget/chat/chat_view_test.dart`, `unit/chat/chat_cubit_test.dart` |
| QR generation / changed Cart / expiry / consumed session | Error/refresh/expired/invalid states remain explicit; no false verified purchase; existing protocol preserved | `unit/cart/qr_session_cubit_test.dart`, `widget/cart/`, `widget/w48/` |
| Missing / broken photo | Actual missing photo renders existing neutral fallback; valid supplied thumbnail retained; no invented thumbnails | New W50 media tests plus existing fallback/favorite/Product Details tests |
| Narrow layout / large text / keyboard | Existing W45–W49 responsive and golden tests pass; two new missing-media proofs inspected at 320/390px | Final full suite; all previous golden bytes retained |

## Feature-flag and runtime-data reconciliation

`visualPrototype` is a historical name with two different meanings in this tree.
Home content, Product Details experiment and shared preview entry defaults remain
false. Cart V2, Nearby and Shop Profile were explicitly promoted to owner-approved
Final UI in W45A; their default `true` selects a presentation that consumes the
same real Cubits/entities. Switching those flags off would reintroduce legacy UI.
The new defaults test records this exception; it does not claim every literal
with that name is false. No test fixture import, mock repository or experimental
screen is added to Customer bootstrap/navigation.

Reward is false with null progress/action. Production taxonomy remains legacy;
Development canonical opt-in is false and does not even invoke its proof loader.
There is no Ads or online checkout/payment engine. Cart keeps **Sepet / Sepete
ekle / QR kod oluştur**. The Help FAQ now names the actual QR action and explicitly
states that app-based refund creation is not available.

The three active media components no longer inject sample product photos.
The remaining example image/review references are in unbound legacy Store,
CategoryTab/card or review demo widgets; their caller isolation was inspected.
The generic illustrated profile avatar is a neutral identity fallback, not a fake
customer photograph. Existing bundled example assets are retained; a later asset
size/licensing review can trim them without deleting Development seed content.

No frames-per-second, memory benchmark, Android cold-start duration, live
availability or physical QR success is inferred from these local tests.
