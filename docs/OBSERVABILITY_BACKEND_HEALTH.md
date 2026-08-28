# EsnaftaVar Backend Health

**State:** `CONCEPTUAL — NO REMOTE MONITORING SETUP`

| Surface | Minimum signals |
|---|---|
| API/RPC | request count, success/error class, latency, timeout, policy rejection |
| Database | connection/transaction errors, query latency, lock/contention and migration state checks |
| Auth | signup/login/refresh delivery and failure class |
| Realtime | subscribe success, disconnect/reconnect, delivery lag, duplicate subscription symptoms |
| Storage | public media fetch success/latency by active bucket class; write attempts if enabled later |
| Functions/triggers | invocation, failure/retry, idempotent outcome reconciliation |

Dimensions are service, operation, environment, region where known and release/
schema version. Customer IDs, raw query paths, SQL values, tokens and payloads are
not metric labels/log fields.

Supabase Logs Explorer can support API, Postgres, Auth, Storage and Realtime
debugging; available retention/capabilities depend on project plan and must be
verified at implementation time. No Production project was read or changed.

Reference: <https://supabase.com/docs/guides/monitoring-and-debugging/logs>

`BACKEND_MONITORING_CONFIGURED: NO`
