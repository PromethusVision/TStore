# Fast Test Suite

**State:** PROPOSED — EVERY SMALL CHANGE

## Required core

1. Format check for changed Dart files.
2. `flutter analyze --no-pub` or a validated incremental equivalent that cannot miss cross-file errors.
3. Unit/Cubit/repository/widget tests directly affected by the diff.
4. Static architecture/security contract tests for touched boundaries.
5. `git diff --check` and changed-file scope review.

## Selection rules

Map changed production files to owning feature tests. Changes to shared core, Auth/session, navigation, environment config, dependency injection, models, Supabase constants, migrations or app bootstrap expand beyond one feature. A test-file-only change runs the modified test plus the production contract it claims.

## Time target

Aim for useful local feedback in a few minutes, but do not delete or skip critical assertions to meet an arbitrary clock. Measure the current suite before setting a hard budget.

## Exclusions

Remote live tests, signed packaging, physical devices, full clean-room database replay and store upload are not fast-suite steps. Their absence is explicit and handled by stronger gates.

`OWNER_DECISION_REQUIRED: FAST_SUITE_TIME_BUDGET`
