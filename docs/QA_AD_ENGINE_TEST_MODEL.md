# Sponsored Advertising Engine Test Model

**State:** PROPOSED — ADS RUNTIME DEFERRED

| Area | Test contract |
|---|---|
| Eligibility | active merchant/shop/listing, policy allowlist, locality and current revision |
| Disclosure | persistent textual `Sponsorlu`, accessible semantics and no late label fetch |
| Ranking | organic set computed independently; spend cannot bypass relevance/policy/fairness |
| Organic fallback | timeout/error/no candidate leaves organic order and layout usable |
| Budget/pacing | atomic cap/reservation, no uncertain double charge, explicit unknown state |
| Policy | regulated/unknown evidence fails closed; taxonomy is not permission |
| Measurement | request/render/impression/interaction identities separate and deduplicated |
| Fraud | self-click/bot/collusion signals do not become opaque automatic punishment |
| Privacy | contextual minimum-data targeting; test traffic excluded from billing/business metrics |

## Performance testing

Measure ad work inside the organic journey budget and confirm late results do not reorder the page. The source proposal's 75–150 ms p95 candidate is a hypothesis, not a release threshold; baseline organic/device evidence is required first.

## Enablement gate

No test plan makes ads launch-ready while sponsored object, pricing, billing, policy, operations, privacy and owner decisions remain open. Deferred code paths should be absent or disabled with organic-only behavior.

`ADS_QA_MODEL: READY_FOR_OWNER_REVIEW`

`ADS_RUNTIME_TESTABLE: NO`
