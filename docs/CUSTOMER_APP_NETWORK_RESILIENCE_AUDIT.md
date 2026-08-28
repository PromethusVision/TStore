# Customer App Network Resilience Audit

Status: PASS FOR LOCAL CONTRACT

## Common behavior

- Data repositories wrap Supabase/network exceptions in `Either` or typed failures.
- `CustomerErrorMessage` maps Auth, timeout, connectivity, permission, not-found, and unexpected failures to bounded Turkish messages without raw server detail.
- Views distinguish first-load failure from refresh/append/action failure so usable snapshots are retained.
- Retry paths repeat the authoritative query/action and do not manufacture success.
- Search, Nearby, Cart, Notifications, Chat, Purchases, Reviews, and Wishlist use generation/request/revision guards where stale responses could cross refresh or identity boundaries.

## Failure classes

| Failure | Expected response |
| --- | --- |
| Timeout/offline/connection reset | Safe message; retry; visible snapshot retained when available. |
| Supabase/Postgrest/Auth exception | Typed/customer-safe mapping; backend details not rendered. |
| Unexpected payload | Repository parsing returns safe failure rather than unchecked UI cast in audited critical RPCs. |
| Stale response | Request generation, IDs, revisions, or mounted/closed checks suppress it. |
| Rapid reconnect | Realtime feeds reconcile by entity ID; manual/silent refresh deduplicates. |
| Ambiguous QR confirmation timeout | Authoritative session-status reconciliation; never blind retry-after-success. |

Remote fault injection was not authorized. Existing mocks cover timeout/error/stale/reconnect-like transitions; Production/Development were not contacted.

`NETWORK_RESILIENCE_AUDIT: PASS`
`UNCAUGHT_CRITICAL_NETWORK_EXCEPTION: NONE_FOUND`
