# CI PR Gate Model

State: PROPOSED — OWNER REVIEW REQUIRED

## Candidate required jobs

- clean dependency/lockfile consistency;
- format/diff/static architecture checks;
- `flutter analyze --no-pub`;
- fast/targeted tests plus affected contract tests;
- secret and dependency advisory scan;
- platform/config compile contract when changed;
- documentation links/names when docs change.

PR jobs are unprivileged, read-only, and must not use Production/Development credentials. Untrusted code is not executed through a privileged `pull_request_target` pattern. Required status cannot be bypassed silently; emergency exception is audited and rerun after merge.

Full regression may run for shared/global changes or on main rather than every trivial docs PR.

OWNER_DECISION_REQUIRED: approve required status checks and exception authority.
