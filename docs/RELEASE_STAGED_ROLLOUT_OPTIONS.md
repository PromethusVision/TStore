# Staged Rollout Options

State: PROPOSED — OWNER REVIEW REQUIRED

Staged rollout reduces blast radius but does not replace candidate testing. Android and iOS store mechanics differ, and a percentage is not a promise about a specific user cohort.

## Proposed control loop

1. start with an owner-approved small cohort;
2. observe crash-free use, auth, RPC, QR, latency, support, and integrity signals;
3. pause on predetermined P0/P1 triggers;
4. expand only after an explicit review;
5. retain a corrected-build and communication path.

Percentages and observation windows must follow real traffic baselines. Low traffic may require longer observation or targeted tester evidence. Backend compatibility must support old and new clients throughout.

OWNER_DECISION_REQUIRED: set platform-specific stages, minimum evidence, and pause/resume authority.
