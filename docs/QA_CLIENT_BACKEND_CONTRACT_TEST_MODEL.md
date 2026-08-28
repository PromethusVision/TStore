# Client–Backend Contract Test Model

**State:** PROPOSED

## Contract surface

Each client-visible RPC/table projection should publish a versioned contract containing operation name, actor classes, request fields, response fields/nullability, typed error classes, idempotency boundary, side effects, privacy classification and minimum/maximum compatible client version.

## Test directions

1. **Server provider tests:** implementation satisfies the published contract for all actor and lifecycle states.
2. **Customer consumer tests:** current and previous supported client decoders accept additive responses and reject unsafe semantic drift.
3. **Merchant consumer tests:** future app uses the same stable identities but its own authorized projections.
4. **Fixture conformance:** mock JSON/DTO fixtures are generated or reviewed against the contract version; mocks cannot invent server fields.
5. **Compatibility replay:** new backend against supported old clients and new client against current backend.

## Drift classification

| Change | Default treatment |
|---|---|
| Add optional response field | backward compatible after consumer tolerance test |
| Remove/rename/type-change field | breaking; new contract/version required |
| Tighten authorization | security fix but old-client denial UX must be accepted |
| Relax authorization | security review and negative RLS tests required |
| Change error text only | clients must use typed code, not raw text |
| Change idempotency/side effect | breaking regardless of DTO shape |

## Gate artifact

A future machine-readable contract manifest should record schema/RPC revision and supported app builds. Tool and format are `OWNER_DECISION_REQUIRED`; this task does not add code generation or dependencies.

`SILENT_CONTRACT_DRIFT_ALLOWED: NO`
