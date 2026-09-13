# W53A Customer light-only and contrast audit

Date: 2026-09-13 (Europe/Istanbul). Role: persistent Astra UI owner.
Base: `origin/main` at `4f0da8201e2571200e99fa3dfe76387e3a1486ce`.
Branch: `ui/w53a-light-theme-home-category-contrast-fix`.
Workspace: isolated Codex worktree `6e1f/TStore_CLEAN`.

## Result and scope

The pilot root now selects `ThemeMode.light` and does not install the legacy
`darkTheme`. Final UI light tokens remain authoritative even when the operating
system changes brightness while the application is mounted. No dark palette was
implemented. `THelperFunctions.isDarkMode` reads the effective Flutter theme;
it no longer selects its dark branches in this pilot root.

Home displays up to eight distinct supplied root categories, retaining source
order. At 390 px the section uses four columns and two rows; narrow content uses
three columns. Empty, loading and retry states remain real states. IDs are
normalized only for duplicate checking/navigation, as in the previous tap flow.
No category is duplicated, invented, sorted anew or added to runtime fixtures.

The heading exposes **Tüm kategoriler** to guests and authenticated customers.
Inspection found no standalone all-root screen in this main revision:
`TaxonomyBrowseView` requires a selected canonical node and `SubCategoryView`
is the existing legacy/product-list destination. The new heading therefore
opens a small full-root index using the same `HomeCategories`, the same existing
`CategoriesCubit` instance, the same `MaterialPageRoute` navigation pattern and
the unchanged `_openCategory` handler. The index is uncapped; Home is capped at
eight. Canonical sources continue through `buildCanonicalTaxonomyDestination`
only when the existing capability supplies them. No capability or route
architecture was changed. This is the concrete root entry into the existing
category/recursive browse flow, not a fabricated taxonomy root.

## Audit method and findings

Customer presentation sources, their shared theme/components and compatibility
widgets were searched for inherited `Theme.of(context)`/`ColorScheme` colors,
white/black/grey foregrounds, opacity, hardcoded colors and dark-aware branches.
Each candidate was checked against its actual surface and route usage. Safe
white text on primary/error surfaces, QR black-on-white, decorative borders,
shimmer, and disabled-control treatment were retained.

New deterministic tests render the real runtime defaults for Home, Product
Details and Shop Details under both system brightness values. Each light/dark
pair matches the **same** golden file without updating goldens in the final run.
The actual `TStore` is separately tested across dark → light → dark changes,
including effective Theme brightness and underlying system brightness.

Resolved text contrast is checked on Product Details before and after scrolling,
on the complete Shop Details fixture, and on the breadcrumb and seller
availability fixtures. The short Shop fixture fits entirely in the viewport;
its second image remains identical after a scroll attempt.
The helper composites ancestor surfaces and checks 4.5:1 for ordinary text or
3:1 for large text. Other matrix rows are source audits backed by the broad
Customer widget regression in the full Flutter suite; they are not additional
physical-device measurements. Image-backed campaign contrast was also inspected
visually. No production or Figma access was used.

| Finding | Before | Change | After |
|---|---|---|---|
| Root theme mismatch | OS dark theme could supply light text to fixed light surfaces | Authoritative root `ThemeMode.light`; remove root darkTheme registration | OS brightness cannot switch customer theme |
| Product price explanation on primarySoft | textMuted, 4.11:1 | Existing textSecondary token | 5.07:1 |
| Product seller “Rafta var” badge | green.shade700 on translucent green, 3.68:1 | Existing success / successSoft tokens | 4.51:1 |
| Seller Comparison “Rafta yok” badge | textMuted on surfaceAlt, 4.31:1 | Existing textSecondary token | 5.31:1 |
| Deep category breadcrumb ellipsis | textMuted on surfaceAlt, 4.31:1 | Existing textSecondary token; matching chevron | 5.31:1 |
| Home campaign CTA typography | Button's local TextStyle discarded inherited Poppins; deterministic glyph fallback was unreadable | Copy the existing themed label style and retain size/weight | “Keşfet” readable in runtime Home evidence |

No global color token values were changed. These are contextual foreground
fixes, not replacements of every inherited color or grey. The root fix also
protects dialogs, sheets, inputs, menus and navigation labels using the theme.

## Customer screen matrix

PASS = source/surface pairing already coherent under the authoritative light
root. FIXED = root inheritance risk and/or a local pairing corrected in this
wave. FOLLOWUP_REQUIRED = an unresolved known readability issue. Historical
FS IDs are retained for comparison with the customer inventory; this is a
contrast matrix, not a redesign or reachability reclassification.

