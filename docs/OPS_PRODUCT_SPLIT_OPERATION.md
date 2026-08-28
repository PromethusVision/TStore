# Canonical Product Split Operation

**State:** PROPOSED — VERY HIGH RISK, NO RUNTIME OPERATION

A split determines that one predecessor represented multiple semantic products/variants. Unlike rename/move, one old ID cannot silently redirect to an arbitrary child.

## Preconditions

- exact reason and identity dimensions causing split;
- candidate successor definitions and stable identities;
- deterministic classification rules where evidence supports them;
- inventory of active listings, reviews, verified purchases, carts/wishlists, search/URLs, analytics, ads/rewards, imports, and policy;
- manual reclassification plan for ambiguous records;
- Catalog + Policy review where sensitive;
- second review, dry-run, reconciliation, and rollback/superseding plan.

## Assignment rules

| Record | Proposed handling |
|---|---|
| Listing with decisive variant/product evidence | Map deterministically and audit |
| Ambiguous listing | Pause affected capability and request merchant/operator evidence |
| Review | Preserve original product context; map only under owner-approved semantics |
| Verified purchase | Immutable historical snapshot; never fabricate successor |
| Analytics | Keep predecessor dimension plus explicit successor bridge |
| Alias/deep link | Disambiguation or neutral predecessor landing; no arbitrary child |
| Ad/reward target | Pause/re-evaluate; no inherited eligibility |
| Policy state | Evaluate each successor independently |

## Failure controls

No bulk default-to-first-child, no deletion of predecessor, no hiding unresolved count, and no Production execution without Development dry-run and explicit authorization. Every mapping has evidence/rule version.

`SPLIT_DEFAULT_SUCCESSOR: PROHIBITED`

`PRODUCT_SPLIT_RUNTIME_EXECUTED: NO`
