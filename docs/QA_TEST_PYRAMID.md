# EsnaftaVar Test Pyramid

**State:** PROPOSED — TARGET BALANCE, NOT A QUOTA

## Recommended layers

| Layer | Relative volume | Primary ownership | Typical runtime |
|---|---:|---|---|
| Pure unit/domain | Highest | validation, models, facets, policy-independent logic | milliseconds |
| Cubit/BLoC | High | loading/error/success, stale generations, double submit, user switch | fast |
| Repository/contract | High | DTO/RPC mapping, safe errors, idempotency and compatibility | fast/medium |
| Widget | High | interaction, navigation, accessibility semantics, layout states | fast/medium |
| Static architecture | Focused | forbidden imports, signing/config/migration manifest | fast |
| Local backend contract | Focused but mandatory | migrations, RLS, RPC, triggers, rollback and concurrency | medium |
| App integration | Small | a few critical cross-layer journeys | slow |
| Physical acceptance | Smallest targeted set | native permissions, camera/GPS, deep links and exact artifact | manual/device |
| Production smoke | Minimal | non-destructive release wiring and health | controlled |

## Placement rule

Put a rule at the lowest layer that can prove it, then add one representative higher-layer journey. For example QR single-use belongs in database concurrency tests; Cubit tests prove retry/reconcile UX; two physical devices prove camera and real lifecycle. Repeating all permutations in E2E increases cost without improving the authoritative invariant.

## Current baseline interpretation

The repository already has strong unit/widget concentration: 58 unit, 59 widget and 6 architecture files, with controlled integration/live tests. It has no tracked `integration_test/` harness. This is not automatically a defect: new device E2E should be introduced only for critical cross-layer risk and must not duplicate existing widget coverage.

## Anti-patterns

- giant happy-path suites that hide which contract failed;
- remote tests in the default fast suite;
- sleeps instead of observable completion;
- mocks used to claim RLS, concurrency or native permission PASS;
- golden snapshots used as the main functional gate;
- coverage percentage used as the sole quality target.

## Gate principle

PRs should receive fast deterministic feedback. Full regression, backend replay, signed artifact and physical matrices belong to progressively stronger gates. A lower gate never promotes an unexecuted higher gate to PASS.

`PYRAMID_OWNER_DECISION_REQUIRED: INTEGRATION_HARNESS_SCOPE`
