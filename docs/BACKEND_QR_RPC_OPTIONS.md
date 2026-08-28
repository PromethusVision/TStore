# Backend QR RPC Options

**State:** PRESERVE AND HARDEN CURRENT RPC FAMILY

Recommended bounded operations:

- issue QR from current customer's active cart;
- read minimal verification preview for authorized exact-shop verifier;
- confirm with idempotency key and expected contract version;
- cancel current customer's still-active session;
- reconcile terminal status after timeout.

Issue and confirm are transactions; preview/reconcile are authorized reads.
Generic QR row writes and client-selected customer/shop/verified flags remain
prohibited.

Responses should distinguish success, expired, cancelled, wrong shop,
unauthorized, already consumed/original outcome, stale summary and transient
unavailable without revealing other customer's data. Confirm returns one stable
transaction identity. An outbox/event publication may follow the same transaction,
but analytics delivery is not part of purchase correctness.

Whether cancellation is a distinct RPC and whether a stale cart can be reconfirmed
are `OWNER_DECISION_REQUIRED`; recommendation is explicit reissue for material
changes.

