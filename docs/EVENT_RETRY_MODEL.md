# EsnaftaVar Event Retry Model

**State:** `PROPOSED — AT-LEAST-ONCE SAFE`

Delivery is assumed at least once. Producers retry transient failures with bounded
exponential backoff and jitter; consumers deduplicate durable event IDs before
side effects. Retry count does not become a business metric.

| Failure | Action |
|---|---|
| Timeout/temporary unavailable | Retry with same event and idempotency identity |
| Rate limit | Respect bounded retry guidance and backpressure |
| Invalid schema/unsupported version | Quarantine; no blind retry loop |
| Authorization/environment mismatch | Reject, security/audit signal; no fallback |
| Consumer bug | Pause/quarantine partition, preserve evidence, alert owner |
| Permanent policy rejection | Terminal result with bounded reason |

Dead-letter/quarantine records store event reference, producer, type/version,
failure class, attempts and timestamps—not unrestricted payloads or secrets.
Replay requires authorization, dry validation, rate limit and idempotent consumers.

Verified purchase, reward, badge, ad billing and reputation correctness resides in
authoritative constraints, never a hope that the broker delivers exactly once.

`DELIVERY_SEMANTICS: AT_LEAST_ONCE_ASSUMED`

