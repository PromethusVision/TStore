# Backend Chat Idempotency

**State:** PROPOSED HARDENING

A send request carries a client-generated opaque idempotency key scoped to sender,
conversation/recipient context and operation. The server stores normalized content
hash and committed message ID.

- same key/same content returns the original message;
- same key/different recipient/content rejects conflict;
- two different keys create two messages intentionally unless product duplicate
  heuristics only warn;
- timeout reconciliation queries message by safe idempotency outcome;
- Realtime duplicate replaces/merges the same message ID, never appends another;
- authorization and staff assignment are rechecked before new execution;
- failed send preserves client draft but creates no phantom message.

Read receipts also use monotonic state/revision and tolerate duplicate delivery.
Idempotency keys and message content have separate privacy/retention. Spam/rate
controls complement but do not replace ownership or duplicate protection.

