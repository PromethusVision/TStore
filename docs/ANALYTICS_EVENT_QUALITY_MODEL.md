# EsnaftaVar Event Quality Model

**State:** `PROPOSED`

| Dimension | Definition | Evidence |
|---|---|---|
| Completeness | Expected producers/types/required fields arrive | Producer and field coverage |
| Uniqueness | Duplicate deliveries/outcomes do not inflate facts | Duplicate rate by event/semantic key |
| Timeliness | Events arrive within declared window | occurred→recorded/delivered latency |
| Validity | Type/version/enums/identity/privacy fields pass contract | Rejection/quarantine rate |
| Consistency | Related facts/revisions/aggregates reconcile | Source-versus-projection checks |
| Authority | Metric receives minimum evidence grade | Authority downgrade/rejection count |

Missing, duplicate, late, invalid and schema-mismatch events remain distinct
quality classes. A single composite score cannot hide a critical authoritative
gap. Quality is segmented by producer, release, environment and event version,
with high-cardinality/private dimensions excluded.

Every metric publishes freshness and source coverage. Quality failures trigger
bounded remediation/replay and restatement, never manual invention of facts.

`EVENT_QUALITY_RUNTIME: NOT_IMPLEMENTED`

