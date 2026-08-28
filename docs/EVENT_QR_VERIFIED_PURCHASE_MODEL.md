# EsnaftaVar QR Verified Purchase Event Model

**State:** `PROPOSED — PRESERVES EXISTING PRODUCT RIGHTS`

| Event | Producer/authority | Meaning |
|---|---|---|
| `qr_issued` | Trusted server / server authoritative for issuance | Opaque, short-lived token was created for a bounded customer/shop context |
| `qr_scanned` | Merchant client / client reported | Merchant device observed a code; no purchase proof |
| `qr_validation_failed` | Trusted server / server derived | Validation rejected with bounded reason: expired, cancelled, wrong shop, malformed, unauthorized or other governed class |
| `verified_purchase_created` | Trusted server / server authoritative | Atomic validation committed exactly one durable verified-purchase fact |
| `qr_replay_rejected` | Trusted server / server authoritative security/domain outcome | A consumed/terminal token could not create another purchase |

## Authoritative flow

Issue and scan share a correlation/transaction identity without logging the raw
token. The merchant confirmation request carries an idempotency key. The server
checks authentication, shop/staff capability, token integrity/state/expiry/shop
binding and existing outcome in one concurrency-safe boundary. Only the committed
result emits `verified_purchase_created`; retry returns the same terminal outcome.

Failure and replay events record bounded reason, trusted time, shop, request,
release and policy/rule version. They do not include customer contact, item names,
price, token value or secrets. High-volume patterns may feed security detection but
do not automatically punish a customer or merchant.

## Semantics

A verified purchase is evidence of the platform's in-person QR confirmation flow.
It is not online checkout, payment settlement, invoice, audited revenue or proof
that an advertisement caused the visit. Review/reward eligibility may consume it
only under their separately approved, idempotent policies.

`QR_PURCHASE_AUTHORITY: SERVER_AUTHORITATIVE`

