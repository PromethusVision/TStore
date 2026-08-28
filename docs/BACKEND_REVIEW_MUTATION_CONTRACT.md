# Backend Review Mutation Contract

**State:** PRESERVES RPC-ONLY SECURITY BOUNDARY

Review create, update and delete remain server contracts. Direct client table
mutation stays revoked.

## Create

Validate customer, verified evidence, canonical product, uniqueness, rating and
bounded content in one transaction. Client cannot supply author or verification.

## Update

Only the author may change allowed content/rating using expected revision and an
idempotency key. Product, author and evidence identity are immutable. Moderation
state is not customer-editable.

## Delete/recreate

Customer deletion changes active visibility under the approved lifecycle; it does
not erase evidence/audit. Recreate is permitted only under the same verified
eligibility and one-active rule. Operator removal is a distinct case-based action.

## Side effects

Aggregate refresh and review events occur once with the committed revision.
Notification/analytics failure cannot duplicate or fabricate the review.

Retention and restoration semantics are `OWNER_DECISION_REQUIRED`; current RPC
response compatibility must be preserved during evolution.

