# Wave 45A — Post Tier A integration Customer inventory

Status: **REFRESHED FROM INTEGRATED RUNTIME — 2026-09-05**.
Starting main: `6cc5d1607da96415f788d5324006bc89fe85d554`.
Final Design Owner source: `b5fe6304d8b3bdf47ee6d40609ff47d409279622`.
Delivery/test gate: [Wave 2A integration result](ASTRA_WAVE2A_TIER_A_INTEGRATION_RESULT.md).

This is the current remaining-work baseline. It supersedes the
[Wave 1 snapshot](UI_W45_POST_CALIBRATION_SURFACE_INVENTORY.md) while retaining
[W44 stable IDs and historical classifications](UI_W44_CUSTOMER_SURFACE_INVENTORY.md).
Count reachable rows whose status is not FINAL_UI_V1_MAIN; do not count a golden,
a loading variant or a prototype as a separate completed conversion unit.

## Reachability and acceptance decisions

- MaterialApp.home remains CustomerLaunchGate. NavigationMenuCubit still has five
  tabs: Home, Nearby, Cart V2, Wishlist, Settings. Nearby/Cart constructors now
  default to the approved Final UI; their actual tab objects are asserted in tests.
- ShopProfileView now defaults to approved Final UI for Home, Home nearby section,
  Nearby, All Products/Search, product sellers and purchase-history callers.
  Actual Nearby-to-Shop navigation checks the same ShopEntity and Final default.
  Search retains Wave 1's actual entity, identity and duplicate-navigation guards.
- Named/generated routes, shell authentication and session listeners are unchanged.
  No standalone AuthGuard class exists; existing login return-to-caller checks
  remain the authority. Search/catalog remain two distinct tasks of one view.
- FS-18, FS-19 and FS-20 are **FINAL_UI_V1_MAIN**. Their inline location/status,
  product, quantity, total and QR-action sections are part of those full screens.
- MD-01–04 (shared location prompts), MD-12 (single-shop conflict), MD-19 (Nearby
  consent), MD-20–22 (cart confirmations) and MD-23 (QR session sheet) still have
  their original presentation implementations. Source tests verify their existing
  behavior and the conflict dialog's responsive fit; this is not a separate
  Final UI conversion/owner approval of each modal. They remain PARTIALLY_FINAL.
  The new Cart QR golden depicts its inline CTA section, not the QR session sheet.
  MD-23's entry copy is corrected below to the exact live CTA: QR kod oluştur.
- FS-24 Saved Locations is independently reachable and unchanged; neither Nearby's
  location selector nor its handoff closes that screen or its editor/delete modals.
- ST-02/ST-03 remain shared families across unfinished screens. Reusing a loader
  or snackbar in these three screens does not close the entire family.
- MD-10 stays REACHABLE=NO: no active caller supplies isMerchantLogin=true.
  FD-05 SellerComparisonView stays unbound, historically DONE, with its seller
  section reachable inside Product Details. Neither is added to active totals.
  The other eight W44 legacy/non-customer exclusions remain excluded. Unknown: 0.

These checks independently reproduce the ledger below. The net closure happens
to be three full screens; no inferred modal closure is hidden in a subtraction.

## Recomputed totals

| Metric | Wave 1 main | Wave 2A integrated runtime |
|---|---:|---:|
| Reachable full screens (shell excluded) | 34 | **34** |
| Active modal/sheet/dialog/menu/overlay surfaces | 23 | **23** |
| Shared-state families | 3 | **3** |
| Final reachable full screens | 17 | **20** |
| Final active modals | 4 | **4** |
| Final shared-state families | 1 | **1** |
| Final main feature surfaces including unbound FD-05 | 18 | **21** |
| Remaining full screens | 17 | **14** |
| Remaining active modals | 19 | **19** |
| Remaining shared-state families | 2 | **2** |
| Remaining conversion units | 38 | **35** |
| Remaining Tier A / B / C | 6 / 15 / 17 | **3 / 15 / 17** |
| Remaining FIGMA_HEAVY / FIGMA_LIGHT / FIGMA_NOT_REQUIRED | 6 / 6 / 26 | **3 / 6 / 26** |
| Remaining W44 nominal hours | 203 | **161** |
| Inactive/compatibility/non-customer exclusions | 9 | **9** |
| Reachability unknown | 0 | **0** |

