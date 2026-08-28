# Customer App Feature Inventory

Status: AUDITED  
Baseline: `f092cf8fe7431f812a017d4cbc9b538775bb41e6`

This inventory follows runtime wiring and call sites, not feature-folder names alone.

| Feature | Status | Route/entry | State | Data source | Test evidence | Commercialization state / risk |
| --- | --- | --- | --- | --- | --- | --- |
| Startup/onboarding | ACTIVE | `CustomerLaunchGate` | `FutureBuilder`, `OnBoardingCubit` | SharedPreferences/Auth session | launch-gate and onboarding widgets | PASS; local preference read failure safely opens discovery. |
| Signup/login/logout | ACTIVE | Login/signup views and guarded return | `AuthCubit` | Supabase Auth + profile trigger | unit, widget, controlled integration, prior physical acceptance | PASS; remote provider/config is manual Production evidence. |
| Email confirmation | ACTIVE | Root callback listener | Auth listener + profile refresh | Supabase Auth callback | callback/listener/physical evidence | PASS for Android; callback config remains a release checklist item. |
| Password recovery | ACTIVE | Root recovery listener → update-password view | typed recovery state in `AuthCubit` | Supabase PKCE/Auth | extensive unit/widget + physical B6 | PASS on signed Android; invalid/expired paths are safe. |
| Profile/account deletion | ACTIVE | Settings/Profile | profile Cubit + `AuthCubit` | `profiles`, protected deletion RPC | unit/widget/live historical evidence | PASS; avatar methods are dormant and target a deferred bucket. |
| Home/discovery | ACTIVE | bottom tab 0 | product/category/banner Cubits | public Supabase reads | home widgets + Production read-only smoke | PASS with demo data; cosmetic rollout deferred. |
| Categories/subcategories | ACTIVE, CURRENT TAXONOMY | Home/category views | category/product Cubits | public category/product reads | category/subcategory widgets | PASS for current runtime; canonical 24-L1/L2/L3/L4 runtime integration deferred. |
| Product list/details/media | ACTIVE | Home/search/category → details | product Cubits/local widget state | product/media public reads | listing/details/media widget and unit tests | PASS; missing media has fallback. |
| Seller comparison/shop details | ACTIVE | Product details → seller/shop | Cubits + view state | shops/shop_products/reviews | seller/shop widgets + Production smoke | PASS for customer discovery; demo merchants have no owner. |
| Search | ACTIVE | Home search and all-products search | `CustomerSearchCubit`, debounce state | products/categories/shops + recent searches | unit/widget search tests | PASS; result caps are finite, not full catalogue pagination. |
| Nearby/location | ACTIVE | bottom tab 1, Home location | Nearby Cubit/view + location service | device GPS/saved locations/public shops | unit/widget + prior physical GPS evidence | PASS; guest-vs-login personalization rule needs owner confirmation. |
| Wishlist | ACTIVE | guarded tab/action | `WishlistCubit` | authenticated wishlist rows | cubit/widget/RLS historical evidence | PASS; local state is cleared on account switch/logout. |
| Cart V2 | ACTIVE | guarded tab/product seller action | `CartV2Cubit` | Cart V2 RPC/table contract | broad unit/widget/QR tests | PASS for single-store preparation list; physical QR completion remains open. |
| Saved locations | ACTIVE | Profile/Home location | saved-location Cubit | authenticated saved-location table + geolocator | unit/widget/RLS historical evidence | PASS. |
| Postal addresses | INACTIVE LEGACY/DEAD CANDIDATE | no active route | registered legacy `AddressesCubit` | address repository | unit-only legacy coverage | Not shipped; hardcoded prototype view must not be treated as customer data. |
| Verified purchases/history | ACTIVE | Profile purchases | purchase/rating Cubits | verified transaction RPC/views | unit/widget/live historical evidence | PASS for existing verified records. |
| Reviews/ratings | ACTIVE | Product/shop/purchase views | review/rating Cubits | canonical review RPCs/read models | architecture/unit/widget/live evidence | PASS contractually; requires verified purchase evidence. |
| QR customer surface | ACTIVE | Cart “Mağazada Göster” | QR session Cubit/timer | canonical QR RPCs | unit/widget + backend evidence | CONDITIONAL: logical tests pass; physical two-device acceptance is open. |
| QR verifier surface | PRESENT, MERCHANT-LIMITED | scanner view | verification Cubit/scanner | camera + verifier RPC | unit/widget | Not a completed Merchant App; physical two-device gate required. |
| Notifications | ACTIVE IN-APP | Profile/notification view | `NotificationsCubit` | paginated/realtime rows | unit/widget | PASS for in-app notifications; push delivery is not implemented. |
| Chat/messages | ACTIVE | seller/shop → conversation | chat/unread Cubits | paginated/realtime rows + pending local context | unit/widget | PASS in tested local contract; no remote write performed here. |
| Settings/legal/about/support | ACTIVE | bottom tab 4/Profile | local view state + Auth/Profile Cubits | static docs/profile/auth/local preferences | widget tests | PASS; Merchant registration remains informational/deferred. |
| Deep links | ACTIVE AUTH-ONLY | Android/iOS callback scheme | root listeners | Supabase Auth stream/initial URI | architecture/unit/widget/physical evidence | PASS for confirmation/recovery contract; arbitrary content links are not a V1 feature. |
| Legacy orders/checkout | DISCONNECTED LEGACY | no active route/DI | legacy Cubit only | legacy tables | architecture isolation test | NOT A V1 FEATURE; do not revive as online commerce. |

## Cross-cutting observations

- Guest discovery is intentionally broad in current runtime; personalized writes require Auth.
- The customer proposition remains physical local discovery: no payment, shipping, or online checkout.
- Production demo shops support discovery and comparison but not merchant ownership or QR confirmation.
- Final UI-kit rollout and canonical taxonomy runtime are separate future integration programs.

`FEATURE_INVENTORY: PASS`  
`MAJOR_UNMAPPED_CUSTOMER_MODULE: NO`