| ID / surface | Status | Source/surface assessment |
|---|---|---|
| FS-01 Launch/loading gate | FIXED | Root supplies consistent light surface, progress and text |
| FS-02 Onboarding | FIXED | Inherited body/buttons now light; explicit primary foregrounds retained |
| FS-03 Customer login | FIXED | Ambient text and input theme consistent with fixed light form |
| FS-04 Customer signup | FIXED | Input, validation, legal links and root light styles agree |
| FS-05 Verify email / resend | FIXED | Inherited headings/body on fixed light cards |
| FS-06 Forgot password | FIXED | Light input and surrounding ambient text remain coherent |
| FS-07 Reset email sent | FIXED | Themed text on fixed light confirmation surface |
| FS-08 Update password | FIXED | Recovery form inherits light text/error/button colors |
| FS-09 Invalid/expired recovery | FIXED | State card uses primary/secondary text on soft surface |
| FS-10 KVKK | FIXED | Document text inherits light theme; white hero text sits on primary |
| FS-11 Terms | FIXED | Same legal document surface and foreground pairings |
| FS-12 Home | FIXED | Root inheritance; eight-root section; themed campaign CTA; 390 evidence |
| FS-13 Recursive category browse | FIXED | Breadcrumb's tinted-surface text hardened; node cards remain white |
| FS-14 Product Listing | FIXED | Ambient text on light cards; summary muted text sits on elevated light surface |
| FS-15 All Products | FIXED | Input/list/card ambient text light; muted metadata sits on white cards |
| FS-16 Search/suggestions/results | FIXED | Themed fields and result text stay light; icon wells are separate from text |
| FS-17 Product Details | FIXED | Physical-smoke regression target; root, price explanation and availability badge fixed |
| FS-18 Nearby | FIXED | Light location/shop cards and inherited titles agree; primary icon/button foregrounds retained |
| FS-19 Shop Details | FIXED | Physical-smoke regression target; inherited titles/products on fixed light surfaces, dark-system goldens |
| FS-20 Cart V2 / QR | FIXED | Shop/item text inherits light; muted totals/items on cream/white; QR remains black on white |
| FS-21 Wishlist | FIXED | Product/action text on white cards; secondary metadata unchanged |
| FS-22 Account hub | FIXED | Themed titles on light account cards; white badge text on primary |
| FS-23 Profile details | FIXED | Light profile/edit fields; error and primary actions have paired foregrounds |
| FS-24 Saved locations | FIXED | Inherited card text plus explicitly light editor; primary selected state |
| FS-25 Privacy & Permissions | FIXED | Light information cards, dark primary/secondary text |
| FS-26 Help & Support | FIXED | FAQ expansion inherits light theme; semantic text on soft surfaces |
| FS-27 Coupons | PASS | Honest empty state; state-card secondary text on primarySoft |
| FS-28 Recently viewed | FIXED | Themed card titles, secondary metadata, existing light dialogs |
| FS-29 Notifications | FIXED | Ambient body on light cards; semantic secondary timestamps; white badge on primary |
| FS-30 Verified purchases / returns | FIXED | Light purchase cards; dates/quantities muted on white; primary selected tabs |
| FS-31 Customer shop ratings | FIXED | Themed shop/title and explicit secondary text on light cards |
| FS-32 Product reviews / eligibility | FIXED | Review cards white; eligibility primarySoft uses secondary text; inherited text light |
| FS-33 Conversations | FIXED | White thread cards, primary/secondary preview, muted date on white, white count on primary |
| FS-34 Chat / composer | FIXED | Incoming white and outgoing primarySoft bubbles; body inherits dark text; timestamps secondary |
| FD-05 Seller Comparison | FIXED | Unavailable badge hardened; primary/secondary/price roles retained |
| W53A full category root index | PASS | Same light root and existing category tiles, no authentication gate |
| Shared state cards / snackbar | PASS | Secondary on primarySoft; white snackbar text on textPrimary |
| Active dialogs / sheets / menus | FIXED | Root light theme propagates into auth, account, cart/QR, review, rating and location overlays |

`CONTRAST_FOLLOWUPS_REMAINING: 0`

Legacy `StoreView` demo, old checkout/order widgets, old address components and
merchant-only screens were identified separately from active Customer paths;
they are not activated or redesigned here. Low-opacity decorative graphics and
disabled controls are not reported as unreadable informational text. The legacy
dark theme definition is retained for compatibility but is not reachable through
the pilot root. No known active unreadable text is left unreported.

## Visual evidence (390 × 844, isolated fixtures)

- [Home: eight roots, authenticated](../test/widget/shop/goldens/w53a_home_eight_authenticated_390.png)
- [Home: eight roots, guest](../test/widget/shop/goldens/w53a_home_eight_guest_390.png)
- [Product Details: system dark](../test/widget/shop/goldens/w53a_product_details_system_dark_390.png)
- [Product Details: metadata and sellers](../test/widget/shop/goldens/w53a_product_details_system_dark_scrolled_390.png)
- [Shop Details: system dark](../test/widget/shop/goldens/w53a_shop_details_system_dark_390.png)
- [Shop Details: complete list after scroll attempt](../test/widget/shop/goldens/w53a_shop_details_system_dark_scrolled_390.png)

