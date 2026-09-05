# Astra Wave 2B — Account Hub collision review

Status: **FINAL SEMANTIC ACCEPTANCE PASS — 2026-09-05**.
Starting main: `c63e61d6363f2cbeb816b7cb55e970e40f798d78`.
Final source: `5c2dc3b6dec6721a59ffe81aa863e89c3a0eaff3`,
origin/astra-ui/w46-account-hub-final-ui.
Common ancestor / source base: `6cc5d1607da96415f788d5324006bc89fe85d554`.
Task branch: `integration/astra-wave2b-account-hub`.

Fetch verified exact required main and source. No later main commits exist.
All six source checkpoints (0ae087e, 3355477, 3ff2f42, 172359d, 0ac2f6a, 5c2dc3b)
are in the final source lineage. The prior Wave 2A task is complete; its branch
is not used as a new base. The stale W40A task was explicitly discarded.

## Exact active scope

| ID | Surface | Runtime entry and preserved authority |
|---|---|---|
| FS-22 | Settings / Account Hub | NavigationMenuCubit tab 4; shell customer guard. Existing public Help/Privacy and return-to-caller guest paths retained. |
| FS-23 | Profile / Hesap Bilgilerim | Authenticated hub identity/menu; existing UserEntity name/email/optional phone. |
| FS-24 | Saved Locations | Hub, Help, Home, Nearby and product-seller routes; existing list/add/default/delete contract. |
| FS-25 | Privacy and Permissions | Public hub item; reads permission status, does not request GPS; existing KVKK/Terms routes. |
| FS-26 | Help and Support | Public hub item; existing protected Purchases/Messages/Locations callbacks and FAQ/support content. |
| MD-06 | Edit Profile sheet | Profile edit action; existing name/phone validation, immutable email, pending lock, returned UserEntity and AuthCubit sync. |
| MD-07 | Delete account dialog | Profile danger action; typed SİL, warning/retention content, existing submit/cleanup/navigation. |
| MD-08 | Add saved location sheet | List/empty add action; explicit GPS capture and existing required name/address fields. **Add only; editing is absent.** |
| MD-09 | Delete saved location dialog | Each saved-location row; cancel/confirm and duplicate-resolution guard, exact existing delete call. |

**5 full screens + 4 active sheets/dialogs = 9/9 scoped surfaces, 7 B + 2 C.**
No logout-confirmation screen/dialog exists. Legacy Address/Profile helpers,
merchant surfaces and inactive routes are not activated. Existing menu destinations
outside this package remain independently counted unfinished work.

## Complete source delta

**30 files: 13 personalization UI Dart + 3 test/fixture Dart + 12 PNG + 2 docs.**
There is no changed-path overlap with the complete main delta since source base.

Presentation paths under `lib/features/personalization/presentation/`:

- views/settings_view.dart
- views/profile_view.dart
- views/customer_saved_locations_view.dart
- views/privacy_and_permissions_view.dart
- views/help_and_support_view.dart
- widgets/account_deletion_confirmation_dialog.dart
- widgets/account_page_header.dart (new, account-local composition)
- widgets/app_settings_section.dart
- widgets/edit_profile_bottom_sheet.dart
- widgets/settings_menu_tile.dart
- widgets/settings_menu_tile_list.dart
- widgets/settings_view_header_section.dart
- widgets/user_profile_tile.dart

Tests under `test/widget/personalization/`: existing
customer_saved_locations_view_test.dart (two button-type selectors adapted,
assertions preserved), new w46_account_final_test.dart and w46_account_fixture.dart.
Twelve new w46_*.png files are in that directory's goldens folder.
Source docs: UI_W46_ACCOUNT_HUB_SURFACE_MAP.md and UI_W46_ACCOUNT_HUB_TASK_RESULT.md.
The fixture uses explicitly synthetic identities/example.com data and local
coordinates; no remote account or location data is required.

## Collision classification

