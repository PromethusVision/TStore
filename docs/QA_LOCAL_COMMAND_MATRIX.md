# Local QA Command Matrix

**State:** DOCUMENTED COMMANDS — NOT EXECUTED BY THIS DESIGN TASK

Commands assume the repository-pinned dependencies already exist; `--no-pub` prevents implicit resolution during verification.

| Purpose | Command | Mutation/safety note |
|---|---|---|
| Analyzer | `flutter analyze --no-pub` | local generated analyzer output only |
| Full Flutter suite | `flutter test --no-pub` | five opt-in declarations keep remote tests off; recorded baseline has six skips |
| Targeted test | `flutter test --no-pub test/path/file_test.dart` | deterministic local file only unless explicitly live |
| Format check | `dart format --output=none --set-exit-if-changed lib test tool` | check mode; no rewrite |
| Diff whitespace | `git diff --check` | read-only |
| Tracked scope | `git status --short` and `git diff --name-status <base>..HEAD` | read-only |
| Migration manifest | `node tool/verify_migration_artifact_manifest.mjs` | reads nine SQL files and recorded hashes |
| Demo generator check | `dart tool/demo_seed/generate_esenler_demo_v1.dart --check` | byte-for-byte check only |
| Demo contract | `flutter test --no-pub test/unit/demo_seed/esenler_demo_v1_contract_test.dart` | static/local |
| Migration Dart contracts | `flutter test --no-pub test/unit/supabase/canonical_migrations_contract_test.dart` | static SQL contract |
| Synthetic Production web compile | `flutter build web --release -t lib/main_production.dart --dart-define-from-file=tool/production_compile_contract.json` | compile-only, non-deployable |
| Development debug APK | `flutter build apk --debug --flavor development -t lib/main_development.dart` | no release signing |
| Production APK/AAB | exact documented production flavor/target | requires secure signing and release authorization |

## Guardrails

Do not append `--no-tree-shake-icons` to hide build defects. Do not run linked Supabase commands from this matrix. Live tests require their own documented opt-in, exact project identity and ignored secret file.

`COMMAND_MATRIX_VERIFIED_STATICALLY: YES`
