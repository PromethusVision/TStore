# Canary Release Options

State: PROPOSED — OWNER REVIEW REQUIRED

## Options

| Option | When useful | Risk |
|---|---|---|
| No canary, internal/closed only | Very low user volume | Weak Production signal |
| Small store cohort | Enough traffic and monitoring | Slower detection at tiny scale |
| Region/account targeting via feature flags | High-risk feature isolation | Complexity and fairness/privacy review |

Recommendation: use store staged rollout as the lean mobile canary once crash/error and key funnel signals are trustworthy. Do not build bespoke canary routing for V1.

A canary needs preset success/stop criteria, enough observation time, comparison to baseline, support readiness, and a pause path. Absence of alerts is not evidence when sample size is too small.

OWNER_DECISION_REQUIRED: approve whether initial Production is staged and define evidence-based pause criteria.
