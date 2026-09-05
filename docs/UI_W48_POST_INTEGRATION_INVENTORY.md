# W48 — Post-integration Customer Final UI inventory

Historical W48 snapshot. Current remaining-work truth is the
[W49 final closeout inventory](UI_W49_POST_INTEGRATION_INVENTORY.md):
zero active Customer Final UI conversion units remain. This historical ledger
and its inactive corrections are retained without rewriting the W48 result.

Status: **RECOMPUTED FROM MERGED RUNTIME — 2026-09-05**.
Main before: `cd1d566c36a669fc9b6cabeaee9a114979ae7fb7`.
W48 source: `257c5aba9a40e6f461cd10ed98a7690f84769e75`.
Acceptance and publication: [W48 integration result](ASTRA_W48_INTEGRATION_RESULT.md).
This supersedes the historical [W46 ledger](UI_W46_POST_ACCOUNT_HUB_INVENTORY.md).
Stable IDs and original Tier/Figma classes are preserved.

## Actual reachability and acceptance

The unchanged launch gate, five navigation tabs, Settings, Home/product cards,
Product Details/seller, Nearby and Cart callers were checked against the exact
[W48 scope ledger](UI_W48_SCOPE_LEDGER.md), changed runtime and targeted/adjacent
tests. No new route, library screen or inactive compatibility path was enabled.

W48 closes **14 active units**: FS-21/27/28/29, MD-12/15/16/19/20/21/22/23 and
ST-02/03. Secondary Library is the family of existing customer utility/activity
destinations, not an additional screen. Previously completed Account, Privacy,
Help and Saved Locations remain done.

MD-01–04 are **INACTIVE_CONFIRMED**, not completed: recursive lib import/call
search finds no active LocationHelper/getAddressFromCurrentLocation caller.
The two compatibility dialog functions have only that unused helper as a lib
caller. Isolated localization tests do not create runtime reachability.
The real service binding is CustomerLocationService ->
GeolocatorCustomerLocationService; active Nearby uses MD-19 consent and Cubit
states. Legacy helper and compatibility dialog bodies remain unchanged.
[Per-window evidence](ASTRA_W48_INTEGRATION_REVIEW.md) preserves the correction.

No Product Owner prototype is counted as runtime completion. W3B 09–12 were
compared with real runtime; three small presentation reconciliations were tested,
and 10 is an acceptable equivalent. W3B fixture code was not merged.
W49 is running independently and has not been readied or integrated by this task.

## Recomputed totals

| Metric | Historical W46 baseline | Accepted W48 runtime |
|---|---:|---:|
| Reachable full screens, shell excluded | 34 | **34** |
| Active modal/sheet/dialog/menu/overlay surfaces | 23 | **19** |
| Shared-state families | 3 | **3** |
| Total active units | 60 | **56** |
| Final reachable full screens | 25 | **29** |
| Final active modal units | 8 | **16** |
| Final shared-state families | 1 | **3** |
| Final active units | 34 | **48** |
| Remaining full screens | 9 | **5** |
| Remaining active modal units | 15 | **3** |
| Remaining shared-state families | 2 | **0** |
| Remaining conversion units | 26 | **8** |
| Remaining Tier A / B / C | 3 / 8 / 15 | **3 / 4 / 1** |
| Remaining Figma HEAVY / LIGHT / NOT_REQUIRED | 3 / 4 / 19 | **3 / 2 / 3** |
| Remaining historical nominal scope | 117 h | **67 h** |
| Inactive/legacy/non-customer exclusions | 9 | **13** |
| Unknown reachability | 0 | **0** |

The reconciliation is independently reproduced by the row ledger: 14 accepted
active conversions and four reachability corrections. Inactive nominal labels
2+1+2+2 = 7 h plus W48's 43 h and pending 67 h explain the previous 117 h.
This is a scope ledger, not a throughput/time forecast. Separately unbound
FD-05 SellerComparisonView remains a historically done reference; it is not
added to 34 active screens or the 13 inactive exclusions.

