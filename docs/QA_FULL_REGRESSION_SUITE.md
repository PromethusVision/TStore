# Full Regression Suite

**State:** PROPOSED

## Trigger

Run before main integration, release candidate cut, high-risk shared changes and after dependency/platform upgrades. It may also run nightly only if duration/cost evidence justifies it.

## Contents

1. Clean dependency/environment identity record.
2. Format, analyzer and all non-live Flutter tests.
3. Static architecture, release, Auth callback, review and migration contracts.
4. Deterministic generated artifact checks.
5. Local clean-room migration/RLS/RPC suite once standardized.
6. Development live contracts only in a separately authorized isolated job.
7. Platform compile checks appropriate to changed code.
8. Secret/dependency scan and complete skip/quarantine report.

## Baseline

Wave 16 recorded `1226 PASS / 0 FAIL / 6 explicit live skips`; WAVE 22 does not rerun or promote that historical result. Future reports compare totals only after confirming test inventory and skip set did not shrink unexpectedly.

## Failure policy

Any deterministic failure blocks promotion. A remote provider outage is classified separately but does not become automatic PASS; retry is bounded and evidence preserved.

`FULL_REGRESSION_CURRENT_RUN: NOT_RUN`
