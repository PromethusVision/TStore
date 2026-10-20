# Merchant and shared Customer inbox recovery

Baseline: `8e1fb70297f787e29d8b6952ae4c0cb9f89be57a`.
Branch: `agent/merchant-inbox-recovery`.
Authority: Product Owner's next implementation request after review integration.
Canonical §12.3; no FROZEN product change.
Status: **LOCAL PASS — independent main integration pending**.

## Audit and reproduced failures

The current PushCoordinator already protects provider enrollment/session/taps.
The inbox repository still compared user IDs only, while its state had no
replacement-session boundary. Existing pagination/request-generation and
duplicate-action guards were retained.

Before implementation, `.buildlog/inbox-red.log` recorded **6 passing renewal
controls and 16 failing regressions**:

- Six late repository successes survived same-user Auth session replacement
  (page, count, single/all read marking and single/all deletion).
- The Realtime seam accepted a foreign recipient and an S1→S2→S1 stale event.
- Late mark-all/delete-all acknowledgements modified newer live arrivals.
- Four thrown mutation paths leaked errors and left action locks stuck.
- A stale live event restored an acknowledged deleted record.
- A delayed count contradicted newer visible unread rows.

## Implementation

Reused stable Auth session keys and `AuthenticatedRequestScope`. The existing
repository exposes an optional session capability recognized by NotificationsCubit;
production Merchant and Customer compositions obtain it from the same adapter.
There is no separate inbox, Auth system, provider SDK or global bootstrap rewrite.

Read/write success and failure continuations are fenced. Captured event keys
prevent queued session replacement from reviving old work. Replacement/observer
failure clears private rows/count and permanently expires that cubit; ordinary
renewal retains it. Repository Realtime also checks recipient and session and
releases its owned listener on cancellation/authority loss.

Existing page generations and duplicate-action locks remain. Reads have bounded
deadlines; writes are not timed out, cancelled or retried automatically. Exceptions
become recoverable errors; uncertain outcomes preserve rows and unread state.
Bulk acknowledgements affect known starting rows, retaining newer live arrivals.
Visible confirmed deletions are suppressed against late events for the current
screen lifetime. Count races use loaded-unread fallback rather than overwrite it
with a contradicted delayed count. Stable timestamp/ID ordering resolves page ties.

Merchant and Customer expose a connection-error retry within existing surfaces.
Existing rows stay visible on transport errors; expired-session private content
is removed. A stale rendered Customer card cannot initiate navigation after
session replacement. Merchant's existing app-role filter remains unchanged.

## Verification

- Full Flutter regression: **3,073 PASS / 0 FAIL / 6 existing conditional SKIP**,
  up from 3,030 PASS (**43 additional tests**, no new skip).
- Targeted notification, Merchant boundary, Customer handoff, badge and adjacent
  visual coverage: **430 PASS**. Existing W48/W49 goldens were not regenerated.
- `flutter analyze --no-pub`: **PASS, no issues**.
- New regressions use the real Supabase/Dart adapter with synthetic HTTP/Auth
  fixtures, state-level races and both inboxes at 320 px / 130% text.
  No live credential, real user data, purchase or notification evidence is created.
- Final test logs: `.buildlog/flutter-full.jsonl`,
  `.buildlog/inbox-targeted-final.log`, `.buildlog/analyze-final.log`.
- Customer `development`, Merchant `merchantPilot` and
  `merchantDevelopment` debug APK builds: **PASS**. The pair tool's
  compatibility suite also passed **135 tests**. APK package identities and
  signatures were verified; all builds used synthetic local configuration.
- Source fingerprint after all builds:
  `16f6da86800e6ae41de7532f17cb2a7577768b149c3f424c1ba7a33b4f73d8de`.
  It matches the built pair. The evidence records the base commit plus
  uncommitted sources because compilation preceded the delivery commit.
- Customer compilation emitted nonfatal Kotlin incremental-cache diagnostics;
  the build and APK verification completed successfully. Diagnostics are kept
  under `.buildlog/kotlin-build-diagnostics`. Generated platform files had
  no content changes and were restored.
- The previously delivered `EsnaftaVar-Development-a0dfbdfd` APK pair is unchanged
  by SHA-256. No new APK was uploaded or copied over those files.
- Evidence: [verification](data/merchant_inbox_recovery_verification.json) and
  [build pair](data/merchant_inbox_recovery_build_pair.json).
- Final whitespace and credential/PII checks: **PASS**.

SQL, grants, migrations and provider contracts are unchanged. Database migration
validation is N/A for this client-only diff; prior I0 database evidence is not
claimed as a newly executed test here.

## Limits and integration

Mutation completion cannot recall an in-flight server request. Unknown outcomes
require explicit refresh/retry; no durable receipt or delivery guarantee is
invented for the existing inbox CRUD API. Bulk server operations retain their
current semantics; newly arriving rows are preserved conservatively in the local
view until authoritative refresh. Realtime is not an immutable event log and the
loaded-count fallback is not an exact global counter. Reopening is required after
session expiration; new screen instances bind to the new session.

Shared conflict areas: notification repository/domain session capability,
NotificationsCubit/state and Customer/Merchant inbox widgets. Existing Customer
visual fixtures only gain the session getter required by the new interaction guard.
No theme/navigation framework, dependency, financial or permission policy changes.

Main integration belongs to Integration Agent. Production and hosted Development
access/writes: **NONE**. Provider configuration/sends: **NONE**. Remote migration:
**NONE**. Previously delivered APKs must remain unchanged; new build outputs are
local compile rehearsals, not device candidates or an authorized public upload.

Phone installation, pilot merchant/product selection, physical two-device QR
and provider/field acceptance remain open manual gates; none blocks this package.
