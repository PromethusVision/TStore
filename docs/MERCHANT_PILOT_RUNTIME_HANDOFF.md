# Merchant Android pilot runtime preparation

Baseline: `6b79a4e919b1993528d71bac7c654592109956ad`.
Branch: `agent/merchant-pilot-runtime`.
Scope: canonical §4.4 / implementation slice J0. Product Owner authorized the next
pilot-readiness implementation after management recovery integration PASS.

## Result and boundaries

This delivery prepares a separate Android nonproduction runtime and Merchant
password recovery. It is not a live pilot, signed distribution, physical QR or
provider acceptance. No backend connection, real email, remote migration, account
provision or Production operation is performed by this task. No main merge/push.

- `merchantPilot` / `lib/main_merchant_pilot.dart` / temporary technical ID
  `com.esnaftavar.app.merchant.pilot`; app label `EsnaftaVar Esnaf Pilot`.
- Callback: `com.esnaftavar.app.merchant.pilot://login-callback/`; recovery adds
  `auth_action=password_recovery`. Customer and local Merchant IDs stay separate.
- Dedicated config names, pinned existing nonproduction project, HTTPS, safe
  client key and legacy JWT project-ref checks. No URL/environment fallback.
- One shared Merchant composition; existing local flags preserved. Pilot base
  composition leaves later business/provider capabilities OFF. This is a release
  preparation fixture, not a final business-scope or economic activation decision.
- Existing shared Supabase provider remains authoritative. An optional callback
  contract/observer selection is additive; Customer defaults remain unchanged.
- Recovery validates exact scheme/host/root path, disallows fragments/ports,
  duplicate/ambiguous query parameters and mixed tokens. PKCE recovery status
  comes from the provider's stored flow marker; the callback marker is not proof.
- Only a stable verified session may change the password. Private routes and
  root overlays close during recovery. Auth changes/resume cannot reopen them.
  Same-session token refresh preserves the form; replacement invalidates it.
- Explicit local recovery logout precedes fresh Merchant login/role checks.
  Ambiguous writes are not retried automatically or shown as success. Cleanup
  failures remain blocking and retryable; old work cannot clear a newer session.
  A failed exchange that cannot identify the changed session keeps the durable
  gate and asks for restart; it never adopts the current session as its own grant.
- A role-specific boolean pending marker blocks incomplete recovery after restart.
  No email/password/callback secret is persisted by this mechanism. Supabase's
  existing session/PKCE persistence remains the shared Auth mechanism.
- Pilot release tasks check exact target and offline config, then the unchanged
  external pinned-certificate signing proof. Local Merchant release remains blocked.
  An unconfigured pilot debug APK renders a setup-required screen without connecting.

## Offline preparation commands

Use an owner-supplied external **client-only** config based on
`tool/merchant_pilot_config.example.json`. The example intentionally fails: it is
disabled and contains a placeholder. Do not reuse Customer/Production config.
The permitted project ID is not proof of remote authority or deployed capabilities.

```powershell
dart run tool/merchant_pilot_preflight.dart --config <external-client-json> --target lib/main_merchant_pilot.dart --flavor merchantPilot
flutter build apk --debug --no-pub --flavor merchantPilot -t lib/main_merchant_pilot.dart
```

The second command intentionally creates a nonconnecting setup artifact unless
the reviewed config is supplied. Do not distribute that artifact to merchants.
After separately authorized signing/configuration, release packaging uses the
same target/flavor with `--release --dart-define-from-file=<external-client-json>`
and existing `ESNAFTAVAR_SIGNING_PROPERTIES` outside every checkout. This document
does not authorize obtaining/reading owner secrets or producing/distributing a
signed artifact. Final store identifier and signing ownership remain release work.

## Remaining pilot gates, in order

1. Review the actual authorized test backend and choose the final pilot feature
   manifest. Rehearse exact required schema, Storage and grants; verify Merchant
   onboarding/listing/media and matching Customer contracts before deployment.
   This preparation performs no generic `db push` or automatic feature enablement.
2. Approve and configure the exact Merchant Auth redirect alongside the existing
   Customer redirect. Preserve Customer templates/callbacks. Exercise reset mail
   on the actual pilot phone, including cold/warm starts, stale links, restart,
   interrupted exchange and fresh-login authority. No wildcard redirect proposal.
