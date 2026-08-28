# Sponsored Ranking Explainability

**State:** PROPOSED EXPLANATION CONTRACT — NO FINAL COPY OR RUNTIME

## Internal explanation

For each decision, authorized operators should reconstruct:

- request/surface/context class and model/ruleset revision;
- candidate campaign/target/listing/shop/product stable IDs;
- merchant/shop/listing/product/policy/budget eligibility outcomes;
- contextual relevance and geo scope class;
- density/frequency/new-merchant/fairness/pacing outcome;
- selection/non-selection and organic fallback reason;
- disclosure variant and measurement qualification;
- invalid-traffic or later credit classification.

This is reasoned decision metadata, not a promise to store every raw feature or
precise personal context.

## Merchant-facing explanations

Use plain reason classes such as:

- listing inactive/out of stock/stale;
- shop outside selected approved local scope;
- campaign paused/exhausted/outside schedule;
- product or creative requires review;
- frequency/density/pacing limited delivery;
- invalid traffic excluded;
- insufficient eligible demand, with no guaranteed delivery/ROI.

Do not expose fraud thresholds, customer identity/queries/coordinates or competitor
bids.

## Customer-facing explanation

The card always says `Sponsorlu`. A directly reachable `Neden Sponsorlu?` can state:

- merchant paid for eligible placement;
- result matched current product/search/category context;
- shop is within the applicable local location context;
- payment may affect placement but does not mean nearest, cheapest, best,
  recommended or verified;
- relevant hide/report/privacy controls.

For targeted advertising, implementation-time legal review must confirm the main
criteria and control disclosure required by the current Turkish framework.

`CUSTOMER_WHY_SPONSORED: REQUIRED_CANDIDATE`

`COMPETITOR_BID_DISCLOSURE: NO`

`EXPLAINABILITY_COPY_FINALIZED: NO`
