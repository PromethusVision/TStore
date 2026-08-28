# Merchant App QR Wrong Shop Model

Status: **PROPOSED — FAIL CLOSED**
Wave: 17 / WP30

## Rule

A valid token presented by a user who lacks authorization for the token-bound shop, or while another shop context is active, must not be confirmed. Organization-level access does not silently redirect the transaction.

## UX

- Message class: `QR_NOT_VALID_FOR_THIS_SHOP`.
- Do not reveal customer identity, exact other-shop data or token contents.
- If actor is authorized for multiple shops, require explicit switch and a fresh server validation; never auto-switch during confirmation.
- Audit attempted actor, active shop, safe token fingerprint, result class and server time.

## Security

- Wrong-shop attempt does not consume token unless canonical backend contract explicitly reserves it; recommendation is no consume.
- Repeated suspicious attempts can trigger rate/risk controls without changing verification truth.
- Merchant support cannot override shop binding by editing client state.
