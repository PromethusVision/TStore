# Wave 46 — Post Account Hub integration Customer inventory

Status: **MERGED RUNTIME REVIEWED — 2026-09-05**.
Starting main: `c63e61d6363f2cbeb816b7cb55e970e40f798d78`.
Source: `5c2dc3b6dec6721a59ffe81aa863e89c3a0eaff3`.
No-ff merge: `5ef2d5e8023790fadc5d3c5b480c645baacc81f0`.
Acceptance: [Wave 2B result](ASTRA_WAVE2B_ACCOUNT_HUB_INTEGRATION_RESULT.md).

This is the historical Wave 2B ledger. Current truth is [W48 post-integration inventory](UI_W48_POST_INTEGRATION_INVENTORY.md), including verified inactive MD-01–04 corrections. [W45A](UI_W45A_POST_TIER_A_INTEGRATION_INVENTORY.md)
remains the historical pre-integration snapshot; W44 IDs and original Tier/Figma
classifications are retained. Only reachable non-Final rows count as remaining.
Goldens, viewport/state variants and unbound views do not create extra units.

## Runtime reachability decisions

- The launch gate and five navigation tabs are unchanged. Settings is the existing
  tab 4; the shell's customer authentication and return-to-caller checks remain.
  Home, Category, Product Listing/Details, Seller Comparison, Search, Auth/Startup,
  Shop, Cart and Nearby accepted runtime is preserved byte-for-byte from main.
- FS-22 Settings/Profile hub enters FS-23 Profile through its customer header,
  FS-24 Saved Locations, FS-25 Privacy & Permissions and FS-26 Help & Support
  through existing destinations. Help/Privacy keep existing public navigation;
  private destinations retain current-customer checks and session refresh.
- FS-23 opens MD-06 EditProfileBottomSheet and MD-07
  AccountDeletionConfirmationDialog. Existing fields, save validation, pending/
  error behavior, exact deletion confirmation and logout behavior are preserved.
- FS-24 opens MD-08 AddSavedLocationSheet and MD-09
  DeleteSavedLocationDialog. **MD-08 is add-only**: the repository has no editing
  API or active edit route. Correcting its historical “add/edit” label creates or
  removes no active unit. No logout-confirmation surface exists or was invented.
- Saved Locations is also reachable from Home, product seller location handling
  and Nearby. The same repository/default-location service remains authoritative.
  Two integration widget tests navigate from real Nearby to real Saved Locations:
  changing the default refreshes the Nearby label/order/distance; deleting the
  only default clears stale location/distance without requesting GPS permission.
- The 73 source tests, original behavior tests and 12 source visual proofs cover
  the five screens and four active sheets/dialogs, including narrow viewports,
  larger text, keyboard, long names, missing data, loading/error and navigation.
  The source's local AccountPageHeader consumes existing Final UI tokens;
  no global primitive or auth/location business logic changed.
- MD-01–04, MD-12, MD-19–23 remain separate unfinished location/Cart/QR
  presentations. Account completion does not close them. ST-02/ST-03 remain
  shared unfinished families; using a loader/snackbar in Account does not close
  their callers across the app.
- MD-10 remains inactive (no active isMerchantLogin=true caller); historical
  unbound FD-05 SellerComparisonView remains done outside active screen counts.
  The nine existing legacy/compatibility/non-customer exclusions remain excluded;
  no route, taxonomy mode or legacy address module was activated. Unknown: 0.

This review maps exact callers, classes and tests in the
[collision review](ASTRA_WAVE2B_ACCOUNT_HUB_COLLISION_REVIEW.md). The nine status
transitions below follow those active paths; they are not an assumed subtraction.

## Recomputed totals

| Metric | Pre-integration W45A | Wave 2B merged runtime |
|---|---:|---:|
| Reachable full screens (shell excluded) | 34 | **34** |
| Active modal/sheet/dialog/menu/overlay surfaces | 23 | **23** |
| Shared-state families | 3 | **3** |
| Final reachable full screens | 20 | **25** |
| Final active modals | 4 | **8** |
| Final shared-state families | 1 | **1** |
| Final main feature screens including unbound FD-05 | 21 | **26** |
| Remaining full screens | 14 | **9** |
| Remaining active modals | 19 | **15** |
| Remaining shared-state families | 2 | **2** |
| Remaining conversion units | 35 | **26** |
| Remaining Tier A / B / C | 3 / 15 / 17 | **3 / 8 / 15** |
| Remaining FIGMA_HEAVY / FIGMA_LIGHT / FIGMA_NOT_REQUIRED | 3 / 6 / 26 | **3 / 4 / 19** |
| Remaining W44 nominal hours | 161 | **117** |
| Inactive/compatibility/non-customer exclusions | 9 | **9** |
| Reachability unknown | 0 | **0** |

Active total remains 60 = 34 screens + 23 modals + 3 state families.
34 active units are Final; 26 remain. Account closure is 7 Tier B + 2 Tier C,
2 FIGMA_LIGHT + 7 FIGMA_NOT_REQUIRED, with original nominal scope 44 h.
Historical labels do not grant Figma access; this task made **0 Figma calls**.
Nominal hours describe historical scope, not elapsed time or a deadline.

## Active row ledger

Every row has REACHABLE=YES. Completed rows retain historical classifications.

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
| FS-22 | Settings/Profile hub | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Bottom tab 4 |
| FS-23 | Profile details | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Settings/header |
| FS-24 | Saved locations | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Settings, Home, seller section, Nearby |
| FS-25 | Privacy & Permissions | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Settings |
| FS-26 | Help & Support | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Settings |
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
| MD-06 | Edit profile form | FINAL_UI_V1_MAIN | B | FIGMA_NOT_REQUIRED | Profile |
| MD-07 | Account deletion confirmation | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Profile |
| MD-08 | Add saved location | FINAL_UI_V1_MAIN | B | FIGMA_LIGHT | Saved Locations |
| MD-09 | Delete saved location | FINAL_UI_V1_MAIN | C | FIGMA_NOT_REQUIRED | Saved Locations |
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

## Remaining ownership and next handoff

The remaining Tier A set is FS-30 Purchases, FS-32 Reviews and FS-34 Chat.
Design Owner Batch 2 and dependent Agent 3 work retain ownership of those
directions plus related FS-31/FS-33/MD-05/MD-17/MD-18: **8 units / 67 nominal h**.
Do not assign them to Agent 2 to inflate a package.

[Wave 3 recommendation](ASTRA_WAVE3_SCOPE_RECOMMENDATION.md) selects a coherent
Agent 2 customer saved-products/activity package: FS-21/27/28/29 and MD-15/16,
**6 units / 24 nominal h**, Tier B/C, one LIGHT reference classification.
Ten location/Cart/QR modals remain a separately owned 22 h block; the two shared
state families remain Integration-owned 4 h. These disjoint sets total all
**26 units / 117 h**. Even all unreserved work is only 50 h, so a 70–100 h Agent 2
package is unsupported by the current inventory. No future package starts here.
