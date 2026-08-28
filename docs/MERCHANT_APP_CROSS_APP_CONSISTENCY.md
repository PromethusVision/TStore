# Merchant App Cross-App Consistency

Status: **PROPOSED — CONTRACT REVIEW REQUIRED**
Wave: 17 / WP74

| Merchant change | Customer expectation | Invariant |
|---|---|---|
| Price updated | New eligible price appears after bounded propagation | No universal product price |
| Listing unavailable | No longer shown as in stock/actionable | Unknown and unavailable stay distinct |
| Listing retired | Removed from active offers; history preserved | Verified snapshots remain |
| Shop temporarily closed | Visible/status treatment follows lifecycle decision | No new invalid QR confirmations |
| Shop suspended | Customer discovery/action disabled | Merchant role cannot override |
| Location updated | Nearby/directions use approved new coordinate | Old transaction snapshot unchanged |
| Product candidate approved | Listing can attach to governed identity | No duplicate canonical product |
| QR confirmed | Customer session becomes verified once | Exactly one transaction |
| Review reported | Visibility follows moderation policy | Merchant cannot directly hide/delete |

## Consistency rules

- Mutation response is authoritative for writer; reader projections may be eventually consistent within a declared target.
- Cache invalidation is scoped by entity revision/event, not global blind refresh only.
- Critical QR outcome has direct status reconciliation and cannot wait on analytics projection.
- Customer stale state is labeled or suppressed when action safety depends on current state.
- Merge/split/retirement preserves durable evidence through owner-approved catalog semantics.
