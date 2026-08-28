# Environment Test Contract

**State:** PROPOSED — NO REMOTE MUTATION

| Environment | Allowed | Forbidden | Promotion evidence |
|---|---|---|---|
| LOCAL | unit/widget/static, disposable DB replay, destructive fixture reset | real credentials, Production data copy | deterministic PASS and artifact output |
| DEVELOPMENT | isolated synthetic accounts, RLS/RPC/live concurrency, provider integration | Production keys/data, uncontrolled shared fixtures | exact project identity, prefix/run ID, cleanup |
| TEST | future dedicated disposable/staging contract; release-like config without customer data | being silently aliased to Production | owner-approved environment and reset policy |
| PRODUCTION | read-only health/catalog smoke by default; exceptional isolated write only with explicit authorization | load/adversarial/destructive tests, reset/seed, broad account creation | exact artifact, change window, owner, rollback and cleanup |

## Fail-closed selection

Every remote harness validates project ref/URL and expected environment before reading a credential. Environment is an explicit input; there is no fallback from missing Development/Test config to Production or vice versa.

## Current facts

Development and Production Supabase projects are distinct. No dedicated TEST remote is established in repository evidence. `TEST` therefore means local/disposable until an owner-approved isolated environment exists.

`OWNER_DECISION_REQUIRED: DEDICATED_TEST_ENVIRONMENT`

`PRODUCTION_AUTOMATED_MUTATION: NO`
