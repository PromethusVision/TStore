# Merchant App QR Scan Flow

Status: **PROPOSED — SERVER-AUTHORITATIVE**  
Wave: 17 / WP28

## Flow

```text
ACTIVE SHOP CONTEXT
 -> CAMERA PERMISSION
 -> SCAN OPAQUE TOKEN
 -> SERVER VALIDATE
 -> SHOW MINIMIZED PURCHASE CONTEXT
 -> EXPLICIT MERCHANT CONFIRM
 -> IDEMPOTENT SERVER CONFIRMATION
 -> AUTHORITATIVE RESULT / RECONCILIATION
```

## States

- `READY_TO_SCAN`, `SCANNING`, `VALIDATING`, `AWAITING_CONFIRMATION`, `CONFIRMING`.
- Terminal: `VERIFIED`, `EXPIRED`, `WRONG_SHOP`, `ALREADY_USED`, `REJECTED`.
- Non-terminal: `NETWORK_REQUIRED`, `UNKNOWN_OUTCOME` followed by status reconciliation.

## Rules

- QR content is opaque; client does not decode customer/product authority from it.
- Merchant sees target shop, safe item/quantity/price snapshot context sufficient to avoid accidental confirmation.
- Double tap is disabled in UX and safe in backend through idempotency/atomic consume.
- Back/cancel before confirm produces no verified transaction.
- Timeout after submit is not shown as failure until authoritative status is checked.

