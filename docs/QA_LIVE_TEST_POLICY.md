# Live Test Policy

**State:** PROPOSED — NO LIVE TEST EXECUTED

## Eligibility

A live test is justified only for provider/control-plane behavior that local mocks cannot prove: hosted Auth/email, RLS/grants, Realtime delivery, Storage policy, actual RPC concurrency or store callback. It must be explicitly opt-in and environment-specific.

## Required envelope

- exact project/app environment checked before secret access;
- synthetic unique run ID and independent actor sessions;
- bounded time/request/row budget;
- no secret, email, token, raw QR or payload logging;
- deterministic expected state and authoritative reconciliation after timeout;
- exact cleanup/residual report;
- test traffic classification and analytics exclusion.

## CI placement

Live Development tests are not PR jobs for untrusted code. Candidate execution is manual or protected scheduled/main job with least-privilege secrets. Production is read-only by default and never a load/adversarial target.

## Failure classes

`PRODUCT_CONTRACT_FAIL`, `ENVIRONMENT_CONFIG_FAIL`, `PROVIDER_OUTAGE`, `CLEANUP_BLOCKED` and `TEST_DEFECT` remain distinct. Only the first is a direct product regression, but none is silently converted to PASS.

`LIVE_TEST_DEFAULT: OFF`
