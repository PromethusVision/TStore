# Backend Migration Observability

**State:** PROPOSED — NO MONITORING IMPLEMENTATION

Migration observability must answer what artifact ran, where, how far it progressed,
what changed and whether customers/merchants remain safe—without logging row PII or
secrets.

## Minimum signals

- environment/project fingerprint and migration/commit hash;
- start/end/duration, phase and success/failure/stop reason;
- scanned/eligible/written/already-correct/ambiguous/conflicted/failed counts;
- lock waits, statement duration, deadlocks, storage growth and connection pressure;
- RLS/RPC/grant/index/constraint postflight status;
- old/new projection mismatch and supported-client error rate;
- retry/resume checkpoint and reconciliation status.

Use exact read-only postflight queries and bounded logs. Row samples use synthetic or
opaque references with restricted access. Alert thresholds and dashboards exist
before Production apply; an absence of application errors is not proof of complete
backfill. Observability is evidence, not permission to auto-remediate.
