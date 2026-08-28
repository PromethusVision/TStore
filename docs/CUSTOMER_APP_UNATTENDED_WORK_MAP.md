# Customer App Unattended Work Map

Status: **PLANNING ONLY — NO BRANCHES CREATED**

| Lane | Parallel-safe work | Must wait for | Integration concern |
|---|---|---|---|
| Agent 1 | Dependency batches; pagination performance; build-size measurement/asset candidates | Owner-approved priorities; no Production | `pubspec.lock`, repositories and shared assets are conflict-prone |
| Agent 2 | Final UI-kit inventory/component migration by bounded screen groups | Final Figma/tokens | Theme/shared widget files require serialized integration |
| Agent 3 | Taxonomy compatibility fixtures, read-only mapping validator and migration dry-run tooling | Owner-final taxonomy/DB design | Models, queries and navigation touch shared contracts |
| Integration | Merge completed bounded branches; run full suite/analyzer/build/security diff | All branch results | Owns main, conflict resolution and final gate reconciliation |

## Safe parallel groups

- Dependency investigation can run in parallel with documentation-only UI and
  taxonomy preparation, but lockfile changes must be isolated.
- Asset optimization can run separately from component rollout if visual
  acceptance compares every changed asset.
- Pagination can be split by repository domain only after a shared cursor/page
  contract is agreed.

## Not unattended

Production dashboard checks/writes, physical two-device QR, signing credentials,
store submissions, iOS signing, privacy/product decisions and destructive data
work require owner/operator participation. Multi-agent execution must never turn
those external gates into assumed PASS results.
