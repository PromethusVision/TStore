# Release Candidate Test Suite

**State:** PROPOSED

## Immutable candidate inputs

Commit, version/build, environment contract, migration/API revision, feature flags, signed certificate identity and artifact hash are frozen before acceptance. Rebuilding after a test produces a new candidate.

## Required evidence

- full deterministic regression and clean analyzer;
- backend/client compatibility across supported installed versions;
- migration precheck/dry-run/postcheck evidence when schema changes;
- exact signed Android AAB/APK and iOS archive/TestFlight candidate identity;
- clean install and upgrade install;
- Auth/deep-link, location, Cart/Review and two-device QR matrices;
- privacy/secret/dependency checks;
- startup/crash/error and critical RPC observability by release;
- open defects, skips, owner decisions and rollback/kill-switch readiness;
- authorized go/no-go record.

## Separation

Compile-only web or unsigned mobile output is useful engineering evidence but not a signed release candidate. Production smoke tests the exact artifact/config; it never repairs or migrates Production.

`RELEASE_CANDIDATE_CERTIFIED: NO`