| Area / files | Classification | Resolution / evidence |
|---|---|---|
| NavigationMenu, NavigationMenuCubit, bootstrap, named/generated routes | NO_CONFLICT | No source change. Same five tabs, caller routes and guarded return-to-caller navigation. No standalone AuthGuard class exists. |
| Auth/Startup Cubits/domain/data, Supabase service/config, callback/session/confirmation/recovery listeners | NO_CONFLICT | Entire source delta excludes these files. Account consumes existing Auth state without changing login/signup/token/session/reset behavior. |
| SettingsView private guards and unread lifecycle; AppSettingsSection logout | SAFE_TEXTUAL | Composition/tokens/icon and physical-shopping copy change; sign-in/public/protected navigation and direct logout methods match main. No invented confirmation dialog. |
| Profile and EditProfileBottomSheet | SAFE_TEXTUAL | Existing UserEntity fields, validators, submit/error/return and AuthCubit sync retained. Source reuses unchanged CustomerAuthFormCard and Final UI theme. No personal-data field or account capability added. |
| AccountDeletionConfirmationDialog / Profile callback | SAFE_TEXTUAL | Final UI wrapper and scrollable content; SİL predicate, duplicate/back lock, submit result and existing deletion/cleanup preserved. No added destructive operation. |
| Privacy / existing Auth legal views | NO_CONFLICT | All human copy strings in Privacy match main. Permission read/refresh/legal navigation methods unchanged. KVKK/Terms files untouched. Help changes only its non-legal header subtitle. |
| CustomerSavedLocationsView / existing repository, Cubit and entity | SAFE_TEXTUAL | Add/default/delete presentation reuses the same model and methods. No editing/update API, geocoding or inferred coordinates. First-default/fallback logic lives in unchanged Cubit/repository. |
| Nearby / Home / product-seller location interaction | NO_CONFLICT | Existing callers reopen the same Saved Locations class. Nearby calls loadShops after return; the shared location service reloads the repository default. Home refreshes its saved-location state; seller section reloads preferred location. Wave 2A views/helpers stay untouched. |
| Real Nearby → Saved Locations → changed default → Nearby path | SEMANTIC_RECONCILIATION_REQUIRED | Existing tests separately cover both sides and callback refresh. Add a bounded integration test of the real destination, real Cubits and local repository/service fakes, including selected-location truth on return. No runtime patch is indicated by static review. |
| Core Final UI theme/tokens/primitives and Auth form card | NO_CONFLICT | No source changes. Reused by reference. No simultaneous foundation rewrite. |
| AccountPageHeader and existing account widgets | SAFE_TEXTUAL | New header composes existing back control/typography for four account pages; other changed widgets are account-local. The legacy AccountSettingsSection consumer remains inactive. This is not a new global design system. |
| Tests/goldens/helpers | NO_CONFLICT | New account-local fixture/matrix and PNG names. No shared test harness/config/golden replacement. Existing live-gated files untouched. |
| Inventory / calibration / coordination | SEMANTIC_RECONCILIATION_REQUIRED | Recompute actual active rows; correct historical MD-08 add/edit label to add-only without inventing a new surface. Preserve Tier A Design Owner/Agent 3 reservations and assess feasible Wave 3 scope. |

**SHARED_COMPONENT_CHANGE_REQUIRED: NO.**
No Home/Category/Listing/Details/Seller/Search/Auth/Shop/Cart/Nearby source file,
core primitive, global form, location service, model, repository, backend, config
or taxonomy file is changed by the source. Existing approved Category UI remains
closed and unchanged.

## Independent behavior audit

Twenty-seven method blocks match current main after whitespace normalization:

| File | Matched methods |
|---|---|
| settings_view.dart | _currentUserId, _requireCustomerSignIn, _openProtectedDestination, _signInFromProfileHeader, _openPublicDestination, _buildAccountDestination, _refreshAndRestart, _refreshIfVisible |
| profile_view.dart | _openAccountDeletionConfirmation, _displayValue |
| edit_profile_bottom_sheet.dart | _onFieldChanged, _submit, _close, _validateFullName, _validatePhone |
| account_deletion_confirmation_dialog.dart | _isConfirmationValid, _submit, _close |
| app_settings_section.dart | _signOut |
| privacy_and_permissions_view.dart | _readPermissionStatus, _refreshPermissionStatus, _openLegalDocument |
| customer_saved_locations_view.dart | _openAddLocation, _setDefaultLocation, _captureLocation, _save, _messageForLocationFailure |

Mixed presentation/action methods were reviewed separately: profile editor
opening changes only sheet colors/radius; saved-location delete changes the
dialog presentation and keeps exact ID, cancel, busy and confirmation semantics.
The read-only permission loader and legal document files remain unchanged.

## Merge and final gate contract

Review PASS permits **source --no-ff** merge; it does not replace the combined
acceptance gate. Complete the real location handoff test, targeted account and
guard/session tests, overlap Auth/Startup/Nearby/Home/Search/navigation tests,
broader Customer regression, analyzer and one combined full suite.

Expected combined count before integration-specific tests: **1766 + 73 = 1839**.
Check discovery against the union of both branch test file sets; no lost
assertion, new skip or unreviewed golden rewrite is acceptable. Inspect source
account/edit/privacy/location/add/deletion visual evidence against the existing
Final UI. A major divergence is a blocker, not permission for broad redesign.

Only Git remotes are authorized. Figma access, Development writes, Production,
backend/auth config/taxonomy changes, canonical activation, Ads/Reward economics,
Merchant implementation and dark mode are outside scope.

## Final semantic acceptance — PASS

Pre-merge review commit **489aa4e3c2ed101f03c5e804f397999231a0e3e9** precedes
no-ff source merge **5ef2d5e8023790fadc5d3c5b480c645baacc81f0**.
Text conflicts: **0**. Runtime reconciliation edits: **0**.

Both SEMANTIC_RECONCILIATION_REQUIRED items are resolved:

