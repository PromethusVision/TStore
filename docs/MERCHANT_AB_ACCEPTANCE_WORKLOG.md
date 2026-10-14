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
