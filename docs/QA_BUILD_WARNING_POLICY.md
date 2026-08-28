# Build Warning Policy

State: PROPOSED — OWNER REVIEW REQUIRED

Warnings are classified, owned, and time-bounded; they are not hidden with broad flags.

## Classes

- release/security/correctness: blocking;
- deprecated API/toolchain with known deadline: planned remediation;
- generated/third-party noise: narrowly documented suppression if no owned fix;
- platform/store advisory: reviewed against supported targets;
- flaky environmental warning: investigated, not normalized.

Each accepted warning records exact message/fingerprint, affected configuration, owner, reason, expiry/review, and evidence that it is harmless. New warnings fail the release gate until classified.

Build scripts must propagate exit codes. The current Android Fastlane use of `|| echo` can mask build failure and must not be treated as release authority until corrected in a separately authorized runtime/tooling change.

OWNER_DECISION_REQUIRED: approve zero-new-warning policy and remediation ownership.
