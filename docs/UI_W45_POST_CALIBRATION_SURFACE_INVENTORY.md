# Wave 45 — Post-calibration Customer surface inventory

Status: **NEW ACCELERATION BASELINE — 2026-09-05**.
Starting main: 4287972429d9befe4ef2637a565ea6d8a2393a5e.
Reviewed runtime: a621d73a30904014d147b8ec2aad14d368b9bf0a (A 44acd83 + B 147a5e1).
Main delivery is recorded in [integration result](ASTRA_WAVE1_IMPLEMENTATION_INTEGRATION_RESULT.md).

## Counting and runtime evidence

This replaces the *remaining-work baseline*, not the historical W44 estimates.
[W44 row-level inventory](UI_W44_CUSTOMER_SURFACE_INVENTORY.md) retains stable IDs,
original tier/Figma classes and nominal hours. Count only REACHABLE=YES rows whose
status is not FINAL_UI_V1_MAIN. Recomputed row totals below include no guesses
about new routes or future capabilities.

MaterialApp.home remains CustomerLaunchGate; NavigationMenu's same five tabs
remain Home, Nearby, Cart V2, Wishlist and Settings. There is no named route /
GoRouter / generated router or standalone AuthGuard class: existing caller checks
push LoginView with return-to-caller. The shell, DI, bootstrap, auth Cubit,
recovery listener and data/domain trees are unchanged from starting main. The
confirmation listener changes its notice rendering only. Source diff inspection,
runtime caller search and the combined 160-file test discovery preserve these
reachability contracts.

FS-15 and FS-16 are different user tasks/modes of AllProductsView. Inline history
and suggestions remain in-flow FS-16 variants; no new modal, sort or filter was
created. Dedicated SellerComparisonView (FD-05) remains unbound and historically
DONE; Product Details still exposes the existing seller section/sort (MD-13).
Legacy Address/Orders/Store/email-success and merchant screens remain excluded.

MD-10's historical YES was incorrect: the wrong-role dialog requires
isMerchantLogin=true, which no active runtime caller supplies. W45C preserved,
restyled and tested it without activation. Keep its ID/status for traceability,
but exclude it from active counts. The two active Auth surfaces are merchant
registration information MD-11 and confirmation notice MD-24.

## Reconciled totals

| Metric | W44 historical | W45 actual merged runtime |
|---|---:|---:|
| Reachable full screens (shell excluded) | 34 | **34** |
| Active modals/sheets/dialogs/menus/overlays | 24 | **23** |
| Shared-state families | 3 | **3** |
| Final reachable full screens | 4 | **17** |
| Final active modals | 2 | **4** |
| Final shared-state families | 1 | **1** |
| Final main feature surfaces including unbound FD-05 | 5 | **18** |
| Remaining full screens | 30 | **17** |
| Remaining active modals | 22 | **19** |
| Remaining shared-state families | 2 | **2** |
| Remaining conversion units | 54 | **38** |
| Remaining Tier A / B / C | 8 / 18 / 28 | **6 / 15 / 17** |
| Remaining Figma HEAVY / LIGHT / NOT_REQUIRED | 8 / 9 / 37 | **6 / 6 / 26** |
| Remaining nominal direct W44 hours | 250 | **203** |
| Inactive/compatibility/non-customer excluded | 8 | **9** |
| Reachability unknown | 0 | **0** |

54 -> 38 means **15 active units completed + one inactive-count correction**.
It does not mean 16 newly reachable or active units completed. Of the active
closure, Discovery supplies 2 full screens; Auth/Startup supplies 11 full screens
and 2 modal/notice surfaces. The compatibility improvement is additional evidence.
The historical 30 h Auth package includes 1 h assigned to MD-10; preserve 30 h
for calibration and do not charge that 1 h to remaining work. Remaining hours
also reconcile as 250 - 17 - 30 = 203; they are size labels, not elapsed forecasts.

The remaining rows independently recompute reuse as HIGH 26 / MEDIUM 11 / LOW 1.
This corrects W44's prose reuse-summary arithmetic; row classifications were
not reclassified to fit its old 37/16/1 summary.

## Accepted Wave 1 surfaces

| Package | IDs | Acceptance |
|---|---|---|
| All Products | FS-15 | FINAL_UI_V1_MAIN — catalog, query, page/error/retry, actual price/image, wishlist and detail/back |
| Search | FS-16 | FINAL_UI_V1_MAIN — unified results, partial/empty/error, history, inline suggestions, category/shop/product handoff |
| Startup | FS-01/02 | FINAL_UI_V1_MAIN — launch/preferences and onboarding, responsive navigation/actions |
| Auth + legal | FS-03–11 | FINAL_UI_V1_MAIN — login/signup/confirmation/recovery/reset/invalid/KVKK/terms |
| Active Auth modal/notice | MD-11/24 | FINAL_UI_V1_MAIN — information dialog and dismissible confirmation notice |
| Compatibility only | MD-10 | FINAL_UI_V1_MAIN presentation; REACHABLE=NO, not an active conversion unit |

Historical FS-15/16 Tier A/HEAVY classification is retained. W45B and W45D's
explicit direct-implementation/integration authority supplies this package's
visual gate exception; it does not silently relabel them B/C. The W45A prototypes
are separate and not merged; initial owner review was pending/partial, while the
newer 4ae9d6d R2 report records approval and continuing closeout. FS-18/19/20
remain PARTIALLY_FINAL on main. Legal content/version and Auth security/session logic are unchanged.

## All remaining units

