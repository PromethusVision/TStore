# Gamification Badge Evidence Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 18 / Workstream P

## Evidence quality

| Quality | Examples | Allowed use |
|---|---|---|
| STRONG | Verified purchase/item, eligible unique review, authoritative account/security state | Badge eligibility when rule/policy allows |
| MEDIUM | Governed shop discovery with dedup/anti-bot, completed profile milestone | Private progress or low-stakes badge |
| WEAK | Directions request, wishlist, product/shop view | Aggregate analytics; never strong public claim alone |
| UNSAFE | Ad view/click, client tap, positive rating, raw QR generated/scanned, merchant claim | No badge entitlement |

## Evidence envelope

Source event ID/system, subject identity, stable product/shop/category reference, server timestamp, integrity/policy state, rule version, privacy class and correction lineage.

## Invariants

- Same source event cannot award a badge/progress twice.
- Badge state is derived from eligible evidence and lifecycle events, not a client boolean.
- Review-derived evidence is sentiment-neutral and respects one active review contract.
- Product/taxonomy merge/split uses versioned stable identity mapping without duplicating history.
- Public display needs separate consent/privacy choice where purchase behavior could be inferred.
