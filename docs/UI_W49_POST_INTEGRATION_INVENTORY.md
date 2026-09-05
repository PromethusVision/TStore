# W49 — Final Customer V1 UI closeout inventory

Status: **VERIFIED FROM MERGED RUNTIME — 2026-09-05**.
Main before: `4bde1156ee0aae5487c67c008583f0354fc3ada6`.
W49 source: `e361352c4af430a6266b1a2d425dddf5f4881d89`.
Merge: `bb93b921cdebd030c6224d7f5be1353d6479eee5`.
Acceptance checkpoint: `98501c30614c12842b30fef130b7a69c665cf1dd`.
[Integration result and publication boundary](ASTRA_W49_INTEGRATION_RESULT.md).
This supersedes the remaining-work counts in the historical
[W48 inventory](UI_W48_POST_INTEGRATION_INVENTORY.md).

## Denominator and actual runtime reconciliation

**All eight W49 scoped units are accepted:** FS-30/31/32/33/34 and MD-05/17/18.
Five full screens and three existing modal families; no shared family remained.
All active child states are included. The unchanged QR completion/rating subtree
reserved by W48 is now independently accepted under MD-23 and FS-30/31/MD-05.
Its two new responsive test cases exercise selection, exact source QR/score,
submitting lockout, failure/retry availability, success and Purchases callback.
Four new PNGs show the actual W48-themed subtree; no QR implementation was edited.

The approved Purchases C1 changes the old third tab into a separate action sheet.
This is already contained in FS-30's worker scope, not a ninth assigned work unit.
The physical composition must nevertheless remain visible in the final inventory:

| Counting convention | W48 | Accepted W49 |
|---|---:|---:|
| Reachable full screens, navigation shell excluded | 34 | **34** |
| Stable MD families in the inherited ledger | 19 | **19** |
| Additional contained refund action-sheet composition | 0 | **1** |
| Active modal/sheet/dialog/menu/overlay compositions under this convention | 19 | **20** |
| Shared-state families | 3 | **3** |
| Stable inventory IDs | 56 | **56** |
| Active compositions including the contained refund sheet | 56 | **57** |
| Final stable IDs | 48 | **56** |
| Final active compositions including the refund child | 48 | **57** |
| Remaining full screens | 5 | **0** |
| Remaining active modal/sheet/dialog compositions | 3 | **0** |
| Remaining state families | 0 | **0** |
| Remaining active conversion units | 8 | **0** |
| Remaining Tier A / B / C | 3 / 4 / 1 | **0 / 0 / 0** |
| Remaining Figma HEAVY / LIGHT / NOT_REQUIRED | 3 / 2 / 3 | **0 / 0 / 0** |
| Inactive/legacy/non-customer exclusions | 13 | **13** |
| Unknown reachability | 0 | **0** |

The 56-row stable ledger is kept for historical comparability. The 57-composition
total explicitly includes the approved refund child; it is not used to inflate
W49 completion or calibration. Repeated instances and variants of existing
families, including QR's nested rating state, are not counted as new screens.
There is no active conversion backlog hidden in either counting convention.

## Reachability audit

The final result is not obtained only by subtracting eight from the old total.
The following current runtime entry points and their actual targets were inspected:

