# EsnaftaVar Observability Signal Model

**State:** `PROPOSED PILOT-SIZED MODEL`

| Signal | Best use | Guardrail |
|---|---|---|
| Log | Discrete error/state detail with bounded structured fields | No payload dumps, secrets or private content |
| Metric | Aggregate rate, latency, saturation, count/gauge | Bounded labels; no customer/raw URL cardinality |
| Trace/request correlation | Path and timing of one request chain | Sampled/purpose-bound; opaque IDs only |

OpenTelemetry distinguishes logs, metrics and traces and supports correlation, but
this architecture does not require a full distributed-tracing platform for the
pilot. Start with structured logs, critical counters/latency distributions,
release/environment and request/correlation IDs. Add traces only where multi-hop
diagnosis repeatedly fails without them.

Business domain events remain separate from diagnostic logs. A log that says a
purchase succeeded is not the authoritative purchase fact.

Reference: <https://opentelemetry.io/docs/concepts/signals/>

`FULL_DISTRIBUTED_TRACING_REQUIRED_FOR_PILOT: NO`
