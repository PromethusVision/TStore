# Startup Performance Model

State: PROPOSED — OWNER REVIEW REQUIRED

Measure cold, warm, and resumed startup separately on release-mode physical devices.

## Checkpoints

- process start to first frame;
- usable shell and first meaningful customer content;
- session restoration/token refresh;
- remote configuration/location permission behavior;
- offline and slow-network fallback;
- memory and crash/ANR during startup.

Tests use clean and returning-user states, guest/authenticated sessions, expired credentials, and low-end representative Android plus supported iOS. Startup must not block indefinitely on analytics, notification setup, location, or nonessential network work.

Results include commit/artifact hash, device/OS, run count, median/tail, cache/network state, and trace evidence stripped of PII.

OWNER_DECISION_REQUIRED: set budgets after a signed-candidate baseline exists.
