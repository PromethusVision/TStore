# Backend Event Outbox Options

**State:** PROPOSED OPTIONS — NO TABLE/WORKER/TRANSPORT

## Question

When must a committed domain mutation reliably produce an asynchronous fact for
notifications, analytics, rewards, reputation, ads, search or operations?

## Options

### A — Direct best-effort emission

Simplest, but a process crash between domain commit and emit can lose the event.
Acceptable only for disposable telemetry where authoritative state can be queried
and missing delivery has no product/economic consequence.

### B — Transactional outbox for critical domain facts — recommended

Write a minimal versioned event/outbox record in the same transaction as the
authoritative mutation. A worker delivers at least once; consumers deduplicate.
Use for verified purchase and future reward/financial, critical notification or
correction facts when downstream recovery cannot safely rely on scanning tables.

### C — Change-data capture from database log

Can reduce application coupling but adds platform/operations complexity, schema
interpretation and replay governance. Consider only after scale/ownership need is
proven.

## Required outbox contract

- immutable event ID/type/version, source aggregate/revision and environment;
- authority/privacy class and allowlisted payload—no raw QR, token or sensitive
  free-form data;
- commit atomically with domain fact;
- at-least-once delivery, durable consumer deduplication and bounded retries;
- claim/lease/attempt status that cannot change domain meaning;
- quarantine unsupported/invalid versions;
- observability, replay authorization, retention and backpressure;
- correction/superseding events rather than row rewrite.

## Decision

Adopt a **selective**, not universal, outbox after event registry/privacy/retention
approval. Customer App correctness must not depend on an analytics pipeline.
Pilot event list, transport/worker and retention are
`OWNER_DECISION_REQUIRED`. No schema or migration is authorized.

