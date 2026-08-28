# Backend Test Architecture

**State:** PROPOSED — NO DATABASE EXECUTION

## Layers

| Layer | Purpose | Safe target |
|---|---|---|
| Artifact/static | migration order, hashes, forbidden grants, signatures | repository only |
| Clean-room replay | apply all migrations from zero and inspect schema | disposable local Postgres/Supabase-compatible stack |
| Database unit | functions, constraints and triggers | local isolated database |
| RLS actor matrix | anon/customer/merchant/staff/operator allow/deny | isolated local/test principals |
| RPC contract | signature, authorization, error and side effects | local then Development |
| Concurrency | real parallel transactions and lock boundaries | isolated database/Development fixture |
| Migration transition | pre-state → apply → post-state/backfill | restored Development clone or disposable dataset |
| Remote acceptance | environment wiring and provider differences | explicit Development; Production read-only by default |

## Mandatory properties

- Every migration replays in canonical order and the manifest/hash is stable.
- RLS and grants are tested independently; one does not compensate for the other.
- RPC tests cover unauthenticated, wrong actor, cross-shop, stale revision and repeated command.
- Trigger tests assert both intended side effects and absence of unintended cascades.
- Concurrency uses genuinely overlapping requests, not sequential calls named concurrent.
- Idempotency key reuse with a different payload conflicts.
- Rollback claims distinguish transaction rollback, forward-fix and client rollback limitations.

## Current repo evidence

Nine canonical migrations, a SHA-256 manifest verifier, static Dart contracts and a PGlite clean-room harness exist. There is no tracked local Supabase CI configuration or `supabase/tests/database` pgTAP suite. PGlite is useful evidence but is not the hosted Supabase control plane.

## Safety

Local `db reset` may be destructive only to an explicitly local disposable stack. `--linked` commands are never implicit CI steps and Production apply is always a separately authorized operation.

`BACKEND_TEST_RUNTIME_IMPLEMENTED: NO`

`OWNER_DECISION_REQUIRED: LOCAL_SUPABASE_OR_POSTGRES_TEST_STANDARD`
