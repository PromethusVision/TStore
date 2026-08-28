# Canonical Product Merge Operation

**State:** PROPOSED — HIGH RISK, NO RUNTIME OPERATION

A merge asserts that multiple predecessor identities represent one semantic product/variant under the approved catalog model. It is not a convenient duplicate cleanup.

## Preconditions

- strong evidence and resolved identity dimensions;
- no unresolved policy/variant/pack conflict;
- selected survivor or new successor with rationale;
- impact preview for listings, reviews, verified purchases, carts/wishlists, search, analytics, ads, aliases, imports, and deep links;
- collision resolution rules;
- authorized Catalog Reviewer and second-review candidate;
- rollback/superseding strategy.

## Preservation contract

| Asset | Required behavior |
|---|---|
| Product IDs | Predecessors retained as retired aliases/successors, not hard deleted |
| Listings | Repoint only through explicit mapping; preserve shop SKU/price/history |
| Reviews | Preserve evidence/authorship; deduplicate only by owner-final rule |
| Verified purchases | Immutable snapshot and predecessor identity remain interpretable |
| Analytics | Historical IDs remain queryable; future projection maps successor |
| Search/deep links | Old slugs/IDs resolve safely without losing identity |
| Catalog provenance | All assertions/conflicts and merge decision retained |
| Ads/rewards | Pause/re-evaluate dependent targets; no silent transfer of eligibility |

## Execution design

Preview → lock/revision check → append merge event → establish predecessor/successor edges → migrate projections idempotently → reconcile counts/conflicts → verify aliases/dependencies → release/rollback decision.

A reversal is another governed event; it cannot pretend the merge never occurred.

`PRODUCT_MERGE_RUNTIME_EXECUTED: NO`

`HISTORICAL_REFERENCE_LOSS_ALLOWED: NO`
