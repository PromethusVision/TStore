# Trust recovery correction — pre-mount session continuity

Task branch: `agent/merchant-trust-recovery`.
Product authority: canonical §7.3 and existing FROZEN D/F rules.
Integration of this corrected branch remains pending.

## Integration context

The original trust delivery `8df49adbb37a8f93c06230a06d753c8005f24016`
started independently from `88fa667b`. Integration rejected it after finding
that a badge dialog first mounted in a replacement session could still show
content captured in the old session. Previous local test/build passes did not
cover that interval and must not be interpreted as acceptance of the delivery.

The independent statement package was integrated at
`4ed927f05923ec5fdaae05eb4981c7a62d78a174`. That main commit is now merged
into this task branch (`8e1d224c`) without changing main. All correction validation
below uses the combined statement + trust tree, rather than certifying two
independent trees as a combined result.

## Reproduction and correction

The Integration Agent's independent fixture was copied without edits into this
worktree. Before correction it reproduced **2 PASS / 2 FAIL**; after correction
all **4 PASS**. No integration checkout/source was modified.

The two new permanent suites cover 64 Merchant/Customer badge navigation cases
and 18 adjacent campaign cases. Re-running those exact suites plus the four
independent checks against the original four presentation files produced
**30 PASS / 56 FAIL** (`.buildlog/overlay-confirmed-red.log`). Corrected files
were restored byte-for-byte afterwards. Earlier exploratory runs also remain
in `.buildlog`; the confirmed run uses the final test fixtures.

The existing `TrustSessionGuard` now checks the initiating screen's continuation
in addition to the destination's own actor and stable-session observation.
That originating guard already observed changes before the destination mounts,
including S1→S2→S1 events. A destination initially lacking authority remains
expired. Normal token renewal preserves valid content and drafts. No second Auth
implementation or global session state was added.

Covered destinations:

- Summary badge explanation, detail explanation, all-badge dialog and trust
  history in both Merchant and Customer scopes.
- Shared campaign preview, publish confirmation and published-photo selection.
- Campaign summary → list, list → editor and editor → product selection.
  These route arguments are captured before navigation, avoiding both unintended
  adoption of a new session and dereferencing a page cleared before first mount.

Private reads and actions remain fenced by the existing repository and view
checks. Existing observer failure/closure, logout, replacement, late response,
retry, cursor and cleanup tests remain. Server badge qualification, verified
purchase requirements, ownership, offers, prices, economics and default-OFF
flags are unchanged. Public badge explanations stay public.

## Validation

- Independent original reproduction: **2 PASS / 2 FAIL**;
  `.buildlog/overlay-independent-red.log`.
- Independent recheck plus related repository, session, widget, campaign and
  statement suites: **320 PASS / 0 FAIL**;
  `.buildlog/overlay-combined-final.log` (includes all four independent checks).
- Full Flutter suite: **3309 PASS / 0 FAIL / 6 existing conditional SKIP**;
  `.buildlog/overlay-full.jsonl`.
  This is integrated main's 3178 + original trust's 49 + this correction's 82.
  Skip names are checked against the previous evidence; none added or weakened.
- `flutter analyze --no-pub`: **PASS, no issues**;
  `.buildlog/overlay-analyze-final.log`.
- Existing layout/golden tests pass without changing goldens. New badge cases
  exercise 320px layouts; existing shared management checks cover 320/390/430px
  at 130% text and trust recovery includes 140% text.

Customer Development, Merchant Development and Merchant Pilot ARM64 debug
compilations all **PASS**. Pair compatibility/preflight is **135 PASS**. APK
identities, callbacks, signatures and hashes are verified. Evidence:
[verification](data/merchant_trust_recovery_verification.json) and
[paired builds](data/merchant_trust_recovery_build_pair.json).

The isolated artifacts are in
`.buildlog/pilot-device/trust-overlay-recovery-20261020/`.
The builds precede the correction commit and honestly record parent `8e1d224c`
with `uncommitted_sources: true`. Their source fingerprint is
`417a9a0041dd3fc62fe9b70efa363b47c5be500bc366e01f32064e8489db2914`.
These are synthetic compile rehearsals, not distributable pilot candidates.
Customer compilation includes nonfatal Kotlin incremental-cache diagnostics;
Gradle completed successfully and its full log is retained.

Original delivered `EsnaftaVar-Development-a0dfbdfd` APKs, the prior trust build
trio and the statement build trio were rehashed unchanged. After copying and
verifying all new APKs, only this task's untracked `build/` cache was removed,
leaving approximately 4.25 GiB free on E:. Copied APKs and logs remain outside
that cache. Final diff, source-fingerprint and added-content/new-file secret/PII
checks pass.

## Scope and remaining gates

Shared review areas: trust/campaign adapter from the original delivery,
`TrustSessionGuard`, trust views, campaign views/editor, canonical and slices.
The correction changes four presentation files, two new permanent test suites
and five delivery/canonical documents. The whole branch changes 16 authored files
relative to integrated main. No statement implementation file is edited by this
correction; its exact integrated content is retained.

Production/hosted Development access or writes: **NONE**. SQL changes, migration
apply, provider configuration/sends and dependency changes: **NONE**.
Physical two-device QR, real provider acceptance and pilot-opening decisions
remain OPEN. This local regression correction needs no user phone action.
Integration Agent owns independent final review and main merge/push.
