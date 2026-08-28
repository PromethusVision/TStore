# QA Failure Registry

**State:** ANTICIPATED DESIGN FAILURES — NOT RUNTIME OBSERVATIONS

The 5,500 stress rows are unexecuted design scenarios. This registry deduplicates the unsafe outcomes those rows are intended to detect; it does not claim that any defect occurred.

| FAILURE_ID | ROOT_CAUSE | AFFECTED_SYSTEM | SEVERITY | TEST_IDS | AUTOMATABLE | PHYSICAL_REQUIRED | OWNER_DECISION | PRODUCTION_GATE | RECOMMENDED_FIX_CLASS |
|---|---|---|---|---|---|---|---|---|---|
| F001 | Wrong environment or unattended Production authority | CI, release, migration | P0 | CI-0451..0500; REL-0451..0500; MIX-0951..1000 | PARTIAL | NO | YES | BLOCK | Authority/identity fail-closed |
| F002 | Wrong signer, package or artifact promoted | Android/iOS release | P0 | REL-0251..0350; REL-0451..0500 | PARTIAL | YES | YES | BLOCK | Exact-artifact/signing control |
| F003 | Client or stale claim escalates role | Auth, merchant, ops | P0 | SEC-0051..0100; MER-0001..0400 | YES | NO | NO | BLOCK | Server authorization/RLS |
| F004 | QR consumed more than once under race/retry | QR, purchase, review | P0 | CUST-0651..0700; MER-0701..0750; MIX-0251..0300 | YES | YES | NO | BLOCK | Transaction/idempotency |
| F005 | Migration corrupts or loses durable data | DB, clients | P0 | MIG-0001..0500; REL-0351..0400 | YES | NO | YES | BLOCK | Precheck/recovery/invariant |
| F006 | Secret/signing material enters source/log/artifact | CI, release | P0 | CI-0301..0400; SEC-0401..0500 | YES | NO | NO | BLOCK | Secret isolation/rotation |
| F007 | Cross-account/shop PII or private state leaks | Customer, merchant, realtime | P0 | SEC-0101..0200; CUST-0051..0100; CUST-0901..0950 | YES | PARTIAL | NO | BLOCK | Subject-scoped cache/RLS |
| F008 | Catalog/taxonomy split arbitrarily rewrites history | Catalog, reviews, analytics | P0 | MIG-0301..0400; MER-0401..0500 | YES | NO | YES | BLOCK | Stable-ID/reclassification review |
| F009 | Signup/confirmation/recovery blocks legitimate user | Auth/email | P1 | CUST-0001..0050; REL-0201..0250 | PARTIAL | YES | YES | BLOCK | Auth contract/provider acceptance |
| F010 | Deep-link callback broken, reused or wrong environment | Auth/navigation | P1 | CUST-0851..0900; REL-0151..0200 | PARTIAL | YES | YES | BLOCK | Atomic callback/config |
| F011 | Startup crash loop or unusable shell | Customer app | P1 | CUST-0101..0200; DEV-0001..0500 | PARTIAL | YES | NO | BLOCK | Lifecycle/startup regression |
| F012 | Physical QR camera flow cannot complete | Customer/merchant | P1 | CUST-0651..0700; MER-0701..0750; DEV-0001..0500 | PARTIAL | YES | YES | BLOCK | Two-device acceptance |
| F013 | Wrong-shop confirmation accepted | QR, merchant authorization | P1 | MER-0701..0750; SEC-0201..0250 | YES | YES | NO | BLOCK | Shop binding/RPC |
| F014 | Review eligibility or one-active invariant breaks | Review/reputation | P1 | CUST-0601..0650; SEC-0251..0300 | YES | PARTIAL | NO | BLOCK | Evidence/uniqueness contract |
| F015 | Backend breaks supported client version | Backend/release | P1 | REL-0351..0400; MIG-0451..0500 | YES | NO | YES | BLOCK | Expand-migrate-contract |
| F016 | RLS/grant/RPC matrix allows or denies wrong actor | Backend | P1 | SEC-0001..0500; MIG-0051..0150 | YES | NO | NO | BLOCK | Role matrix contract |
| F017 | Migration checksum/order/environment drift ignored | Migration/CI | P1 | MIG-0001..0100; CI-0401..0450 | YES | NO | NO | BLOCK | Artifact manifest/precheck |
| F018 | Artifact hash/provenance mismatch ignored | Release/CI | P1 | CI-0351..0400; REL-0451..0500 | YES | NO | NO | BLOCK | Immutable identity |
| F019 | Upgrade loses session or customer state | Install/auth/cart | P1 | CUST-0951..1000; REL-0051..0100 | PARTIAL | YES | NO | BLOCK | Upgrade matrix/data continuity |
| F020 | Real GPS/permission behavior prevents discovery | Location | P1 | CUST-0251..0300; DEV-0001..0500 | PARTIAL | YES | YES | BLOCK | Physical location acceptance |
| F021 | Store promotes wrong build/track | Store/release | P1 | REL-0301..0350; CI-0451..0500 | PARTIAL | NO | YES | BLOCK | Protected promotion |
| F022 | Release is blind to crash/auth/RPC/QR failure | Observability | P1 | REL-0401..0450; MIX-0951..1000 | PARTIAL | NO | YES | BLOCK | Minimum health signals |
| F023 | Untrusted PR reaches secret or privileged job | CI/security | P1 | CI-0001..0500 | YES | NO | NO | BLOCK | Trigger/permission isolation |
| F024 | Exact artifact physical smoke omitted | Release/device | P1 | REL-0451..0500; DEV-0001..0500 | PARTIAL | YES | YES | BLOCK | Exact-artifact smoke |
| F025 | Search stale result or latency degrades discovery | Search | P2 | CUST-0201..0250; MIX-0101..0150 | YES | PARTIAL | NO | REVIEW | Cancel/version/performance |
| F026 | Offline retry duplicates customer mutation | Customer writes | P2 | CUST-0001..1000 | YES | PARTIAL | NO | REVIEW | Idempotent retry/state |
| F027 | Background/resume applies disposed or stale action | Flutter lifecycle | P2 | CUST-0901..0950; DEV-0001..0500 | YES | YES | NO | REVIEW | Lifecycle cancellation |
| F028 | Notification token/deep-link targets wrong account | Notification | P2 | CUST-0701..0750; SEC-0351..0400 | YES | YES | NO | REVIEW | Token/account isolation |
| F029 | Chat reconnect duplicates/leaks messages | Chat/realtime | P2 | CUST-0751..0800; SEC-0101..0200 | YES | PARTIAL | YES | REVIEW | Realtime/idempotency/privacy |
| F030 | Turkish copy/normalization causes wrong result | Localization/search | P2 | CUST-0201..0250; DEV-0001..0500 | YES | YES | YES | REVIEW | Locale corpus/manual review |
| F031 | Accessibility blocks critical interaction | Customer app | P2 | DEV-0001..0500; CUST-0001..1000 | PARTIAL | YES | YES | REVIEW | Semantics/layout/manual |
| F032 | Text scale/screen clipping hides action | UI/device | P2 | DEV-0001..0500 | PARTIAL | YES | NO | REVIEW | Responsive layout |
| F033 | Cache poisoning or stale dependency output | CI | P2 | CI-0251..0300 | YES | NO | NO | REVIEW | Trust-scoped cache |
| F034 | Flaky rerun hides first failure | CI/QA | P2 | CI-0101..0250 | YES | NO | NO | REVIEW | Preserve/quarantine/root fix |
| F035 | Fixture collision or cleanup leaves synthetic data | Test data | P2 | MIG-0001..0500; MIX-0551..0600 | YES | NO | NO | REVIEW | Namespaced cleanup ledger |
| F036 | Support/privacy/terms surface unavailable | Release/support | P2 | REL-0301..0350; MIX-0951..1000 | PARTIAL | YES | YES | REVIEW | Dependency preflight |
| F037 | Store metadata contradicts runtime behavior | Store | P2 | REL-0301..0350 | PARTIAL | YES | YES | REVIEW | Metadata/artifact reconciliation |
| F038 | Future Merchant App assumes nonexistent authority | Merchant/backend | P2 | MER-0001..1000 | YES | YES | YES | DEFER | Capability/RLS implementation |
| F039 | Backfill cannot resume or exceeds safe operation | Migration | P2 | MIG-0251..0350 | YES | NO | YES | REVIEW | Chunk/checkpoint/exception |
| F040 | Supported device-specific functional regression | Device | P2 | DEV-0001..0500 | PARTIAL | YES | YES | REVIEW | Focused matrix/root fix |
| F041 | Minor visual spacing differs from approved UI | UI | P3 | CUST-0101..0500; DEV-0001..0500 | PARTIAL | YES | YES | ACCEPT/PLAN | Visual regression |
| F042 | Noncritical diagnostic warning has owner | Build | P3 | CI-0101..0150 | YES | NO | NO | ACCEPT/PLAN | Warning governance |
| F043 | Low-value duplicate test increases runtime | QA | P3 | CI-0151..0250 | YES | NO | NO | ACCEPT/PLAN | Test minimization |
| F044 | Noncritical notification copy/presentation issue | Notification | P3 | CUST-0701..0750 | PARTIAL | YES | YES | ACCEPT/PLAN | Copy/visual fix |
| F045 | Optional chat feature cosmetic defect | Chat | P3 | CUST-0751..0800 | PARTIAL | YES | YES | DEFER | Scope-aware fix |
| F046 | CI report is noisy but gate remains correct | CI UX | P3 | CI-0001..0500 | YES | NO | NO | ACCEPT/PLAN | Failure reporting |
| F047 | Noncritical analytics/test metric presentation issue | Analytics | P3 | MER-0801..0900; MIX-0951..1000 | YES | NO | YES | DEFER | Metric definition |
| F048 | Deferred platform/device case lacks evidence | Release planning | P3 | DEV-0001..0500; REL-0001..0500 | NO | YES | YES | DEFER | Explicit scope record |

## Counts

P0: 8 · P1: 16 · P2: 16 · P3: 8 · Total: 48.

`FAILURES_OBSERVED_AT_RUNTIME: 0`
`ANTICIPATED_FAILURE_CLASSES: 48`
