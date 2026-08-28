# EsnaftaVar Analytics Data Quality Scorecard

**State:** `PROPOSED TEMPLATE — THRESHOLDS REQUIRE BASELINE`

| Signal | Formula | Gate concept | Owner |
|---|---|---|---|
| Required-field validity | valid required fields / received | No critical authoritative omissions | Producer/data |
| Duplicate delivery rate | duplicate deliveries / deliveries | Informational if dedup works; alert on surge | Platform |
| Semantic duplicate rate | duplicate business keys / accepted facts | Zero for protected outcomes | Domain |
| Timely-arrival rate | events within declared lag / accepted | Baseline per class | Data |
| Quarantine rate | quarantined / received | Reason/version segmented | Producer/data |
| Environment purity | correctly scoped / accepted | Production contamination is a stop gate | Release/data |
| Projection reconciliation | aggregate facts matching source / checked | Exact for ledgers; bounded for soft events | Metric owner |
| Privacy conformance | allowlisted fields / inspected fields | Any secret/forbidden field is critical | Privacy/security |

Scorecards show absolute counts, rate, trend, release/version, freshness and top
bounded causes. Exact green/amber/red thresholds are set after pilot baseline;
privacy leaks and duplicate authoritative outcomes do not wait for a baseline.

`QUALITY_THRESHOLDS_FINALIZED: NO`

