# Ecosystem QR / Verified Purchase / Review Contract Audit

**Result:** PASS — NO FOUNDATION MAY OVERRIDE THESE INVARIANTS

## Master sequence

```text
Customer Cart V2
  -> server-issued opaque short-lived exact-shop QR session
  -> authorized merchant/verifier inspect
  -> atomic one-winner confirmation
  -> immutable verified transaction + item/product snapshot
  -> review eligibility for customer + canonical product
```

## Invariants

1. Client cannot manufacture verification; QR validation and consumption use
   server time, state and exact-shop authority.
2. QR is intent/evidence transport, not payment, order settlement or revenue.
3. Wrong shop, expired/cancelled token, replay and concurrent second confirmation
   fail or return the same prior idempotent result.
4. Verified item preserves durable canonical `product_id`; future variant/listing
   snapshots may add context without replacing product evidence.
5. Only merchant-confirmed physical purchase unlocks product review.
6. One active review exists per customer + canonical product for life.
7. Repeat purchase and quantity do not multiply review rights.
8. Delete/recreate uses immutable evidence; legacy boolean/order/analytics alone is
   insufficient.
9. Product merge/split retains predecessor evidence; ambiguous mapping does not
   grant or remove rights automatically.
10. Ads attribution, Reward earning, badges, reputation and analytics reference the
    verified purchase but cannot create or modify it.

## Source audit

Customer, Catalog, Merchant, Ads, Reward, Ops, Analytics, Backend and QA foundations
all support the master direction. Tensions concern variable-measure snapshots,
cross-branch verification and merge/split collisions; each is owner-gated without
weakening current evidence.

`QR_REVIEW_INVARIANTS: PASS`
