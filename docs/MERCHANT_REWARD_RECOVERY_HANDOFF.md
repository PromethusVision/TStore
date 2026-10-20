# Merchant reward client recovery

Source branch: `agent/merchant-reward-recovery`.
Integrated base: `42dd8f5a5b08e737aa1dacbf32291cda4d102ca6`.
Boundary: canonical §8.3 / E client recovery; Integration Agent owns main.

Local verification: **PASS, Integration review pending**. 120 targeted tests,
3,360 full Flutter tests, zero final failures, the same six conditional skips,
and `flutter analyze --no-pub` without issues. The package adds 51 regressions.
Customer Development, Merchant Pilot and Merchant Development debug builds pass;
the build-pair compatibility group passes 135 checks. The unchanged campaign
recheck passes nine tests. Diff, source-fingerprint and secret/PII audits pass.

## Problem and resulting behavior

The reward adapter previously observed user IDs but compared only the latest live
session key. Queued S1 → S2 → S1 transitions could admit stale data, malformed
replies or server failures. Private UI also equated the same user with the same
session, ignored observer closure, and reset its busy state on normal renewal.

The adapter now uses existing `AuthenticatedRequestScope` and captured
`AuthenticatedSessionEvents`. Success, parse errors and structured server errors
are fenced alike. Private views retire on replacement, logout/return or failed
observation. Merchant navigation captures its origin before route mount. Normal
renewal preserves in-flight work. The Customer home subscription can recover with
fresh data for the same account's new session and continue later refreshes.

Acceptance writes retain the server's existing expected revision. A concurrent
write is refused; reopened owner reads wait for outstanding transport. A timed-out
queued read cannot later dispatch. Successful receipts must acknowledge both the
requested preference and the next revision. Missing or invalid receipts hide the
toggle until an explicit fresh read; no silent write replay or optimistic success.
If transport never settles, the in-memory write guard remains held and reopened
owner reads report their bounded failure. The client cannot prove cancellation or
server completion; authoritative revision/ownership checks remain the safety net.

Reservation calls do not release their local overlap guard merely because time
passes or the originating widget closes. Cart edits coalesce one latest recheck
after settlement, always with `startNew: false`. Retiring the session cancels that
continuation. A new attempt still requires the existing explicit expired-attempt
action. Displayed remaining time includes transport delay conservatively instead
of adding that delay back at receipt. Unexpected read/write failures are contained
and retryable; bounded reads
cannot restore old content after expiry or context replacement.

## Scope and shared surfaces

- Merchant package entry/view, shared reward RPC adapter and reservation card.
- A feature-local presentation continuation guard reuses existing Auth interfaces.
  No second Auth, notification, reward or accounting system.
- Customer counter/center, coupons and coupon checkout regression coverage; their
  accepted screen layouts and global composition are preserved.
- Canonical and slices record the bounded implementation. No FROZEN amounts,
  qualification, capacity, funding or ownership changes; no feature activation.
- No SQL changes: the current owner/CAS/read contracts suffice. Reading reward
  RPCs can reconcile server state; a local timeout does not cancel server work.

## Verification and reproduction

Machine-readable final results and artifact identities are in
`data/merchant_reward_recovery_verification.json` and
`data/merchant_reward_recovery_build_pair.json`.

Original behavior was reproduced with SDK-backed session events (15 failures,
one valid-renewal control passing) and 18 UI regressions. The first SDK fixture
omitted `token_type`; those setup failures are excluded from reproduction evidence.
Corrected baseline evidence: `.buildlog/reward-unit-red.log`; widget baseline:
`.buildlog/reward-red.log` in the task worktree.

Permanent regressions cover captured replacement/return, observer failure/closure,
late malformed/structured failures, pending transport versus deadlines, receipt
revision mismatch, reopen/read ordering, cart coalescing, first route mount,
Customer counter recovery, exception containment and narrow/large-text retry.
All test fixtures are synthetic and local. No purchase or reward evidence is
created in a hosted project.

Final commands and results are retained in `.buildlog/reward-targeted-final.log`,
`.buildlog/reward-full.jsonl` and `.buildlog/reward-analyze-final.log`.
The first full run (`reward-full-first.jsonl`) passed 3,359 tests and failed only
the unchanged campaign fixture that expires after two seconds: its initial
visibility check completed after about 6.4 seconds under parallel load. Its nine
campaign tests passed unchanged in isolation. The final full run uses concurrency
two; no additional skip, weaker assertion or longer expiry is used to obtain a pass.
Android rehearsal output is isolated under
`.buildlog/pilot-device/reward-recovery-20261021/`. Its Customer Development,
Merchant Pilot and Merchant Development artifacts use synthetic compile-only
configuration and are not a replacement install pair. Previously delivered APKs
and previous trust/statement compile artifacts must retain their recorded hashes.
All recorded hashes were rechecked successfully. Customer and Merchant Development
build logs contain non-fatal Windows Kotlin incremental-cache diagnostics; compiler
fallback completed, both commands exited successfully and the resulting APKs
passed manifest/signature inspection. No dependency or Gradle policy was changed.

## Remaining gates

Integration review/merge remains separate. Production and hosted Development were
not accessed; no remote environment write, migration, real account or provider send occurred.
The feature gates remain OFF. Real merchant/product selection and physical
two-device QR/pilot acceptance remain open; this reliability delivery does not
declare the pilot ready.