Nominal hours are historical scope labels, not elapsed forecasts or success limits.
All three completed screens retain their original Tier A / FIGMA_HEAVY labels;
this task forbids Figma access and reuses the approved source/Flutter evidence.

## Active row ledger

Every row below has REACHABLE=YES. Original classification is preserved even for
completed rows; only non-Final rows contribute to remaining Tier/Figma totals.

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
| FS-21 | Wishlist | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Bottom tab 3; favorite guards |
| FS-22 | Settings/Profile hub | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Bottom tab 4 |
| FS-23 | Profile details | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Settings/header |
| FS-24 | Saved locations | PARTIALLY_FINAL | B | FIGMA_LIGHT | Settings, Home, seller section |
| FS-25 | Privacy & Permissions | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Settings |
| FS-26 | Help & Support | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Settings |
| FS-27 | Customer coupons | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Settings |
| FS-28 | Recently viewed products | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Settings |
| FS-29 | Customer notifications | PARTIALLY_FINAL | B | FIGMA_LIGHT | Home app bar, Settings |
| FS-30 | Verified purchase history | PARTIALLY_FINAL | A | FIGMA_HEAVY | Settings, Cart QR result, Notifications |
| FS-31 | Customer shop ratings | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Settings |
| FS-32 | Product reviews/eligibility | PARTIALLY_FINAL | A | FIGMA_HEAVY | Product Details |
| FS-33 | Conversation list | PARTIALLY_FINAL | B | FIGMA_LIGHT | Settings, Notifications |
| FS-34 | Chat detail/composer | PARTIALLY_FINAL | A | FIGMA_HEAVY | Conversation list, Shop, pending-chat listener |
| MD-01 | Permanently denied/settings dialog | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Location helper |
| MD-02 | Location acquisition loading | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Location helper `DialogRoute` |
| MD-03 | Location service disabled | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Location helper |
| MD-04 | Runtime permission request explanation | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Location helper |
| MD-05 | Shop rating editor | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Purchases |
| MD-06 | Edit profile form | PARTIALLY_FINAL | B | FIGMA_NOT_REQUIRED | Profile |
| MD-07 | Account deletion confirmation | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Profile |
| MD-08 | Add/edit saved location | PARTIALLY_FINAL | B | FIGMA_LIGHT | Saved Locations |
| MD-09 | Delete saved location | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Saved Locations |
| MD-11 | Merchant registration information | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Login |
| MD-12 | Single-shop conflict | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Seller add-to-cart |
| MD-13 | Seller sort menu | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Seller list |
| MD-14 | Product sort menu | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Category product listing |
| MD-15 | Clear all recently viewed | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Recently Viewed |
| MD-16 | Recently viewed item action menu | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Recently Viewed item |
| MD-17 | Review create/edit form | PARTIALLY_FINAL | B | FIGMA_LIGHT | Product Reviews |
| MD-18 | Review delete confirmation | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Product Reviews |
| MD-19 | Use current location consent | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Nearby |
| MD-20 | Remove cart item | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Cart V2 |
| MD-21 | Clear cart | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Cart V2 |
| MD-22 | Continue after refreshed totals | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Cart V2 QR preparation |
| MD-23 | Customer QR session | PARTIALLY_FINAL | B | FIGMA_LIGHT | Cart V2: QR kod oluştur |
| MD-24 | Email confirmation success notice | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Confirmation deep link destination |
| ST-01 | `EsnaftaVarStateCard` empty/error/unavailable family | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Home/category/final screens |
| ST-02 | Generic progress/loading family | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | `TLoadingIndicator` + repeated progress usage |
| ST-03 | Snackbar feedback family | PARTIALLY_FINAL | C | FIGMA_NOT_REQUIRED | Auth/cart/chat/location/mutation feedback |

## Next Design Owner planning handoff

The remaining Tier A set is **FS-30 Verified purchase history, FS-32 Product
reviews/eligibility, FS-34 Chat detail/composer**. The next Design Owner batch is
to be selected from this refreshed set; this inventory does not start that work.
Stay near three owner-reviewable Tier A prototypes per visual batch. Keep their
related B/C forms, sheets and list screens explicit in the next task contract.
Shared component ownership and remote/Figma authority remain task-specific.

Completed defaults and tests are documented in the
[collision review](ASTRA_WAVE2A_TIER_A_COLLISION_REVIEW.md). Existing Wave 1
Discovery/Auth and W39–W43 accepted surfaces remain FINAL_UI_V1_MAIN.
