# Reward Quantity Trust Model

**State:** OPTIONS — OWNER DECISION REQUIRED

Verified transaction item quantity is useful historical evidence, but review quantity semantics must not be reused blindly for rewards. One lifetime review right remains tied to customer + canonical product regardless of quantity or repeat purchase.

## Risks

- Merchant/customer inflate quantity without authoritative settlement.
- One purchase is split or combined to optimize thresholds.
- Unit semantics differ by product (piece, weight, pack).
- Refund/partial-return changes earned quantity.
- Product merge/split creates false derived counts.

## Options

1. Ignore quantity and evaluate one idempotent purchase event (recommended starting hypothesis).
2. Cap quantity contribution per event after authoritative unit and correction contracts exist.
3. Weight every unit — not recommended with current trust evidence.

Quantity anomaly may trigger review but cannot automatically prove fraud or create public reputation harm.

