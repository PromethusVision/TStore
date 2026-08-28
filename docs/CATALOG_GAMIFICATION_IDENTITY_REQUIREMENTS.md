# Gamification Identity Requirements

Status: **FUTURE OWNER REVIEW DRAFT — NO REWARD SYSTEM**
Wave: 16, Work Package 46

Gamification must use stable identity and server-authoritative events so catalog
duplicates, listing churn or repeated scans cannot multiply rewards.

## Eligible identity anchors

- canonical product for discovery/collection breadth;
- variant only when the reward explicitly values distinct configurations;
- shop listing/shop for local-merchant exploration;
- verified transaction/item for purchase-derived achievement;
- verified product review for contribution-derived achievement;
- stable taxonomy leaf for category breadth under a versioned mapping.

## Safeguards

- Product merge deduplicates logical progress through predecessor lineage; it does
  not award again. Split does not duplicate prior progress into every child unless an
  owner rule explicitly defines it.
- Listing retirement or price change cannot erase earned progress. Fraud reversal or
  account deletion follows a separately approved retention/revocation policy.
- Cart additions, views and QR creation are not verified purchases. Purchase rewards
  use merchant-confirmed immutable transaction evidence.
- One active review policy prevents duplicate review rewards; deletion/recreation
  does not automatically re-award the same evidence.
- Merchant SKU, barcode scan and title aliases are lookup signals, not achievement
  identities.
- Policy-blocked/excluded products must not create unsafe incentive paths.

Badge catalog, points, reward value, anti-abuse thresholds and public profile display
are deferred product decisions.
