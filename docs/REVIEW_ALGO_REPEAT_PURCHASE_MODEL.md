# Repeat Purchase and Cross-Shop Evaluation Model

**State:** OPTIONS ANALYSIS — OWNER DECISION REQUIRED

## Frozen product-review result

All cases preserve one lifetime active product review per customer plus canonical product. Quantity,
repeat purchase, second shop and basket amount never create another product-review vote.

## Scenario matrix

| Scenario | Product review | Shop evaluation hypothesis |
|---|---|---|
| Same product, Shop A, first purchase | create or skip | evaluate Shop A |
| Same product, Shop A, later purchase | edit/keep same review | new raw Shop A response may be collected |
| Same product, Shop B, later purchase | edit/keep same review; no second | independently evaluate Shop B |
| Multiple products, one Shop A basket | each canonical product may have its own lifetime review | one shop-experience questionnaire per verified transaction, not per line |
| Quantity ten of one product | one product right | one shop response; no quantity weight |

## Shop contribution options

| Option | Meaning | Strength | Risk |
|---|---|---|---|
| A — per purchase | every verified transaction contributes | reflects repeated experiences | frequent customer/large merchant dominance |
| B — customer+shop lifetime | only one contribution ever | strong anti-spam simplicity | cannot reflect improvement/decline |
| C — latest customer+shop in rolling window | retain raw responses; latest eligible response is effective | recency plus one-customer cap | window/version complexity |
| D — bounded frequency | up to N contributions per customer/window | more longitudinal signal | threshold gaming and explanation cost |

## Recommendation for owner review

Prefer **C** as the research candidate: store each evidence-bound submission, but aggregate at most
one effective contribution per customer, shop and scoring window, normally the latest eligible
response. Exact window, replacement timing and appeal effect remain unselected. Phase 1 may collect
data without publishing a score while validating this assumption.

## Cross-shop attribution

Shop B receives its structured evaluation. The existing product free-text review remains projected
to its immutable origin shop; a Shop B purchase does not copy or move it. The single form must explain
that the customer is editing the product opinion while separately rating Shop B’s experience.

`REPEAT_PRODUCT_REVIEW_RIGHTS: 0`
`CROSS_SHOP_EVALUATION_ALLOWED: PROPOSED`
