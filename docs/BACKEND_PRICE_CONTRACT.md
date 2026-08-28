# Backend Price Contract

**State:** PROPOSED — ESNAFTAVAR IS NOT PAYMENT SETTLEMENT

Price is a listing-owned merchant assertion displayed for local discovery. It is
not proof of payment, tax invoice, settlement or guaranteed checkout total.

## Required semantics

- currency, amount, unit/basis, tax/display posture, source and observed/effective
  time are explicit;
- negative, malformed or policy-invalid amounts fail closed;
- sale price requires a valid comparison-price/promotion rule; UI must not infer a
  discount from arbitrary fields;
- verified purchase item stores the confirmed unit/line snapshot independently of
  later listing changes;
- stale/unknown price is labelled or withheld under product policy;
- ads display the same current listing truth as organic results.

Current `shop_products.price` is the active listing source. `products.price` and
`sale_price` are compatibility fields until caller migration. Historical price
changes append audit/provenance rather than rewriting purchase evidence.

Exact freshness windows and tax/comparison-price requirements are
`OWNER_DECISION_REQUIRED` with policy/legal review.

