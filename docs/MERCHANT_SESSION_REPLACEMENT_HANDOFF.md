# Merchant same-account session replacement — 2026-10-20

Status: **PASS — scoped local checks and Integration source review; main validation pending**.
Branch: `agent/merchant-development-mail-acceptance`.
Implementation baseline: `cc0872ff5d55a435a16804ef2402dbb0d2e56f5d`.
Worktree: `.buildlog/merchant-pilot-server-audit` beneath `TStore_CLEAN`.
Authority: canonical §§4.2–4.3. No new product decision or FROZEN exception.

## Baseline and outcome

At implementation start, the Integration record was PASS_WITH_NOTES for the preceding T1 logout
correction, with no merge, commit or push. Its four runtime changes and two-test
T1 fixture were still local at task start and are preserved in this delivery.
Do not interpret that review or this report as a main integration.

The follow-through fixes same-user replacement across the private workspace:

- S1 → S2 clears the existing route tree, dialogs and drafts before the new
  access read completes. Stable token refresh within S1 preserves the draft.
- Queued S1 → S2 → S1 events cannot revive the original editor or dispatch an
  old logout after device revocation finishes.
- Access reads check the live user, stable session key and identity revision on
  success and error. An old read cannot replace a newer result. A replacement
  without a callback is detected when the pending read completes; this does not
  promise instantaneous revocation in the absence of an event/read.
- A runtime session without a usable stable key cannot read private access.
  The existing explicit retry can validate a subsequent valid session.
- A delayed product-save completion cannot navigate or display a success message
  in the replacement workspace. Already dispatched writes are not cancelled.

## Implementation and review areas

`MerchantSessionIdentity` carries only the event user ID and stable session key.
The production Merchant service composition derives it from `event.session`,
not the later live session. The host subscribes to this stream once. The legacy
user-ID stream remains available for existing consumers and local previews;
previews that omit stable identity do not claim replacement-session protection.

The shared `authenticatedSessionKey` parser delegates to a session-snapshot
overload, keeping the original parsing and live-client contract. Notification
and transport callers retain their existing behavior. There is no second Auth
or notification system and no dependency change.

Shared review areas: the session-key helper, Merchant service composition,
Merchant host/navigation boundary, session controller and the two canonical
planning documents. Customer screens/routing, provider configuration, server
authorization, schema and migrations are unchanged. Server role, live-session
and exact-shop authorization remain mandatory.

## Validation actually run

Before implementation, five new targeted regressions failed for the intended
behavior: replacement kept old access visible, callback-absent success/error
used the old identity, an old root dialog survived, and an old product editor
remained active. After correction all five pass within the following run.

| Local test file | PASS |
| --- | ---: |
| `merchant_session_logout_replacement_test.dart` | 2 |
| `merchant_session_resilience_test.dart` | 28 |
| `merchant_session_boundary_test.dart` | 17 |
| `merchant_pilot_auth_test.dart` | 9 |
| `push_backend_session_test.dart` | 19 |
| `merchant_transport_recovery_test.dart` | 50 |
| `merchant_push_client_test.dart` | 3 |
| **Total** | **128** |

Result: **128 PASS / 0 FAIL / 0 SKIP** in this scoped run, including 13 new
regressions in this follow-through. Original T1 assertions are unchanged. Its
Supabase SDK session and real token-refresh tests use MockClient and synthetic
credentials; they do not contact hosted services. Widget tests exercise actual
Merchant navigation and editor lifecycles, including Back after invalidation.

Reproduce from this worktree using the existing Flutter SDK:

```powershell
flutter test --no-pub --concurrency=1 --reporter expanded test/unit/merchant/merchant_session_logout_replacement_test.dart test/unit/merchant/merchant_session_resilience_test.dart test/widget/merchant/merchant_session_boundary_test.dart test/widget/merchant/merchant_pilot_auth_test.dart test/unit/notifications/push_backend_session_test.dart test/unit/merchant/merchant_transport_recovery_test.dart test/widget/merchant/merchant_push_client_test.dart
flutter analyze --no-pub lib/core/supabase/authenticated_session_key.dart lib/features/merchant/domain/merchant_session_identity.dart lib/features/merchant/merchant_app.dart lib/features/merchant/merchant_services.dart lib/features/merchant/presentation/merchant_session_cubit.dart lib/features/merchant/runtime/merchant_runtime.dart test/unit/merchant/merchant_session_logout_replacement_test.dart test/unit/merchant/merchant_session_resilience_test.dart test/unit/notifications/push_backend_session_test.dart test/widget/merchant/merchant_session_boundary_test.dart
```

Scoped analyzer: **PASS, 10 items, no issues**. Full-suite analysis/tests, APK
builds, hosted acceptance and physical-device acceptance were not rerun. Earlier
full-suite/build results are historical evidence, not results of this package.

## Delivery boundary and remaining work

Integration Agent reviewed the 13-file local package and reported PASS with no
blocking code finding or canonical conflict. That review did not rerun tests,
analyzer or builds and did not merge main. The Product Owner then explicitly
requested source commit/push and completion of integration. This source commit
contains those 13 files, including the preserved T1 fix; only this handoff's
delivery status changed after that review. The exact source SHA and verified
remote branch are supplied with the integration request.

Integration Agent must validate the committed source against current main,
independently run the full regression suite, analyzer and Customer/Merchant
development builds, then merge and normally push main only if those gates pass.
Only Integration Agent may merge main. No server configuration, account
provisioning or migration application is part of this delivery. Production
access/writes: **NONE**. Development hosted changes: **NONE**. No real credential
or recovery link is included in this package.

This local result does not establish that the pilot is ready for real merchants.
Merchant role/shop provisioning, dashboard use on a device, physical QR
acceptance and other existing release gates remain open. No phone action is
required to review this client correction.
