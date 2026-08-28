# Location, Search, Analytics and Advertising Privacy

**State:** V1 PRIVACY RECOMMENDATION — OWNER/PRIVACY REVIEW REQUIRED

## Location tiers

| Tier | Example | V1 posture |
|---|---|---|
| Precise transient | device coordinate for current nearby request | allowed candidate only for requested operation; discard after response |
| Explicitly saved | user-named saved location/address | private feature; separate notice and deletion |
| Coarse operational | distance/result bands | preferred for diagnostics |
| Coarse analytics | approved district/cell with cohort threshold | off until purpose/threshold/retention approved |
| Precise history | time-linked coordinates/routes/home-work inference | prohibited candidate |
| Merchant visitor map | customer origins/visits | prohibited candidate |

Permission to access location is not consent to analytics, advertising or merchant
reporting. A denied permission preserves non-location discovery where possible.

## Search

Raw searches can reveal names, addresses, health intent and other sensitive context.
The recommended pilot sends/retains only resolved product/category IDs, result-count
and quality/error classes. Short restricted unmatched-query sampling is a later
privacy-approved research option; general account-linked raw history is not
recommended.

## Analytics classes

- `ESSENTIAL_OPERATIONAL`: minimum service outcomes.
- `SECURITY`: restricted anti-abuse facts; never marketing.
- `PRODUCT_ANALYTICS`: optional/approved fields and retention.
- `AD_MEASUREMENT`: separate purpose and controls.
- `PERSONALIZATION`: off until explicit owner/privacy decision.

Mixed-purpose events are split. Customer/merchant-level export is replaced by
aggregate reporting with minimum cohorts and anti-differencing controls.

## Advertising V1 recommendation

Use contextual surface/query/category plus current bounded local context. Do not
build behavioral profiles, import customer lists, use third-party ad identifiers,
enable cross-app retargeting or infer health/regulated-product interest. Refusing
optional ad processing must not remove organic results. Children-directed or
profiled-child targeting is fail-closed.

`PRECISE_MOVEMENT_HISTORY: PROHIBITED_RECOMMENDATION`
