# Product Review and Shop Evaluation Evidence Model

**State:** CONCEPTUAL LOGICAL MODEL — NO DB/RPC

## Shared authority, separate use

One immutable verified-purchase item may be consumed by two independent policies:

```text
server-authoritative VerifiedPurchaseItem
  ├─ ProductReviewEligibility(customer, canonicalProduct)
  └─ ShopEvaluationEligibility(customer, shop, purchase)
```

The purchase is evidence of the QR confirmation event, not satisfaction, payment, authenticity,
receipt or a positive endorsement.

## Conceptual references

| Fact | Product review use | Shop evaluation use |
|---|---|---|
| verified purchase/item ID | durable eligibility and origin | exact submission eligibility |
| customer subject | lifetime uniqueness | customer-contribution cap |
| canonical product snapshot | review identity/history | feed context only; never merchant score |
| shop ID/snapshot | immutable feed origin | primary evaluation scope |
| merchant organization at event | lineage/context | optional future roll-up only |
| confirmation time | eligibility provenance | scoring window/recency |
| quantity/price | historical display where allowed | **no vote weight** |
| integrity/correction state | owner-rule projection update | hold/recompute eligibility |
| policy/question version | review policy interpretation | dimension meaning and aggregation |

## Origin rule recommendation

At first product-review creation, bind one qualifying verified-purchase item as immutable
`origin_evidence`. Its shop is the only shop whose merchant feed may project that free-text review.
Later purchases and review edits do not silently move attribution. If several purchases predate first
creation, the current eligible evaluation flow supplies the origin; any manual relink requires an
auditable owner-approved correction, never recency guessing.

## Correction boundary

- `DISPUTED` may hold derived badge/score effects without deleting source evidence.
- `VOIDED/INVALIDATED` recomputes the affected projection under a versioned owner rule.
- A content-moderation action may hide text while leaving a valid structured response.
- A fraud finding may invalidate structured contribution without operator-editing its value.
- No correction transfers product-review rights to an arbitrary product/shop successor.

`SHARED_EVIDENCE: YES`
`SHARED_AGGREGATE: NO`

