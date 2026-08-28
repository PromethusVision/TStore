# Organic and Sponsored Ranking Model

**State:** CONCEPTUAL STAGES — NO EXECUTABLE OR FINAL FORMULA

## Owner direction preserved

An eligible sponsored merchant may appear above a nearer organic merchant when the
customer's searched/opened product truly exists in the sponsor's active storefront
listing. Payment never waives relevance, local, policy, availability, quality or
disclosure gates.

## Proposed serving stages

1. **Interpret intent:** resolve query/category/canonical product without allowing
   ad targeting to rewrite the customer's intent.
2. **Build organic set:** compute normal organic candidates and order independently.
3. **Retrieve sponsored candidates:** match contextual target and physical geo
   scope; campaign retrieval does not yet imply eligibility.
4. **Hard eligibility:** validate merchant, shop, listing, product/variant, policy,
   campaign state, budget and target revision at serve time.
5. **Relevance floor:** exact same product for seller comparison; strong product or
   category/query match elsewhere. Below-floor ads are rejected regardless of money.
6. **Locality floor:** confirm real shop location and customer location context is
   within the approved campaign/experience scope.
7. **Quality/fairness gates:** suppress inactive, misleading, abusive, overly
   repeated or low-integrity candidates and apply new-merchant-safe thresholds.
8. **Pacing/selection:** choose from remaining campaigns under budget/frequency/ad
   density controls. Bid is optional future input, never the only rank signal.
9. **Interleave:** place the limited sponsored result with persistent disclosure;
   leave the organic order unchanged below/around it.
10. **Record decision:** immutable IDs, revision, eligibility reasons, context class
    and measurement event—not raw unnecessary personal data.

## Signal posture

| Signal | Role | Cannot do |
|---|---|---|
| Product/query match | Hard floor + relevance | Infer a product not in listing |
| Active listing/shop | Hard gate | Be bypassed by campaign status |
| Distance/location | Local hard floor + ordering context | Be replaced by nationwide budget |
| Budget/pacing | Delivery gate | Buy relevance or policy approval |
| Merchant quality | Safety/quality guard | Permanently exclude legitimate newcomers |
| Availability/price freshness | Hard/conditional gate | Fabricate stock, discount or cheapest claim |
| Bid | Future optional selector | Override eligibility or relevance floor |
| Merchant sector | Weak contextual signal | Own product taxonomy or prove authorization |

## Safe no-ad behavior

No eligible sponsor, timeout, disagreement or selector failure returns the normal
organic response with no empty slot, delay-dependent reorder or customer-visible
error. Organic ranking must be reproducible without the ad system.

`SPONSORED_MAY_OUTRANK_NEARER_ORGANIC: CONDITIONALLY_PROPOSED`

`PAID_RELEVANCE_OVERRIDE: PROHIBITED`

`NUMERIC_FORMULA_FINALIZED: NO`
