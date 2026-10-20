# Merchant review-center session and response recovery

Baseline: `86ac4e970ab9f36e8ca77696da12549127f61596`.
Branch: `agent/merchant-review-recovery`.
Status: **PASS — local package complete; independent integration pending**.
Authority: Product Owner adopted Integration Agent's reliability package.
Canonical §6.2; FROZEN decisions unchanged.

## Reproduced before implementation

Seven failing regression scenarios exposed missing guarantees:

1. A late successful v2 RPC survived same-user S1→S2 replacement.
2. A late failed v2 RPC after replacement was reported as a network error.
3. Queued S1→S2→S1 events revived an old v2 request.
4. Closing and reopening an uncertain Merchant reply lost its request/text.
5. Customer “Güncel durumu kontrol et” discarded the uncertain submission.
6. Customer purchase history accepted a replacement-session response.
7. Shared Customer eligibility accepted rights from the replaced session.

Task-local red logs: `.buildlog/red-regressions.log` (5 failures) and
`.buildlog/customer-red.log` (2 failures, normal-renewal control passing).
The final tests are committed. These scenarios supplement the existing tests;
no existing skip or assertion was weakened.

## Implemented

- Reused `authenticatedSessionKey`, `AuthenticatedRequestScope` and existing
  Auth streams. Event-captured keys prevent queued replacement events from
  reviving old continuations even when the live user/key has returned.
- Applied success/error fences to evaluation RPCs, purchase history and the
  shared Customer review repository. Customer history/review state and open
  legacy editors discard replaced-session private state. Token renewal retains
  valid forms and loaded data.
- Preserved existing Merchant request generations and pagination offsets.
  Detail now re-reads its selected page/filter and matches the exact review root
  before exposing actions. Missing/moved rows fail closed and ask for a center
  refresh; no unbounded scan or new detail RPC was introduced.
- Added one in-memory recovery helper for existing v2 request receipts. It
  retains immutable reply/report/purchase commands across close/reopen and
  read refresh, deduplicates simultaneous sends, and retries the same ID/body.
  Network/invalid-response outcomes stay uncertain; definitive rejection or
  validated receipt clears the pending command. Old completions cannot clear
  a new session's command. Nothing is persisted or replayed automatically.
- The Customer form can explicitly retry the pending receipt after the server
  read marks an entitlement used. This neither creates a new entitlement nor
  claims success from a read; the existing RPC checks exact receipts first.
- Existing layouts, feature flags, verified-purchase provenance, server edit
  window, root reply uniqueness and exact shop ownership remain unchanged.
  No dependency, migration, provider configuration or second system was added.

## Validation

- Full Flutter regression: **3,030 PASS / 0 FAIL / 6 existing conditional SKIP**.
  Baseline was 2,998 PASS: **32 additional tests**, no new skip.
  Final machine log: `.buildlog/flutter-full.jsonl`.
- `flutter analyze --no-pub`: **PASS, no issues**.
- Targeted repository/session/widget coverage includes queued and missed Auth
  changes, stale errors, missing session provenance, narrow layouts, loading,
  detail failure/retry, filter/page races, duplicate sends, refresh/reopen and
  private editor disposal. Existing Customer/review goldens passed unchanged.
- Native PostgreSQL: **17 PASS groups**; [evidence](data/merchant_review_recovery_native_acceptance.json).
- Real local Auth/REST/Storage: **28 PASS groups**; [evidence](data/merchant_review_recovery_managed_acceptance.json).
- Local acceptance runner safety: **4 PASS**.
- Only task-owned ephemeral resources were used; the owned local stack was
  stopped. Existing Docker networks/stacks and historical evidence were retained.
- Existing SQL accepted identical retries without duplicating roots, revisions,
  service evaluations, reply slots or reports, and enforced ownership/privacy.
  No SQL change or remote migration was necessary.
- Android debug builds: **Customer development, Merchant merchantDevelopment,
  and Merchant merchantPilot PASS**. The paired-artifact tool also passed
  **135 compatibility tests** and verified package IDs, callbacks, signatures,
  payloads and unchanged source snapshot. [Pair evidence](data/merchant_review_recovery_build_pair.json).
- New local artifacts are in
  `.buildlog/pilot-device/review-recovery-20261020/`. They use synthetic build
  inputs and are **compile rehearsals, not distributable device candidates**.
  Existing delivered `a0dfbdfd` APK hashes were independently checked unchanged.
- Customer Gradle emitted non-fatal Kotlin incremental-cache diagnostics but
  completed successfully; both package inspection and signature verification
  passed. Task-local diagnostics are retained in `.buildlog/`.
- `git diff --check` and credential/personal-data pattern audit: **PASS**.
  Synthetic local Auth fixtures contain no live credential.
  [Consolidated verification](data/merchant_review_recovery_verification.json).

## Shared areas and limits

Shared files include AuthenticatedRequestScope, dependency injection,
PurchaseEvaluationRepository and the Customer review/history repositories,
cubits and existing form/editor. Other request-scope callers retain their API;
only the new optional captured-key stream extends it.

Recovery is in memory for the current repository/session lifetime. Process
restart loses the payload; reopened screens read server state and never infer
an exact receipt from that read. A report against a superseded immutable
revision is not silently retargeted. A detail row that moved out of its page or
filter requires returning to the center. Transport timeout is not cancellation;
the server may have committed, so explicit retry reuses the original command.

Hosted Development access/writes: **NONE**. Production access/writes: **NONE**.
Remote migration: **NONE**. Main merge/push: **Integration Agent only**.
Previously delivered APK pair: **unchanged**; no public distribution/upload.

Open manual gates remain phone installation, real pilot merchant/products,
physical two-device QR, provider delivery and field acceptance. They are not
required from the Product Owner to continue this independent code package.
