# Sponsored Ranking Guardrails

**State:** PROPOSED SAFETY CONTRACT — NO RUNTIME

## Hard gates

- exact listing/shop ownership and active lifecycle;
- canonical product/variant match to the customer intent;
- fresh price and explicit availability state;
- actual physical shop coordinate and allowed local scope;
- campaign active, funded and within schedule;
- product/listing/merchant/campaign policy eligible;
- visible `Sponsorlu` disclosure variant;
- no unresolved identity split, stale target revision or severe abuse state.

Failure of any hard gate means **do not serve**, not lower rank.

## Relevance and locality

- Seller comparison requires the same canonical product; a similar product cannot
  buy the seller row.
- Exact query beats broad category targeting.
- Merchant sector is a weak prior only and cannot prove the advertised product.
- Nationwide targeting is out of the V1 proposal.
- A distant sponsor may outrank a nearer organic seller only inside the approved
  local scope and after an exact/high-confidence match; real distance remains shown.

## Density and repetition

- Proposed ceiling: at most one sponsor in the first five Search/Category results
  and no more than 20% of a result page.
- At most one sponsored seller row in comparison.
- Same merchant/product/campaign repetition is capped across request/session/day
  using privacy-minimizing counters.
- Organic choices remain visible; ads never create an all-sponsored viewport.

Exact values are owner/usability decisions, not final here.

## Quality and truth

- Payment cannot create `nearest`, `cheapest`, `recommended`, `verified` or
  `discount` claims.
- Price bait, stock bait and misleading media trigger suppression/review.
- Badges/reputation and advertising eligibility are separate.
- New merchants can qualify through identity/listing/policy evidence without a
  minimum review-count monopoly.
- Advertiser cannot target competitor names deceptively or imitate another shop.

## Operational controls

- atomic budget reservation and idempotent measurement;
- invalid-traffic filtering and credits separated from ranking;
- policy/ranking decision reason codes and immutable audit trail;
- customer hide/report/why-sponsored controls;
- kill switch by campaign, merchant, product policy, surface and whole ad service;
- organic fail-open on uncertainty or latency timeout.

`IRRELEVANT_SPONSOR: HARD_BLOCK`

`SPONSOR_DOMINATION: CAPPED`

`ORGANIC_DISCOVERY_PRESERVED: YES`