**MD-23 boundary:** W48 session preparation/QR/status/summary/expiry/cancellation
presentation is accepted. Its existing nested _QrSessionCompletedView and rating
state remain unchanged and reserved for W49 Post-Purchase/Trust acceptance.
That dependency is explicitly attached to FS-30/31/MD-05 below; it is not claimed
converted by W48 and is not invented as a ninth top-level conversion unit.

## Remaining work — exclusively W49

| ID | Pending surface | Tier | Figma | Existing entry / dependency |
|---|---|---|---|---|
| FS-30 | Verified purchase history | A | FIGMA_HEAVY | Settings, Notifications, Cart/QR; include reserved nested QR completion handoff |
| FS-31 | Customer shop ratings | B | FIGMA_NOT_REQUIRED | Settings and purchase/trust context; QR rating dependency |
| FS-32 | Product reviews / eligibility | A | FIGMA_HEAVY | Product Details; server-authoritative existing eligibility |
| FS-33 | Conversation list | B | FIGMA_LIGHT | Settings, Notifications |
| FS-34 | Chat detail / composer | A | FIGMA_HEAVY | Conversation list, Shop, pending-chat listener |
| MD-05 | Shop rating editor | B | FIGMA_NOT_REQUIRED | Purchases and existing QR rating context |
| MD-17 | Review create/edit form | B | FIGMA_LIGHT | Product Reviews |
| MD-18 | Review delete confirmation | C | FIGMA_NOT_REQUIRED | Product Reviews |

**ONLY_W49_MAJOR_CUSTOMER_UI_REMAINS: YES.**
All remaining active top-level conversion units and the recorded nested QR
completion/rating dependency belong to W49 Post-Purchase, Shop Ratings, Product
Reviews and Messaging. W49 later integration may therefore be the final major
Customer V1 UI closeout gate. None is marked done merely because W3B's 12 visual
surfaces are approved. W49 still needs source review, visual/runtime acceptance,
shared theme/QR/destination reconciliation and combined tests when it arrives.

This does not establish Merchant, physical QR, signing, legal/support or Production
readiness. No new Agent 2 Customer utility package remains or starts here.

## Active row ledger

Every row below is REACHABLE=YES. Only non-Final rows count as remaining.
MD-23's dependent nested subtree is qualified above and in its entry column.

