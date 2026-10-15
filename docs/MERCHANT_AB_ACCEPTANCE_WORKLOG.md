# Merchant A+B local acceptance and hardening

Authorized: 2026-10-15 (Europe/Istanbul). Baseline:
`e51149ab7c204c00f798c3172bbd32fba7fa853f`.
Task branch: `agent/merchant-ab-acceptance`.

## Objective and boundaries

Close the existing A+B real-service acceptance gaps where a safe local runtime
is available, fix evidenced defects, and deliver reproducible tests and an
Integration Agent handoff. Canonical product rules and accepted Customer UI stay
unchanged. No remote backend access, Production migration, main merge, physical
two-device claim, new review/badge/reward/Ads feature, Docker reset or data loss.

## Completion evidence

- Real local Auth, pgcrypto and independent PostgreSQL connections for claim,
  finalization, returns and revoked ownership/session behavior.
- Real local Storage upload/publish/read with owned listing and a fresh client.
- Relevant automated regressions, analyzer, justified build checks and clean diff.
- Task-only commit/push after checks; explicit report of every unexecuted gate.

If local services cannot be recovered safely, complete the executable acceptance
suite and independent hardening, but keep the real-service gates OPEN. Do not
replace missing evidence with a mock/PGlite success claim. Limit the initial
environment diagnosis to approximately 45 minutes rather than retrying forever.

## Checkpoints

- [x] Verify protected-root boundary, clean original checkout and integrated main.
- [x] Create isolated worktree/branch (managed tool unavailable: Git unavailable).
- [x] Establish local runtime or capture actionable environmental blocker.
- [x] Implement native real-database checks and the separately gated managed suite.
- [x] Verify scoped compatibility; no application defect demonstrated by these checks.
- [x] Final review, documentation and Integration Agent handoff prepared.

Commit/push identity and final working-tree state are recorded in the task result
and Git history; only the task branch is eligible for push.

## Progress

- 01:51 TRT: goal started; main fingerprint verified against origin, no changes.
- Docker Linux engine is initially stopped. Earlier logs show Windows AF_UNIX
  error 1920 in `sailor-ingest.sock`; no general WSL or filesystem health failure
  established. Existing runtime backup is preserved.
- A matching upstream report suggests MSIX AppData virtualization as a possible
  cause, not yet established on this host:
  https://github.com/openai/codex/issues/52698 . Testing normal Windows launch
  without modifying Docker data, permissions or application manifests.
- Normal Windows launch comparisons and the Docker CLI did not resolve the
  startup failure. Failed processes stopped; all data preserved.
- Switched to official portable PostgreSQL 17.11 for independent database proof.
  Resolved test-launcher inherited-output handling and sandbox loopback access.
  Fixed synthetic ownership-test setup to respect the existing one-shop rule.
- 02:08 TRT: 16 native PostgreSQL/pgcrypto/observed-lock-contention groups passed.
  Auth/Storage schemas in that proof are explicitly synthetic, not managed services.
- Managed local CLI config parses; acceptance fails closed before connection while
  Docker is unavailable. Complete HTTP journey is implemented but remains OPEN.
- 3 isolation/transport checks and 227 relevant Flutter regressions passed;
  analyzer reports no issues. No runtime code or new migration needed.

## Docker-restored continuation — 2026-10-15

- Product Owner confirmed Docker repaired and explicitly authorized continuation.
  Verified engine 29.8.2/Linux; remote main remains e51149ab, task branch b014b70a
  has not been merged. Continued in the same clean isolated task worktree.
- The initial CLI stack ignored the bridge's loopback binding option. Guard
  refused acceptance before app migration/fixture writes; owned stack stopped.
  A separate empty-container probe confirmed the host behavior. Added explicit
  pre-creation loopback binding through a short-lived local Docker socket proxy.
- Fixed the proxy's handling of project-labeled Auth/Storage bootstrap jobs and
  Docker attach headers that must arrive before a container produces output.
  Added real local-socket regression checks; no global Docker setting changed.
- First managed acceptance passed 19 groups; its final assertion incorrectly
  expected capability metadata to enforce live-session provenance. Replaced it
  with an actual claimed QR logout/complete/reconcile denial test and added a
  complete HTTP cart/manual-code/purchase/return journey. Product code unchanged.
- 12:20 TRT: fresh managed run passed **21 groups**; sanitized evidence records
  exact images, binding addresses and migration hashes. Actual Auth JWTs, real
  Storage bytes and transaction HTTP endpoints were exercised. Physical J OPEN.
- Native initialization failed once before server start during concurrent setup;
  no server was left running. Added bounded initialization allowance and stage
  diagnostics; fresh sequential run passed **16 groups** and stopped normally.
- Final harness checks **5 PASS**, JavaScript syntax checks PASS, Flutter analyzer
  clean. Prior b014b70a's 227 Flutter regressions remain applicable; no Flutter
  source or dependency changes, no additional UI acceptance claim.
- All task stacks stopped with data retained. No remote backend access, migration
  apply, Production write, main merge or deferred feature activation.
