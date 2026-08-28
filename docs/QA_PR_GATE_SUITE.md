# Pull Request Gate Suite

**State:** FUTURE CI CANDIDATE — NO WORKFLOW CREATED

## Required deterministic gates

- checkout of exact commit and locked Flutter/Dart dependency resolution;
- format check and `flutter analyze --no-pub`;
- full local `flutter test --no-pub` unless measured cost justifies safe sharding;
- migration artifact manifest and canonical migration static contracts;
- generated demo/taxonomy artifact check where changed;
- secret scan, dependency/security review and `git diff --check`;
- targeted compile contract for platform/config changes;
- changed-file ownership and skip/quarantine governance.

## Untrusted PR safety

PR jobs receive read-only repository permission and no Development/Production/signing secrets. They do not use privileged `pull_request_target` with untrusted checkout. Caches are treated as untrusted and contain no secrets. Third-party Actions should be reviewed and pinned to immutable full commit SHAs.

## Reporting

One concise summary lists failed gate, command, test file, skips/quarantines, artifact links and retry classification. Redaction is not assumed sufficient; sensitive values are never emitted.

## Non-gates

Remote live suites and signed release deployment do not run on arbitrary PRs. Physical acceptance remains release-candidate evidence.

`CI_PR_GATE_IMPLEMENTED: NO`