| ID | Surface | Current status | Tier | Figma | Actual entry |
|---|---|---|---|---|---|
| FS-01 | Customer launch/loading gate | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | `MaterialApp.home` |
| FS-02 | Onboarding carousel | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Launch gate, first run |
| FS-03 | Customer login | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Auth guard, Settings, feature detours |
| FS-04 | Customer signup | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Login |
| FS-05 | Verify email waiting/resend | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Signup/login confirmation-required |
| FS-06 | Forgot password request | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Login |
| FS-07 | Password reset email sent | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Forgot-password success |
| FS-08 | Update password | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Recovery deep link |
| FS-09 | Invalid/expired recovery | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Invalid recovery deep link |
| FS-10 | KVKK information | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Signup, Privacy |
| FS-11 | Terms of Use | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Signup, Privacy |
| FS-12 | Home | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Bottom tab 0 |
| FS-13 | Recursive category browse | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Home category; recursive push |
| FS-14 | Category-scoped product listing | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Recursive leaf; `SubCategoryView` |
| FS-15 | All products catalog | FINAL_UI_V1_MAIN | A | FIGMA_HEAVY | Home “Tümünü Gör”, promo |
| FS-16 | Search/suggestions/results | FINAL_UI_V1_MAIN | A | FIGMA_HEAVY | Home query/search tap; `isSearchMode` |
| FS-17 | Product Details | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Product cards/results |
| FS-18 | Nearby shops/location | FINAL_UI_V1_MAIN | A | FIGMA_HEAVY | Bottom tab 1 |
| FS-19 | Shop Details/Profile | FINAL_UI_V1_MAIN | A | FIGMA_HEAVY | Home/Nearby/seller/purchase |
| FS-20 | Cart V2 | FINAL_UI_V1_MAIN | A | FIGMA_HEAVY | Bottom tab 2; seller add-to-cart |
| FS-21 | Wishlist | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Bottom tab 3; favorite guards |
| FS-22 | Settings/Profile hub | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Bottom tab 4 |
| FS-23 | Profile details | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Settings/header |
| FS-24 | Saved locations | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Settings, Home, seller section, Nearby |
| FS-25 | Privacy & Permissions | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Settings |
| FS-26 | Help & Support | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Settings |
| FS-27 | Customer coupons | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Settings |
| FS-28 | Recently viewed products | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Settings |
| FS-29 | Customer notifications | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Home app bar, Settings |
| FS-30 | Verified purchase history | PARTIALLY_FINAL | A | FIGMA_HEAVY | Settings, Cart QR result, Notifications |
| FS-31 | Customer shop ratings | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Settings |
| FS-32 | Product reviews/eligibility | PARTIALLY_FINAL | A | FIGMA_HEAVY | Product Details |
| FS-33 | Conversation list | PARTIALLY_FINAL | B | FIGMA_LIGHT | Settings, Notifications |
| FS-34 | Chat detail/composer | PARTIALLY_FINAL | A | FIGMA_HEAVY | Conversation list, Shop, pending-chat listener |
| MD-05 | Shop rating editor | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Purchases |
| MD-06 | Edit profile form | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Profile |
| MD-07 | Account deletion confirmation | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Profile |
| MD-08 | Add saved location | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Saved Locations |
| MD-09 | Delete saved location | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Saved Locations |
| MD-11 | Merchant registration information | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Login |
| MD-12 | Single-shop conflict | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Seller add-to-cart |
| MD-13 | Seller sort menu | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Seller list |
| MD-14 | Product sort menu | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Category product listing |
| MD-15 | Clear all recently viewed | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Recently Viewed |
| MD-16 | Recently viewed item action menu | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Recently Viewed item |
| MD-17 | Review create/edit form | PARTIALLY_FINAL | B | FIGMA_LIGHT | Product Reviews |
| MD-18 | Review delete confirmation | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Product Reviews |
| MD-19 | Use current location consent | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Nearby |
| MD-20 | Remove cart item | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Cart V2 |
| MD-21 | Clear cart | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Cart V2 |
| MD-22 | Continue after refreshed totals | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Cart V2 QR preparation |
| MD-23 | Customer QR session | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Cart V2 QR session; W49 completion/rating subtree pending |
| MD-24 | Email confirmation success notice | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Confirmation deep link destination |
| ST-01 | `EsnaftaVarStateCard` empty/error/unavailable family | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Home/category/final screens |
| ST-02 | Generic progress/loading family | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | `TLoadingIndicator` + repeated progress usage |
| ST-03 | Snackbar feedback family | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Auth/cart/chat/location/mutation feedback |

## Inactive corrections and existing exclusions

| ID | Surface | Reachability / status |
|---|---|---|
| MD-01 | Permanently denied/settings dialog | INACTIVE_CONFIRMED; unused legacy helper |
| MD-02 | Location acquisition loading | INACTIVE_CONFIRMED; unused legacy helper |
| MD-03 | Location service disabled | INACTIVE_CONFIRMED; unused helper-only compatibility dialog |
| MD-04 | Runtime permission explanation | INACTIVE_CONFIRMED; unused helper-only compatibility dialog |
| MD-10 | Wrong merchant-account warning | Inactive compatibility; no active isMerchantLogin=true caller |
| EX-01 | Legacy address list | Inactive; Settings opens Saved Locations |
| EX-02 | Legacy add address | Inactive; unreachable parent |
| EX-03 | Store tab/view | Inactive; customer tab uses Wishlist |
| EX-04 | Legacy orders | Inactive; customer path is Purchases |
| EX-05 | Legacy SuccessView composition | Inactive; active confirmation uses MD-24 |
| EX-06 | My Shop | Excluded Merchant scope |
| EX-07 | My Shop form | Excluded Merchant scope |
| EX-08 | Merchant QR scanner | Excluded verifier/Merchant scope |

FD-05 is separately unbound and historically done; its embedded seller section
remains reachable in Product Details. No exclusion is silently restored.
