# Test Ownership Model

**State:** PROPOSED

The feature agent writes or updates the tests needed by its change. Integration independently verifies that the combined branch preserves shared contracts and does not inherit another agent's unsupported claims.

## Responsibilities

- feature agent: targeted unit/widget/contract tests, fixture cleanup and local evidence;
- backend/migration owner: RLS/RPC/invariant/concurrency and Development dry-run evidence;
- integration: changed-scope review, full/risk-selected regression, conflict and environment checks;
- release owner: exact artifact, signing, physical/manual and go/no-go evidence;
- domain/policy owner: expected behavior where engineering cannot infer it.

Test ownership follows the protected behavior, not permanent personal ownership. Failures route to the domain most able to fix the root cause.

No agent may mark physical, Production or owner-choice gates PASS through documentation alone.
