# Merchant Badge Explainability Model

**State:** REQUIRED PRODUCT CONTRACT — COPY/THRESHOLDS OPEN

Every public badge needs a short meaning and a detail view containing:

- what behavior/dimension it represents;
- that evidence comes from eligible verified physical purchase evaluations;
- effective response count or understandable sample band;
- evaluation/freshness window;
- current definition version/effective date where useful;
- what the badge does **not** guarantee;
- reporting/correction channel.

Merchant-facing explanation additionally shows dimension distributions, effective versus held counts,
state transitions and appeal reasons without customer PII or exploitable anti-fraud thresholds.

## Decision reason codes

Examples: `INSUFFICIENT_SAMPLE`, `INSUFFICIENT_FRESHNESS`, `DIMENSION_BELOW_RULE`, `PREREQUISITE_INACTIVE`,
`INTEGRITY_HOLD`, `SHOP_INACTIVE`, `REGION_INELIGIBLE`, `DEFINITION_RETIRED`. Customer copy translates
these safely; internal reason codes remain stable for audit.

## No dark reputation

Badges do not hide distributions, suppress low product reviews or imply platform certification. A merchant
can challenge evidence/process but cannot demand removal merely because an accurate result is unfavorable.

`BADGE_WHY_VIEW: REQUIRED`
`SECRET_REPUTATION_SCORE_AS_PUBLIC_TRUTH: NO`
