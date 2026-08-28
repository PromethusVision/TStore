# Merchant Badge Dependency Graph

**State:** GENERIC VERSIONED DAG — NO ELIGIBILITY THRESHOLDS

## Graph

```text
Verified structured evidence
  ├─ Friendliness aggregate ──> Friendly primary badge ─┐
  ├─ Helpfulness aggregate ───> Helpful primary badge ──┼─> Composite badge ─┐
  └─ Information aggregate ───> Knowledge primary badge ┘                   ├─> Local/meta badge
Shop active + freshness + integrity + policy/fraud gates ───────────────────┘
Region eligibility + local cohort sufficiency ──────────────────────────────┘
```

The graph is a directed acyclic derivation graph. Nodes are versioned definitions; edges state
prerequisites, not transferable assets.

## Generic node contract

- immutable definition/version ID and customer-facing name/version;
- subject scope (`SHOP` by default), dimension/family and lifecycle state;
- prerequisite set with `ALL`, `ANY_N` or balanced-family semantics;
- minimum effective sample and confidence condition;
- freshness/time-window rule;
- fraud/policy and shop/region eligibility;
- earned/evaluated time, evidence snapshot and reason codes.

## Propagation rules

- A composite/meta badge is `ACTIVE` only while every required upstream condition is active.
- A prerequisite entering `AT_RISK` puts downstream badges at least `AT_RISK`; a hold can suspend
  downstream nodes without rewriting source evidence.
- Confidence is recomputed from underlying effective contributions; badge icons do not contribute
  confidence to another badge.
- Cycles, manual edge overrides and paid prerequisites are invalid.
- Definition changes create a new version and impact preview; they do not reinterpret history silently.

`DEPENDENCY_GRAPH_TYPE: VERSIONED_DAG`
`BADGE_AS_EVIDENCE_FOR_ITSELF: NO`

