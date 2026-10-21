# Merchant QR, coupon and return session continuity

Base: `a886dfdd58e63f3ee83c27479b141ccc9db9f98c`.
Branch: `agent/merchant-transaction-session-recovery`.
Authority: Product Owner's next implementation request; canonical §5.4.
Local validation and task-branch delivery only. Main integration belongs to
Integration Agent.

## Corrected behavior

The previous transaction adapters sometimes compared only the live session after
an await. A queued same-account S1 → S2 → S1 transition could therefore accept an
old response, continue from installation/ownership/capability reads into another
RPC, or classify a stale return rejection as definitive. The existing return
controller could then clear its durable retry intent.

QR v1/v2, coupon and purchase adapters now use captured stable Auth keys and the
existing shared request fence. Inter-step checks precede further dispatch. A
request retired by an event, stream error or closed source never revives. Token
renewal retaining the session key remains valid. Already dispatched writes may
finish on the server; this client change cannot cancel them.

Merchant and Customer QR controllers discard old display state, stop polling and
block further actions in the retired view. Purchase list/detail and return screens
observe the same boundary. The sale-confirmation dialog checks its opener even
when the change occurs between tap and first build. Customer QR can recover by
opening a fresh view; the application-wide repository remains reusable.

An old return response cannot clear the original account/purchase retry record,
mark it confirmed or dispatch after a pending local save. The existing durable
store, exact-request retry, server rejection rules and cleanup-only retry remain
unchanged. This records return evidence; it does not execute a refund.

Coupon approval no longer uses the preview's 15-second read timeout for a write.
Concurrent identical approvals share one in-flight call. Different commands for
that session/cart are refused until it settles. Reopening preview waits before
reading the existing server QR. Session change prevents that queued read from
dispatching. Normal renewal preserves the user's chosen amount.

## Scope and compatibility

- Reuse `AuthenticatedRequestScope`, `AuthenticatedSessionEvents` and the common
  stable-key parser. `QrSessionGuard` is a local transaction/view lifetime fence.
- Shared files: QR repositories/cubits, coupon adapter/approval widget, Merchant
  QR wrapper/screens, purchase adapter and return scope/controller/form.
- Server endpoint names/arguments, legacy and v2 capability selection, ownership,
  purchase/return evidence, allocation, thresholds and deadlines are unchanged.
- No dependency, bootstrap/global routing/provider, flag or migration change.
  Customer V1 layouts are retained. No new Auth/QR/notification system.
- In-flight coupon serialization is repository-instance memory. It is not
  cross-process recovery or a new persistent queue. Server idempotency and the
  existing authoritative preview/recovery remain necessary after restart.

## Validation

Detailed counts, source fingerprint, APK identities/hashes and baseline skip
comparison are in
[`merchant_transaction_session_recovery_verification.json`](data/merchant_transaction_session_recovery_verification.json).
Paired compilation evidence is in
[`merchant_transaction_session_recovery_build_pair.json`](data/merchant_transaction_session_recovery_build_pair.json).

The baseline replay uses the first 82 new regression cases with original main
runtime sources: 65 failures and 17 passing controls. The final package contains
99 new tests, including later concurrency, source-loss and widget cases.
Earlier harness runs omitted the HTTP
response's request reference and three purchase fields; those runs are not used
as product-failure evidence. Two existing mocked-usecase suites now explicitly
provide their repository dependency; their assertions remain unchanged.

Coverage includes real SDK queued session events with intercepted HTTP, success
and error responses, all continuation steps, token renewal, stream loss, unchanged
idempotency payloads, durable return-save/result races, old and reopened controller
lifetimes, narrow-screen states and pre-mount/already-visible dialogs.
No real hosted or local database transaction is claimed by these transport tests;
SQL/server contracts are unchanged.

Integration should review the shared Customer QR and coupon paths alongside
Merchant, run independent regressions on current main, and preserve the six
existing conditional live-test skips. Do not replay a migration or distribute
the synthetic build artifacts during integration.

Final full Flutter result: **3,516 PASS, 0 FAIL, the same 6 conditional SKIP**.
Analyzer: **PASS**, zero issues. No existing assertion was weakened or test
skipped to obtain these results.

Targeted regressions: **269 PASS**. Paired-build compatibility: **135 PASS**.
Customer Development, Merchant Pilot and Merchant Development ARM64 debug builds:
**PASS**. Actual APK identities, callbacks and certificates were checked, and the
source fingerprint matches the compiled pair. Windows Kotlin incremental-cache
diagnostics occurred; all three builds completed successfully using the compiler
fallback. No dependency or Gradle changes were made.

Only this task's generated build cache was reclaimed after copied APK verification.
The two delivered Development APKs and the preceding promotion, reward, trust and
statement rehearsal artifacts retain their recorded hashes.

## Remaining gates

Production/hosted Development access and writes: NONE. Remote migrations and
provider sends: NONE. Existing delivered APKs are preserved; new synthetic debug
builds are compilation evidence, not phone-install candidates.

Physical two-device QR acceptance and actual pilot merchant/catalog onboarding
remain OPEN. This package does not make the full pilot or economic features live.
