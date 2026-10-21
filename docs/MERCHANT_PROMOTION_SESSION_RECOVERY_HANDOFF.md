# Merchant promotion session and command recovery

Source branch: `agent/merchant-promotion-session-recovery`.
Integrated base: `d1805677a9987c692b713d4826fa7c7ae239b010`.
Boundary: canonical §11.3, existing G draft preparation only.
Main merge/push belongs to Integration Agent.

Validation status: **LOCAL PASS, independent Integration review pending**.
180 targeted tests and 3,417 full Flutter tests PASS, zero failures and the same
six conditional skips; 57 new tests. Analyzer PASS. Customer Development, Merchant
Pilot and Merchant Development debug builds PASS; 135 pair compatibility checks
PASS. Source, manifest/callback, signature, prior-artifact, scope, diff and
secret/PII checks PASS. Machine evidence:
`data/merchant_promotion_session_recovery_verification.json` and
`data/merchant_promotion_session_recovery_build_pair.json`.

## Reproduced problems and resulting behavior

The promotion adapter observed user IDs and checked the current live session key,
but missed a queued S1 → S2 → S1 replacement. SDK-backed regressions reproduced
acceptance of stale successes, malformed responses and structured errors across
list, exact detail, source selection, preview, history and mutation. Independent
widget regressions reproduced stale private surfaces and the old discard prompt.
Two simultaneous identical commands also dispatched two transport requests.

The adapter now exposes the existing captured-session event contract and supplies
it to `AuthenticatedRequestScope`. Every continuation, including delayed image
signing and failure classification, belongs to the initiating session. Ordinary
token renewal remains valid; replacement, logout/return and broken observation
retire private work. Existing Campaign Lite already had the shared captured-session
guard and was verified without rewriting its implementation.

The unchanged dashboard card delegates navigation to a scoped entry. Repeated taps
open one route, and the destination cannot acquire a new session between the tap
and first mount. Discard prompts also retain their opener; late answers cannot
operate on another workspace. Resume during a prompt retains a usable cancel
path. Context replacement clears previous draft/search labels and suppresses old
read completions. Existing screens, selectors and pagination remain intact.

The repository retains one original command per shop while transport is pending
or its acknowledgement is uncertain. Concurrent identical calls share the same
future; a different payload cannot replace it, even with the same request ID.
View reopening exposes the existing explicit same-command check and blocks new
draft creation. Reading this recovery port sends no request. A still-running
request is joined; a settled uncertain request is retried only on explicit action
with its original payload and server idempotency key. Successful/definite rejected
outcomes release the command. Old-session commands are not inherited or replayed.

This is app-memory continuity, not a durable offline queue. Process/repository loss
does not retain a command, and session loss does not cancel a dispatched request.
Never-ending transport remains guarded until settlement. Existing server ownership,
revision, fingerprint and idempotency checks remain the authority; a fresh read is
not treated as a receipt. No automatic replay or artificial mutation deadline.

## Scope and verification

Runtime changes are limited to Merchant dashboard navigation and the existing
promotion domain/adapter/views. The optional pending-command port and feature-local
view guard reuse shared Auth primitives. No Customer layout/source, dependency,
global provider/bootstrap, SQL, migration, feature-default or business-rule change.

Baseline red evidence: `.buildlog/promotion-red.jsonl` (25 failures, seven controls
passing). New permanent tests cover all six adapter operations, SDK event ordering,
signing, errors/observer closure, original-payload reconciliation, definite rejection,
replacement while writing, list/editor/history/source privacy, first mount,
normal renewal, repository replacement and actual adapter-to-widget reopening.
The latter runs at widths 320 and 430 with 1.3 text scale.

An expanded test harness initially addressed a lazy list item using `.last` before
it existed and awaited a root-zone stream close from FakeAsync. Those fixture-only
runs were interrupted/corrected; they are excluded from product reproduction proof.
Final expectations remain unchanged. Analyzer's four test-only brace-style findings
were corrected; no runtime assertion or existing test was weakened.

Final logs: `.buildlog/promotion-targeted-complete.jsonl`,
`.buildlog/promotion-full.jsonl`, `.buildlog/promotion-analyze-final.log`.
Full regression uses concurrency two and preserves the six existing conditional
skips. Synthetic Android output is isolated at
`.buildlog/pilot-device/promotion-session-recovery-20261021-final/`.
It is a compile rehearsal, not an updated install candidate. Machine verification
records source/APK/signature/callback fingerprints and checks the previously
delivered pair plus reward/trust/statement compile artifacts remain unchanged.

The first pair attempt compiled both applications but failed at `inspect-merchant`.
Its underlying copy/inspection error was not captured: disk exhaustion was first
suspected from a misleading mixed-table output, but is not proven. Logs and the
failure receipt remain. The incomplete generated Customer copy was reclaimed;
its hash was recorded and matched the next attempt exactly. A second attempt's
Customer APK independently passed all inspection checks, but legacy Windows
PowerShell refused the cache-cleanup script. No execution policy was changed.

A task-local copy of the existing pair runner uses the current `pwsh` host and
preserves every source/config/test/artifact check. Its only differences are import
root adjustment, guarded cleanup of this task's generated `build/` after each
verified APK and command-failure diagnostics. Final verification mechanically
compares those edits with the original runner. Fresh output folders preserve
failure evidence. No tracked build tooling, delivered APK or another worktree's
file was changed. These operational retries are not product-code corrections.
Final build logs contain nonfatal Windows Kotlin incremental-cache diagnostics;
compiler fallback completed successfully. All three APKs were independently
inspected. No dependency, Gradle or execution-policy change was made.

## Open gates

No hosted Development/Production access or write, migration apply, real account,
catalog publication, provider configuration/send or paid activation occurred.
All existing feature defaults remain OFF. Real merchant/product selection,
physical two-device QR, provider/release and pilot-opening acceptance remain open.
This package needs independent Integration review; it does not declare pilot readiness.
