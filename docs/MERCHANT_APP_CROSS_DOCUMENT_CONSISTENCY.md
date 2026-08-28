# Merchant App Cross-Document Consistency

Status: **WP119 COMPLETE — RESEARCH/PROPOSALS ONLY**
Wave: 17 / WP119

## Count reconciliation

| Contract | Reconciled value | Sources |
|---|---:|---|
| Feature inventory | 31 | 16 MUST + 7 SHOULD + 5 DEFER + 3 FUTURE_ENGINE |
| Raw owner decisions | 42 | P0 22 + P1 18 + P2 2 |
| Root owner decisions | 18 | P0 9 + P1 7 + P2 2 |
| Security threats | 15 | P0 8 + P1 5 + P2 2 |
| Failure classes | 20 | P0 10 + P1 7 + P2 3 |
| Readiness areas | 12 | Ready 4 + minor gap 6 + major gap 2 |
| Stress rows | 3,500 | 11 deterministic CSV matrices |
| Implementation waves | 10 | Decision through pilot hardening |

## Stress reconciliation

| Matrix | Rows | Unique IDs |
|---|---:|---:|
| QR | 300 | 300 |
| Analytics | 200 | 200 |
| Merchant personas | 200 | 200 |
| Operations | 1,000 | 1,000 |
| End-to-end journeys | 100 | 100 |
| Edge cases | 500 | 500 |
| Onboarding | 200 | 200 |
| Catalog workload | 500 | 500 |
| Multi-staff | 200 | 200 |
| Multi-branch | 200 | 200 |
| Regulated | 100 | 100 |

## Concept boundaries

- Product Taxonomy, Merchant Taxonomy, canonical product, variant, shop listing, merchant account, organization, shop/branch, verified purchase, customer review, ad campaign and reputation/badge remain separate.
- Price, availability, merchant SKU and shop relation remain listing-owned; no universal product price/stock.
- Merchant sector is proposed except for the confirmed Beauty subtree and never grants role/product/policy authority.
- Customer and merchant projections minimize the other party's private data.

## Confirmed Beauty subtree preservation

The exact already-confirmed subtree is preserved as read-only source truth:

- `Berber, Kuaför & Güzellik Salonu`
  - `Erkek Berberi`
  - `Kadın Kuaförü`
  - `Güzellik Salonu`

No additional child was introduced. `FORBIDDEN_BEAUTY_NODE_ABSENT: PASS`.

## Frozen QR/review consistency

- QR remains opaque, short-lived, server-time controlled, correct-shop bound, one-time and atomic.
- Offline confirmation fails closed; timeout is reconciled authoritatively.
- Only merchant-confirmed physical QR purchase creates verified evidence.
- One active review per customer + canonical product for life.
- Repeat purchase/quantity does not create another active review.
- Delete/recreate depends on immutable evidence; legacy boolean alone is insufficient.

## Status consistency

No proposal or hypothetical recommendation is marked Product Owner final. Future ads, gamification, badge and reward sections define only boundaries/readiness; no engine, formula, payment or runtime exists.

## Implementation consistency

The 10-wave sequence respects isolated task branches and permanent multi-agent integration: owner roots and backend contracts precede parallel UI streams; shared contracts/config/navigation/migrations have explicit ownership; Integration alone combines verified tasks.
