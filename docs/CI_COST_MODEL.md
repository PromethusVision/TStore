# CI Cost Model

State: PROPOSED — OWNER REVIEW REQUIRED

CI cost includes hosted minutes, storage/egress, macOS premium, runner maintenance, developer wait time, flaky reruns, and incident risk—not only subscription price.

## Lean controls

- change-aware jobs without skipping shared-contract risks;
- fast PR gate, fuller main/RC, scheduled expensive suites only when valuable;
- cancel superseded branch runs;
- safe immutable caches and short artifact retention;
- shard only after measured bottlenecks;
- macOS only for iOS-specific build/tests;
- live/physical tests outside untrusted PRs;
- publish timing, queue, pass, and rerun metrics.

Never save cost by hiding failures, sharing Production secrets, or accepting untested release artifacts.

OWNER_DECISION_REQUIRED: approve monthly budget and maximum acceptable PR feedback time after baseline measurements.
