# Wave 35A — Next Development Write Plan

**State:** `FUTURE PLAN ONLY — NO REMOTE WRITE AUTHORIZED OR EXECUTED`

This sequence is the next safe Development path after the read-only profile is
completed. Each remote mutation requires a separate explicit authorization.

## 1. Prerequisites

1. Separately authorize and resume only `EsnaftaVar Development /
   tnipyxnvhgelwdpykyez`.
2. Rerun Wave 35A read-only and populate all three live CSVs with exact category,
   product, listing and dependency records.
3. Verify fresh migration ledger, schema drift, server capabilities, RLS/policy,
   functions, indexes, Realtime and Storage references.
4. Freeze a single-writer change window and the exact repository/manifest hashes.
5. Obtain a fresh secure backup and prove restore in a disposable environment.
6. Freeze the 18 anchor-only assignability decisions and prepare fail-closed
   queues for all live split/manual/policy products.

Stop on identity mismatch, drift, missing restore proof, ambiguous active product
mapping, unsafe policy activation or unrelated writes.

## 2. Stable UUID allocation

1. Preserve a current UUID only after semantic identity is reviewed.
2. Allocate trusted-backend UUIDv4 values once for genuinely new nodes.
3. Store an idempotent planning-key-to-UUID allocation ledger outside clients.
4. Convert parent, alias and lineage edges through that ledger.
5. Preserve rename/move UUIDs; represent merge/split/retire history explicitly.

Allocation is a controlled backend operation. Flutter/client generation and
name/path-derived IDs are prohibited.

## 3. Migration creation

Create one reviewed migration in the active canonical chain, initially for local
rehearsal only. Prefer additive fields/tables and backward-compatible reads:

- explicit source key, level, lifecycle, assignability, policy/review state and
  taxonomy version;
- alias/synonym and predecessor/successor lineage;
- depth, cycle, parent-level and uniqueness validation;
- security-invoker root/children/descendant/path lookups;
- fail-closed product/listing visibility.

Do not delete/replace `categories.id`, existing product IDs or listing/evidence
identities.

## 4. Staged import

1. Import all canonical nodes as `staged` and inactive in parent-first order.
2. Re-run the import to prove idempotency.
3. Reconcile exact 1,563 and 24/244/1,096/199 counts, 1,245 leaves, unique IDs,
   no orphan/cycle/L5 and policy metadata completeness.
4. Load alias and lineage registries without enabling ambiguous redirects.

## 5. Product reassignment

1. Snapshot each `(product_id, old_category_id)` pair.
2. Require one reviewed assignable target for every active product.
3. Quarantine zero/multiple-target and pending-policy products.
4. Update only approved `products.category_id` values in measured batches or one
   reviewed transaction chosen from live size evidence.
5. Preserve product/listing/review/wishlist/cart/QR/verified-purchase identities
   and immutable snapshots.

## 6. Postchecks

Verify exact before/after counts, all FKs, zero orphan/cycle, alias/lineage totals,
policy/RLS/grants, public fail-closed behavior, demo dependencies and unchanged
historical evidence.

## 7. Client compatibility

Before activation, ship and validate root-only Home reads, variable-depth child
navigation, exact-leaf/descendant product scopes, breadcrumb/alias/search,
inactive/retired/quarantine states and old/new serializer compatibility.

## 8. Activation

Activation is a later, separately authorized change window. Activate only
policy-cleared containers/leaves parent-first; retire legacy categories only
after every dependency is mapped; run customer read, search, seller comparison,
cart, QR and review regressions.

## 9. Rollback

Keep the pre-change assignment snapshot and restored baseline available. Rollback
must deactivate staged canonical nodes, restore product category assignments and
compatible reads without deleting audit/lineage history. Rehearse this exact
sequence locally before any Development apply.

`DEVELOPMENT_WRITE_EXECUTED: NO`

`MIGRATION_CREATED: NO`

`UUID_ALLOCATED: NO`

`WRITE_AUTHORIZATION_REQUIRED: YES`
