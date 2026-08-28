# Sponsored Search Interaction Model

**State:** PROPOSED SEARCH SAFETY CONTRACT — NO SEARCH RUNTIME

## Query behavior

| Query | Eligible sponsorship | Safe fallback |
|---|---|---|
| Exact product/model | Exact active listing for resolved canonical product/variant | Organic exact products/sellers only |
| Broad category | Active listing inside resolved category with strong contextual relevance | Organic category results |
| Brand-like | Authentic catalog brand/product evidence; no competitor impersonation | Organic brand/product grouping or clarification |
| Ambiguous | Serve only after confidence threshold; otherwise separated groups/no ad | Organic disambiguation |
| No eligible sponsor | None | Organic ranking unchanged |
| Multiple sponsors | Apply hard gates, caps, pacing, fairness/rotation | At most approved density; remaining organic |
| Only distant sponsors | Reject outside local ceiling | Nearby organic results, even if fewer |
| Policy-sensitive query | Exact allowlist and review | Policy-safe organic or no result |

## Interaction contract

- Preserve raw customer intent and Turkish-aware normalization.
- Search synonyms may retrieve candidate contexts but cannot invent product facts or
  relax policy.
- Merchant sector is not enough to match a product query.
- Sponsored listing opens the same truthful product/shop destination as represented.
- Back navigation and pagination retain disclosure and do not multiply impressions.
- Typo/fuzzy expansion is lower confidence than exact canonical/product evidence.
- One sponsored result cannot cause organic results to be removed from the result
  set; only approved interleaving changes the visible position.

## Proposed first-page guardrails

- maximum one sponsored item in first five and <=20% page;
- no duplicate listing/merchant in sponsored and organic card without explicit
  dedup/label handling;
- exact same product required for seller comparison;
- no empty sponsored placeholder;
- textual `Sponsorlu` label present before measurement as qualified impression.

Exact density and thresholds require owner/usability testing.

`NO_ELIGIBLE_SPONSOR_BEHAVIOR: ORGANIC_ONLY`

`AMBIGUOUS_QUERY_AD_AUTOPICK: NO`

`SEARCH_RANKING_FORMULA_FINALIZED: NO`
