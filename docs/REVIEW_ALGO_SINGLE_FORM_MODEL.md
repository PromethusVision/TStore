# Single-Form Evaluation Model

**State:** UX SEMANTICS PROPOSAL — NO UI IMPLEMENTATION

## Recommended flow hypothesis

1. Show purchase/shop/product context and bounded verification explanation.
2. Show existing product review as **edit**, or an empty product review if none exists.
3. Ask up to four clearly shop-scoped structured questions; allow skip/not applicable.
4. Review a summary separating `Ürün yorumun` and `Mağaza deneyimin`.
5. Submit one idempotent flow request with independent section results.

## Section semantics

| Situation | Product section | Shop section |
|---|---|---|
| First product purchase/review | create allowed | current-purchase evaluation allowed |
| Existing active product review | edit existing; never create second | current-purchase evaluation independently allowed |
| Product section skipped | no product mutation | shop section may submit |
| Shop questions skipped | product may submit | no neutral/zero responses |
| One section fails validation | no false all-success message | successful section remains explicit/idempotent |
| Offline/duplicate tap | retry same request/evidence | exactly one terminal contribution per section identity |

## Comprehension guardrails

- Product stars use product wording; shop dimensions never inherit those stars.
- “Genel mağaza deneyimi” is a shop response, not product rating.
- No preselected midpoint and no forced response merely to publish product text.
- A merchant cannot require high structured scores to accept a remedy.
- Customer can understand whether editing product text will update an older shop feed projection.

## Question count experiment

Compare a three-item form with a four-item form in Phase 1 collection. Measure completion, skip rate,
time, straight-lining, variance and customer confusion. Do not optimize for completion by hiding
meaning or forcing default answers.

`VISIBLE_EVALUATION_FLOWS: 1`
`LOGICAL_OUTPUTS: 2`
