# EsnaftaVar Event Idempotency Model

**State:** `PROPOSED — NO TRANSPORT/SCHEMA SELECTED`

Idempotency protects a business outcome from repeated commands and protects every
consumer from repeated delivery. `event_id`, `idempotency_key` and
`correlation_id` are distinct:

- `idempotency_key`: one logical command/outcome boundary;
- `event_id`: one immutable committed fact;
- `correlation_id`: related events in a bounded journey/transaction.

| Outcome | Required deduplication identity | Invariant |
|---|---|---|
| Verified purchase | QR transaction/token surrogate + confirmation idempotency key | At most one purchase fact |
| Reward ledger entry | reward account + source event + policy version + entry kind | Replay cannot duplicate value |
| Badge/grant | subject + achievement + rule version + qualifying period/source | One governed grant |
| Ad billing fact | campaign/revision + qualified source event + pricing rule version | Measurement retry cannot double bill |
| Reputation evidence | source event + signal/rule version | Projection replay does not amplify evidence |

Producers persist outcome and event atomically where correctness requires it.
Consumers maintain a processed-event ledger or equivalent durable constraint for
their own projection. A duplicate returns/records the original result; it does not
emit a second semantically identical outcome.

Payload mismatch under the same idempotency key is rejected and audited. Keys have
a scope and retention at least as long as retry/replay risk; expiry is not assumed
safe for irreversible ledgers. Exact runtime mechanisms remain open.

`EXACTLY_ONCE_TRANSPORT_ASSUMED: NO`

