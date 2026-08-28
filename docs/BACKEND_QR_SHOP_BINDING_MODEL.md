# Backend QR Shop Binding Model

**State:** FAIL-CLOSED CONTRACT

The issuing server binds every QR session to one exact shop ID derived from the
single-shop cart. Confirmation compares that immutable ID with the caller's
authorized shop scope.

## Rules

- organization membership does not authorize sibling shops implicitly;
- a merchant client cannot submit an alternate shop ID to rebind a token;
- shop rename/location edit keeps ID and does not break valid binding;
- shop transfer/suspension rechecks current policy at confirmation;
- shop closure/cancellation makes unresolved active tokens invalid under a bounded
  reason;
- public demo shops with `owner_user_id = NULL` have no verifier authority;
- a mismatch reveals no customer/item detail and creates no transaction.

Cross-branch confirmation is recommended **not supported** in V1. Any future
shared-counter exception is `OWNER_DECISION_REQUIRED` and would need explicit
issuance scope, capability and customer disclosure—not a broad membership OR.

