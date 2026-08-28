# Customer App Compatibility Gate

**State:** REQUIRED FOR EVERY BACKEND EVOLUTION WAVE

## Invariants

- Existing production entrypoints and environment contracts remain unchanged.
- Anonymous category/product/shop/listing reads keep their fields and visibility.
- `shop_products` remains the owner of price and availability semantics.
- Existing Cart V2 single-shop behavior and local quantity/remove behavior remain
  compatible.
- Existing QR clients can issue and display an opaque token; server remains the
  only authority for consumption.
- Verified purchase snapshots keep durable canonical `product_id` evidence.
- Review eligibility remains verified purchase plus one active review per
  customer and canonical product.
- Profile role cannot be escalated by the customer client.

## Release matrix

| Backend | Customer N-1 | Customer N | Merchant N | Gate |
|---|---:|---:|---:|---|
| additive pre-cutover | PASS required | PASS required | feature off/compatible | safe deploy |
| dual-read transition | PASS required | PASS required | PASS targeted | observe before cutover |
| new canonical path | PASS required or explicit minimum-version gate | PASS required | PASS required | owner-authorized cutover |

## Stop conditions

- existing fields change meaning or become non-null without compatibility;
- Customer N-1 fails discovery, QR, verified purchase or review tests;
- RLS widens anonymous/customer access or merchant mutations cross shop scope;
- backfill is incomplete, reconciliation differs, rollback is unavailable or the
  server asks an old client to understand a new mandatory state.

No migration is “successful” until both schema postflight and client behavior
pass. A UI feature flag cannot compensate for broken authorization.
