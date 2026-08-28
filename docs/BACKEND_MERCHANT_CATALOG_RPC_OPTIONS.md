# Backend Merchant Catalog RPC Options

**State:** PROPOSED OPTIONS — NO IMPLEMENTATION

## Option A: direct listing CRUD with RLS

Simple but weak for canonical validation, idempotency, revision conflicts,
candidate creation and audit. Suitable only for narrowly allowlisted single-row
fields.

## Option B: bounded listing commands — recommended

`create_listing`, `revise_listing`, `set_listing_availability`, `set_listing_price`
and `retire_listing` (conceptual names) validate exact shop capability, product/
variant state, merchant SKU namespace, revision and idempotency. Each returns the
canonical committed listing projection and bounded conflict reason.

## Option C: generic merchant catalog mutation

One flexible endpoint reduces names but creates free-form payload, authorization
and versioning risk. Not recommended.

Candidate submission is separate from active listing creation. Bulk import should
be an asynchronous/batched future contract with per-row results, not one giant
transaction. Exact command grouping and direct-vs-RPC field split are
`OWNER_DECISION_REQUIRED`.

