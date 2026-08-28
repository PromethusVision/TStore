# UI Functional Regression Risks

## Non-negotiable principle

Visual components render authoritative state and emit callbacks. They do not move,
recreate or reinterpret Auth, Cart V2, reviews, QR, search, location, wishlist,
shop/product, chat or notification business logic.

## Risk registry

| Risk ID | Surface | Regression | Prevention/evidence | Severity |
|---|---|---|---|---|
| UFR-001 | Navigation | Bottom destination changes or wrong index | Existing navigation tests + five-destination semantics | P0 |
| UFR-002 | AuthGuard | Cancel selects protected tab or login does not resume | Guest cancel/success widget tests | P0 |
| UFR-003 | Home/location | Guest discovery becomes login-only | Guest Home + location-action tests | P0 |
| UFR-004 | Search | Query debounce/pagination/reset changes during layout extraction | Search Cubit/widget tests and request-count assertions | P0 |
| UFR-005 | Taxonomy | Proposed nodes or fixed depth become hardcoded | Fixture with varying depth/name/count | P0 |
| UFR-006 | Product identity | Card/details/seller navigate with wrong product/listing ID | Navigation argument tests | P0 |
| UFR-007 | Wishlist | Optimistic state or auth gate breaks | Double-tap/error/guest tests | P0 |
| UFR-008 | Cart V2 | Different-store decision becomes implicit | Conflict cancel/replace tests | P0 |
| UFR-009 | Cart totals | Displayed arithmetic diverges from Cubit/domain total | Deterministic total fixtures | P0 |
| UFR-010 | Quantity/remove | Double-tap duplicates mutation or disabled limit works incorrectly | Busy/duplicate-submit tests | P0 |
| UFR-011 | QR | Visual success shown before server verification | State-authority assertion + failure/expiry tests | P0 |
| UFR-012 | Verified purchase | Badge inferred from client/navigation | Authoritative entity-only widget input | P0 |
| UFR-013 | Reviews | Ineligible customer sees editor/action | Eligibility matrix tests | P0 |
| UFR-014 | Shop | Directions/chat callbacks receive wrong shop or bypass auth | Callback/route tests | P0 |
| UFR-015 | Location | Permission denial loops or precise data leaks into copy/logs | Permission-state tests and PII scan | P0 |
| UFR-016 | Chat | Rebuild duplicates subscription/message or loses draft | Reconnect/dedup/widget tests | P0 |
| UFR-017 | Notifications | Read state/recipient navigation changes | State transition and navigation tests | P0 |
| UFR-018 | Account deletion | Destructive confirm hierarchy/result changes | Confirm/cancel/busy/error tests | P0 |
| UFR-019 | Media | New frame bypasses safe media resolver | Resolver regression tests + fallback widget tests | P1 |
| UFR-020 | Dark mode | Direct light colors make content unreadable under system mode | Both-mode golden/contrast tests or approved light-only policy | P0 |
| UFR-021 | State restoration | Extracted widgets reset scroll/query/form state | Stateful navigation/restoration tests | P1 |
| UFR-022 | Accessibility | Gesture-only/tooltip-only action loses semantics | Semantics and keyboard tests | P0 |

## High-risk code seams

- Large private widget extractions from `all_products_view.dart`,
  `cart_v2_view.dart`, `purchases_view.dart`, `nearby_view.dart`,
  `product_reviews_view.dart`, `shop_profile_view.dart` and `chat_view.dart`.
- Global theme and widget-theme edits that can change every route at once.
- Replacing custom navigation with a standard component without badge/auth parity.
- Introducing fixed-height Figma dimensions into scroll/keyboard/text-scale paths.
- Renaming “brand” widgets while accidentally changing data/API semantics.

## Required per-wave proof

1. Baseline tests run before code changes.
2. Component behavior tests added before call-site replacement.
3. Old and new fixture outputs compared for state/callback parity.
4. Targeted feature tests, analyzer and `git diff --check` pass.
5. Screenshot set covers loading/empty/error/long-text/large-text.
6. Diff contains only declared matrix rows and test/evidence files.

## Rollback

Each wave is independently revertible. Compatibility adapters keep old public
callbacks/keys until all call sites pass. If P0 behavior fails, revert that visual
wave rather than patching domain logic to match the new component.
