# Merchant App QR Offline Model

Status: **PROPOSED — FAIL CLOSED FOR CONFIRMATION**
Wave: 17 / WP34

## Recommendation

QR validation and confirmation require connectivity. Offline confirmation queues are not allowed because expiry, replay, wrong-shop, role and concurrency checks are server-authoritative.

## Offline behavior

- Camera may recognize an opaque QR locally but must label it unvalidated.
- No purchase context is trusted or displayed from decoded client payload.
- No “will confirm later” success state and no offline verified transaction.
- Preserve no raw token beyond the minimum retry lifecycle; after reconnection require fresh validation and server expiry check.
- Previously cached QR success may be shown only as historical read with freshness, never as new confirmation authority.

## UX

Show `CONNECTION_REQUIRED_FOR_VERIFICATION` with retry and safe cancel. Do not blame QR/customer. If connectivity returns after token expiry, server rejects and customer generates a new token.
