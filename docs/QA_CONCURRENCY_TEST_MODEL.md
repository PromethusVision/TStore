# Concurrency Test Model

State: PROPOSED — OWNER REVIEW REQUIRED

Concurrency tests issue truly overlapping server operations from independent sessions; sequential Futures or one mocked repository are not sufficient.

## Priority races

- two merchant confirmations for one QR;
- duplicate review submission;
- concurrent listing price/availability writes;
- catalog candidate dedup/merge;
- reward accrual/redemption;
- campaign budget reservation;
- account/merchant suspension versus active write;
- migration/backfill versus application traffic.

Assertions cover one committed authority, deterministic loser response, no partial state, idempotent retry, audit evidence, and invariant preservation. Use synchronization barriers and repeatable synthetic fixtures; record database/runtime versions.

Production load/race attacks are prohibited. Run locally or in authorized isolated Development windows.

OWNER_DECISION_REQUIRED: choose concurrency repetition counts after flake/performance baselines.
