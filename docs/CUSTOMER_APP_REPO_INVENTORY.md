# Customer App Repository Inventory

Status: AUDITED — Wave 16 Work Package 1  
Baseline: `origin/main@f092cf8fe7431f812a017d4cbc9b538775bb41e6`  
Audit date: 2026-08-28

## Scope and method

This inventory was derived from the tracked repository, runtime wiring, dependency injection, platform configuration, tests, scripts, migrations, and release documentation. It does not assume that a file is active merely because it exists. No file, remote backend, build configuration, or dataset was changed while producing it.

## Repository snapshot

| Area | Observed size | Classification | Notes |
| --- | ---: | --- | --- |
| Tracked files | 948 | ACTIVE / SUPPORTING | Git baseline at the commit above. |
| `lib/**/*.dart` | 425 | ACTIVE + LEGACY | Flutter customer client and retained legacy code. |
| `test/**/*.dart` | 129 | ACTIVE | 5 architecture, 3 integration, 3 live, 58 unit, 59 widget, plus root smoke test. |
| `docs/**/*.md` | 35 before Wave 16 | SUPPORTING | Product decisions, live evidence, release gates, and audits. |
| `supabase/migrations/*.sql` | 9 | CANONICAL / READ-ONLY IN THIS WAVE | Canonical `0001`–`0009`; no migration work is authorized here. |

## Runtime entry and application shell

| Path/area | Classification | Evidence |
| --- | --- | --- |
| `lib/main_development.dart` | ACTIVE | Selects only the namespaced Development configuration contract. |
| `lib/main_production.dart` | ACTIVE | Selects only the namespaced Production configuration contract. |
| `lib/t_store.dart` | ACTIVE / SHARED HOTSPOT | Creates global providers and composes recovery, confirmation, session, and pending-chat listeners around `MaterialApp`. |
| `lib/core/common/widgets/navigation_menu.dart` | ACTIVE / SHARED HOTSPOT | Five-tab customer shell; Home and Nearby are guest-accessible, Cart/Wishlist/Settings are guarded. |
| `lib/features/auth/.../customer_launch_gate.dart` | ACTIVE | Routes first launch to onboarding and returning/authenticated launch to the customer shell; local preference failure fails open to Home. |

There is no centralized named-route/router table. Most secondary journeys use typed `MaterialPageRoute` calls. The two global Auth callback listeners use the root navigator key.

## Feature modules

| Module | Dart files | Layers observed | Classification | Runtime responsibility |
| --- | ---: | --- | --- | --- |
| `auth` | 58 | data/domain/presentation | ACTIVE | Signup, login, logout, email confirmation, password recovery, account deletion, legal consent metadata, onboarding. |
| `cart` | 32 | data/domain/presentation | ACTIVE | Cart V2 single-store intent, QR session, verifier client components. |
| `chat` | 19 | data/domain/presentation | ACTIVE | Customer conversations, product context, unread state, realtime updates. |
| `notifications` | 7 | data/domain/presentation | ACTIVE | In-app notification list, pagination, realtime updates, read/delete actions. |
| `orders` | 10 | data/domain/presentation | LEGACY / ISOLATED | Old online-commerce order skeleton; excluded from active DI and customer navigation. |
| `personalization` | 48 | data/domain/presentation | ACTIVE + DORMANT PATH | Profile, settings, address, saved locations, privacy/support; avatar repository methods are not exposed by current profile UI. |
| `purchases` | 9 | data/domain/presentation | ACTIVE | Verified purchase history and customer ratings. |
| `reviews` | 18 | data/domain/presentation | ACTIVE | Verified-review RPC contract and aggregate/rating state. |
| `shop` | 103 | data/domain/presentation | ACTIVE + MERCHANT-LIMITED | Home, categories, product/search/seller/shop discovery, Nearby and retained shop-management views. |
| `wishlist` | 10 | data/domain/presentation | ACTIVE | Authenticated customer favorites. |

## Layer and dependency shape

The active modules generally follow `data → domain → presentation`:

- Data contains Supabase-backed repository implementations, models, and local `SharedPreferences` adapters.
- Domain contains entities, repository interfaces, use cases, and small services.
- Presentation contains Cubits/states, views, widgets, and navigation interactions.
- `lib/core/dependency_injection/service_locator.dart` is the composition root for feature dependencies.
- Global shared Cubits are created in `lib/t_store.dart`; route-local Cubits are typically obtained from the service locator in their view.

The layering is pragmatic rather than absolute: Supabase queries are intentionally concentrated in data repositories, while view files perform local orchestration and navigation. Several large view files are maintainability risks but are not evidence of a functional defect by themselves.

## Core services and adapters

| Area | Classification | Notes |
| --- | --- | --- |
| `core/supabase/supabase_config.dart` | ACTIVE / SECURITY CRITICAL | Fail-closed environment validation; rejects placeholders, Development-as-Production, and server-only keys. |
| `core/supabase/supabase_service.dart` | ACTIVE / SHARED HOTSPOT | Client initialization, Auth/deep-link signals, generic database/storage helpers. |
| `core/supabase/supabase_tables.dart` | ACTIVE | Canonical client table constants. |
| Public media source resolver | ACTIVE | Maps client-safe bucket/object sources and fallbacks. |
| Customer error-message helper | ACTIVE | Converts backend/client exceptions to Turkish customer-facing text. |
| Geolocator customer location service | ACTIVE | Runtime permission/service/acquisition boundary. |
| SharedPreferences adapters | ACTIVE | Onboarding, recent searches, recent products, and pending product-chat handoff. |

