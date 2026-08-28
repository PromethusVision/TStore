# Backend Realtime Contract Audit

**State:** REPOSITORY-EVIDENCED CURRENT + PROPOSED FUTURE

## Current

Migration `0007` requires the managed Supabase Realtime publication and adds
`chat_messages` and `notifications`. The Customer App subscribes to authenticated,
customer-filtered streams and reconciles them with paginated reads. Realtime is a
delivery hint/projection; durable table/RPC state wins after gaps, duplicates or
reconnect.

## Not currently present

There is no canonical merchant organization/shop channel, listing operations
stream, QR operator stream, ads, rewards, reputation, ops case or general event
bus publication. Their absence is not a Customer App defect.

## Future criteria

Publish a table/change only if freshness materially improves the product and row
authorization, payload minimization, reconnect/reconciliation, fan-out and cost
are understood. High-risk purchase/reward/ops state should normally expose a
bounded projection/event, not unrestricted raw rows.

Every channel needs owner subject, filter identity, event revision, duplicate/
ordering rules, unsubscribe/user-switch behavior and authoritative refresh path.
Adding tables to a publication requires a separate migration and Development
security test.

