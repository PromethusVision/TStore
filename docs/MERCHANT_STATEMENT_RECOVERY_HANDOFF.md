# Merchant statement and private accounting read recovery

Task branch: `agent/merchant-statement-recovery`.
Integrated base: `88fa667b982608338044219f06897da5007c9eda`.
Product authority: canonical §9.3 and H0/H1 read recovery follow-through.
Main integration belongs to Integration Agent.

## Audit and reproduction

H1 already supplies a default-OFF, read-only statement with exact integer amounts,
source-specific receivables, reserve and immutable journal projections. Existing
SQL ownership/snapshot rules, decoder, financial labels and disabled settlement
are retained. The adjacent H0 private-account adapter shares the same transport.

Before runtime edits, `.buildlog/statement-red.log` recorded **9 PASS / 18 FAIL**:

- Statement reads rejected the real SDK's replayed initial Auth event and normal
  same-session renewal. Earlier transport tests used an event stream without
  the SDK's initial-event replay.
- Merchant and Customer H0 account reads accepted same-user replacement and an
  intervening S1→S2→S1 event sequence. All three private read paths could dispatch
  a request without a stable session key.
- The statement widget restarted loaded state on normal renewal. It ignored
  stable-key replacement and stream completion, and could revive old private
  state after observer failure or logout/relogin.
- Further pages with the same revision accepted changed totals, a changed reserve
  cap or a newer first movement, contradicting the existing snapshot contract.

The HTTP fixture uses the actual Supabase/PostgREST Dart client with synthetic
JWT/session events and an isolated `.invalid` transport. Its mock responses
include originating request metadata required by the SDK. No real credentials,
participants, purchase evidence or accounting postings are created.

## Implementation

`SupabaseCommerceLedgerRepository` reuses `AuthenticatedRequestScope` and the
existing optional `AuthenticatedSessionEvents` capability. Private reads require
a stable key, compare current identity and observe captured actor/key events.
All response/error paths respect that authority. Initial replay and ordinary
renewal retain valid work. Scope listeners are released after completion/timeout.
Public capabilities and existing error types/RPC parameters stay unchanged.

The Merchant statement view observes both actor and stable key. Replacement or
broken observation clears values and permanently expires that binding; reopening
is required. Normal renewal and stream-wrapper replacement keep loaded pages.
Shop/owner/repository replacement creates a fresh binding and rejects old replies.
Disposal releases the view's owned streams. A bounded read deadline covers custom
repositories as well as the production adapter. Resume starts a new first-page
generation; stale results and late failures cannot overwrite it.

Same-revision pagination also requires equal account maps/reserve cap and the
existing strict descending timestamp/ID order across the page boundary.
Contradictions clear the partial statement and retry from the first page.
Valid equal-timestamp ordering, revision changes, transient retry at the same
cursor, duplicate-page protection and exact large integer formatting are retained.

No amount computation, reserve allocation, financial permission, payout workflow,
SQL, dependency, global Auth implementation, navigation framework or Customer UI
was changed. The shared H0 read adapter is the only Customer-adjacent runtime area.

## Validation and integration limits

Results and artifact fingerprints are recorded in
[verification evidence](data/merchant_statement_recovery_verification.json) and
[paired build evidence](data/merchant_statement_recovery_build_pair.json).

Focused accounting/statement coverage: **92 PASS**. It includes SDK HTTP/Auth
tests, public capability compatibility, late success/error, observer failure/
closure, listener cleanup, timeout/retry, resume, cross-shop/repository isolation,
ordered pagination, source-separated amounts and 320 px / 140% text states.

- Adjacent Merchant unit/widget and accounting suites: **603 PASS**.
  Log: `.buildlog/statement-targeted.log`.
- Full Flutter regression: **3,178 PASS / 0 FAIL / 6 existing conditional SKIP**.
  This is **53 new tests** over integrated baseline 3,125. All six skip identities
  match the previous package. Log: `.buildlog/statement-full.jsonl`.
- `flutter analyze --no-pub`: **PASS, no issues**.
  Log: `.buildlog/statement-analyze.log`.
- Pair compatibility/preflight suite: **135 PASS / 0 FAIL / 0 SKIP**.
- ARM64 debug builds: **Customer Development, Merchant Pilot and Merchant
  Development PASS**. Package identities, callbacks and signatures verified.
  Isolated output: `.buildlog/pilot-device/statement-recovery-20261020/`.
  Customer compilation reported nonfatal Kotlin incremental-cache diagnostics;
  Gradle completed successfully. The diagnostics are preserved in its build log.

Builds ran before the delivery commit, so paired evidence intentionally records
the integrated base commit with `uncommitted_sources: true`. The source
fingerprint, verified again after all builds, is
`0d2dd545017cc96c889b0ec66bed35bcb51151c47301aaaf50e7a9083e524443`.
This identifies the built runtime rather than claiming the base alone includes
the fixes. Integration Agent must independently verify the delivered commit.

The previously delivered `EsnaftaVar-Development-a0dfbdfd` APK pair is unchanged;
both original SHA-256 hashes were rechecked and are recorded in verification
evidence. The three new artifacts use synthetic compile configuration and are
not distributable device candidates.

Existing transport fixtures now supply explicit synthetic stable-session
identity. The same-user replacement test changes the key; it no longer treats
every token renewal as replacement. The existing logout/relogin widget case is
strengthened to require a new route before private state becomes visible.
No test is skipped or weakened. Existing rendered evidence/goldens are preserved.
Final scope contains 12 authored files. `git diff --check` and the added-content/
new-file secret/PII scan pass. No generated metadata, dependency or unrelated
checkout changes are included.

No database code changed. Database validation is **N/A**. The existing captured
local-service response still passes decoding tests, but historical PostgreSQL/
PostgREST acceptance is not claimed as newly executed. The client consistency
checks do not replace RLS, prove current shop ownership without a server read, or
provide an atomic cross-device statement snapshot.

Production and hosted Development access/writes: **NONE**. Provider setup/sends:
**NONE**. Remote migration: **NONE**. Feature flags and payout activation remain
OFF. New synthetic APKs are compile rehearsals only; prior delivered device
candidates must not be overwritten or publicly uploaded.

Shared conflict areas: the H0/H1 adapter, Merchant statement widget, canonical
and slice documents. Physical two-device QR, provider acceptance, real pilot
merchant/product selection and full H1 settlement/O8 policy remain OPEN.
No manual action from the user is required to finish this local package.
