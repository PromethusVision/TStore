# QA Test Metric Model

**State:** PROPOSED — OWNER REVIEW REQUIRED

Metrics support decisions; they are not productivity scores.

## Useful measures

- first-run pass/fail by required gate and critical journey;
- deterministic runtime, queue delay and time-to-actionable-result;
- flake rate, age, reruns and quarantine debt;
- critical-journey/invariant coverage mapped to evidence layers;
- escaped P0/P1 defects and detection source;
- defect reopen/recurrence and regression-protection completion;
- physical/manual gate completion and evidence freshness;
- test maintenance cost for low-value suites.

Raw test count, assertion count, lines covered or green percentage alone are vanity metrics. Report trend, denominator, environment, exclusions/skips and uncertainty. Never rank agents by defect or test volume.

OWNER_DECISION_REQUIRED: approve a small pilot dashboard and review cadence after CI baseline exists.
