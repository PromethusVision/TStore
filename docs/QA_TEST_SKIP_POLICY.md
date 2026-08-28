# Test Skip Governance

**State:** PROPOSED

Every skip must declare:

- exact test/path and reason;
- class: `LIVE_OPT_IN`, `PLATFORM_UNAVAILABLE`, `TEMPORARY_DEFECT`, or `FUTURE_FEATURE`;
- owner and evidence link;
- environment/platform scope;
- review or expiry date for temporary skips;
- replacement evidence and release impact.

## Rules

`LIVE_OPT_IN` skips may remain in the default local suite when their dedicated job proves them. `FUTURE_FEATURE` tests should usually not be executable tests until the contract is enabled. A deterministic regression cannot be changed to skip merely to restore green.

CI compares skip inventory and count to the approved baseline. New or broadened skips require review. A skipped physical/manual gate stays `OPEN`, never `PASS`.

## Current repository

Five source skip declarations gate the controlled remote suites; the Wave 16 baseline reported six skipped cases. WAVE 22 did not rerun them. Future inventory should record test-case-level IDs so file declarations and runner counts reconcile automatically.

`SKIP_COUNT_INCREASE_REQUIRES_REVIEW: YES`
