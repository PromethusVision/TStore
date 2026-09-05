# Astra Wave 1 — Implementation collision review

Date: 2026-09-05. This review was written and committed **before either merge**.
Owner: Integration Agent, `integration/astra-wave-1-implementation-batch`.

## Inputs and authority

| Input | Verified revision | Base-relative scope |
|---|---|---|
| Starting main | `4287972429d9befe4ef2637a565ea6d8a2393a5e` | Fetch found no newer main commits |
| A — Discovery | `44acd83181e9128afe97c43d5bc995e6377fd58c` | 34 files: 2 runtime, 3 test/fixture, 27 PNG, 2 docs; 6 commits |
| B — Auth/Startup | `147a5e1a7c7d5462ab7ee3421712e822be35e65d` | 55 files: 22 runtime, 4 tests, 27 PNG, 2 docs; 4 commits |

Both merge bases equal starting main. Complete changed-path sets have **zero
intersection**. Neither source changes core UI, theme, navigation, dependency
injection, bootstrap, dependencies, backend, taxonomy, domain/data or Cubits.
The source patches, package test/fixture code and source reports were reviewed;
committed binary images are covered by the post-merge visual gate below.

W39 authoritative Flutter semantic tokens/Poppins/primitives remain the source
of truth, as preserved by W44B's newer execution protocol. No branch needs to
replace a shared foundation implementation. Preserve A's complete Discovery
blobs and B's complete Auth blobs; do not choose versions by timestamp alone.

W44 calls FS-15/16 Tier A / FIGMA_HEAVY. The explicit W45B direct-implementation
contract and this W45D integration instruction waive their separate per-screen
owner gate. Their historical tier is retained in the inventory. This exception
does not approve W45A's Shop/Nearby/Cart prototypes or other future Tier A work.
W45A is read-only evidence here and **must not be merged**.

## Shared-file and semantic classification

Every row is `NO_CONFLICT` unless explicitly stated otherwise. Unchanged means
the same Git blob in main, A and B; consumer behavior still requires combined
tests. There are no `TEXTUAL_CONFLICT_SAFE`, runtime
`SEMANTIC_RECONCILIATION_REQUIRED`, or `BLOCKER` files at pre-merge review.

