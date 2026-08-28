# Lean Admin Dashboard Model

**State:** PROPOSED — NO UI OR METRICS PIPELINE

## Primary dashboard questions

- Is a P0/P1 incident active and who owns it?
- Are critical feature kill switches active?
- Which must-have queues are oldest or breaching internal target?
- Are Auth/RPC/QR/catalog/review critical paths degraded?
- Are regulated/policy/verification cases awaiting external decision?
- Are appeal, reopen, false-positive, operator-error, or audit-integrity signals rising?
- Is telemetry/report freshness known?

## Candidate cards

Active incidents; feature health; urgent queue counts/oldest age; unassigned high-priority cases; pending regulated/legal escalations; verification expiry; catalog merge/split holds; QR fraud holds; privacy/security cases; release/error regressions; audit/export anomalies.

## Avoid vanity metrics

Do not headline raw signups, total clicks, operator closures/hour, ad revenue, average handling time without case mix, or green “zero incidents” when telemetry is missing. Dashboard is not employee surveillance or commercial pressure on moderation.

## Drill-down

Every card links to a role-authorized queue/query with definition, denominator, freshness, target/status, and safe correlation. No raw PII/content in cards. Counts are environment-scoped.

## Pilot posture

One operational overview plus specialized queue pages is enough. Do not build an enterprise command center. Exact layout, tools, and thresholds remain owner/operations decisions.

`ADMIN_DASHBOARD_IMPLEMENTED: NO`

`OPERATOR_LEADERBOARD: PROHIBITED`
