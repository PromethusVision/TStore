# Backend Parallel Agent Build Plan

**State:** FUTURE EXECUTION PLAN — NO RUNTIME WORK

## Persistent boundaries

| Lane | Primary ownership | May not own simultaneously |
|---|---|---|
| Agent 1 | migration/RPC/RLS contract implementation for the active backend wave; exact database tests | Customer/Merchant UI and another agent's migration |
| Agent 2 | Merchant App client/domain adapters, capability-aware states and targeted UI tests | database migration or Customer global navigation |
| Agent 3 | Customer compatibility/read models, catalog/search adapters and regression tests | database migration or Merchant authorization policy |
| Integration | source review, dependency order, conflict resolution, combined tests, Development/Production gate evidence | feature invention or hidden schema edits |

## Safe parallel examples

- Agent 1 builds an additive membership/RLS migration while Agent 2 uses a
  committed mock contract and Agent 3 strengthens existing Customer regressions.
- Agent 1 alone authors QR transaction changes; other agents may build clients
  only against the versioned command/error contract.
- Catalog correction and Reward/Ads consumers run in separate later waves; they
  do not share a migration author.

## Coordination rules

- One designated migration author per wave; no parallel edits to the canonical
  migration chain.
- Shared schema/RPC names freeze before client work; changes are communicated as
  contract revisions, not silently rewritten.
- Feature branches push only their own changes. Integration applies ordered
  commits and owns combined backward-compatibility evidence.
- Remote apply, Production write and destructive cleanup always require separate
  explicit authority.

