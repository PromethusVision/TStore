# Network Condition Matrix

**State:** PROPOSED

| Condition | Read expectation | Mutation expectation | Evidence |
|---|---|---|---|
| Offline at launch | safe cached/empty/error state; no crash | disabled or queued only if explicitly designed | no hidden retry storm |
| Slow response | visible bounded loading and cancel/stale protection | single in-flight action | duration and state sequence |
| Timeout before server receipt | retry offered | new attempt allowed under idempotency | authoritative state check |
| Timeout after unknown commit | refresh/reconcile | do not create a new logical command blindly | original result or explicit unknown |
| Connection drops mid-stream | preserve usable prior state | no partial client success | subscription/retry state |
| Wi‑Fi → mobile | reconnect once and refresh current scope | idempotent replay only | duplicate count zero |
| Mobile → Wi‑Fi | same | same | current session preserved |
| Out-of-order responses | latest generation wins | server revision/idempotency wins | stale result rejected |
| 4xx typed denial | safe Turkish action | no retry loop | no raw backend detail |
| 5xx/provider outage | retry/backoff and organic/core fallback | no optimistic authoritative success | alert/correlation class |

## Critical journeys

Auth callback/recovery, Home/search/nearby, product/sellers, cart replacement, QR create/confirm/reconcile, review mutation, chat/notifications and future merchant price/availability each exercise the applicable rows.

Network shaping tools are implementation choices. Tests wait on observable state rather than fixed sleeps.

`OWNER_DECISION_REQUIRED: OFFLINE_WRITE_SCOPE`
