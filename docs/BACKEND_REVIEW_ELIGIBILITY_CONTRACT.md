# Backend Review Eligibility Contract

**State:** CANONICAL RULE PRESERVED

## Eligibility predicate

An authenticated customer is eligible for a canonical product only when an
immutable, valid merchant-confirmed QR verified-purchase item references that
customer and product. Legacy order flags, cart/wishlist, directions, ad events,
rewards, rating, merchant assertion or client metadata are insufficient.

## Semantics

- evidence is reusable for edit/delete/recreate under the lifetime rule;
- repeat purchase and item quantity do not add review rights or weight;
- product lineage is resolved under explicit merge/split policy, never name match;
- invalidated/disputed evidence follows a versioned correction policy;
- the eligibility read is server-derived and customer-scoped;
- callers receive bounded reasons without private evidence leakage.

Current `get_product_review_eligibility` and mutation RPCs remain active. A future
projection may cache eligibility only if rebuildable from authoritative purchase
evidence and protected against duplicate events.
