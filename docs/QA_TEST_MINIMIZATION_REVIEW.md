# Test Minimization Review

**State:** STATIC REVIEW — NO TEST DELETED OR WEAKENED

## Repository evidence

Current inventory has 130 Dart test files: 58 unit, 59 widget, 6 architecture/static, 3 controlled integration, 3 opt-in live and one root smoke. No tracked `integration_test/` exists.

## Keep

- Auth confirmation/recovery/callback and user-switch lifecycle;
- discovery stale-result/duplicate navigation behavior;
- location/cart/review/QR eligibility, RLS/RPC and concurrency;
- platform identity/signing/migration static contracts;
- live tests opt-in and physically honest.

## Consolidation candidates—review before action

- shared widget pumps/fakes repeated across closely related screen tests;
- overlapping architecture scans that can share a parser but retain distinct assertions;
- repeated success-path repository mocks where a stronger contract fixture can cover mapping;
- broad full-suite reruns for docs-only changes.

## Change layer

Move authorization/invariant proof from mocks to RLS/RPC contract tests; keep widget tests for presentation/state. Defer broad goldens, mutation/fuzz, nightly and E2E until stable need. No current file is declared safe to delete without a line-level behavior map.

`TESTS_REMOVED: 0`
