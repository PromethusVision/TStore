# Sponsored Budget and Pacing Model

**State:** CONCEPTUAL — NO PAYMENT, LEDGER OR BILLING IMPLEMENTATION

## Budget envelope

The campaign has an immutable currency, proposed daily cap, total cap, effective
window and charging model revision. Exact values and minimums are owner/commercial
decisions.

Conceptual amounts must be separated:

- `AUTHORIZED`: merchant-approved maximum exposure;
- `RESERVED`: held for an in-flight qualifying unit/day;
- `SPENT`: finalized billable amount;
- `CREDITED`: reversed/credited after invalid traffic or under-delivery;
- `AVAILABLE`: authorized minus finalized/reserved exposure;
- `PENDING_DISPUTE`: not silently reusable until resolved.

## Pacing

- distribute eligible delivery across the campaign window instead of spending at
  the first traffic spike;
- use surface/geo demand forecasts only as estimates, never delivery guarantees;
- reserve atomically before serve when the pricing model requires it;
- do not exceed daily or total caps under concurrency/retry;
- stop/skip immediately at exhaustion and move to `BUDGET_EXHAUSTED`;
- resume next day only if the daily window resets and total budget remains;
- merchant pause prevents new reservation but preserves settled history;
- budget increase/decrease creates an audited revision.

## Failure and credit questions

| Event | Proposed posture |
|---|---|
| No eligible impressions all day | No full daily charge; credit/no-charge contract required |
| Ad selector outage | Organic fallback; do not charge unserved opportunity |
| Invalid traffic found later | Credit/reversal subject to immutable evidence |
| Listing/shop becomes ineligible | Stop serving; unused budget remains |
| Merchant pauses | Stop new delivery; settled valid usage remains |
| Policy rejection after submission | No serving; review/refund rule owner-required |
| Duplicate event | Idempotent; never double-spend |

## Guardrails

- currency cannot change in-place;
- budget cannot make an ineligible ad eligible;
- no negative available balance through ordinary serve path;
- platform fees, tax and payment balance are distinct from campaign delivery ledger;
- merchants see cap, spend/credit definitions and freshness timestamp;
- all financial semantics require separate legal/finance/security review.

`BUDGET_CAP_CONCURRENCY: FAIL_CLOSED`

`EXHAUSTED_CAMPAIGN_SERVES: NO`

`MINIMUM_BUDGET_FINALIZED: NO`
