# Rollback Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

Rollback testing proves a documented recovery path in an isolated environment. It does not authorize Production rollback.

## Cases

- transactional migration failure before commit;
- partial non-transactional operation;
- backward-compatible application rollback;
- restore from verified backup;
- forward-fix when down migration would lose data;
- kill-switch containment while mixed clients remain active.

Validate schema, data invariants, RLS/RPC, supported clients, migration ledger, audit evidence, and time/operational dependencies after recovery. A destructive down migration is not accepted merely because it executes.

Preferred strategy is expand–migrate–contract with forward repair; down migrations exist only when semantically safe and tested.

OWNER_DECISION_REQUIRED: define recovery objectives and destructive-rollback approval.
