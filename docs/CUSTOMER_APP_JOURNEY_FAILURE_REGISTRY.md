# Customer App Journey Failure Registry

Status: **DEDUPLICATED**  
Wave: **16 — Customer App Commercialization Closeout**

| FAILURE_ID | FEATURE | SEVERITY | ROOT_CAUSE | AUTO_FIXABLE | DEPENDENCY | TEST | STATUS |
|---|---|---|---|---|---|---|---|
| CUST-REL-001 | Release/security | P1 | Shared diagnostics could serialize URLs, bodies, exact location or raw Auth errors; logger remained enabled in release | YES | None | `release_logging_contract_test.dart` | FIXED |
| CUST-AUTH-001 | Signup | P1 | `AuthCubit.signUp` lacked the in-flight guard used by other Auth writes | YES | None | `auth_cubit_test.dart` duplicate-signup test | FIXED |
| CUST-CART-001 | Cart V2 | P1 | Replace-cart mutation bypassed the shared exclusive mutation guard | YES | None | `cart_v2_cubit_test.dart` replace double-action test | FIXED |
| CUST-QR-001 | QR | P1 | Physical two-device/camera acceptance has not been completed | NO | Two devices, merchant/verifier principal, physical camera | QR contract tests plus manual plan | PHYSICAL_TEST_REQUIRED |
| CUST-IOS-001 | iOS release | P1 | No proven archive/signing/TestFlight/physical callback lifecycle; tracked Podfile is absent | NO | Apple signing, macOS/Xcode and iOS device | Static iOS contract only | PHYSICAL_TEST_REQUIRED |
| CUST-STORE-001 | Release distribution | P1 | Current release candidate has not passed Play Console/internal-track review and reinstall | NO | Product owner/store accounts | Android static/signing contracts | PRODUCTION_CONFIG_REQUIRED |
| CUST-CONFIG-001 | Production operations | P1 | Final pre-release Auth/RLS/Realtime/Storage/backup evidence is human-controlled and time-sensitive | NO | Production dashboard/operator | Manual checklist | PRODUCTION_CONFIG_REQUIRED |
| CUST-PRIV-001 | Search privacy | P2 | Five recent searches are device-wide rather than user-scoped | NO | Owner retention/logout policy | Recent-search tests | OWNER_DECISION_REQUIRED |
| CUST-PRIV-002 | Chat privacy | P2 | Pre-login product-chat draft is device-wide for up to 24 hours | NO | Owner retention/logout policy | Pending-chat tests | OWNER_DECISION_REQUIRED |
| CUST-NAV-001 | Nearby | P2 | Brief wording conflicts with current public Nearby discovery contract | NO | Product owner decision | Nearby guest tests | OWNER_DECISION_REQUIRED |
| CUST-ADDR-001 | Address | P2 | Legacy postal-address prototype is hardcoded and unwired | NO | Future commerce/service scope | Architecture reachability audit | FUTURE_FEATURE |
| CUST-AVATAR-001 | Profile media | P2 | Dormant avatar repository assumes deferred `avatars` bucket | NO | Storage/backend contract if feature is revived | Static repository audit | BACKEND_SCHEMA_REQUIRED |
| CUST-SCALE-001 | Performance | P2 | Several lists are eager/unbounded at growth scale | YES, later | Traffic/data scale and pagination contract | Current demo-scale tests | ACCEPTED_RISK |
| CUST-MON-001 | Operations | P2 | No crash reporting/analytics/feature-flag service is active | NO | Privacy/telemetry owner decision and provider | Static inventory | FUTURE_FEATURE |
| CUST-DEPS-001 | Dependencies | P2 | 68 locked packages are upgradable; some direct packages have major-version paths | YES, separately | Dedicated upgrade/compatibility wave | Analyzer/full suite baseline | ACCEPTED_RISK |
| CUST-ASSET-001 | Build size | P2 | One review image is 12.8 MB and several visual assets are multi-megabyte | YES, separately | Visual-quality/UI-kit approval | Build output audit | ACCEPTED_RISK |
| CUST-PUSH-001 | Notifications | P2 | Push delivery is not implemented; only in-app notifications are active | NO | Future push product/backend decision | In-app notification tests | FUTURE_FEATURE |
| CUST-TAX-001 | Taxonomy | P2 | Canonical taxonomy research is not yet a runtime data model/query/navigation contract | NO | Owner-final taxonomy and DB migration plan | Dependency maps only | TAXONOMY_DEFER |
| CUST-UI-001 | UI | P3 | Final UI kit has not been rolled out across active screens | NO | Figma/product-owner decisions | Functional widget tests | UI_KIT_DEFER |

## Reconciliation

- Unique failures/risks: **19**.
- Fixed in Wave 16: **3** (`CUST-REL-001`, `CUST-AUTH-001`,
  `CUST-CART-001`).
- Open P0: **0**.
- Open P1: **4**, all external/manual/physical rather than automatically
  remediable code defects.
- Open P2: **11**; three owner-sensitive, the rest deferred/accepted/future.
- Open P3: **1**, final UI-kit rollout.