All six images are generated from Flutter widgets; fixture data remains under
`test/`. Home's existing golden baselines are updated for its local heading/grid
change, with the rest of the composition preserved. The prior runtime Product
Details baseline changes only for its darker price explanation. Original
prototype directions for Product Details and Shop Details are not redesigned.

## Shared ownership and boundaries

`SHARED_COMPONENT_CHANGE_REQUIRED: YES` — authoritative root enforcement only.
Exact shared file: `lib/t_store.dart`. Owner branch is the W53A branch above.
The user explicitly required MaterialApp/theme inspection and enforcement.
No shared token or component definition, provider wiring, listener, dependency,
backend, taxonomy data/model/capability, reward mechanic or production setting
was modified. Category root navigation is local to `home_categories.dart` and
uses its existing guarded category handler. No observed file collision; the
worktree started clean. Main is not merged or pushed by this worker.

## Validation and delivery

- Targeted gate: **72 tests PASS** across the actual root, category behavior,
  Home/Details/Shop evidence and semantic contrast fixtures (also passed within
  the final full run). This includes **21 new tests**. Home counts 0/1/3/7/8/11,
  duplicate/child filtering, source order, 320 px enlarged text, guest/auth index
  navigation, rapid taps and uncapped canonical identity handoff are covered.
- Related Category/Seller Comparison visual regression: **45 PASS**.
- Final full Flutter suite: `flutter test --no-pub` — **2086 PASS, 6 existing
  opt-in live tests skipped**, 0 failures, 73 seconds. This includes the broad
  Customer widget regression and architecture, unit and mocked integration
  coverage. Live Development/Production tests were not enabled and no skips
  were introduced by W53A.
- Analyzer: `flutter analyze --no-pub` — **PASS, no issues** (13.7 seconds).
- `git diff --check`: **PASS**.
- Added/changed text secret/PII scan: **PASS**, zero private-key, credential/JWT,
  email or Turkish-phone-pattern hits. Local fixture screenshots contain no
  production data. Document screenshot links: **6 valid, 0 broken**.
- Visual inspection: all six new 390 px artifacts inspected, including actual
  detail metadata/seller content. Existing narrow/enlarged Home and deep-category
  samples also inspected. The full suite verifies all updated references.

Failures addressed during validation: the old 100 px minimum category-width
check exposed the need for three columns at 320 px; two measured low-contrast
Product Details strings were corrected; a fixture destination needed a back bar;
the Shop test needed its real ListView scroll target. Home image decoding is now
awaited before capture. Two lint formatting issues were fixed. The first full
suite's single mismatch was inspected and limited to the intended availability
badge; its Product Information reference was updated before the final full pass.
No tests were deleted, skipped or relaxed to conceal a runtime failure.

Changed files: **42** = **7 runtime Dart + 7 test Dart + 27 PNG + 1 report**.
The 27 PNGs comprise six new evidence images and 21 relevant existing baselines:
Home heading/grid, category breadcrumb foreground, Product Details price text
and the Product Information availability badge. No dependencies/config/backend
files changed.

Observed start: **2026-09-13 23:06:53 Europe/Istanbul** (20:06:53 UTC).
Elapsed through final verification: approximately **29 minutes**; Git delivery
follows on the same task branch. The final commit/HEAD and normal push/tree
confirmation are supplied in TASK_RESULT. No main merge or force push.

All **8/8 requested phases completed**. Blockers: **NONE**. Required Product
Owner decisions: **NONE** beyond visual acceptance. Figma calls: **0**.
Calibration: **GREEN** — no critical regression, no scope drift, zero new
substantive owner corrections. Recommended next package size: **SAME_SIZE**,
with any root/shared-theme edits kept under one owner.

```text
LIGHT_ONLY_ENFORCED: PASS
SYSTEM_DARK_MODE_OVERRIDE_SAFE: PASS
HOME_CATEGORY_MAX_DISPLAY: 8
HOME_8_CATEGORY_RENDER: PASS
HOME_ALL_CATEGORIES_ACTION: PASS
ALL_CATEGORIES_NAVIGATION: PASS
PRODUCT_DETAILS_CONTRAST: PASS
SHOP_DETAILS_CONTRAST: PASS
CUSTOMER_GLOBAL_CONTRAST_AUDIT: PASS
CONTRAST_FOLLOWUPS_REMAINING: 0
FULL_TEST_SUITE: PASS
ANALYZER: PASS
BACKEND_CHANGED: NO
TAXONOMY_CHANGED: NO
PRODUCTION_ACCESSED: NO
FIGMA_ACCESSED: NO
READY_FOR_PRODUCT_OWNER_VISUAL_REVIEW: YES
READY_FOR_INTEGRATION: YES
```
