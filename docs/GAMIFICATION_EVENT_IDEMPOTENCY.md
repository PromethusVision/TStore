# Gamification Event Idempotency

Status: **PROPOSED — BACKEND CONTRACT REQUIRED**
Wave: 18 / Workstream AO

## Idempotency keys

- Source event ID + evaluator/rule version + subject identity.
- Ledger event ID and unique predecessor/type constraints for correction/reversal.
- Badge definition/version + subject + qualifying evidence set.
- Reputation projection revision/window.

## Rules

- Same source and rule returns existing evaluation; no duplicate reward/badge/metric.
- Same idempotency key with different payload conflicts.
- Replayed delivery, worker retry or app refresh is harmless.
- Product merge/split and account merge use lineage/correction events, not new “earn” events.
- Concurrent redemption/expiry/reversal is transactionally ordered and reconciled.
- Client-supplied key never grants eligibility or authorization.

## Unknown outcomes

Clients/services read authoritative evaluation/ledger state before creating a new logical request. Delivery exactly-once is not assumed; business outcome at-most-once per defined evidence is required.
