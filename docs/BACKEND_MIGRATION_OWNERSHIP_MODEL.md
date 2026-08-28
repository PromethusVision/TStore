# Backend Migration Ownership Model

**State:** REQUIRED GOVERNANCE

## Roles

- **Migration author:** exactly one named agent per wave; owns sequence number,
  executable artifact and clean-room proof.
- **Security reviewer:** reviews RLS, grants, security-definer search path and
  service-role boundaries without editing the migration concurrently.
- **Contract reviewers:** Customer and Merchant owners verify client compatibility.
- **Integration/release owner:** accepts the commit, runs combined validation and
  controls authorized remote apply.
- **Product Owner:** approves only material product/policy/destructive/Production
  choices; does not choose lock or index syntax.

## Gates

1. Freeze the intended contract and owner decisions.
2. Inventory current ledger and actual schema without assuming either is truth.
3. Author one additive, ordered migration plus rollback/forward-repair plan.
4. Run clean-room apply, repeat/applicability checks, RLS/RPC/concurrency tests,
   N/N-1 client tests and data reconciliation.
5. Integrate normally; no rebase/history rewrite of applied migrations.
6. Apply to Development only under explicit Development authority.
7. Record postflight, soak and rollback evidence.
8. Apply to Production only under a distinct explicit authorization window.

Changing an already-applied migration is prohibited. Correct it with a new
forward migration and preserve the ledger/history evidence.
