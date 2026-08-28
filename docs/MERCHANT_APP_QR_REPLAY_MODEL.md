# Merchant App QR Replay Model

Status: **PROPOSED — EXACTLY-ONCE OUTCOME REQUIRED**  
Wave: 17 / WP32

## Contract

The first eligible atomic confirmation consumes the token and creates at most one verified transaction. Every later scan/confirm returns the existing terminal status without creating another transaction or review right.

## Controls

- Unique token fingerprint/nonce and server-side consumed state.
- Atomic consume plus transaction/item evidence creation.
- Idempotency key handles duplicated requests; token uniqueness handles different clients.
- Durable audit links successful and replay attempts without exposing raw token.
- Raw QR/token is never logged in analytics/support output.

## UX

- Same staff retry after unknown timeout: reconcile and show “already verified” as successful prior outcome when authorized.
- Unrelated actor replay: generic already-used/invalid message, minimized context.
- Customer UI refreshes authoritative session/result; it does not assume success from scanner UI.

