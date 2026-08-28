# Operations Analytics Model

**State:** PROPOSED — NO ANALYTICS PIPELINE

## Useful metrics

- case intake/resolution/rejection/reopen/appeal by type, severity, priority, source, policy version;
- queue age, unassigned, waiting-external and blocked dependency;
- evidence completeness/conflict and recheck/expiry;
- enforcement scope/duration/restoration;
- false-positive/overturn/reviewer disagreement;
- duplicate/report-abuse and repeat substantiated patterns;
- incident detection/containment/recovery intervals;
- operator-error and reversal categories;
- privacy/PII access/export;
- catalog candidate/link/merge/split outcomes;
- QR/ad/reward invalid activity where enabled.

## Quality context

Use distributions and case mix, not one average. Separate active handling from waiting. Include denominators, freshness, unknown/missing telemetry, and policy/release changes.

## Prohibitions

No individual closures/hour leaderboard, keystroke/screen surveillance, simplistic “accuracy score,” merchant value/spend priority, reporter identity exposure, or raw PII/content labels. Analytics does not decide enforcement.

## Privacy

Aggregate/cohort minimums, role-scoped drilldown, opaque IDs, short raw retention, audited export, and re-identification review. Operational analytics is a derived projection; authoritative case/audit remains separate.

## Owner questions

Which quality/health targets, cohort thresholds, retention, operator/team views, and public transparency reporting are appropriate? No target is finalized.

`ADMIN_ANALYTICS_IMPLEMENTED: NO`

`OPERATOR_PRODUCTIVITY_SURVEILLANCE: PROHIBITED`
