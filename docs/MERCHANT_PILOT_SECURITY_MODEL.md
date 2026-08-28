# Merchant Pilot Security Model

State: `PROPOSED — FAIL-CLOSED`

## Assets and threats

Protected assets are merchant/shop authority, listing truth, QR token/session, immutable price snapshot, verified purchase evidence, customer privacy and audit history. Primary threats: role escalation, cross-shop IDOR, shared credentials, stolen device/session, replay/concurrency, QR collusion, operator overreach, stale price, catalog poisoning and log/notification PII.

## Required controls

- Every mutation and sensitive read re-authorizes on the server; UI hiding is only UX.
- Exact shop/listing identifiers come from authorized server scope, never trusted client claims.
- Capability/lifecycle/policy state is checked at execution time, including after preview.
- QR tokens are opaque, high entropy, short lived, redacted from logs and single-use.
- Confirm is atomic and idempotent; one concurrent winner.
- Listing writes use value validation, expected revision and idempotency key.
- Session/user/shop switch invalidates in-flight client work and cached sensitive state.
- Sensitive responses expose no customer email, phone, precise location or auth metadata.
- High-risk changes and denials get correlation IDs; secrets/tokens stay out of analytics.
- Suspended/unverified/unknown states deny, not optimistically permit.

## Abuse signals, not automatic guilt

Repeat QR attempts, many customer accounts per device/shop, impossible cadence, operator-assisted changes immediately before purchases and unusual correction volume may open a case. These signals cannot alone erase history, punish a merchant or affect customer-visible reputation. Human review and appeal are separate.

## Device loss

Merchant can revoke sessions through supported auth controls; support verifies identity without password. A stolen device must not retain usable QR preview/history after session revoke. Local storage must not persist raw tokens or unnecessary customer evidence.

## Security acceptance

Cross-shop read/write/confirm, customer-as-merchant, suspended merchant, stale session, duplicate tap, real concurrent confirm, token replay, malformed QR and operator bypass all deny. Any positive path that only succeeds due to client role checks is a release blocker.
