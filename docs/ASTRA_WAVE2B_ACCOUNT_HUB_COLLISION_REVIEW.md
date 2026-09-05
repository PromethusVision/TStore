# Astra Wave 2B — Account Hub collision review

Status: **PRE-MERGE SEMANTIC REVIEW PASS — 2026-09-05**.
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
