# Merchant session and private navigation resilience

Status: **PASS — local client hardening delivered**.
Baseline: `origin/main@0c79dca1504443ca47ee827def8e54f65657e685` (integrated G preparation).
Task branch: `agent/merchant-session-resilience`.
Product authority: canonical §4.2; all existing FROZEN decisions are unchanged.

## Outcome and audit

The Merchant host now invalidates its entire private navigation scope when
account authority changes or validation fails. This includes the root navigator,
nested pages, confirmation dialogs, bottom sheets and transient messages.
Ordinary same-account, unchanged-shop refresh preserves an open form and its
unsaved input. Failed login preserves the user's typed fields for correction.

Five regression scenarios failed on the integrated baseline before the fix:

1. A token refresh during device revocation reopened the workspace before logout
   completed.
2. Logout started for one account was dispatched after another account arrived
   during revocation.
3. Permanent termination of session monitoring left private access available.
4. A root confirmation dialog remained visible after session expiry.
5. A private success message survived into the login screen.

The audit also covered same-account exit/re-entry between rendered frames,
delayed form results, missing account-change callbacks, role/shop changes,
read failure/timeout, login failure and interrupted auth. These cases need a host
boundary, not separate patches to every feature screen.

## Implementation and reuse

Only two runtime files change: `MerchantSessionCubit` and `MerchantApp`.
Existing repositories, shared Auth credentials, push revocation, owner checks,
Merchant tabs, QR state machine and feature-specific pending-request guards
remain the contracts. No new dependency, server endpoint, migration, capability
flag or notification store is introduced. Customer runtime is unchanged.

- A monotonic scope revision keys the complete MaterialApp navigation subtree.
  User ID alone cannot distinguish A → signed-out → A between frames. Shop
  identity/revision changes retain the existing workspace-reset behavior and
  also clear root overlays.
- Auth work is serialized. Session callbacks and resume do not re-enter private
  navigation during login/logout. Revocation still precedes the credential logout
  call; identity drift, interruption or disposal prevents that continuation.
  Already dispatched requests are not claimed to be cancelled.
- Completion uses the live account. An old failed response cannot replace a
  newly authenticated owner. Session-stream errors invalidate pending reads;
  a late success cannot reopen them. A closed stream requires app restart.
- Access reads time out after 15 seconds, fail closed and offer explicit retry.
  Request generation and current account are checked on both success and error.
  Auth and economic writes are not retried or timed out as though cancelled.
- Failure controls are disabled while auth is unresolved. Checking and safe-exit
  states have visible explanatory text. Root dialogs and queued messages cannot
  be recovered by pressing Back after the scope is invalidated.

The current Merchant development bootstrap remains loopback-only. These UI guards
do not replace server live-session/role/exact-owner authorization, revoke a token
themselves, or promise instantaneous remote invalidation without an event/read.
No server purchase, return, draft or accounting evidence is removed by clearing
navigation. Existing server reconciliation remains authoritative after re-entry.

## Screen and validation inventory

Affected surfaces: access checking, login, access failure/retry, denied access,
onboarding and the complete Merchant workspace's navigation/overlay lifecycle.
Accepted Merchant layouts and five tabs are preserved.

New automated scenarios exercise the real MerchantApp, product editor and QR sale
confirmation, plus representative root dialogs/sheets and transient messages.
They verify no purchase confirmation after logout, no late save navigation/toast,
no stale editor after rapid same-account return, preserved input on safe refresh,
closed-monitor behavior, authority failures, revocation ordering and duplicate
auth suppression. The callback-absent cases test both successful and throwing
old access reads. Read timeout tests use a short injected duration.

Final Flutter verification: **2572 PASS / 0 FAIL / 6 existing SKIP**,
including **33 new focused tests PASS**. Static analysis: **PASS**.
Both Android development debug APKs compiled successfully: Merchant with the
existing QR/review/trust/reward/checkout/statement/promotion flags, Customer with
its existing QR/review/trust/reward/checkout flags. Builds ran sequentially with
task-local Gradle memory/worker limits; repository build settings are unchanged.
Existing Java source/target-8 deprecation warnings were nonfatal.
Build results, source fingerprints and evidence hashes:
[validation record](data/merchant_session_resilience_validation.json).
Rendered failure/restart states: [evidence](evidence/merchant_session/) at
320/390/430 pixels and 130% text. This is widget/render evidence, not physical
device or two-device QR acceptance.

Reproduce from this task branch:

```powershell
flutter pub get --offline
flutter analyze --no-pub
flutter test --no-pub --concurrency=2 --reporter expanded
flutter test --no-pub --concurrency=2 --dart-define=MERCHANT_SESSION_CAPTURE=true test/unit/merchant/merchant_session_resilience_test.dart test/widget/merchant/merchant_session_boundary_test.dart
```

No database rehearsal is required for this client-only change. The migration
chain and all server/service sources are unchanged; historical database PASS
evidence is not represented as a new run. No local or remote database was changed.

An initial capture run was interrupted at test teardown because a previously
closed stream's completion was awaited again under the widget fake clock. Only
test cleanup changed: close live controllers outside that clock. The final
focused and full runs independently passed. All six captured screens were
visually inspected; existing Merchant golden comparisons also passed in the suite.

## Integration and remaining gates

Shared review areas: Merchant host/navigation and session controller, canonical
§4.2 and a bounded slice-status addition. No global Customer routing, theme,
dependencies, bootstrap, shared notification code or central project-state files
are modified. Integration Agent alone reviews and merges main.

Rollback is a normal reviewed client revert/build; there is no data migration or
server cleanup. This package does not authorize remote rollout or release.

Full G still requires commercial price/purchase policy, fairness/measurement,
audience and retention decisions before paid promises are activated. O8/O9/O10,
H1 settlement, Firebase/APNs setup and physical two-device J remain open. Further
feature work must resolve the relevant real policy inputs instead of fabricating
billing, advertising metrics or provider success. No new manual acceptance step
is needed specifically for this bounded host correction.

Production access/writes/migration application: **NONE**.
Main merge/push by this Merchant agent: **NONE**.