## Platform and release configuration

| Area | Classification | Evidence |
| --- | --- | --- |
| Android Gradle/flavors | ACTIVE / RELEASE CRITICAL | Production application ID `com.esnaftavar.app`; Development suffix; release signing fails closed. |
| Android manifest | ACTIVE | Internet, coarse/fine location, and camera permissions declared. |
| iOS Info.plist/project | ACTIVE / MANUAL RELEASE GATE | Auth callback and camera/location usage descriptions exist; signing/archive remains an external gate. |
| `.env.example` and Dart defines | ACTIVE / CLIENT SAFE | Namespaced public client configuration only; `.env` files are ignored and not bundled. |
| `tool/production_compile_contract.json` | ACTIVE / SYNTHETIC | Client-safe compilation contract; not proof of a real Production connection or smoke test. |
| Keystore/signing files outside Git | ACTIVE EXTERNAL INPUT | Canonical signing contract is documented and tested; secrets and private keys are not repository artifacts. |
| `build/` outputs | GENERATED / UNTRACKED | Disposable build output; not source of truth and not committed. |

## Tests

| Directory | Files | Main coverage |
| --- | ---: | --- |
| `test/architecture` | 5 | Auth redirect, legacy-order isolation, review security, production platform, release signing. |
| `test/integration` | 3 | Controlled Auth flow and opt-in Development live contracts. |
| `test/live` | 3 | Explicit opt-in remote Development/Production read-only harnesses. |
| `test/unit` | 58 | Cubits, repositories, contracts, models, location/search/cart/review behavior. |
| `test/widget` | 59 | Customer screens, listener/navigation behavior, state surfaces, and interactions. |
| `test/widget_test.dart` | 1 | Root application/widget smoke. |

Live tests are environment-gated and must not be interpreted as remote execution unless their explicit opt-in variables are supplied. Wave 16 does not supply them.

## Scripts, SQL, and documentation

- `tool/` contains deterministic demo dataset generation/validation and safe build-contract support.
- `supabase/migrations/0001`–`0009` are the canonical database history. They are reference-only in this wave.
- Root demo seed and cleanup SQL are operational artifacts with separate owner authorization requirements; neither is run here.
- Product, release, Auth, QR, storage, review, and taxonomy documents are decision evidence. Historical statements are subordinate to later owner-final/live evidence.

## Classification register

### ACTIVE

- Customer startup, Auth, Home/discovery, categories, product/shop/seller views, search, Nearby/location, Wishlist, Cart V2, address/saved location, verified purchases/reviews/ratings, chat, notifications, profile/settings/support.
- Development/Production entrypoints and fail-closed client configuration.
- Android release/signing and canonical Auth deep-link contracts.

### LEGACY

- `lib/features/orders`: retained online-order skeleton, deliberately disconnected from active DI/navigation by an architecture contract.
- Historical SQL and superseded documentation: evidence only, not current runtime authority.

### UNCLEAR

- Guest access to Nearby is implemented and exercised by existing smoke evidence, while the Wave 16 brief describes personalized location as intended to be login-gated if canonical documentation confirms it. The documentation does not establish a single owner-final rule. This is `OWNER_DECISION_REQUIRED`; runtime is unchanged.
- iOS archive/signing and store submission readiness depend on external Apple/console state that the repository cannot prove.

### DEAD_CANDIDATE

- Profile avatar upload/delete repository methods target the deferred `avatars` bucket, but no current profile presentation/Cubit call site was found. Keep isolated; do not expose or delete without a separate reachability/product decision.
- Generic mutating helpers in `SupabaseService` are capability code; each call site must be judged individually. Their existence alone is not an active feature.
- Retained shop-management screens are outside Customer V1 and must not be mistaken for a finished Merchant App.

## Hotspots and cautions

- Shared hotspots: `t_store.dart`, navigation shell, service locator, Supabase bootstrap, theme, `pubspec.yaml`, and canonical migration chain.
- Large presentation units (notably all-products, purchase history, Cart V2, sellers, Nearby, saved locations, reviews, shop profile, chat) raise testability and review cost. Splitting them is a future maintainability task, not a closeout prerequisite absent a functional defect.
- No deletion is justified from inventory evidence alone.
- Taxonomy proposals are documentation only; runtime taxonomy implementation has not started and was not changed.
- Final UI-kit rollout, Merchant App, payment/checkout/shipping, advertising, and rewards are outside this wave.

## Work Package 1 result

`REPO_INVENTORY: PASS`  
`ACTIVE_MODULES_MAPPED: YES`  
`LEGACY_ISOLATION_RETAINED: YES`  
`DELETION_PERFORMED: NO`  
`PRODUCTION_TOUCHED: NO`  
`DEVELOPMENT_TOUCHED: NO`
