# W48 — Remaining Customer Utility & Engagement scope ledger

Base: `cd1d566c36a669fc9b6cabeaee9a114979ae7fb7`; branch:
`astra-ui/w48-remaining-customer-utility-engagement-final-ui`.
Observed start: 2026-09-05 11:58:26 UTC (14:58:26 Europe/Istanbul).
Fetched main exactly matches the requested base. Clean task branch created.

The current explicit W48 contract supersedes the older 24 h recommendation.
All 18 historically unreserved candidates / 50 nominal hours were examined.
Actual call-chain verification corrects four stale active labels (MD-01–04):
14 active scoped units / 43 historical nominal hours remain, all included.
No reduction is based on time, effort, or package size.

The 60 historical active rows reconcile to 56 actually active units:
14 IN_THIS_PACKAGE, 5 RESERVED_FOR_AGENT3, 3 RESERVED_FOR_DESIGN_OWNER,
34 ALREADY_DONE, plus 4 newly INACTIVE/LEGACY rows. Existing 9 excluded rows
remain, so inactive exclusions total 13 (plus unbound already-done FD-05).
26 historical remaining rows examined = 14 scoped + 8 reserved + 4 inactive.
Active scope: 4 screens, 8 modals, 2 shared families; Tier A/B/C = 0/4/10.
Actual active inventory: 34 screens + 19 modals + 3 families = 56.

Secondary Library is a family label for existing Settings destinations and
saved-product/activity surfaces, not an additional screen. Coupons, Recently
Viewed and their actions are included; Profile, Privacy, Help and Saved Locations
are already done. Purchases/reviews/chat secondary paths remain reserved.

## Active ledger

