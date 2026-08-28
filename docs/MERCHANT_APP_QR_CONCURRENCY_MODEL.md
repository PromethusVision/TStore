# Merchant App QR Concurrency Model

Status: **PROPOSED — SERVER ATOMICITY REQUIRED**  
Wave: 17 / WP33

## Scenario

Two authorized staff members scan and confirm the same token nearly simultaneously, possibly on separate devices.

## Required result

- Exactly one verified transaction and one immutable evidence chain.
- One request wins atomic consume; the other receives existing terminal outcome/conflict.
- No duplicate transaction items, metric increment or review eligibility.
- Both clients can reconcile by token/session status without raw token disclosure.

## Client behavior

- Disable repeated confirmation locally, but never rely on this for correctness.
- Use unique request id plus token/session identity.
- Treat network timeout as unknown; read status before new attempt.
- Clearly distinguish “this attempt created verification” from “already verified earlier”.

## Test dimensions

Same actor/two devices, different authorized staff, wrong-shop actor racing valid actor, expiry boundary, delayed response and process restart.

