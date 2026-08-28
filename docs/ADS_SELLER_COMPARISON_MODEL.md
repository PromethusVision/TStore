# Seller Comparison Sponsorship Model

**State:** HIGH-TRUST-RISK PROPOSAL — P0 PRODUCT OWNER DECISION REQUIRED

## Question

When a customer opens one canonical product, may one paid seller row appear above
organic sellers? The known owner direction allows this possibility. Recommendation:
permit a tightly controlled pilot only after the following non-negotiable gates.

## Eligibility gates

- target is an active listing for the **same canonical product and exact variant**
  being compared;
- merchant controls the active physical shop/listing;
- known-in-stock/fresh availability and current price;
- shop inside approved local geo scope;
- product, merchant, campaign and creative policy eligible;
- budget/frequency/density valid;
- `Sponsorlu` visible on the row before interaction.

Similar, substitute, bundle or category-level products cannot buy this row.

## Presentation and ordering

- At most one sponsored row above the organic seller list.
- The sponsored row shows real distance and current price with no fabricated rank.
- Organic sellers remain sorted by the existing organic rule and are not reordered
  by sponsor bid/spend.
- Sponsor cannot claim nearest, cheapest, best, verified or recommended solely from
  payment.
- If the sponsored seller is also present organically, deduplicate the row while
  preserving access to its organic facts; never show two misleading copies.
- Customer can immediately compare alternatives and access “Neden Sponsorlu?” and
  report controls.

## Failure and lifecycle

If stock/price/shop/policy/selector/disclosure validation fails, remove the paid row
and show the exact organic comparison. No blank top row, delayed organic list or
fallback to a similar product is allowed.

## Contrarian risk

Seller comparison is the strongest point of customer purchase intent. A paid top
row can be interpreted as cheapest/nearest/platform endorsement even when labeled.
The owner should consider deferring this surface until Search/Category disclosure
and trust metrics pass a controlled pilot.

`SELLER_COMPARISON_SPONSORSHIP: PROPOSED_CONDITIONAL_YES`

`SAME_CANONICAL_PRODUCT_REQUIRED: YES`

`OWNER_P0_DECISION_REQUIRED: YES`
