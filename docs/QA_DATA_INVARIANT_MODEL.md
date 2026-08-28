# Data Invariant Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

Invariants must be server-authoritative and tested across direct writes, RPCs, retries, concurrency, migrations, and role boundaries.

## Core candidates

- QR confirmation is single-use and bound to expected shop/customer context;
- verified purchase price snapshot is immutable;
- at most one active review per canonical eligibility contract;
- listing mutations belong to the authorized shop/merchant;
- customer clients cannot self-assign merchant/staff/operator roles;
- canonical product and taxonomy stable identity survives rename/move;
- merge/split preserves history without arbitrary reassignment;
- ad/reward events are idempotent and cannot alter review eligibility;
- audit records exist for privileged correction.

Each invariant has positive, negative, race, retry, and migration checks. Client validation is supplementary.

OWNER_DECISION_REQUIRED: approve invariant registry ownership as domains become runtime.
