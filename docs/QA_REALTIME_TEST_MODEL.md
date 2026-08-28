# Realtime Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

Realtime is an optimization for freshness; authorization and durable truth remain server-side.

## Scenarios

- initial fetch then subscribe without gap/duplicate;
- reconnect after network drop, token refresh, background/resume, and account switch;
- out-of-order, duplicate, delayed, deleted, and unauthorized events;
- rapid subscribe/unsubscribe and screen disposal;
- channel isolation across customers, merchants, shops, and operator roles;
- fallback polling/manual refresh when realtime is unavailable.

Assertions cover stable identity, ordering/version conflict policy, no stale state after user switch, bounded retries, subscription cleanup, and redacted diagnostics. Mocks cover client reducers; authorized live Development tests prove service behavior.

OWNER_DECISION_REQUIRED: define which V1 features require realtime versus refresh-only behavior.
