# Migration Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

Migrations are immutable, ordered production code. Testing is Development-first and never implies automatic Production application.

## Layers

- static file/order/naming and canonical artifact-manifest validation;
- disposable local database apply from empty state;
- upgrade from representative prior schema/data;
- pgTAP or equivalent RLS/RPC/trigger/invariant tests;
- backfill volume, restartability, and idempotency;
- old/candidate client compatibility;
- rollback or forward-fix rehearsal;
- Development dry-run with pre/post evidence.

Tests must include concurrency and failure injection around transaction boundaries. Production data is not copied into CI; sensitive shape is represented by synthetic fixtures.

OWNER_DECISION_REQUIRED: approve local Supabase/ephemeral database CI scope and migration Production authorization chain.
