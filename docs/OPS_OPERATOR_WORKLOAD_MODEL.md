# Operator Workload Model

**State:** PROPOSED ESTIMATION METHOD — NO CALENDAR OR STAFFING PROMISE

## Workload equation

`workload = intake × case mix × handling complexity × reopen/appeal × evidence wait/handoff + incident reserve`

Counts alone are misleading.

## Drivers

| Driver | Effect |
|---|---|
| Verification/policy evidence complexity | review time and specialized capability |
| Catalog dedup/merge/split | dependency impact and second review |
| QR/security/privacy incidents | urgent interruption and investigation |
| Duplicate/low-quality reports | triage burden unless safely grouped |
| Merchant/customer communication | language, evidence requests, appeal |
| Tool fragmentation/manual SQL | error and handling time |
| Policy churn | re-review of active subjects |
| Incomplete catalog/merchant data | repeated clarification |
| False positives | appeals, restoration, trust cost |
| Staffing schedule | coverage and handoff latency |

## Estimation approach

Sample representative synthetic cases by type; estimate median and tail active time separately from waiting time; include QA, training, incident drills, policy maintenance, and support communication. Model low/base/high volume and burst scenarios. Revisit with real pilot evidence.

## Healthy workload signals

Queue age by type/priority, unassigned P0/P1, reopen/appeal, handoffs, waiting-external, QA disagreement, operator error, and overtime/incident load—aggregated without surveillance.

## Guardrails

Do not use closures/hour as performance, set calendar promises without volume evidence, or automate enforcement merely to reduce workload. Reduce burden first through better product data, structured reasons, dedup, and safe tooling.

`STAFFING_NUMBER_DECIDED: NO`

`WORKLOAD_FORECAST_VALIDATED: NO`
