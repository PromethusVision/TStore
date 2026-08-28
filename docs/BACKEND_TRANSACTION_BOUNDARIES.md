# Backend Transaction Boundaries

**State:** PROPOSED CONSISTENCY MAP

| Operation | Must be atomic together | May be eventual |
|---|---|---|
| QR issue | session + immutable item snapshot + active-session invariant | analytics |
| QR confirm | conditional consume + transaction + all items + required source uniqueness | notifications/analytics; outbox fact if adopted must commit atomically |
| Review create/update/delete | row revision + uniqueness/evidence check + authoritative aggregate delta/rebuild marker | analytics/notification |
| Listing mutation | row revision + SKU/variant/shop invariants + idempotency result | search projection/media processing |
| Membership grant/revoke | membership revision + scope/capability + audit reference | session/channel invalidation signal |
| Product merge/split | lineage + status + deterministic mapping set + operation audit | search/analytics rebuild after durable plan |
| Reward mutation | ledger entry + balance/progress projection + redemption reservation | notification/analytics |
| Ops action | domain mutation + decision/audit linkage | external communication |

Do not hold a database transaction open across camera interaction, email/push,
network media processing or third-party calls. Use prepare/reservation/outbox and
reconciliation where a remote side effect is unavoidable.

An event is atomically coupled only when losing it would make a committed domain
fact unrecoverable or unsafe. Exact outbox scope is `OWNER_DECISION_REQUIRED`.
