# Backend Retry Safety

**State:** PROPOSED

## Classification

- retry transient timeout/unavailable/rate-limit with the same idempotency key and
  bounded exponential backoff/jitter;
- reconcile authoritative state before retry after an ambiguous commit;
- do not retry validation, authorization, wrong-shop, stale revision, policy or
  same-key/different-payload failures blindly;
- quarantine unsupported event/schema versions;
- cap attempts and surface a stable support correlation ID.

Retries always recheck current authorization, suspension, lifecycle and policy.
They never create a second purchase, review, listing, campaign debit, reward entry
or reputation signal. Client retry controls complement database constraints.

Notifications, Realtime and analytics delivery may be at least once; consumers
deduplicate before side effects. Do not roll back a valid purchase merely because
a non-authoritative notification failed.
