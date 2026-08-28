# Location Release Acceptance

State: PROPOSED — OWNER REVIEW REQUIRED

## Matrix

- permission not requested, allowed, denied, and denied forever;
- OS location service disabled and restored;
- precise/approximate where supported;
- unavailable, stale, implausible, and timeout results;
- cold start, background/resume, and account switch;
- Wi-Fi/mobile transition and offline fallback;
- nearby result ordering and safe no-location UX.

The client should explain why permission is needed, avoid request loops, and not imply precision it lacks. Location must not leak into logs, screenshots, analytics, or support beyond the approved minimization contract.

Automated mocks cover state transitions; at least one real Android and iOS device validates OS dialogs/GPS behavior when those platforms ship.

OWNER_DECISION_REQUIRED: approve acceptable approximate-location behavior and physical device coverage.
