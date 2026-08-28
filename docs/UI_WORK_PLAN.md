# EsnaftaVar Customer App Final UI Kit Rollout — Wave 27 Work Plan

**State:** `EXECUTION PLAN — AUDIT/ROLLOUT DESIGN/STRESS TEST ONLY`
**Branch:** `agent3/w27-customer-ui-kit-rollout-preparation`
**Base:** `origin/main@fca935fdbe3053d2d9aa4bbb7a10b1f928007b63`

## Guardrails

Only new `docs/UI_*` artifacts will be created. Flutter/Dart, Figma, runtime,
database, Supabase, Production, Development and taxonomy runtime remain read-only.
No visual/product option is Product Owner-finalized. Current Auth, Cart V2, Reviews,
QR, Search, Location, Wishlist and shop/product behavior must survive any future
visual rollout unchanged.

## Execution phases and 92 substantive work packages

| # | Phase | Work package | Completion evidence |
|---:|---|---|---|
| 1 | Foundation | Source branch HEAD manifest | Exact read-only refs and availability |
| 2 | Foundation | Existing UI document reconciliation | Canonical/proposal/runtime state separated |
| 3 | Foundation | Customer functional invariant ledger | Behavior that visual work must preserve |
| 4 | Foundation | Known C1 issue evidence check | Each requested refinement verified, not assumed |
| 5 | Inventory | Flutter feature/view file census | Exact customer-facing files and roles |
| 6 | Inventory | Route/navigation screen inventory | Reachable, guarded, nested and legacy screens |
| 7 | Inventory | Core pilot screen inventory | Home through Guest AuthGuard coverage |
| 8 | Inventory | Secondary account/settings inventory | Profile, address, settings and deletion surfaces |
| 9 | Inventory | Chat/notification inventory | Active state and rollout relevance |
| 10 | Inventory | Widget/component census | Shared, local, duplicated and one-off widgets |
| 11 | Inventory | Theme/config census | ThemeData, extensions and bootstrap use |
| 12 | Inventory | Asset/icon/media census | Images, SVGs, placeholders and icon families |
| 13 | Debt | Hardcoded color scan | File/line/surface/value findings |
| 14 | Debt | Hardcoded spacing scan | EdgeInsets/SizedBox/gap patterns |
| 15 | Debt | Typography scan | TextStyle/font size/weight/line-height debt |
| 16 | Debt | Radius/border scan | Shape values and semantic variants |
| 17 | Debt | Elevation/shadow scan | Shadow/elevation consistency and overuse |
| 18 | Debt | Opacity/state-color scan | Disabled/overlay/state ambiguity |
| 19 | Debt | Inline decoration scan | Container/Card/InputDecoration duplication |
| 20 | Debt | Marketplace-template residue audit | Cold/generic/irrelevant visual patterns |
| 21 | Tokens | Canonical token source audit | Final versus proposal token authority |
| 22 | Tokens | Color semantic mapping | Warm surfaces, teal/green and terracotta roles |
| 23 | Tokens | Typography semantic mapping | Display/title/body/label roles |
| 24 | Tokens | Spacing semantic mapping | Layout/component/inset scale |
| 25 | Tokens | Shape/elevation mapping | Radius, border, shadow and focus rings |
| 26 | Tokens | Icon/media token mapping | Size, stroke, tint and aspect roles |
| 27 | Tokens | Motion token boundary | Restrained duration/easing proposals |
| 28 | Tokens | Dark-mode dependency review | Decision and non-blocking strategy |
| 29 | Tokens | Token migration mechanics | Compatibility layer and deprecation sequence |
| 30 | K’pasa | K’pasa visual primitive inventory | Reusable basis versus unsuitable template parts |
| 31 | K’pasa | K’pasa color/shape mapping | Preserve basis without cold marketplace residue |
| 32 | K’pasa | K’pasa layout mapping | Mobile composition and density reuse |
| 33 | K’pasa | EsnaftaVar-specific variant register | Local-commerce/customer trust needs |
| 34 | Components | Button variants | Primary/secondary/tertiary/destructive/loading |
| 35 | Components | Input variants | Search/form/password/error/disabled/focus |
| 36 | Components | Product cards | Grid/list/compact/skeleton/unavailable |
| 37 | Components | Category cards | Image/icon/text/fallback/variable depth |
| 38 | Components | Merchant/shop cards | Distance/rating/status/local identity |
| 39 | Components | SellerPriceRow | Compact mobile/price/distance/CTA states |
| 40 | Components | Rating/review components | Average/count/stars/forms/status |
| 41 | Components | Verified-purchase badge | Evidence wording and visual authority boundary |
| 42 | Components | Cart components | Quantity/remove/conflict/summary arithmetic |
| 43 | Components | Bottom navigation | Selected/unselected/badge/safe-area behavior |
| 44 | Components | AuthGuard surface | Guest explanation, continuation and cancellation |
| 45 | Components | Search UI | Field, filters, history, no-results and loading |
| 46 | Components | Location UI | Permission/manual area/distance/error states |
| 47 | Components | Wishlist states | Toggle/loading/auth/error semantics |
| 48 | Components | Review UI | Eligibility/form/edit/delete/error states |
| 49 | Components | Chat/notification UI | Active messages, unread, reconnect and empty states |
| 50 | Components | Profile/address/settings UI | Form, validation, destructive action consistency |
| 51 | States | Loading strategy | Inline/page/modal/skeleton/progress decisions |
| 52 | States | Empty-state system | First-use/filter/no-data/coverage distinctions |
| 53 | States | Error-state system | Recoverable/blocking/offline/authorization classes |
| 54 | States | Dialog/bottom-sheet system | Confirmation/forms/info/destructive consistency |
| 55 | States | Snackbar/message system | Success/info/warning/error/action semantics |
| 56 | States | Disabled/in-flight system | Double-action guards remain visible and correct |
| 57 | Content | Text hierarchy | Scan order, prominence and semantic roles |
| 58 | Content | Turkish copy consistency | Terminology, casing, punctuation and tone |
| 59 | Content | Developer/placeholder copy audit | Customer-facing residue removal map |
| 60 | Content | Long Turkish text model | Wrapping, truncation and disclosure rules |
| 61 | Accessibility | Semantic-label audit model | Screen-reader names/roles/state |
| 62 | Accessibility | Touch-target model | Minimum interactive geometry and spacing |
| 63 | Accessibility | Contrast/focus model | State-aware contrast and keyboard focus |
| 64 | Accessibility | Text-scale model | 100–200% behavior and no hidden actions |
| 65 | Responsive | 390px reference contract | Canonical narrow-mobile layout evidence |
| 66 | Responsive | Small-device behavior | 320–359px overflow/reflow priorities |
| 67 | Responsive | Larger-device behavior | Width caps, grids and whitespace control |
| 68 | Motion | Animation restraint | Purposeful state/transition motion only |
| 69 | Navigation | Transition consistency | Route/modal/back/guard behavior preserved |
| 70 | Identity | Local-commerce visual identity | Warmth, proximity, shop trust and physical intent |
| 71 | Screens | Screen-by-screen rollout map | Current debt, target components and priority |
| 72 | Screens | Exact Flutter file impact map | Future write ownership and risk per file |
| 73 | Screens | Duplicated widget consolidation map | Consolidate only proven semantic matches |
| 74 | Risk | Functional regression register | Auth/cart/review/QR/search/location/wishlist risks |
| 75 | Risk | Taxonomy dependency map | Variable depth, names and proposal-state boundaries |
| 76 | Risk | Catalog/media dependency map | Product/listing/media/fallback ownership |
| 77 | Risk | Merchant future consistency | Shared brand language without equal polish requirement |
| 78 | Acceptance | Screenshot baseline strategy | Exact route/state/device/text-scale manifest |
| 79 | Acceptance | Visual acceptance rubric | Objective tokens/layout/states/a11y plus owner review |
| 80 | Testing | Rollout regression strategy | Widget/golden/navigation/functional test gates |
| 81 | Rollout | Dependency graph | Tokens → components → screens → polish → freeze |
| 82 | Rollout | Parallel-agent ownership | Three-agent safe file/component/screen partition |
| 83 | Rollout | First 10 implementation waves | Ordered bounded future tasks |
| 84 | Rollout | Final polish plan | Cross-screen QA and residue removal |
| 85 | Rollout | Visual freeze contract | Exact artifact/screens/states/acceptance evidence |
| 86 | Review | Contrarian design review | Over-customization, over-systemization and delay risks |
| 87 | Review | Simplification pass | Minimum component/token/screen set |
| 88 | Decisions | Raw owner decision inventory | Only material visual/product choices |
| 89 | Decisions | Semantic decision dedup | Every raw decision retained exactly once |
| 90 | Decisions | Minimum root decision set | Options/recommendation/effects, none selected |
| 91 | Stress | Seven UI stress matrices | Exactly 2,000 synthetic/static scenarios |
| 92 | Closeout | Master blueprint/readiness | Complete rollout answer and safety self-review |

## Major checkpoints

1. Source reconciliation, work plan and exact inventory.
2. Design debt, tokens and K’pasa mapping.
3. Component/screen/file rollout and state/content/accessibility models.
4. Risk, acceptance, dependency graph, first waves and parallel plan.
5. Stress matrices.
6. Owner decisions, contrarian and simplification.
7. Final polish, visual freeze, master blueprint and readiness.
8. Final scope/count/security/Git validation.

`WORK_PACKAGE_COUNT: 92`

`OWNER_FINALIZATION_PERFORMED: NO`

`FINAL_UI_IMPLEMENTED: NO`

`RUNTIME_IMPLEMENTATION: NO`
