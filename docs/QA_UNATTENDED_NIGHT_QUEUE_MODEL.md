# Unattended Night Queue Model

**State:** PROPOSED — NO ELAPSED-TIME GUARANTEE

## Queue design

1. verify repo/worktree/base/branch and clean ownership;
2. read canonical scope/safety rules;
3. split only genuinely independent workstreams with explicit outputs;
4. after each meaningful unit run diff/scope/secret checks, commit and push;
5. isolate a blocked item, record exact reason and continue independent safe work;
6. stop before physical observation, secret entry, owner choice, Production or destructive action;
7. reconcile manifests/counts/IDs/cross-references in a final consistency pass;
8. report evidence honestly and leave a clean remote-matched tree.

## Stop conditions

Unexpected dirty worktree, source-branch conflict, secret/PII exposure, wrong environment, unsafe migration, corrupted artifact, ambiguous destructive target, force/history rewrite need or a decision that materially changes product intent.

Nonfatal missing optional branches, unimplemented future runtime and owner TBDs remain labeled and do not block unrelated analysis.

See [automation boundaries](CI_AUTOMATION_SAFETY_BOUNDARIES.md) and [Codex automation map](QA_CODEX_AUTOMATION_MAP.md).
