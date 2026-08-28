# Backend Schema Evolution Principles

**State:** PROPOSED — NO MIGRATION FILE

1. Start from current 0001–0009 facts and live callers; do not redesign by taste.
2. Prefer additive nullable/default-safe structures before changing reads/writes.
3. Separate schema deployment, data backfill, caller cutover and old-path retirement.
4. Preserve stable IDs, historical snapshots, RLS/RPC grants and error semantics.
5. Every migration is forward-only, deterministic, idempotency-aware and owned by
   one designated author.
6. Validate ledger vs actual schema, dependency counts, locks, runtime and rollback/
   forward-fix posture before remote application.
7. Unknown/ambiguous backfill rows remain explicit and fail closed.
8. New constraints use staged validation when table size/locks justify it.
9. New reads can precede writes only with compatibility; old clients remain safe.
10. Destructive cleanup/removal is a later separately authorized release.
11. Production apply is distinct from committing a migration artifact.
12. Development clean-room/dry run and client version overlap are mandatory gates.

Avoid default values that invent business truth, trigger-based dual-write without
reconciliation, silent enum coercion and rewriting applied migrations.

