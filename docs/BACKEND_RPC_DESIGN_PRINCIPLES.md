# Backend RPC Design Principles

**State:** PROPOSED — NO FUNCTION SQL

Use an RPC/server command when an operation needs multi-row atomicity, privileged
authority, capability evaluation, immutable evidence, idempotency, concurrency
serialization, bounded projection or a stable compatibility facade. Do not wrap
every CRUD call merely to hide SQL.

## Contract requirements

- stable versioned request/response and bounded error codes;
- authenticated subject derived server-side;
- least-privilege execute grant and internal object access;
- fixed search path and fully qualified objects for privileged functions;
- input size/type/range checks and no dynamic SQL from client data;
- idempotency scope plus same-key/different-payload conflict;
- expected revision where lost updates matter;
- transaction boundary explicit in documentation/tests;
- audit/correlation without secrets, raw QR or unrestricted payload;
- no exception text that leaks row existence or internals.

Security-definer is exceptional, narrowly scoped and separately reviewed. RPC
does not automatically mean secure; authorization and result filtering remain
inside the server contract. Migration rollout must preserve old callers until
compatibility is demonstrated.

