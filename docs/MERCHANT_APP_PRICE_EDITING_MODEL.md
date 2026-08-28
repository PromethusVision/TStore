# Merchant App Price Editing Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP19

## Contract

Price is a timestamped shop-listing claim. It is not a universal product property, payment capture, invoice or guaranteed checkout price.

## Safe edit flow

1. Show active shop, product/variant, current price and last update.
2. Validate currency, positive amount, decimal precision and listing eligibility.
3. Warn on material change using policy thresholds; do not invent market-price truth.
4. Confirm exact new amount and affected listing(s).
5. Submit idempotently with expected revision.
6. Show authoritative saved value or conflict/error.

## History and audit

- Keep actor, timestamp, old/new value and source channel for dispute/support.
- Customer UI eventually reflects latest eligible value and freshness.
- Whether merchants see/export price history is `OWNER_DECISION_REQUIRED` (`CAT-14 P1`).
- Bulk price editing is deferred until blast-radius controls and approval model exist.

## Failure rules

- Network timeout is `UNKNOWN_OUTCOME`; re-read authoritative listing before retry.
- Validation failure does not mutate local “saved” state.
- Suspended shop/listing cannot update customer-visible price.