| ID | Surface | Type | Tier | Figma class | Nominal h | Actual entry |
|---|---|---|---|---|---:|---|
| FS-18 | Nearby shops/location | FULL_SCREEN_FLOW | A | HEAVY | 14 | Bottom tab 1 |
| FS-19 | Shop Details/Profile | SCREEN | A | HEAVY | 12 | Home/Nearby/seller/purchase |
| FS-20 | Cart V2 | FULL_SCREEN_FLOW | A | HEAVY | 16 | Bottom tab 2; seller add-to-cart |
| FS-21 | Wishlist | SCREEN | B | NOT_REQUIRED | 6 | Bottom tab 3; favorite guards |
| FS-22 | Settings/Profile hub | SCREEN | B | NOT_REQUIRED | 6 | Bottom tab 4 |
| FS-23 | Profile details | SCREEN | B | NOT_REQUIRED | 7 | Settings/header |
| FS-24 | Saved locations | FULL_SCREEN_FLOW | B | LIGHT | 9 | Settings, Home, seller section |
| FS-25 | Privacy & Permissions | SCREEN | B | NOT_REQUIRED | 5 | Settings |
| FS-26 | Help & Support | SCREEN | B | NOT_REQUIRED | 4 | Settings |
| FS-27 | Customer coupons | SCREEN | C | NOT_REQUIRED | 2 | Settings |
| FS-28 | Recently viewed products | SCREEN | B | NOT_REQUIRED | 6 | Settings |
| FS-29 | Customer notifications | FULL_SCREEN_FLOW | B | LIGHT | 8 | Home app bar, Settings |
| FS-30 | Verified purchase history | FULL_SCREEN_FLOW | A | HEAVY | 16 | Settings, Cart QR result, Notifications |
| FS-31 | Customer shop ratings | SCREEN | B | NOT_REQUIRED | 5 | Settings |
| FS-32 | Product reviews/eligibility | FULL_SCREEN_FLOW | A | HEAVY | 14 | Product Details |
| FS-33 | Conversation list | SCREEN | B | LIGHT | 8 | Settings, Notifications |
| FS-34 | Chat detail/composer | FULL_SCREEN_FLOW | A | HEAVY | 14 | Conversation list, Shop, pending-chat listener |
| MD-01 | Permanently denied/settings dialog | DIALOG | C | NOT_REQUIRED | 2 | Location helper |
| MD-02 | Location acquisition loading | DIALOG_OVERLAY | C | NOT_REQUIRED | 1 | Location helper `DialogRoute` |
| MD-03 | Location service disabled | DIALOG | C | NOT_REQUIRED | 2 | Location helper |
| MD-04 | Runtime permission request explanation | DIALOG | C | NOT_REQUIRED | 2 | Location helper |
| MD-05 | Shop rating editor | BOTTOM_SHEET | B | NOT_REQUIRED | 4 | Purchases |
| MD-06 | Edit profile form | BOTTOM_SHEET | B | NOT_REQUIRED | 4 | Profile |
| MD-07 | Account deletion confirmation | DIALOG | C | NOT_REQUIRED | 2 | Profile |
| MD-08 | Add/edit saved location | BOTTOM_SHEET | B | LIGHT | 5 | Saved Locations |
| MD-09 | Delete saved location | DIALOG | C | NOT_REQUIRED | 2 | Saved Locations |
| MD-12 | Single-shop conflict | DIALOG | C | NOT_REQUIRED | 2 | Seller add-to-cart |
| MD-15 | Clear all recently viewed | DIALOG | C | NOT_REQUIRED | 1 | Recently Viewed |
| MD-16 | Recently viewed item action menu | POPUP_MENU | C | NOT_REQUIRED | 1 | Recently Viewed item |
| MD-17 | Review create/edit form | BOTTOM_SHEET | B | LIGHT | 5 | Product Reviews |
| MD-18 | Review delete confirmation | DIALOG | C | NOT_REQUIRED | 1 | Product Reviews |
| MD-19 | Use current location consent | DIALOG | C | NOT_REQUIRED | 2 | Nearby |
| MD-20 | Remove cart item | DIALOG | C | NOT_REQUIRED | 1 | Cart V2 |
| MD-21 | Clear cart | DIALOG | C | NOT_REQUIRED | 1 | Cart V2 |
| MD-22 | Continue after refreshed totals | DIALOG | C | NOT_REQUIRED | 2 | Cart V2 QR preparation |
| MD-23 | Customer QR session | BOTTOM_SHEET | B | LIGHT | 7 | Cart V2 “Mağazada Göster” |
| ST-02 | Generic progress/loading family | SHARED_STATE | C | NOT_REQUIRED | 2 | `TLoadingIndicator` + repeated progress usage |
| ST-03 | Snackbar feedback family | SHARED_STATE | C | NOT_REQUIRED | 2 | Auth/cart/chat/location/mutation feedback |

## Gate and next planning handoff

Combined runtime gate: **536 targeted PASS; 407 adjacent regression PASS;
1637 full-suite PASS / 0 FAIL / 6 existing opt-in skips; analyzer clean**.
The 54 source golden files are retained byte-for-byte; representative Discovery
and Auth images were compared with W39–W43 Final UI. No major visual divergence.
Neither an image variant nor a prototype is counted as a new screen completion.

[Wave 2 scope recommendation](ASTRA_WAVE2_SCOPE_RECOMMENDATION.md) uses this
38-unit / 203-nominal-hour baseline. This document starts no future implementation,
Figma session, Merchant work or remote environment operation.
