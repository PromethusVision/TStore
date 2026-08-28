# Reward Purchase Amount Trust Model

**State:** MAJOR GAP — OWNER/CONTRACT DECISION REQUIRED

The existing read-only architecture sources confirm durable item identity and optional listing/shop/display/quantity/unit-price/line-total snapshots. A snapshot inside verified purchase evidence does not by itself prove that money changed hands at that amount, was settled, included tax/discount correctly or was not later refunded.

## Trust classes

| Input | Trust for spend-weighted reward |
|---|---|
| Client cart/displayed price | UNSAFE |
| Listing price snapshot | UNSAFE as paid amount |
| Merchant-confirmed QR item snapshot | MEDIUM identity evidence; monetary authority unproven |
| Future POS/payment-settled amount | POTENTIALLY STRONG after signed integration/reconciliation |
| Manual merchant amount | UNSAFE without controls/audit |

## Gate

Until currency, tax/discount, total authority, settlement, refund and correction provenance are contractually defined, reward must not be spend-weighted. Use no implied monetary value in progress copy.

**Recommendation:** fixed event/stamp shadow evaluation, not amount weighting.
