# Test Data Cleanup Model

**State:** PROPOSED — NO CLEANUP EXECUTED

## Cleanup contract

1. Register exact created IDs and dependency relationships during setup.
2. Reconcile unknown outcomes before cleanup.
3. Verify environment, run marker, owner principal and expected maximum count.
4. Delete/deactivate children before parents according to approved lifecycle.
5. Refuse broad name-prefix, wildcard, table-wide or unscoped cleanup.
6. Confirm account/session, domain rows, Storage objects, Realtime subscriptions and analytics classification.
7. Emit residual counts without printing PII or secrets.

## Failure modes

If a row has an unexpected non-test dependency, owner mismatch, missing marker or count overflow, cleanup stops. The run is `CLEANUP_BLOCKED`, evidence is retained safely and no compensating broad deletion is attempted.

## Lifecycle choices

Hard deletion is appropriate only for disposable test-owned environments and entities whose contract permits it. Immutable transaction/audit/event tests may require test-environment reset or explicit invalidation rather than history deletion. Production demo retirement is a separate owner-authorized product operation.

## CI requirement

Setup and teardown both need idempotency. A scheduled residual monitor may report abandoned prefixes, but automated destructive cleanup requires an exact manifest and environment allowlist.

`CLEANUP_BY_PREFIX_ONLY: PROHIBITED`
