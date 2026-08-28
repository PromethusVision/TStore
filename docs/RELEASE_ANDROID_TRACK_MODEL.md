# Android Release Track Model

State: PROPOSED — OWNER REVIEW REQUIRED

## Proposed progression

1. local signed artifact verification;
2. Play internal testing for release plumbing and a small trusted group;
3. closed testing for broader device and upgrade acceptance;
4. Production staged rollout after go/no-go.

Each promotion references the same artifact/version/hash when the store permits it. Rebuilding resets artifact acceptance. Tester accounts and feedback are separated from Production customer data.

Internal or closed distribution does not prove Production readiness. Required evidence still includes signing identity, permission/deep-link checks, clean and upgrade installs, physical QR where applicable, store listing correctness, and monitored rollout.

Recommendation: avoid open testing until product support and privacy handling justify it.

OWNER_DECISION_REQUIRED: choose tester groups, promotion authority, and staged rollout percentages after baseline traffic exists.
