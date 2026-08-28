# Reward Eligible Event Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 18 / Workstream C

## Candidate source event

Server-authoritative, merchant-confirmed physical QR verified purchase is the strongest current candidate. Reward evaluator uses an immutable event/reference and independently decides eligibility; it never changes verification truth.

## Event envelope

- Verified transaction/item identity and customer owner.
- Merchant organization, shop and confirmed timestamp.
- Durable canonical product ID plus historical snapshot.
- Listing/variant reference when known.
- Quantity, unit and monetary snapshot only with explicit trust state.
- Source integrity/fraud/policy/correction state and event version.

## Behavioral analysis

| Case | Proposed reward behavior | Review behavior |
|---|---|---|
| Quantity > 1 | One event by default; quantity weighting TBD and not assumed | No extra review right |
| Repeat purchase | May earn again under owner rule and anti-split window | No second active review |
| Multiple products | Per-transaction or eligible-item policy TBD; deduplicate identity | One-review rule per canonical product unchanged |
| Same merchant | Merchant-specific progress may accumulate | Independent |
| Different merchants | Separate progress unless cross-merchant root approved | Independent |
| Future refund/correction | Append reverse/adjust event; never mutate history | Evidence correction follows frozen review policy |
| Duplicate QR/retry | Same source event processed once | No duplicate evidence |
| Fraud/collusion | Hold/reverse reward; preserve investigation audit | Does not let reward engine rewrite review evidence |

## Eligibility states

`PENDING_INTEGRITY`, `ELIGIBLE`, `INELIGIBLE_POLICY`, `HELD_FRAUD`, `REVERSED_SOURCE`, `UNKNOWN`. These are conceptual—not DB enums.

## Open roots

Earning granularity, repeat/split window, monetary/quantity trust, correction delay and policy-domain allowlist are Product Owner decisions.
