# Customer App Test Coverage Map

Status: **AUDITED**  
Wave: **16 — Customer App Commercialization Closeout**

This map is evidence-based and does not claim line or branch percentages. The
repository contained 130 tracked Dart test files at this checkpoint. Ratings
describe commercialization-relevant behavior, not raw test volume.

## Active customer scope

| Area | Rating | Existing evidence | Critical gap / action |
|---|---|---|---|
| Bootstrap and environment contract | STRONG | Development/Production entrypoint, missing-config, client-safe key, startup and release-build contract tests | Real store-distributed binary remains a manual release gate |
| Authentication | STRONG | Sign-in/up/out, confirmation, recovery/PKCE, account deletion, role and callback widget/unit tests | Add Cubit-level duplicate-signup defense test |
| Profile and legal consent | STRONG | Repository, Cubit, widget, canonical migration and live-controlled contract tests | Remote behavior is outside Wave 16 |
| Session expiry and account switch | STRONG | Root session listener, stale-result generations, cart/wishlist reset tests | Add explicit guest-to-customer load regression |
| Home and discovery | STRONG | Layout, categories, products, featured, nearby, saved-location and demo-read tests | Final UI-kit visual acceptance deferred |
| Category and product listing | STRONG | Filters, pagination/loading/error/empty, category localization and navigation tests | No commercialization-critical local gap found |
| Product details and seller comparison | STRONG | Product state/layout, seller mapping, pricing, favorite and navigation tests | Physical rendering remains covered by release acceptance plan |
| Shop details | STRONG | Profile, product list, contact/action guards, loading/error/navigation tests | No critical gap found |
| Search | STRONG | Aggregation, category expansion, deduplication, partial/full error, no-result and result navigation tests | Add explicit stale-query and whitespace-query Cubit regressions |
| Nearby/location | STRONG | Permission denied/forever, service disabled, timeout, lifecycle return, sorting, fallback and widget tests | GPS accuracy is physical-only |
| Wishlist | STRONG | Repository/Cubit/widget, auth guard, account-switch and stale-result tests | No critical gap found |
| Cart V2 | STRONG | Single-store rule, quantities, removal, local clearing, QR handoff, stale result and duplicate mutation tests | Add missing replace-cart double-action guard test |
| Saved locations | STRONG | CRUD, ownership/auth guard, validation and widget states | Postal address feature is not an active shipped route |
| Reviews | STRONG | Frozen RPC contract, eligibility/evidence, submit/update/delete, duplicate submit, pagination and widget tests | Add duplicate-delete lock regression |
| QR customer client | STRONG (LOCAL) | Token opacity, expiry, status refresh, confirmation/replay/concurrency backend contracts and widgets | Physical two-device acceptance remains open |
| In-app notifications | ADEQUATE | Repository, auth guard, read state, Cubit and widget tests | Push delivery is a future feature, not current scope |
| Product chat | STRONG | Repository/Cubit/view, product context, pending draft and session behavior tests | Device-local draft retention needs owner policy decision |
| Navigation | STRONG | Bottom navigation, badges, deep links, auth callbacks and legacy-order isolation | iOS physical deep-link acceptance remains open |
| Error mapping/resilience | ADEQUATE | Network/permission/session/duplicate/not-found sanitization plus feature retry states | Add explicit 503/404 data-leak regressions |
| Android release contract | STRONG (STATIC) | Manifest, application id, deep-link, permissions and signing contract tests | Play Console and final signed-device install are manual gates |
| iOS release contract | ADEQUATE (STATIC) | Bundle id, URL scheme and permission-string contract tests | Signing/archive/TestFlight/physical callback are blocked externally |
| Legacy orders | STRONG (ISOLATION) | Architecture tests prove no active import, route or Cart V2 dependency | Retain isolated until separately removed |

## File-level concentration

The largest relevant test directories at this checkpoint were: shop 40 files,
auth 21, personalization 10, chat 9, cart 8, notifications 4, purchases 4 and
reviews 4. File count is not used as the rating by itself; the rating also
requires negative states, lifecycle behavior and boundary contracts.

## Commercialization-critical additions

Work Packages 61–68 are limited to meaningful gaps found by this audit:

1. Ignore a repeated signup while the first request is unresolved.
2. Serialize replace-cart against all Cart V2 mutations.
3. Prove a repeated review delete cannot produce a second RPC.
4. Prove stale/blank search requests cannot publish incorrect results.
5. Prove a guest-to-customer session transition clears and loads scoped data.
6. Prove common 404/503 backend details remain sanitized.

Existing comprehensive location/auth-guard and navigation suites are retained
as the regression gates for Work Packages 65 and 68; duplicating those tests
without a behavioral gap would not improve confidence.
