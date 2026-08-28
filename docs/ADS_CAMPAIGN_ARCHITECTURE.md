# Sponsored Campaign Architecture

**State:** PROPOSED FOR PRODUCT OWNER REVIEW — CONCEPTUAL ONLY

## Minimal model

| Concept | Responsibility |
|---|---|
| `CAMPAIGN` | Merchant-owned objective, schedule, budget policy, geo/context and lifecycle root |
| `SPONSORED_TARGET` | Versioned reference to one eligible shop listing and its product/shop identity |
| `TARGETING_RULESET` | Contextual product/taxonomy/search and local geo constraints |
| `BUDGET_ENVELOPE` | Daily/total caps and reservation/spend/credit history |
| `CAMPAIGN_REVISION` | Immutable snapshot of editable settings at approval/serve time |
| `POLICY_DECISION` | Server-authoritative review outcome and reason |

An `AD GROUP` is not justified for the V1 proposal. It becomes useful only if one
campaign needs multiple targeting/bid/creative policies. V1 can model a campaign
with one or more independently eligible listing targets without exposing ad-group
complexity to a micro merchant.

## Proposed V1 fields

- immutable campaign ID and merchant/shop ownership;
- objective `LOCAL_PRODUCT_DISCOVERY`;
- one or more shop-listing target IDs;
- selected physical shop and geo scope;
- contextual product/category/search targeting;
- start/end window and time zone;
- proposed daily and total budget caps;
- lifecycle and review state;
- disclosure/creative variant identifier;
- revision, created/updated/effective timestamps;
- audit and policy reason references.

Names, slugs, search text and taxonomy paths are mutable metadata, never primary
campaign identity.

## V1 boundary

- contextual plus location-based listing promotion;
- no behavioral profiles, cross-app retargeting or external audience purchase;
- no automatic bidding or auction requirement;
- no CPA promise because EsnaftaVar has no online checkout conversion;
- no banner asset requirement for a native listing card;
- no campaign serving without organic fallback.

## Future candidates

- shop-awareness objective;
- ad groups and multiple creative variants;
- auction/bid strategy;
- merchant portfolio/branch budgets;
- experiment framework;
- advanced pacing and forecasting;
- service-object promotion after service identity exists.

## Validation rules

1. Campaign owner must control the target shop/listing.
2. Every target is evaluated independently at creation and serve time.
3. Schedule uses explicit zone and half-open effective intervals.
4. Budget exhaustion pauses serving atomically.
5. Editing a material field creates a revision and may require re-review.
6. A campaign cannot change Product or Merchant Taxonomy.

`ADS_CAMPAIGN_V1_COMPLEXITY: MINIMAL`

`AD_GROUP_V1: DEFER`

`OWNER_FINALIZATION_PERFORMED: NO`
