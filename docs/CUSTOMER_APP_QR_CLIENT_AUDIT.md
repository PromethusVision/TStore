# Customer App QR Client Audit

Status: LOGICAL CLIENT PASS; PHYSICAL TWO-DEVICE GATE OPEN

## Customer QR contract

- Authenticated Cart V2 creates an opaque, short-lived QR session through the canonical RPC.
- Client displays only the server token/QR representation and customer-safe summary; it does not encode profile, email, item, price, or secret data directly.
- Missing/invalid summary or invalid totals hide the QR.
- Server total or item-count changes require explicit customer reconfirmation.
- A visible countdown/status poll handles the approximately two-minute expiry; local and server expiry converge on the same safe state.
- Poll timeout keeps the QR visible with connectivity guidance; recovery removes the warning.
- Confirmed state closes the waiting path, refreshes Cart/Purchases, and offers the verified-rating action.
- Cancelled/expired sessions cannot be treated as success; retry/renew operations are de-duplicated.

## Verifier client contract

- Camera permission/scanner lifecycle is bounded to the verifier view.
- Confirmation Cubit prevents a second submission after success and reconciles an ambiguous timeout through authoritative session state.
- Wrong-merchant, replay, expiry, and backend rejection are mapped from the canonical RPC; client checks are not treated as security boundaries.

## Acceptance classification

Unit/widget/database contract evidence covers state logic, but the following remain one physical gate: two distinct devices, real camera scan, wrong merchant, replay, concurrent double confirmation, exactly one verified transaction, durable `product_id`, and customer state refresh. Demo Production shops cannot run this because their owner is null. Do not fake PASS.

`QR_CLIENT_AUDIT: PASS`
`QR_TOKEN_OPAQUE: PASS`
`PHYSICAL_TWO_DEVICE_ACCEPTANCE: BLOCKED`
