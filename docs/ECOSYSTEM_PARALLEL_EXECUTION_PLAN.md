# Ecosystem Parallel Agent Execution Plan

**State:** FUTURE IMPLEMENTATION PROPOSAL

## Permanent boundaries

| Lane | Primary ownership | May not independently change |
|---|---|---|
| Agent 1 | backend authority, QR/review transaction, production acceptance | owner product policy, Ads/Reward economics |
| Agent 2 | merchant/ops/policy/Ads bounded work | canonical catalog identity, Customer navigation |
| Agent 3 | catalog/search/analytics/QA tooling | merchant authorization, production migration |
| Integration | shared wiring, migration ordering, combined verification | unreviewed source semantics |

## Safe parallel groups

- Customer regression and catalog read models can run beside merchant UI scaffolding.
- Policy registry research can run beside QA harness design.
- Analytics naming can run beside domain work only if it cannot manufacture authority.
- Ads/Reward/Gamification remain separate post-pilot branches with explicit owner gates.

## Serial ownership points

Only one migration author per wave. QR consume/verified-purchase change, canonical
identity correction, shared auth/bootstrap, release signing and any remote apply are
serialized. Integration reads task results, resolves conflicts semantically, runs
combined gates and alone advances the designated integration branch.

## Handoff checklist

Every lane reports base/head, changed files, invariant impact, migrations/RPC/RLS,
tests, remote reads/writes, secrets, blockers and `INTEGRATION_REQUIRED`. No lane
claims a manual or physical gate it did not observe.

`PARALLEL_EXECUTION_PLAN: PASS`
