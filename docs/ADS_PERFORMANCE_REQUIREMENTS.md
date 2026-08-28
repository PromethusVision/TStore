# Sponsored Advertising Performance Requirements

**State:** CONCEPTUAL LATENCY/RESILIENCE BUDGET — NUMBERS NOT FINAL

## Principle

Customer discovery must not wait excessively for advertising. Organic retrieval has
priority; ad selection runs within a strict sub-budget and fails open to organic.

## Proposed budgets for owner/engineering review

| Stage | Requirement |
|---|---|
| Context assembly | Reuse current request product/query/geo; no remote profile fan-out |
| Candidate retrieval | Bounded result count, stable IDs, indexed context |
| Eligibility | Batched/current projections; no N+1 per candidate |
| Selection | Deterministic bounded work; no auction network chain in V1 |
| Disclosure render | Local component contract with textual `Sponsorlu`; no late label fetch |
| Measurement | Async/non-blocking after qualified client/server event |
| Deadline | Ad work must finish materially inside organic end-to-end SLO |

A candidate engineering budget of `75–150 ms p95` for server-side ad decision may be
tested, but this is **not final** and must be derived from measured organic budgets,
network architecture and device acceptance.

## Timeout/failure

- cancel/ignore late ad result for the current stable response;
- render organic with no blank slot;
- do not insert a late sponsor causing layout/rank jump;
- do not count an impression for a timed-out/unrendered ad;
- use circuit breaker/kill switch by surface;
- stale eligibility cache never overrides hard policy/listing invalidation;
- measurement degradation does not block navigation.

## Capacity considerations

Bound candidate retrieval, page density and event retry. Budget/frequency checks need
atomicity without global locks. Audit detail should be sampled/retained according to
risk while every billable candidate remains reconstructable.

`ORGANIC_BLOCKED_BY_AD_LATENCY: NO`

`LATE_AD_LAYOUT_REORDER: NO`

`NUMERIC_LATENCY_SLO_FINALIZED: NO`