1. **Actual location handoff coverage — PASS**, checkpoint
   **699b3a897935724ee63a77c78fc33ff9b347b1a2**:
   `test/widget/personalization/wave2b_nearby_saved_locations_handoff_test.dart`
   adds two real-view/real-Cubit offline tests. Changing the repository default
   updates Nearby's label, merchant ordering and real computed distance; deleting
   the only default clears stale label/source/distances. No GPS or permission
   request occurs. Existing Home/seller callbacks and location service tests
   remain intact. No coordinate, geocoding, editing or distance behavior invented.
2. **Inventory and planning — PASS**:
   [merged row ledger](UI_W46_POST_ACCOUNT_HUB_INVENTORY.md) independently counts
   26 remaining = 9 screens + 15 modals + 2 state families; Tier 3/8/15, Figma
   3/4/19. MD-08 is add-only. [Wave 3 ownership](ASTRA_WAVE3_SCOPE_RECOMMENDATION.md)
   excludes Design Owner/Agent 3's 67 nominal h, rejects infeasible 70–100 h
   padding and recommends an independent 24 h / 6-unit Agent 2 package.
   Calibration, the three-scenario plan and four coordination docs are refreshed.

Validation: **279 targeted, 603 overlap, 598 broader PASS**; analyzer clean;
one combined full run **1841 PASS / 0 FAIL / 6 unchanged conditional skips**.
All **165/165 expected test files** discovered. Exact skip names match the
1766-test main baseline; source +73 and integration +2 explain all growth.
No test/assertion loss, new skip, weakened business assertion or golden rewrite.

All **30 source files** match final source byte-for-byte. All **186 existing main
PNGs** remain exact; the source adds **12**. Runtime changes relative to main are
only the source's **13 account presentation files**. Auth, core primitives,
Category and every protected previous Final UI feature remain unchanged.

Representative source visuals reviewed: Hub, Edit, Privacy, Saved Locations,
320px/130% keyboard Add Location, and deletion confirmation. Final UI typography,
spacing, colors, responsive layout, state truth and existing destructive copy
are consistent; no major visual divergence or additional Product Owner gate.
This is local visual/behavior acceptance, not a physical-device or pilot gate.

Diff/secret/PII review: no whitespace errors or credential findings. The four
email/phone candidates are reviewed synthetic fixture lines (43/45/77/79 in
w46_account_fixture.dart); fixture names, address text and coordinates are local
test data, never fetched from or sent to a remote account. No real PII identified.

**SHARED_COMPONENT_CHANGE_REQUIRED: NO. SEMANTIC_COLLISIONS_RESOLVED: PASS.**
No unresolved blocker, required owner decision, Figma call, Development write,
Production access, backend/auth configuration/taxonomy change or legacy
activation. Full delivery and Git publication details:
[Wave 2B integration result](ASTRA_WAVE2B_ACCOUNT_HUB_INTEGRATION_RESULT.md).

## Exact source path manifest

- docs/UI_W46_ACCOUNT_HUB_SURFACE_MAP.md
- docs/UI_W46_ACCOUNT_HUB_TASK_RESULT.md
- lib/features/personalization/presentation/views/customer_saved_locations_view.dart
- lib/features/personalization/presentation/views/help_and_support_view.dart
- lib/features/personalization/presentation/views/privacy_and_permissions_view.dart
- lib/features/personalization/presentation/views/profile_view.dart
- lib/features/personalization/presentation/views/settings_view.dart
- lib/features/personalization/presentation/widgets/account_deletion_confirmation_dialog.dart
- lib/features/personalization/presentation/widgets/account_page_header.dart
- lib/features/personalization/presentation/widgets/app_settings_section.dart
- lib/features/personalization/presentation/widgets/edit_profile_bottom_sheet.dart
- lib/features/personalization/presentation/widgets/settings_menu_tile.dart
- lib/features/personalization/presentation/widgets/settings_menu_tile_list.dart
- lib/features/personalization/presentation/widgets/settings_view_header_section.dart
- lib/features/personalization/presentation/widgets/user_profile_tile.dart
- test/widget/personalization/customer_saved_locations_view_test.dart
- test/widget/personalization/goldens/w46_add_320_130.png
- test/widget/personalization/goldens/w46_add_390_100.png
- test/widget/personalization/goldens/w46_deletion_390_100.png
- test/widget/personalization/goldens/w46_edit_390_100.png
- test/widget/personalization/goldens/w46_help_390_100.png
- test/widget/personalization/goldens/w46_hub_320_130.png
- test/widget/personalization/goldens/w46_hub_390_100.png
- test/widget/personalization/goldens/w46_locations_390_100.png
- test/widget/personalization/goldens/w46_locations_430_130.png
- test/widget/personalization/goldens/w46_privacy_390_100.png
- test/widget/personalization/goldens/w46_profile_390_100.png
- test/widget/personalization/goldens/w46_profile_430_130.png
- test/widget/personalization/w46_account_final_test.dart
- test/widget/personalization/w46_account_fixture.dart
