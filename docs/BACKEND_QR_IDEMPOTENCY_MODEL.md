# Backend QR Idempotency Model

**State:** PROPOSED HARDENING OF ACTIVE CONTRACT

## Identities

- QR session/token surrogate: one consumable business subject;
- confirmation idempotency key: one logical caller attempt;
- verified transaction ID: one committed outcome;
- correlation ID: diagnostics only.

They are not interchangeable.

## Behavior

| Situation | Result |
|---|---|
| Same key, same payload, original committed | Return original transaction outcome |
| Same key, original in progress | Wait/reconcile or return bounded in-progress result |
| Same key, different shop/payload | Reject conflict and audit |
| Different key, same active session | One may commit; others return used/original terminal outcome |
| Timeout after unknown commit | Query authoritative session/transaction before retry |
| Replay after terminal state | Reject without a new transaction/review/reward effect |

Keys are scoped to authenticated merchant membership, shop and operation. Retention
must cover token/retry/audit risk; irreversible purchase uniqueness ultimately
rests on the source-session constraint, not key expiry.
