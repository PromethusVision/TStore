# QA Parallel Execution Plan

**State:** PROPOSED — RESPECTS PERMANENT WORKTREES

## Future roles

- **Agent 1:** Customer App feature/regression implementation and critical widget/integration coverage.
- **Agent 2:** backend/live QR, Auth release acceptance, platform signing/release QA and environment-safety documentation.
- **Agent 3:** catalog/taxonomy/search/facet contract testing and deterministic large-data fixtures.
- **Integration:** independent combined diff, shared contract conflicts, full regression, analyzer, evidence freshness and task-branch integration.

## Parallel-safe

Independent test files, docs, fixture generators in separate paths, read-only audits, platform static checks and domain contract designs. Each branch owns its changes and pushes only its task branch.

## Serialize / coordinate

`pubspec.yaml`, routing/bootstrap, global providers, shared schema/migrations, signing/build configuration, CI workflows, environment credentials, live Development fixture windows and exact release artifact. Production is never parallel unattended work.

## Handoff

Each task reports base/head, files, tests, skips, environment, artifact identity, open physical/owner gates and clean tree. Integration never infers PASS from another agent's proposal.

OWNER_DECISION_REQUIRED: only staffing/platform gates; engineering allocates routine test work.
