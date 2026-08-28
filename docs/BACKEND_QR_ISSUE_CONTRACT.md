# Backend QR Issue Contract

**State:** PRESERVES ACTIVE QR CONTRACT — DESIGN ONLY

## Caller and authority

An authenticated customer may request a QR session for their active Cart V2. The
server issues the opaque token after validating customer ownership, one-shop cart,
active shop/listings, bounded quantities and a coherent snapshot. The client does
not generate or choose the token.

## Issued subject

The session references customer, shop, source cart, expiry, item/listing/product
snapshot and lifecycle. It is an invitation to merchant confirmation, not payment,
reservation, stock guarantee, review eligibility or purchase evidence.

## Rules

- cryptographically opaque token; no email, profile, item or price encoded for
  camera disclosure;
- short expiry consistent with the current approximately two-minute contract;
- at most the allowed active session set for the bounded customer/cart context;
- request idempotency returns the same eligible issue result or a defined conflict;
- raw token is never written to analytics/audit/logs;
- customer-safe summary is returned separately from token identity;
- session snapshots are immutable; changed cart requires a new/reconfirmed issue.

Exact reissue/cancel policy remains `OWNER_DECISION_REQUIRED`; recommendation is
to terminally cancel the prior active session when a materially changed cart is
explicitly reissued.
