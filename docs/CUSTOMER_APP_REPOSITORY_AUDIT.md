# Customer App Repository and Use-case Audit

Status: PASS WITH DEFERRED DEAD-CANDIDATE CAPABILITIES

## Consistency

- Active feature repositories implement domain interfaces and return `Either<String, T>` or explicit typed review/recovery results.
- Authentication/user ownership is checked before customer writes; current user is resolved at operation time rather than stored permanently.
- Customer error mapping prevents raw Supabase exceptions from becoming UI copy.
- Paginated repositories use inclusive `range(from, to)` consistently.
- Critical multi-step mutations use canonical RPCs (QR, verified reviews/ratings, saved-location default/delete, account deletion) rather than trusting client orchestration.
- Product/shop/category/banner/brand reads are public discovery data; customer writes remain user-scoped.

## Findings

- `SupabaseService` exposes generic CRUD/storage helpers, but audited active repositories use explicit tables/filters. Capability presence is not evidence of an unscoped active write.
- Profile avatar methods target a deferred bucket and have no active presentation call site: `DEAD_CANDIDATE/BACKEND_SCHEMA_REQUIRED` before revival.
- Postal address repository/use cases are complete enough for unit tests but not routed; treat as legacy, not shipped.
- Chat contains a safe fallback when optional aggregate RPCs are absent. This preserves thread usability but should remain monitored during canonical backend changes.

No active legacy order repository leaked into the customer graph. No return-semantic mismatch justified runtime modification.

`REPOSITORY_AUDIT: PASS`  
`ACTIVE_LEGACY_REPOSITORY_LEAK: NO`