| Exact file / explicitly bounded file set | A / B | Classification and preservation evidence |
|---|---|---|
| `lib/core/ui/foundation/esnaftavar_design_tokens.dart` | unchanged / unchanged | NO_CONFLICT — one color/spacing/radius/target family |
| `lib/core/ui/foundation/esnaftavar_theme.dart` | unchanged / unchanged | NO_CONFLICT — Poppins/light theme, shared button/input/card styles |
| `lib/core/utils/theme/theme.dart` and `lib/core/utils/theme/widget_themes/` | unchanged / unchanged | NO_CONFLICT — no global style override |
| `lib/core/ui/components/esnaftavar_scaffold.dart` | unchanged / unchanged | NO_CONFLICT — both consumers use existing theme/safe-area contract |
| `lib/core/ui/components/esnaftavar_section_header.dart` | unchanged / unchanged | NO_CONFLICT — A uses existing header |
| `lib/core/ui/components/esnaftavar_state_card.dart` | unchanged / unchanged | NO_CONFLICT — both use existing state/actions API |
| `lib/core/ui/components/esnaftavar_surface_icon_button.dart` | unchanged / unchanged | NO_CONFLICT — no competing 44 px control |
| `lib/core/utils/constants/customer_home_v1_tokens.dart` | unchanged / unchanged | NO_CONFLICT — compatibility facade retained for other callers |
| `lib/core/common/widgets/customer_light_input_theme.dart` | unchanged / unchanged | NO_CONFLICT — Discovery input and Auth forms consume same light-input contract |
| `lib/core/common/widgets/navigation_menu.dart` | unchanged / unchanged | NO_CONFLICT — guest detour, caller return and shell retained |
| `lib/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart` and `navigation_menu_state.dart` | unchanged / unchanged | NO_CONFLICT — same five tabs/index semantics |
| `lib/core/dependency_injection/service_locator.dart` | unchanged / unchanged | NO_CONFLICT — no registrations/lifetime changes |
| `lib/main.dart`, `lib/t_store.dart` | unchanged / unchanged | NO_CONFLICT — launch target/listener placement unchanged; no route generator added |
| `lib/features/wishlist/presentation/widgets/product_favorite_button.dart` | unchanged / unchanged | NO_CONFLICT — A changes only the consuming size/semantics; guest pushes the same B Login with return-to-caller |
| `lib/features/shop/presentation/widgets/home_search_bar.dart` | changed / unchanged | NO_CONFLICT — Home-visible history/suggestions only; field, debounce, storage, callbacks retained |
| `lib/features/shop/presentation/views/all_products_view.dart` | changed / unchanged | NO_CONFLICT — owned ProductsCubit, search Cubit, canonical handoff, price loader and navigation locks retained; no invented filter/sort |
| `lib/features/shop/presentation/widgets/product_image_fallback.dart` | unchanged / unchanged | NO_CONFLICT — A consumes existing fallback |
| `lib/features/shop/presentation/widgets/product_sellers_section.dart` | unchanged / unchanged | NO_CONFLICT — seller sort, listing price, cart/auth handoff preserved |
| `lib/features/auth/presentation/widgets/customer_auth_form_card.dart` | unchanged / changed | NO_CONFLICT — Auth-only consumers; theme duplication removed; autofill cancels on disposal |
| `lib/features/auth/presentation/widgets/email_confirmation_listener.dart` | unchanged / changed | NO_CONFLICT — import and notice build only; subscriptions, callback validation, dedupe, session checks, route replacement, notice lifecycle unchanged |
| `lib/features/auth/presentation/widgets/password_recovery_listener.dart` | unchanged / unchanged | NO_CONFLICT — fail-closed recovery routing retained |
| `lib/features/auth/presentation/widgets/login_form_section.dart` | unchanged / changed | NO_CONFLICT — validator/submit/role/caller-return retained; presentation, autofill, read-only loading and scrollable compatibility dialog |
| `lib/features/auth/presentation/widgets/sign_up_form_section.dart` | unchanged / changed | NO_CONFLICT — BlocConsumer rebuilds read-only loading fields; listener and submit/security validation unchanged |
| `lib/features/auth/presentation/widgets/terms_and_privacy_agreement.dart` | unchanged / changed | NO_CONFLICT — consent values unchanged, labels and 44 px legal links |
| `lib/features/auth/presentation/views/legal/legal_document_views.dart` | unchanged / changed | NO_CONFLICT — Privacy consumes same legal views; content and version unchanged |
| `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `test/helpers/` | unchanged / unchanged | NO_CONFLICT — no dependency, analyzer or common harness change; no global flutter_test_config introduced |
| `test/widget/shop/w45b_discovery_fixture.dart` | new / absent | NO_CONFLICT — package-local mocks, isolated service-locator reset and fonts; no network fixtures |
| `test/widget/shop/w45b_discovery_final_test.dart`, `w45b_inline_search_final_test.dart` | new / absent | NO_CONFLICT — 92 + 44 cases; no pre-existing assertion or golden overwritten |
| `test/widget/auth/w45c_auth_startup_final_ui_test.dart` | absent / new | NO_CONFLICT — separate fixture/font setup and golden namespace; 68 cases |
| `test/widget/auth/on_boarding_view_test.dart` | unchanged / changed | NO_CONFLICT — 3 added tests, existing cases retained |
| `test/widget/auth/password_recovery_flow_test.dart`, `password_recovery_listener_test.dart` | unchanged / changed | NO_CONFLICT — two icon-container finders become actual icon-descendant assertions inside StateCard; behavior assertions retained |
| `test/widget/shop/goldens/w45b_*.png`, `test/widget/auth/goldens/w45c_*.png` | separate / separate | NO_CONFLICT — 27 + 27 new images; no shared golden replacement |
| The four W45B/W45C package docs | separate / separate | NO_CONFLICT — source claims remain attributable to their branch test revisions |

All other changed B runtime files are listed below and individually classified
`NO_CONFLICT`: A does not edit or consume their private composition; imports,
layout, copy and accessibility changes retain the existing route/state methods.

- `lib/features/auth/presentation/views/login/login_view.dart`
- `lib/features/auth/presentation/views/on_boarding/customer_launch_gate.dart`
- `lib/features/auth/presentation/views/on_boarding/on_boarding_view.dart`
- `lib/features/auth/presentation/views/password_configuration/forget_password_view.dart`
- `lib/features/auth/presentation/views/password_configuration/invalid_password_recovery_view.dart`
- `lib/features/auth/presentation/views/password_configuration/reset_password_view.dart`
- `lib/features/auth/presentation/views/password_configuration/update_password_view.dart`
- `lib/features/auth/presentation/views/signup/sign_up_view.dart`
- `lib/features/auth/presentation/views/signup/verify_email_view.dart`
- `lib/features/auth/presentation/widgets/forget_password_form_section.dart`
- `lib/features/auth/presentation/widgets/forget_password_header_section.dart`
- `lib/features/auth/presentation/widgets/login_header_section.dart`
- `lib/features/auth/presentation/widgets/on_boarding_dot_navigation.dart`
- `lib/features/auth/presentation/widgets/on_boarding_next_button.dart`
- `lib/features/auth/presentation/widgets/on_boarding_page.dart`
- `lib/features/auth/presentation/widgets/on_boarding_skip_button.dart`

## Documentation reconciliation required

`docs/UI_W44_CUSTOMER_SURFACE_INVENTORY.md` is
`SEMANTIC_RECONCILIATION_REQUIRED` for the integration-owned refresh: MD-10 was
incorrectly counted active. Its wrong-role dialog requires `isMerchantLogin:
true`; no active runtime caller supplies that value. B preserves and tests the
compatibility surface without activating it. Record REACHABLE=NO, keep the ID
and historical estimate, exclude it from the active modal count. MD-11 and
MD-24 are the two active Auth modal/notice surfaces. A adds no modal. MD-13
remains reachable through the existing Product Details seller section, while
FD-05's dedicated screen stays unbound. Do not turn compatibility/legacy code
into a route to make old counts fit.

## Merge and acceptance plan

1. Commit this review; merge A then B with `--no-ff`. Order has no shared-file
   dependency; the requested order is safe. Any unexpected conflict stops merge
   for explicit resolution review, never automatic ours/theirs selection.
2. Compare every changed source blob with the merged tree; retain both complete
   feature/test/golden sets. Compare discovered test-file sets and source counts.
3. Run combined Discovery/navigation/Product Details handoff/Wishlist-login and
   all Auth/Startup/listener tests, then existing Home/Category/Listing/Details/
   Seller/Cart/QR/Reviews/Wishlist regression. Run analyzer and one final full
   suite, no golden updates, no opt-in live tests, no added skips.
4. Inspect representative committed images from both sources against W39–W43
   final images; check narrow/large-text evidence. Major divergence blocks main.
5. Reconcile inventory/calibration/planning; diff/secret/PII gate; push task and
   main only after PASS, without force. Record final evidence in
   `ASTRA_WAVE1_IMPLEMENTATION_INTEGRATION_RESULT.md`.

Pre-merge decision: **SAFE_TO_MERGE_FOR_VALIDATION**. This is not a claim that
post-merge tests or main delivery have already passed.
