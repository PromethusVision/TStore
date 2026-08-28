# Backend Review Aggregate Contract

**State:** PROPOSED HARDENING OF CURRENT SERVER AGGREGATE

Product review aggregate is a derived projection of currently eligible, visible
reviews under a declared rule version. It is not an independently editable score.

## Contract

- count and average derive only from qualifying review rows;
- create/update/delete/moderation/correction applies exactly one reversible delta
  or triggers deterministic recomputation;
- repeat purchase and quantity never add weight;
- legacy boolean verification is excluded;
- missing/zero reviews is distinct from rating zero;
- displayed customer reviews remain accessible; merchant reputation cannot hide
  unfavorable valid ratings;
- cache/projection exposes freshness and rule version where needed;
- reconciliation can rebuild from authoritative reviews/evidence.

Product merge/split may require a new projection while preserving predecessor
history and collision policy. Exact rounding, moderation inclusion and merge
display are `OWNER_DECISION_REQUIRED`. Advertising spend and reward activity have
zero aggregate effect.
