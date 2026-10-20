# Merchant and Customer notification preference recovery

Task branch: `agent/merchant-preference-recovery`.
Integrated base: `4aceba6542d38c2c1ab49d2c6b4456920708c0b0`.
Product authority: canonical §12.4 and Slice I local follow-through.
Main integration belongs to Integration Agent.

## Audit and reproduced failures

The previous inbox package was integrated, including the Customer home badge
rebind correction. Existing PushCoordinator enrollment/session guards and inbox
recovery are retained. This package addresses the adjacent existing preference
controls, local storage adapter and Supabase push backend.

Before implementation, 14 regressions failed while 20 controls passed:

- A lost save acknowledgement left the previous preference editable without
  checking whether the server had already committed the requested value.
- Server-backed preference controls did not expire on session replacement.
- Failed native persistence could still appear successful through the
  SharedPreferences optimistic cache. Fresh reads missed native changes.
- A reopened local adapter could read past an unresolved write or send a second
  overlapping write for the same account/role.
- Five backend operations accepted an intervening S1→S2→S1 transition.
- Two incomplete preference rows silently supplied fallback consent values.
- A notification lookup accepted a returned foreign recipient.

The first HTTP fixture used `recoverSession`, which does not emit a same-account
event in the installed SDK. It was corrected to `setInitialSession`, also used
by the application's recovery adapter. All eight backend defects were then
independently reproduced against the untouched base implementation:
`.buildlog/backend-event-red.log` records **0 PASS / 8 FAIL**.
The initial storage/widget reproduction remains in `.buildlog/preference-red.log`.
No production credentials, real notifications or fabricated purchase evidence.

## Changes

The shared preference controls keep the last confirmed values disabled after
an unknown write outcome and offer **Kaydı kontrol et**. That action reads
current state without replaying the write. A failed reread stays locked.
Reads retain the existing deadline; pending writes are not timed out or cancelled.

One small in-memory guard rejects overlapping writes and makes reads wait for
the pending owner/role write to settle. Local adapters share it for the existing
device store; server adapters share it per Supabase client through a weak key.
It does not introduce a queue, database, persisted identity or new dependency.
Local reads reload the native store before interpreting existing account/role
keys, including after a failed optimistic setter. Local state is never promoted
to server consent.

The existing optional notification session source binds server-backed controls
to a stable session. Replacement, logout, account switch and observer failure
retire private state; reopening binds the new session. Normal renewal preserves
valid state and pending work. Existing identity/repository replacement guards
remain, including the lock for an older same-account pending write.

The existing backend reuses `AuthenticatedRequestScope` for register, disable,
preference read/save and lookup. Captured Auth events fence intervening session
changes and both successful and failed delayed responses. Malformed existing
preference rows fail explicitly; absent rows retain existing defaults. Lookup
verifies the returned recipient. Role-bound RPC names/parameters are unchanged.

## Verification

Final automated results and artifact hashes are recorded in
[verification evidence](data/merchant_preference_recovery_verification.json)
and [paired build evidence](data/merchant_preference_recovery_build_pair.json).

- Focused regression suite: **67 PASS**, including SDK HTTP/Auth fixtures,
  native method-channel persistence fixtures and shared widget states.
- Adjacent notification, Merchant boundary, Customer home and W48/W49 suite:
  **427 PASS**. Existing goldens were not regenerated.
- Full Flutter regression: **3,125 PASS / 0 FAIL / 6 existing conditional
  SKIP**, with **39 additional tests** over integrated baseline 3,086.
  All six skip identities match the integrated baseline. No removed/weakened
  test or new skip. Log: `.buildlog/preference-full.jsonl`.
- `flutter analyze --no-pub`: **PASS, no issues**.
  Log: `.buildlog/preference-analyze.log`.
- Customer `development`, Merchant `merchantPilot` and `merchantDevelopment`
  debug APKs: **PASS**, including package identity/signature inspection.
  Paired-build compatibility suite: **135 PASS**. All use synthetic compile
  input; no backend request or device delivery is implied.
- Final source SHA-256:
  `cf9b1fccc594f4d8989cdfe58676eee3b0314f45ecc5cd8f5a76c17c40fdaf82`.
  It matches the built pair. The receipt names the integrated base and marks
  uncommitted sources because compilation preceded the delivery commit.
- Customer compilation emitted nonfatal Kotlin incremental-cache diagnostics;
  Gradle's fallback completed successfully. The complete log is preserved in
  `.buildlog/pilot-device/preference-recovery-20261020/customer.build.log`.
  No dependency or build setting was changed to suppress diagnostics.
- The previously delivered `EsnaftaVar-Development-a0dfbdfd` pair is unchanged
  by SHA-256. New artifacts remain in their separate task-local output folder.
- Final `git diff --check`, added-content secret/PII scan and exact 13-file
  scope audit: **PASS**. Existing canonical sender documentation is unchanged.
- UI coverage includes duplicate callbacks, slow reads/writes, lost response,
  failed reread, late callbacks after disposal/session changes, observer
  failure/closure, normal renewal and 320 px / 140% text recovery controls.
- No SQL/grant/migration change. Database validation is **N/A**, not an inferred
  database PASS. Test doubles do not claim physical device persistence or
  real Supabase/provider delivery acceptance.

## Limits and integration

An in-memory guard cannot cancel an already dispatched request or survive
process death. After a lost acknowledgement, the server may still finish later;
an explicit read observes current state, not a durable acknowledgement for that
write. This package does not guarantee cross-device ordering or introduce an
idempotency/revision contract absent from the existing server. Local native-store
reload does not claim OS flush/disk durability beyond SharedPreferences' contract.

Shared conflict areas: local/server notification preference repositories, the
existing push backend adapter, shared preference controls, canonical and slice
documentation. No changes to Auth implementation, home badge, inbox, navigation,
theme, dependencies, permissions or feature defaults.

Production and hosted Development access/writes: **NONE**. Provider
configuration/sends: **NONE**. Remote migration: **NONE**. Existing delivered
APKs remain protected; fresh synthetic builds are compile rehearsals only and
must not be distributed as pilot candidates.

Phone installation, real merchant/product selection, physical two-device QR
and provider/field acceptance remain OPEN. They are not required from the user
to finish this local code package; pilot opening is not declared ready.