| ID | Surface | Classification | Tier | Actual entry |
|---|---|---|---|---|
| FS-01 | Customer launch/loading gate | ALREADY_DONE | C | `MaterialApp.home` |
| FS-02 | Onboarding carousel | ALREADY_DONE | B | Launch gate, first run |
| FS-03 | Customer login | ALREADY_DONE | B | Auth guard, Settings, feature detours |
| FS-04 | Customer signup | ALREADY_DONE | B | Login |
| FS-05 | Verify email waiting/resend | ALREADY_DONE | C | Signup/login confirmation-required |
| FS-06 | Forgot password request | ALREADY_DONE | C | Login |
| FS-07 | Password reset email sent | ALREADY_DONE | C | Forgot-password success |
| FS-08 | Update password | ALREADY_DONE | C | Recovery deep link |
| FS-09 | Invalid/expired recovery | ALREADY_DONE | C | Invalid recovery deep link |
| FS-10 | KVKK information | ALREADY_DONE | C | Signup, Privacy |
| FS-11 | Terms of Use | ALREADY_DONE | C | Signup, Privacy |
| FS-12 | Home | ALREADY_DONE | DONE | Bottom tab 0 |
| FS-13 | Recursive category browse | ALREADY_DONE | DONE | Home category; recursive push |
| FS-14 | Category-scoped product listing | ALREADY_DONE | DONE | Recursive leaf; `SubCategoryView` |
| FS-15 | All products catalog | ALREADY_DONE | A | Home “Tümünü Gör”, promo |
| FS-16 | Search/suggestions/results | ALREADY_DONE | A | Home query/search tap; `isSearchMode` |
| FS-17 | Product Details | ALREADY_DONE | DONE | Product cards/results |
| FS-18 | Nearby shops/location | ALREADY_DONE | A | Bottom tab 1 |
| FS-19 | Shop Details/Profile | ALREADY_DONE | A | Home/Nearby/seller/purchase |
| FS-20 | Cart V2 | ALREADY_DONE | A | Bottom tab 2; seller add-to-cart |
| FS-21 | Wishlist | IN_THIS_PACKAGE | B | Bottom tab 3; favorite guards |
| FS-22 | Settings/Profile hub | ALREADY_DONE | B | Bottom tab 4 |
| FS-23 | Profile details | ALREADY_DONE | B | Settings/header |
| FS-24 | Saved locations | ALREADY_DONE | B | Settings, Home, seller section, Nearby |
| FS-25 | Privacy & Permissions | ALREADY_DONE | B | Settings |
| FS-26 | Help & Support | ALREADY_DONE | B | Settings |
| FS-27 | Customer coupons | IN_THIS_PACKAGE | C | Settings |
| FS-28 | Recently viewed products | IN_THIS_PACKAGE | B | Settings |
| FS-29 | Customer notifications | IN_THIS_PACKAGE | B | Home app bar, Settings |
| FS-30 | Verified purchase history | RESERVED_FOR_DESIGN_OWNER | A | Settings, Cart QR result, Notifications |
| FS-31 | Customer shop ratings | RESERVED_FOR_AGENT3 | B | Settings |
| FS-32 | Product reviews/eligibility | RESERVED_FOR_DESIGN_OWNER | A | Product Details |
| FS-33 | Conversation list | RESERVED_FOR_AGENT3 | B | Settings, Notifications |
| FS-34 | Chat detail/composer | RESERVED_FOR_DESIGN_OWNER | A | Conversation list, Shop, pending-chat listener |
| MD-01 | Permanently denied/settings dialog | INACTIVE/LEGACY | C | No active caller; legacy LocationHelper only |
| MD-02 | Location acquisition loading | INACTIVE/LEGACY | C | No active caller; legacy LocationHelper only |
| MD-03 | Location service disabled | INACTIVE/LEGACY | C | No active caller; legacy LocationHelper only |
| MD-04 | Runtime permission request explanation | INACTIVE/LEGACY | C | No active caller; legacy LocationHelper only |
| MD-05 | Shop rating editor | RESERVED_FOR_AGENT3 | B | Purchases |
| MD-06 | Edit profile form | ALREADY_DONE | B | Profile |
| MD-07 | Account deletion confirmation | ALREADY_DONE | C | Profile |
| MD-08 | Add saved location | ALREADY_DONE | B | Saved Locations |
| MD-09 | Delete saved location | ALREADY_DONE | C | Saved Locations |
| MD-11 | Merchant registration information | ALREADY_DONE | C | Login |
| MD-12 | Single-shop conflict | IN_THIS_PACKAGE | C | Seller add-to-cart |
| MD-13 | Seller sort menu | ALREADY_DONE | DONE | Seller list |
| MD-14 | Product sort menu | ALREADY_DONE | DONE | Category product listing |
| MD-15 | Clear all recently viewed | IN_THIS_PACKAGE | C | Recently Viewed |
| MD-16 | Recently viewed item action menu | IN_THIS_PACKAGE | C | Recently Viewed item |
| MD-17 | Review create/edit form | RESERVED_FOR_AGENT3 | B | Product Reviews |
| MD-18 | Review delete confirmation | RESERVED_FOR_AGENT3 | C | Product Reviews |
| MD-19 | Use current location consent | IN_THIS_PACKAGE | C | Nearby |
| MD-20 | Remove cart item | IN_THIS_PACKAGE | C | Cart V2 |
| MD-21 | Clear cart | IN_THIS_PACKAGE | C | Cart V2 |
| MD-22 | Continue after refreshed totals | IN_THIS_PACKAGE | C | Cart V2 QR preparation |
| MD-23 | Customer QR session | IN_THIS_PACKAGE | B | Cart V2: QR kod oluştur |
| MD-24 | Email confirmation success notice | ALREADY_DONE | C | Confirmation deep link destination |
| ST-01 | `EsnaftaVarStateCard` empty/error/unavailable family | ALREADY_DONE | DONE | Home/category/final screens |
| ST-02 | Generic progress/loading family | IN_THIS_PACKAGE | C | `TLoadingIndicator` + repeated progress usage |
| ST-03 | Snackbar feedback family | IN_THIS_PACKAGE | C | Auth/cart/chat/location/mutation feedback |

## Excluded and unbound references

