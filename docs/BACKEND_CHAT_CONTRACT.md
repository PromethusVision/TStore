# Backend Chat Contract

**State:** EVOLVE CURRENT DIRECT CHAT, DO NOT REBUILD

Current `chat_messages` models authenticated sender/receiver, pagination, stable
identity, read revision and Realtime reconciliation. Keep this Customer App
behavior while Merchant App requirements mature.

## Future bridge

A merchant conversation may additionally bind shop, customer and assigned merchant
membership/staff context. Organization membership alone must not expose every
conversation. Sender identity is server-derived; shop/customer reassignment is not
an ordinary message edit.

## Invariants

- participants/assignment can read; others cannot infer thread existence;
- message text is bounded and treated as private content, never analytics/audit
  payload;
- send validates active relationship/policy and uses idempotency;
- edit/delete/moderation, if introduced, preserves revision/history under policy;
- late page and Realtime results deduplicate by stable message ID/revision;
- shop suspension or staff revocation blocks new merchant sends while preserving a
  customer-safe history/support path.

Thread entity, attachments, retention and merchant assignment UX are
`OWNER_DECISION_REQUIRED`. Do not create them merely for architectural symmetry.