3. Review exact signed artifacts, real account/shop provisioning, physical
   Customer↔Merchant QR and operational pause/support before cohort distribution.
   Real push is still unconfigured; financial/Ads/Reward activation remains gated.

## Verification

### Integration correction after `ef216b3a`

Integration rejected the first delivery: GoTrue 2.18.0 applies verification and
password-update responses to its own current session before returning to the
adapter. The original 2,929 passing tests did not cover this SDK mutation boundary.
Both supplied independent scenarios were reproduced unchanged: **0 PASS / 2 FAIL**.
Their assertions are retained in the committed SDK regression suite (fixture
wiring now supplies the same response-staging factory as the production entrypoint;
diagnostic prints became additional assertions).

- Verification and password update now use disposable GoTrue response buffers
  against the **same** provider and PKCE storage, with no refresh, persisted session,
  navigation or application services. No second Auth provider/store is introduced.
- A monotonic lease observes event snapshot identities, including same-account
  replacement and change-away-and-back. A verified, consistent, unexpired response
  may reach the shared client only while that lease remains valid. The public SDK
  `setInitialSession` import applies synchronously and cannot trigger a refresh.
  The shared client continues to own session persistence/events and Realtime Auth.
- Password responses never update shared user metadata. A stale or lost response
  leaves the newer session intact; no automatic password retry or old-account
  restoration occurs. Existing server-side effects are not claimed to be cancelled.
- The pending-marker write is fenced before dispatch as well. Mixed JWT subject /
  user identities cannot clear the recovery gate. Backend leases and UI state both
  reject revived grants. Customer initialization keeps its default PKCE storage;
  the explicit shared PKCE instance is supplied only by the Merchant pilot host.
- A second link without recovery proof does not discard an earlier verified
  recovery identity: explicit dismissal still closes that session before lifting
  the gate. The added SDK regression failed before this correction and passes now.

The regression matrix uses the actual Supabase/Gotrue client with delayed synthetic
HTTP/storage: both reported races, hash and PKCE exchange, another account, the same
account's new session, logout, change-away-and-back, missing exchange/update/cleanup
acknowledgements, malformed identity, expired response, disposal, PKCE cleanup and
valid same-session refresh. Tests are local; no live backend or real mail is used.

```powershell
flutter test --no-pub test/unit/merchant/merchant_recovery_sdk_race_test.dart --reporter expanded
```

### Current measured validation

Final measured results, source fingerprints and artifact hashes are recorded in
[the validation manifest](data/merchant_pilot_runtime_validation.json).

- Full suite: **2,961 PASS / 0 FAIL / 6 existing conditional SKIP**; baseline
  2,853 passes, **108 new tests** across the delivery, including **32 added by
  this correction**. Final analyzer: **PASS, no issues**.
- Targeted recovery: **77 PASS**, including **30 real-SDK race cases** and the
  original two Integration failures. Widget suite: **9 PASS**, six existing renders at
  320/390/430 logical pixels and 130% text scale, visually inspected.
- Offline preflight: **8 PASS**; Gradle configuration policy: **34 PASS**;
  actual Gradle packaging rejection boundaries: **8 PASS**, including Customer
  bundle signing and isolated Merchant target/config/signing requirements.
- Customer development, Merchant development and Merchant pilot debug APKs:
  **PASS**. APK manifest inspection confirms distinct package/callback identities.
  The pilot debug APK is deliberately unconfigured and is not for distribution.
- Merchant pilot ARM64 release compilation: **PASS**, with synthetic offline
  client data and explicit pilot flavor. This creates compile output only;
  no owner signing material, signed APK/AAB or remote backend is involved.
- The original Windows cross-drive Kotlin incremental cache failure was resolved with
  process-only compiler/cache/worker settings; no dependency or tracked Gradle
  property change. An initial direct Gradle argument-quoting issue was corrected;
  the final compile and all eight packaging cases passed. No unresolved failure.

Tests distinguish fake-domain HTTP adapter evidence from a real remote Auth/SMTP
test. Screenshots prove rendering only. Debug compilation does not prove signing,
email delivery, camera operation, physical acceptance or release readiness.

Shared review areas: additive Auth initialization/redirect seam, Merchant session
gate/composition and Android flavor/packaging guards. No Customer screens,
global locator, dependency versions, applied migrations or financial rules change.
