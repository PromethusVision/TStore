# Migration Postcheck Model

State: PROPOSED — OWNER REVIEW REQUIRED

Postchecks determine whether the intended contract—not only SQL completion—holds.

## Checks

- applied migration versions/checksums and schema objects;
- RLS enabled and role matrices unchanged except approved deltas;
- RPC signatures, grants, triggers, indexes, constraints, and invariants;
- row counts and null/orphan/duplicate checks using non-sensitive aggregates;
- app contract smoke for current and previous-supported clients;
- latency/error/lock/auth/QR/catalog health signals;
- backfill completeness and restart state;
- no unexpected test/demo fixtures.

Evidence links to the change record and exact queries/tool versions. A failed postcheck triggers the predefined contain/forward-fix/rollback decision; arbitrary manual row editing is prohibited.

OWNER_DECISION_REQUIRED: approve observation window and severity thresholds after baselines exist.
