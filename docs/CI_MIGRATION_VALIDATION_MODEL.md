# CI Migration Validation Model

State: PROPOSED — OWNER REVIEW REQUIRED

CI validates migration artifacts; it never automatically applies them to Production.

## Unprivileged PR gate

- file naming/order/immutability and duplicate version detection;
- canonical manifest/checksum consistency;
- SQL static/lint checks;
- apply full chain to an ephemeral local Supabase/Postgres instance;
- RLS/RPC/trigger/invariant and upgrade fixture tests;
- destructive-pattern review signal.

## Trusted Development gate

Only an explicitly approved job may use the exact Development project, scoped credential, serialized fixtures, pre/post checks, and cleanup. Production apply remains a separate protected human-authorized operation with backup, dry-run evidence, environment identity, and rollback/forward-fix plan.

Migration bytes that passed CI must match bytes approved for execution.

OWNER_DECISION_REQUIRED: choose ephemeral database tooling and protected Development workflow; no workflow is created here.
