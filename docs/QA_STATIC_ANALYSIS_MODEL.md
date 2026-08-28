# Static Analysis Model

State: PROPOSED — OWNER REVIEW REQUIRED

## Required gates for Flutter/Dart changes

- `dart format` verification on changed Dart files;
- `flutter analyze --no-pub`;
- `git diff --check`;
- architecture/static contract tests relevant to the change;
- targeted searches for forbidden imports, debug endpoints, secrets, or platform identity drift.

Warnings are not silently converted to ignores. A suppression requires exact scope, rationale, owner, and review. Generated files are handled according to their generator contract.

Docs-only work uses markdown/content consistency, diff check, scope and secret scans; it does not claim Flutter analyzer evidence when no runtime changes occurred.

OWNER_DECISION_REQUIRED: decide whether future CI enforces repository-wide format or changed-file format during legacy cleanup.
