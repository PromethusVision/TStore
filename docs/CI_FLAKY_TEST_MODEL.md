# CI Flaky Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

CI detects flakiness through preserved first results, repeated controlled runs, and fingerprints. Automatic rerun may gather diagnosis but must not turn a failure green silently.

## Flow

1. classify reproducibility and environment dependence;
2. link owner, issue, first failure, and observed rate;
3. fix clocks, randomness, ordering, network, lifecycle, and shared-state roots;
4. quarantine only under the narrow QA quarantine contract;
5. keep critical security/invariant tests blocking;
6. restore after repeated clean evidence and close the record.

Dashboards show flake rate, age, affected gate, and rerun cost. Test deletion or permanent skip is not remediation.

OWNER_DECISION_REQUIRED: set quarantine approval and maximum age.
