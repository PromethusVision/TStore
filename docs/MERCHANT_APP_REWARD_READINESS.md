# Merchant App Reward Readiness

Status: **PROPOSED BOUNDARIES — NO FORMULA/LEDGER IMPLEMENTATION**
Wave: 17 / WP118

## Evidence candidate

An authoritative verified physical purchase can emit a versioned reference for a future reward evaluator. It remains immutable purchase/review evidence even if reward processing fails, is reversed or is ineligible.

## Required architecture before launch

- Owner-approved reward purpose, eligibility and funding.
- Separate idempotent reward ledger/state machine.
- Abuse, reversal, dispute, expiry and account-deletion semantics.
- Consumer terms, tax/accounting/privacy and notification review.
- Merchant/customer visibility and support ownership.

## Merchant boundaries

- Merchant cannot assign balances, multipliers or customer eligibility.
- QR confirmation UI never promises reward.
- Quantity/repeat purchase does not change the one-active-review rule.
- Ads spend, badge/reputation and reward value are independent.
- Reward failure cannot roll back verified transaction; duplicate events cannot double reward.

No reward formula, currency, points, campaign or runtime is created.
