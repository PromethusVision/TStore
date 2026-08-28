# EsnaftaVar Analytics Aggregation Model

**State:** `PROPOSED LOGICAL MODEL — NO DATA STORE`

Dashboards should read versioned daily/weekly aggregates rather than repeatedly
scan raw events. A projection key includes metric definition/version, environment,
event-time date/timezone, entity scope, allowed dimensions and quality-filter
version.

Pipeline concept:

1. validate and deduplicate source events;
2. apply authority/privacy/test/bot filters;
3. resolve event-time identity and optional current lineage projection;
4. aggregate counts/sums/distributions using stable metric rules;
5. apply minimum-cohort suppression;
6. publish freshness, completeness and restatement version;
7. recompute bounded windows for late/corrected source events.

Daily shop metrics use shop-local date; platform comparisons also retain UTC
boundaries. Weekly/monthly values roll up compatible daily facts rather than
mixing partial and complete windows. Unique counts require an approved identity
and privacy contract; approximate algorithms must be labelled.

Raw facts remain the reconciliation source within approved retention. Aggregate
tables cannot award rewards, establish reviews, bill ads or modify reputation.

`AGGREGATION_RUNTIME: NOT_IMPLEMENTED`
