# EsnaftaVar Analytics Data Minimization

**State:** `PROPOSED CONTROL STANDARD`

For every field answer: which approved question requires it, why an aggregate or
coarser value is insufficient, who can access it, how long it is needed and how it
is deleted. If no concrete answer exists, do not collect it.

Controls:

1. allowlist event types and fields; reject arbitrary metadata;
2. use opaque entity IDs, controlled enums and count/time buckets;
3. compute on device or at ingestion where raw detail is unnecessary;
4. separate event-time operational facts from analytics projections;
5. aggregate early and enforce minimum cohort thresholds;
6. redact/drop sensitive fields before transport, not only in dashboards;
7. sample noisy UI telemetry with release/health coverage guarantees;
8. expire raw data by class while retaining non-identifying aggregates when
   approved;
9. periodically prove every field has an active consumer and decision owner;
10. disable unused producers and document the removal.

Raw search text, precise location, customer contact, private content, tokens and
full request/response bodies are excluded by default. “May be useful later” is not
a valid collection purpose.

`DATA_MINIMIZATION_REQUIRED: YES`