| ID | Surface | Classification | Reason |
|---|---|---|---|
| EX-01 | User address list | INACTIVE/LEGACY | Settings artık Saved Locations açıyor. |
| EX-02 | Add new address | INACTIVE/LEGACY | Parent route erişilemez. |
| EX-03 | Store tab/view | INACTIVE/LEGACY | Bottom navigation `WishlistView` kullanıyor. |
| EX-04 | Legacy orders | INACTIVE/LEGACY | Customer path `PurchasesView`. |
| EX-05 | Legacy email success/`SuccessView` composition | INACTIVE/LEGACY | Aktif flow MD-24 confirmation notice kullanıyor. |
| EX-06 | My Shop | INACTIVE/LEGACY | Merchant scope. |
| EX-07 | My Shop form | INACTIVE/LEGACY | Merchant scope. |
| EX-08 | Merchant QR scanner | INACTIVE/LEGACY | Verifier/merchant scope. |
| MD-10 | Wrong merchant-account warning | INACTIVE/LEGACY | No active isMerchantLogin=true caller; compatibility only |
| FD-05 | SellerComparisonView | ALREADY_DONE | Unbound standalone view; excluded from active counts |

## Reachability and ownership audit

Routes, NavigationMenu, Settings, Home, product sellers, Nearby and Cart entries
are reconciled with the W46 inventory and current feature files. No unknown
active Customer surface remains after the correction below. No new dialog is counted for existing states.
Auth/session checks, local history storage and notification destination builders
are implementation contracts, not redesign targets.

The fetched W47 branch changes only purchases/reviews/chat prototype views,
their tests and review documentation. W48 edits none of those files.

SHARED_COMPONENT_CHANGE_REQUIRED: YES

- EXACT_FILES: `lib/core/common/widgets/progress_indicator.dart`,
  `lib/core/utils/helpers/helper_functions.dart`,
  `lib/core/ui/foundation/esnaftavar_theme.dart`.
- REASON: ST-02 still uses legacy colors; ST-03 typed helper overrides Final UI
  with legacy colors and zero margins. Repeated Material progress/snackbar/dialog
  consumers require shared theme defaults. Location helper modals MD-01–04
  are inactive; their implementation is unchanged.
- CONSUMERS_AND_TESTS: all helper/progress/theme callers are audited in the
  result; Customer Home/Auth/Account/Cart/Nearby/Notifications/history and
  reserved chat presentation consume defaults. Shared regression plus full suite.
- OWNER_BRANCH: W48 branch above is the sole writer for these assigned families;
  Integration reviews their combined impact before main integration.
- COLLISIONS: NONE in fetched W47 diff. No W47 view or global route/provider edit.

Completion evidence and final status are recorded in UI_W48_TASK_RESULT.md.

## Four historical reachability errors corrected

`rg` over all `lib/**/*.dart` finds no caller or import of `LocationHelper` or
`getAddressFromCurrentLocation`. `showLocationServiceDialog` and
`showPermissionDialog` are called only from that unused helper. Existing isolated
localization tests and a release-logging source check do not activate a route.
The real binding is `CustomerLocationService -> GeolocatorCustomerLocationService`
in `lib/core/dependency_injection/service_locator.dart`; Nearby uses its cubit,
the active MD-19 consent and existing location result states. It never calls the
four legacy dialogs. No legacy route was activated.

The W46 inventory labelled MD-01–04 active based on historical helper ownership.
W48 initially followed those labels and tested temporary presentation edits;
the final call-chain audit found the error. All those uncommitted edits and their
new evidence were removed before final verification. They are not counted DONE.
Their historical hours are 2 + 1 + 2 + 2 = 7, explaining 50 -> 43 nominal hours.

Within MD-23, `_QrSessionCompletedView` and its rating state implementation are
`RESERVED_FOR_AGENT3` dependencies. Their source remains byte-for-byte unchanged;
W48 finishes preparation, loading/failure, active QR, delayed connection,
expiration/cancellation, invalid snapshot and refreshed-summary presentation.
This nested reservation adds no new inventory unit and does not claim Reviews
or Purchases completion. Existing completion/rating/navigation tests still run.
