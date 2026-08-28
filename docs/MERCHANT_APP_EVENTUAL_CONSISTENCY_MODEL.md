# Merchant App Eventual Consistency Model

Status: **PROPOSED — NO INFRASTRUCTURE CLAIM**
Wave: 17 / WP75

## Classes

| Class | Examples | Required behavior |
|---|---|---|
| STRONG_OPERATIONAL | QR consume/transaction, authorization, listing revision write | Authoritative response/read-back |
| BOUNDED_CUSTOMER_PROJECTION | Price, availability, shop status/location | Defined propagation target and stale protection |
| ASYNC_ANALYTICS | Views, aggregates, summaries | Freshness/watermark; delayed ≠ zero |
| IMMUTABLE_HISTORY | Verified transaction/item evidence | Append/preserve; never rewritten by current catalog state |

## Conflict/recovery

- Every mutable entity carries revision/updated time sufficient for stale write detection.
- Unknown mutation outcome triggers direct authoritative read before retry.
- Events/projections are idempotent and order-aware; late events do not create duplicates.
- Deactivation/policy blocks require priority invalidation so stale cache cannot authorize action.
- Client polling/realtime is a transport choice, not consistency truth.

Exact latency targets, event bus/realtime mechanism and cache topology remain implementation decisions after backend contract approval.
