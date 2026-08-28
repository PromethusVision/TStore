# Code Coverage Review

**State:** PROPOSED — NO ARBITRARY TARGET

Coverage reveals unexecuted code; it does not prove correct assertions, RLS, device behavior or business invariants.

## Useful

- changed-domain branch/line trends for deterministic Dart logic;
- discovery of untouched error/retry/state branches;
- mapping critical Cubit/repository/parser code to tests;
- review signal when coverage falls materially.

## Misleading

- generated/platform glue;
- trivial getters and visual layout inflation;
- mocked client paths presented as backend proof;
- chasing 100% while physical QR, signing or migration gates remain open.

Recommendation: collect coverage for unit/widget suites, review critical changed-code gaps and establish a baseline before considering thresholds. Exclusions must be explicit and narrow.

OWNER_DECISION_REQUIRED: decide whether V1 CI publishes coverage and who reviews critical gaps; no 100% requirement is proposed.
