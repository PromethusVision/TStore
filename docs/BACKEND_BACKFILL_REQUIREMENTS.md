# Backend Backfill Requirements

**State:** PROPOSED — NO BACKFILL EXECUTED

## Before

- exact environment/schema/ledger and source/target counts;
- deterministic mapping rule, policy/version and ambiguity class;
- dependency/lock/storage/runtime estimate and stop thresholds;
- backup/restore evidence appropriate to risk;
- idempotent batch identity, checkpoint and dry-run report;
- representative old/new client compatibility tests.

## During

Use bounded deterministic batches ordered by immutable key. Write only missing or
exact-compatible targets using expected source revision. Record scanned, eligible,
written, already-correct, ambiguous, conflicted, failed and retry counts. Do not
coerce ambiguity or overwrite concurrent edits.

## After

Reconcile total and per-class counts, relationship integrity, null/duplicate/error
registries, query behavior, RLS and performance. Shadow compare old/new projections.
Keep source fields until the migration and supported-client gate closes.

Product variants, organization membership and product split mappings must remain
unresolved when evidence is insufficient. Exact Production backfill requires a
separate authorized change task.

