# Review, Evaluation and Badge Moderation/Dispute Model

**State:** OPERATIONS FOUNDATION — NO RUNTIME

## Separate objects, separate remedies

| Object | Valid intervention | Invalid intervention |
|---|---|---|
| product text/media | hide/redact under content policy; preserve history | merchant disagreement as removal reason |
| product rating | invalidate only with authoritative evidence/policy outcome | operator typing a preferred value |
| structured response | hold/exclude after evidence or abuse finding | editing `1` into `5` |
| aggregate | deterministic recomputation | manual score override |
| badge | lifecycle transition from versioned rule/case | paid/manual award |
| merchant reply/report | publish/moderate under UGC rules | retaliatory customer exposure |

Text moderation and structured-score validity are independent. Offensive text may be hidden while a valid
rating/evaluation remains; invalid evidence may remove aggregate effect while historical content is retained
for audit according to policy.

## Case flow

`REPORT → TRIAGE → EVIDENCE REVIEW → DECISION → DERIVED RECOMPUTE → NOTICE → APPEAL → CLOSED`

Cases reference review/evaluation/evidence/badge versions, reason codes and before/after projections.
High-risk bulk corrections require impact preview and separation-of-duties where operations policy demands.

## Appeals

- Merchant may contest evidence, attribution, fraud classification or rule application.
- Customer may contest removal, eligibility or misattribution.
- Appeal does not expose reporter/customer PII or detection thresholds.
- An appeal cannot purchase or negotiate a higher score.
- Reversal restores/recomputes from authoritative evidence; it does not rewrite the original decision.

## Special combinations

A negative product review and a positive shop evaluation are valid. Moderating one does not automatically
moderate the other. A product merge/split, shop transfer or closure uses lineage/correction rules, not a
generic moderation deletion.

`OPERATOR_RATING_EDIT: NO`
`MERCHANT_DISAGREEMENT_REMOVAL: NO`

