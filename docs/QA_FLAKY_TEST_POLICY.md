# Flaky Test Policy

**State:** PROPOSED

## Definition

A test is flaky when identical source, dependencies, environment and declared inputs can produce different outcomes without a product change. A remote provider outage or explicitly unsupported device is an environment failure, not automatically a flaky assertion.

## Handling

1. Preserve first failure evidence: seed, shard, duration, stack, platform and release.
2. Re-run at most once for classification; the original failure remains visible.
3. Determine owner and class: clock/randomness, async race, shared state, order dependence, network, device, resource or real product race.
4. Fix root cause with deterministic clock, awaited signal, isolated fixture or production correction.
5. If immediate isolation is necessary, enter time-bounded quarantine with replacement coverage.

## Prohibited

- infinite retries or “retry until green”;
- broad sleeps as synchronization;
- lowering assertions, swallowing errors or deleting tests;
- permanently excluding a flaky file from all gates;
- counting a retry PASS as equal to first-attempt PASS in quality metrics.

## Metrics

Track first-attempt pass rate, flaky occurrences by root class, quarantine age and recurrence after fix. Do not rank developers by flaky count.

`OWNER_DECISION_REQUIRED: MAX_RETRY_AND_FLAKY_BUDGET`
