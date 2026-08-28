# Backfill Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

Backfills are restartable, observable data transformations separated from schema deployment when scale or risk warrants it.

## Required tests

- empty, single, boundary, duplicate, malformed, and already-processed rows;
- deterministic result and idempotent rerun;
- chunking, checkpoint/resume, partial failure, and retry;
- concurrent application writes and old/new client reads;
- stable identity, provenance, audit, and no silent fan-out;
- representative volume/lock/latency without arbitrary thresholds;
- pre/post invariant reconciliation and exception registry.

Split/merge, taxonomy, catalog, review, and purchase history require explicit rules; ambiguous records go to review rather than arbitrary assignment. Logs contain aggregate progress and safe locators, not sensitive payloads.

OWNER_DECISION_REQUIRED: approve exception handling and who authorizes irreversible classification.
