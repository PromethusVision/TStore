# Merchant App QR Operational Load Model

Status: **PROPOSED SIMULATION — NO PERFORMANCE CLAIM**
Wave: 17 / WP107

## Load dimensions

- Opening/closing-time bursts at one shop.
- Many shops scanning independently.
- Two or more staff racing one token.
- Customer regenerates QR while prior token remains near expiry.
- Weak mobile network, timeout after commit and retry storms.
- App background/restart during validation or confirmation.
- Repeated invalid/wrong-shop scans and abuse-rate spikes.

## Required properties under load

- Exactly one verified transaction per eligible token.
- Authorization and shop binding are never skipped for throughput.
- Rate limiting distinguishes valid shop operations from suspicious repeated invalid input.
- Idempotency/reconciliation prevents retry amplification.
- Audit/telemetry is bounded and never stores raw tokens/customer PII.
- Customer result can read authoritative terminal state even if Merchant response was lost.
- Service degradation fails closed for new confirmations and preserves prior committed truth.

## Measurement plan

Track validation/confirm/reconcile latency distributions, error/result classes, concurrency conflicts, duplicate-prevention count and audit lag in an isolated load environment. Define capacity and SLO only after an implemented backend; this document asserts no throughput number.
