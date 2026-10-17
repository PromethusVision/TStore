# Merchant I1 — shared notification client preparation

Status: **PASS — local I1 preparation delivered; full I/provider/physical gates remain OPEN.**
Baseline: `4613988bf75564f66e3ebd2b7fffcac13dbca67e`.
Branch: `agent/merchant-notification-client`.

## Audit and bounded scope

I0 provided the server service-message dispatcher. The existing mobile
PushCoordinator and SupabasePushBackend were not composed in the Merchant host.
The initial coordinator subscribed after registration, losing early token
rotations; logout could finish while permission/token acquisition was pending;
device state was not persisted; the adapter checked user UUID only and could
accept a stale response after the same user's Auth session was replaced.

I1 reuses that coordinator, provider/device/preferences contracts, inbox and
authenticated notification lookup. It prepares the local Merchant composition
and adds controls inside its existing notification preferences screen. Five tabs,
Customer layouts/entrypoints, inbox storage and all commerce rules stay unchanged.
Canonical12.2 and the I1 slices subsection define the implementation boundary.

No dependency, provider SDK, secret, environment file, schema, SQL proposal,
automatic migration, financial rule or server privilege changes are included.
`MERCHANT_PUSH_SCHEMA_LOCAL_ENABLED` defaults false and is read only in the
existing loopback-only Merchant bootstrap. The provider remains explicitly
unconfigured even if that local schema switch is true. There is no real send.

## Behavior and screen inventory

- Existing Merchant account → notification preferences: truthful provider-pending
  copy; with an injected configured test provider, explicit permission/enrollment,
  connected state, device disable and recoverable cleanup error. No startup prompt.
- Existing Merchant inbox: a validated provider tap returns nested routes to the
  inbox tab. Provider payload targets cannot open arbitrary/admin routes. The
  authoritative existing notification must belong to the current account/role.
- Existing Merchant login/failure surfaces: logout waits for device revocation;
  a failed revoke keeps the account authenticated and offers existing retry.
- Existing shared preference controls: unchanged Customer presentation when no
  push coordinator is supplied. Reads time out after15s; account/repository
  replacement discards stale read/write results. Writes remain pending until an
  outcome arrives; duplicate taps cannot create overlapping saves.

The shared coordinator subscribes before fetching the initial token, retains the
latest token during enrollment, and serializes later rotations. Disable coalesces
repeated calls, invalidates new work immediately and waits for existing SDK and
write operations. No timeout claims an uncertain write was cancelled. A rotation
or stream failure becomes a visible cleanup state instead of silent failure.

Authority revision and stable Auth session key fence pending work. Same-session
token refresh remains valid; same-user replacement session does not. Merchant
private-scope changes invalidate old callbacks, including A→logout→A between
frames. The server still validates the actual JWT/session/role and owns all
authorization. An already dispatched network request is not claimed cancelled.

Tap lookup has a15s timeout, max16 simultaneous lookups and128 session-local
successful-ID dedup entries. Failed lookup can be retried; late timed-out results
cannot navigate. No provider body, device token or raw error enters logs/UI.

## Persistence and recovery limits

The role-scoped local record contains a random UUIDv4 installation identifier
and boolean cleanup marker only. Persist the marker before token acquisition.
Never persist account/session identifiers, tokens, consent or credentials in it.
Corrupt/unwritable storage fails closed instead of discarding uncertain state.

Normal same-session disable first revokes the existing server registration, then
deletes the provider token and persists clean state. Any failure blocks reuse.
After a process restart or foreign-session transition, delete the old provider
token before persisting a new installation and registering again. This avoids
issuing an old-session disable using replacement-account credentials. The
configured provider contract requires confirmed token invalidation or failure.

This is conservative preparation with explicit reconnect, not automatic startup
re-enrollment. The old server row may remain until existing invalid-token handling
or separately reviewed retention cleanup; no server-row disable is fabricated.
An in-flight provider message cannot be recalled. I0 generic copy and private
record lookup remain necessary. Real SDK deletion, OS permission behavior,
backup/restore/reinstall behavior, cold-start/background delivery and retired-row
retention require later provider/physical rollout review. Current tests use fake
providers and local synthetic HTTP; they do not prove those properties on phones.

## Validation

Final source: **2635 Flutter tests PASS, 0 FAIL, 6 existing SKIP; analyzer PASS**.
The diff adds63 tests:33 lifecycle/storage,18 Supabase HTTP/session contracts,
9 preference/device controls and3 Merchant host journeys. The9 preference tests
also passed with rendered evidence enabled. These tests are included in the full
count, not additional unique coverage. All6 images were visually inspected.

MerchantDevelopment and Customer development debug APK builds both PASS
(183.0s /206.8s respectively). Existing Java8 source/target deprecation warnings
are non-fatal; no toolchain upgrade was made. APK hashes are in the validation
record; APK files and raw build/test logs remain in ignored local output.

Source fingerprints and build evidence are recorded in
`docs/data/merchant_notification_client_i1_validation.json` after validation.
Six rendered preference states cover320/390/430px at1.3 text scale in
`docs/evidence/merchant_push_client/` (pending/connected, synthetic providers).

Reproduction:

```powershell
flutter analyze --no-pub
flutter test --no-pub --concurrency=2
flutter test --no-pub test/unit/notifications test/widget/notifications test/widget/merchant/merchant_push_client_test.dart test/widget/merchant/merchant_session_boundary_test.dart test/unit/merchant/merchant_session_resilience_test.dart --concurrency=2
flutter test --no-pub test/widget/notifications/push_device_controls_test.dart --dart-define=MERCHANT_PUSH_CAPTURE=true
flutter build apk --debug --flavor merchantDevelopment -t lib/main_merchant_development.dart --no-pub
flutter build apk --debug --flavor development -t lib/main_development.dart --no-pub
```

The development APK build verifies compilation, not a live configured launch.
No real database rehearsal is necessary for this diff: all SQL/server files are
unchanged from the integrated I0 baseline. HTTP tests use the real Supabase/Dart
adapter with synthetic responses and Auth sessions, including same-user session
replacement during each register/disable/read/save/lookup request. I0's real
PostgreSQL/Auth/Storage evidence remains its separate historical handoff, not a
new I1 execution claim.

## Integration and remaining gates

Review the source branch at its reported final SHA and compare against baseline.
Shared conflict areas: notification coordinator/contracts/adapter/preferences,
Merchant composition/navigation, canonical and implementation slices. No global
Customer locator/bootstrap, theme, dependencies or migration chain changed.
Only Integration Agent merges/pushes main; this agent pushes the task branch.

Remote backend/Production access and writes: NONE. Migration apply: NONE. Provider sends:
NONE. Full I, Customer host/provider binding, G/O10 marketing, H1 settlement and
physical two-device J remain OPEN. No manual Product Owner check is needed for
this local diff; actual phones/provider setup require a separately authorized task.
