# Unified Shopping Evaluation Product Contract

**State:** PROPOSED PRODUCT DIRECTION — OWNER REVIEW REQUIRED

## Customer-visible promise

After an eligible physical QR purchase, the customer may see one
`Alışveriş Değerlendirmesi` flow containing:

1. **Ürün:** product rating plus the one canonical product free-text review.
2. **Mağaza deneyimi:** a short set of structured, independently optional 1–5 responses.

There is no second merchant/seller free-text review box. “One flow” describes UX and correlation,
not one database identity or one aggregate.

## Frozen product-review contract

- Only merchant-confirmed, server-authoritative QR physical-purchase item evidence grants rights.
- One active product review per customer plus canonical product for life.
- Repeat purchase and quantity do not create another active product review.
- Rating/title/comment may be edited; delete/recreate uses immutable evidence.
- Unverified legacy content never enters verified aggregates.
- Advertising and reward outcomes never establish eligibility or change weight.

## Independent logical outcomes

| Outcome | Identity hypothesis | Mutable customer content | Aggregate lane |
|---|---|---|---|
| Product review | customer + canonical product | product rating/text | product only |
| Shop evaluation response | customer + verified purchase + shop + dimension version | structured value | shop dimension only |
| Evaluation-flow submission | idempotent correlation/request | none after terminal result | none |
| Merchant feed projection | derived review/evaluation view | no independent content | no new vote |

## Required behaviors

- Either section may be skipped without fabricating zero/neutral answers.
- Product dislike and excellent shop experience, or the inverse, are valid combinations.
- A partial failure reports section-specific state; retry is idempotent and cannot duplicate either
  right or contribution.
- Product and merchant values are never averaged together or labeled as one star score.
- Customer-visible text explains what was rated, which shop/purchase supplied evidence and what
  “verified” does not prove.

## Non-goals

No runtime schema, RPC, badge threshold, mandatory dimension set, public merchant score or owner
decision is created by this contract.

`SECOND_MERCHANT_FREE_TEXT_REVIEW: NO`
`PRODUCT_REVIEW_RIGHTS_CHANGED: NO`