| Entry | Current reachable surfaces and evidence |
|---|---|
| `lib/t_store.dart`, launch gate and Auth listeners | FS-01–11 and MD-24; launch/onboarding/login/signup/legal/recovery remain Final. No new route, AuthGuard or listener diff. |
| `lib/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart` | Exactly Home, Nearby, Cart V2, Wishlist, Settings tabs. No legacy Store/Orders activation. |
| Home/category/product entry family | FS-12–20; recursive taxonomy browse, category-scoped listing, catalog/search modes, Product Details, Nearby and Shop. Approved Category and all earlier Final implementations remain byte-identical to main. |
| `settings_view.dart`, Profile, Privacy and Help | FS-22–29 plus Purchases, Ratings, Inbox; existing protected entry/login return and Saved Locations handoffs unchanged. |
| Purchases / QR / Notifications | FS-30 uses the default actual PurchasesView; target purchase/source QR IDs, bounded delayed-arrival recovery and history refresh retained. Real Cart-to-Purchases test and new default notification-to-Purchases test pass. |
| Purchases / Ratings | FS-31 and MD-05 use actual history and verified-transaction rating Cubit; rated-only history, date fallback/sort and one-shot submission remain. |
| Product Details / ProductDescriptionSection | FS-32 and MD-17/18 use canonical product identity and the existing Reviews Cubit/RPC projection. Direct purchase-item-to-review navigation does not exist and was not invented. |
| Settings / Notifications / Shop / pending chat / Inbox | FS-33/34 use actual merchant user IDs. Inbox-to-Chat and pending-login resume remain; default notification fallback now additionally renders the real Inbox in an integration test. |
| Active modal callers across `lib` | Profile edit/delete, Saved Locations add/delete, merchant-registration info, seller conflict/sort, product sort, Recent clear/menu, Nearby consent, Cart dialogs/QR, auth notice and review/rating forms all map to the stable rows below. |
| New C1 refund child | `purchases_final_ui.dart` → `showModalBottomSheet` → existing preparation state; return action closes the sheet and selects history. Tested at normal/narrow scale; no refund submission backend. |
| Shared families | State card, loader/Material progress and snackbar feedback use W48's integrated theme and existing primitives; W49 does not replace them. |

A recursive search of all `lib` Navigator/helper/modal/menu calls found no new
unclassified active Customer destination. Imports/callers of legacy location,
address, orders, store and unbound seller screen were checked separately.
Source changes are limited to five existing presentation views and three local
composition parts. Their changed imports do not activate a prototype or a legacy
route. Test discovery retains every baseline file; targeted/adjacent/full tests
cover actual entry, navigation, guards and visible states.

## Active stable row ledger

All rows below are REACHABLE=YES and FINAL_UI_V1_MAIN.

| ID | Surface | Current status | Historical Tier | Historical Figma | Actual entry |
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
| FS-30 | Verified purchase history | FINAL_UI_V1_MAIN | A | FIGMA_HEAVY | Settings, Cart QR result, Notifications |
| FS-31 | Customer shop ratings | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Settings |
| FS-32 | Product reviews/eligibility | FINAL_UI_V1_MAIN | A | FIGMA_HEAVY | Product Details |
| FS-33 | Conversation list | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Settings, Notifications |
| FS-34 | Chat detail/composer | FINAL_UI_V1_MAIN | A | FIGMA_HEAVY | Conversation list, Shop, pending-chat listener |
| MD-05 | Shop rating editor | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Purchases |
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
| MD-17 | Review create/edit form | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Product Reviews |
| MD-18 | Review delete confirmation | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Product Reviews |
| MD-19 | Use current location consent | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Nearby |
| MD-20 | Remove cart item | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Cart V2 |
| MD-21 | Clear cart | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Cart V2 |
| MD-22 | Continue after refreshed totals | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Cart V2 QR preparation |
| MD-23 | Customer QR session | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Cart V2 QR session; completion/rating subtree accepted in W49 |
| MD-24 | Email confirmation success notice | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Confirmation deep link destination |
| ST-01 | `EsnaftaVarStateCard` empty/error/unavailable family | FINAL_UI_V1_MAIN | DONE | FIGMA_NOT_REQUIRED | Home/category/final screens |
| ST-02 | Generic progress/loading family | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | `TLoadingIndicator` + repeated progress usage |
| ST-03 | Snackbar feedback family | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Auth/cart/chat/location/mutation feedback |

## Contained composition disclosed separately

| Parent scope | Active composition | Status | Caller |
|---|---|---|---|
| FS-30 / approved C1 | İade Talebi Oluştur preparation action sheet | FINAL_UI_V1_MAIN | Separate Purchases action; two peer tabs remain |

The parent already owned this preparation content. Changing its presentation to
a sheet does not create a new business feature, refund process or scope estimate.

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

## Milestone and next authority

`FINAL_CUSTOMER_UI_INVENTORY_ZERO: YES`
`CUSTOMER_V1_FINAL_UI_CONVERSION_COMPLETE: YES`

This closes the **Customer V1 Final UI conversion program** only. No further
Customer conversion package is recommended merely to fill a package-size target.
Ready for the separately scoped Customer V1 release-gate assessment: **YES**.
Commercial release, Merchant minimum, physical-device QR E2E, legal/privacy and
support approval, signing/store publication and Production authority remain
separate, unverified gates. This integration does not grant access to those systems.
