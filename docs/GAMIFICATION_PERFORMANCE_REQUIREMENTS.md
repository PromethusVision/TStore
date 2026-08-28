# Gamification Performance Requirements

**State:** CONCEPTUAL — TARGETS TBD

## Principles

- Do not synchronously scan purchase/review history on Home, shop card or QR confirmation.
- Append authoritative events quickly; calculate reward/badge/reputation projections asynchronously.
- Read precomputed customer/shop projections with version/freshness metadata.
- Partition/limit ledger and audit queries by stable identity and time.
- Batch replay/backfill with checkpointing, rate limits and production kill switches.
- Preserve idempotency under retry, concurrency and worker restart.

## Measurements required later

Event-ingest latency, derivation lag, projection-read latency, queue depth, retry/dead-letter rate, duplicate suppression, replay throughput and hot-shop/customer skew. Numeric SLOs remain TBD after workload measurement.
