# Merchant daily catalog and media session continuity

Status: **LOCAL PASS — Integration review pending**. Branch:
`agent/merchant-catalog-session-continuity`. Base:
`05bd42b705369aa5653c2e4a7e449e01b9ebba22`.
Canonical: §§4.2–4.3 and bounded follow-through §4.17; slice A.

## Reproduced problems

1. The Merchant data fence compared only live user/session getters. A queued
   S1 → S2 → S1 transition or logout → restoration could therefore admit the
   original delayed response. The actual Supabase SDK regression covers owned
   access/listings/profile, catalog search/submission, media and daily operations.
   Further probes demonstrate legacy fallback after a stale missing-capability
   error, continued signed-URL lookup after a swallowed image error, and upload
   preparation → Storage → publication continuation after the session boundary.
2. The Merchant host already replaces its private workspace correctly. However,
   before the next rendered frame, the former form remains mounted. A completed
   gallery picker could start an upload, a catalog lookup could start submission,
   and a profile-save response could call its success handler in that interval.

Baseline evidence uses unchanged integrated runtime: **36 FAIL / 16 controls PASS**
in the initial 52 adapter tests; **6 FAIL / 3 controls PASS** in the initial nine
host-widget tests. These are test cases representing the two related defects,
not 42 distinct reported product bugs. Final tests additionally cover file-size
and byte-read waits, uncertain-media refresh, stream failure/end, abandoned
request cleanup, editor recovery and catalog-list continuation.

Initial test-harness errors (logout mock recursion, ambiguous scrolling and
attempted UTF-8 decoding of binary upload data) were corrected. They are not
product-failure evidence. The first broad test command also included a nonexistent
test directory; the corrected command passed. No old assertion or skip was changed.

## Delivered change

- `MerchantRequestScope` delegates to the existing shared authenticated request
  scope. The three Merchant adapters supply captured Auth event subjects and stable
  session keys; both success/error and every subsequent request are fenced.
  Subscriptions close after completion or an abandoned read. The 15-second read
  limit remains; mutation acknowledgements are not timed out or replayed.
- A small Merchant presentation mixin checks the existing host revision, actor,
  stable key and authority before a continuation. It does not create another
  Auth controller or navigation system. The host still removes private routes,
  dialogs and messages. Standalone local previews retain their current behavior.
- Product/profile edits, catalog picker/submissions, listing photos and pending
  photo navigation use that guard. Gallery, length, byte-read, lookup, save and
  return callbacks cannot dispatch work or publish success from a retired
  workspace. Catalog paging and edit-recovery controllers accept the same guard.
- Ordinary renewal preserves valid drafts and in-flight work. Existing optimistic
  revisions, uncertain-upload intents, explicit recovery and exact submission
  request/payload retries are preserved. Already-dispatched server operations
  are not represented as cancelled.

Runtime changes are confined to `lib/features/merchant`. Shared Auth primitives
are reused without edits. No Customer layout, routing/bootstrap, dependency,
capability default, provider, RPC, RLS or migration change. Central coordination
documents and earlier delivery proofs remain untouched.

## Validation

| Check | Result |
|---|---|
| New regressions, final sources | **88 PASS** |
| Merchant + adjacent shop/notification tests | **1,124 PASS** |
| Full Flutter, concurrency 2 | **3,604 PASS / 0 FAIL / same 6 conditional SKIP** |
| `flutter analyze --no-pub` | **PASS, 0 issues** |
| Paired-build compatibility tests | **135 PASS** |
| Customer Development ARM64 debug | **PASS** |
| Merchant Pilot ARM64 debug | **PASS** |
| Merchant Development ARM64 debug | **PASS** |
| Scope, `git diff --check`, added-content secret/PII scan | **PASS** |
| SQL/local service migration validation | Not required: no server contract change |

The existing golden/narrow-screen, loading/error/recovery, session navigation,
duplicate-submit, Customer notification-counter and QR regression suites remain
included. A native gallery is represented by an explicit widget-test seam;
these tests do not certify camera or physical-device behavior.

The Customer build logged Kotlin incremental-cache diagnostics and completed
successfully using the compiler fallback. Both Merchant builds completed without
that diagnostic. Logs are retained. The unmodified paired-build runner was used.
To avoid limited E: capacity, only this task's ignored generated build directory
was temporarily mapped to a fresh owned C: temporary folder. No global Flutter
configuration, SDK cache, earlier worktree or artifact was altered.
The task-owned temporary output and its junction were removed after all copied
APK hashes were verified; delivery artifacts and logs remain available.

Sanitized evidence:
[verification](data/merchant_catalog_session_continuity_verification.json),
[build pair](data/merchant_catalog_session_continuity_build_pair.json).
Source fingerprint:
`e534d5dfad615052509a09296c66046ae7c157539e390192cfa2c0037e1dc501`.

Task-local APKs/logs:
`.buildlog/pilot-device/catalog-session-continuity-20261021/`.
Both paired APKs and the separate Merchant Development artifact were inspected
for identity/callback/signature/source consistency. These are synthetic compilation
rehearsals, **not install/distribution candidates**. The previously delivered
Development pair and transaction/promotion/reward/trust/statement rehearsals were
independently hash-checked unchanged.

Reproduce from the task branch:

```text
flutter test --no-pub --concurrency=2 test/unit/merchant/catalog_session_continuity_test.dart test/unit/merchant/catalog_request_lifetime_test.dart test/widget/merchant/catalog_workspace_continuity_test.dart
flutter test --no-pub --concurrency=2 test/unit/merchant test/widget/merchant test/unit/shop test/widget/notifications
flutter analyze --no-pub
flutter test --no-pub --concurrency=2
```

## Integration and remaining gates

Review the task commit against current main and independently validate before
merging. Merchant Agent commits/pushes only this task branch; main merge/push
belongs to Integration Agent. No hosted Development or Production access/write,
remote migration, provider send or actual account/catalog operation occurred.

Physical two-device QR and selected real merchant/product acceptance remain open;
this package adds no new requirement for the owner's phone. Provider/distribution,
policy and Product Owner pilot-opening gates remain separate. Full pilot readiness
is not claimed by local automated tests or successful compilation.
