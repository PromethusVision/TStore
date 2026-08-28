# Gamification Abuse Model

Status: **PROPOSED — SECURITY REVIEW REQUIRED**
Wave: 18 / Workstream AD

## Customer abuse

- Multi-account/device farming.
- Fake/collusive verified purchases.
- Split purchases and quantity/amount inflation.
- Review create/delete/recreate or low-quality spam farming.
- Automated views, wishlist, directions and shop-discovery events.
- Account merge/closure cycling to reset history.

## Merchant/staff abuse

- QR inflation, self-verification and staff/customer collusion.
- Fake listings/products/availability to trigger progress.
- Reputation farming through controlled accounts/reviews.
- Merchant closure/recreation or branch cycling.
- Paying for ads/rewards to imply trust.
- Reporting legitimate reviews or disputing evidence in bulk.

## Controls

Authoritative events, identity/scope linkage, idempotency, velocity/anomaly holds, policy allowlists, account/program lineage, immutable audit, manual appeal, privacy-limited risk signals and reward/reputation separation.

## Boundary

Fraud risk/hold is not a public social-credit label. An abuse decision can reverse reward/badge under its rule but cannot rewrite verified purchase or review evidence outside their canonical correction process.
