# Remote Test Safety

**State:** REQUIRED GUARDRAIL — NO REMOTE EXECUTION

## Before connection

1. Require explicit opt-in flag and exact expected environment.
2. Validate URL host/project ref before reading or constructing credentials.
3. Refuse Production for any mutation-capable harness unless the task contains explicit authorization.
4. Use client-safe key for client tests; service role never enters Flutter, fixtures or logs.
5. Allocate unique run prefix and record only opaque test IDs.

## During execution

- Use independent sessions for independent actors.
- Bound row count, time, rate and concurrent requests.
- Never enumerate or modify non-prefixed subjects.
- Treat timeout as unknown outcome; reconcile before retry.
- Mark test traffic at a trusted account/config boundary.
- Capture safe result classes without email, token, raw QR, location or payload.

## Cleanup

Cleanup is exact-ID and dependency-aware. Verify expected ownership and count before delete. Unexpected dependencies stop cleanup; broad wildcard or table-wide delete is prohibited. Residuals become a cleanup incident, not justification for unsafe deletion.

## Production

Read-only smoke selects minimal public/health projections and has strict request budgets. Adversarial RLS, concurrency, expiry, invalid-token and load tests belong to local/Development. Production account creation, seed, reset, migration apply and Storage mutation are never implicit CI steps.

`REMOTE_TEST_FAIL_CLOSED: REQUIRED`
