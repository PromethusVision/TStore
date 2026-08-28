# Merchant App Reward Extension Points

Status: **PROPOSED — FUTURE ENGINE ONLY**
Wave: 17 / WP64

## Evidence candidate

Server-authoritative verified physical purchase may be an input to a future reward engine. It is not by itself a reward promise, balance, monetary value or entitlement formula.

## Required separations

- Verified transaction evidence remains immutable and independent.
- Reward ledger/rules, eligibility, reversal and abuse controls are separate concepts.
- Quantity/repeat purchase review rules remain unchanged.
- Merchant cannot grant, edit or revoke customer rewards through QR UI.
- Payment, tax/accounting, campaign funding and consumer terms require separate decisions.

## Safe extension contract

Consume a versioned event/reference after authoritative QR success; record reward processing independently and idempotently. Reward failure must not roll back physical purchase verification.

No points, formula, monetary conversion or launch scope is finalized.
