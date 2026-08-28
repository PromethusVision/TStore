# Merchant App QR Expiry Model

Status: **PROPOSED — CURRENT CONTRACT APPROXIMATELY TWO MINUTES**
Wave: 17 / WP31

## Authority

Expiry is calculated and enforced by server time. Customer or merchant device clock, animation and cached countdown are advisory only.

## Behavior

- Merchant validation before expiry does not guarantee a later confirmation if expiry occurs before atomic consume; exact reservation semantics are an owner/backend decision.
- Expired token returns a stable terminal result and creates no verified transaction.
- Customer is guided to generate a new QR; old token remains unusable.
- Network retry sends same idempotency context, but expiry is still evaluated authoritatively.
- UI may show remaining time only from server-derived expiry and should tolerate clock skew.

## Security/usability trade-off

Current short-lived contract is approximately two minutes. Changing TTL is `OWNER_DECISION_REQUIRED`; do not lengthen it in the client to solve scanning friction.
