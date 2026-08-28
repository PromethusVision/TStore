# CI V1 vs Future Scope

**State:** PROPOSED — NO CI CONFIGURATION

## Recommended minimal V1

- GitHub Actions or equivalent hybrid candidate;
- clean checkout and locked dependencies;
- format/diff/static architecture, analyzer and deterministic Flutter tests;
- secret/dependency scan;
- canonical migration static + ephemeral validation when available;
- Android compile contract without signing secrets;
- preserved first failures and concise reports;
- no secret on untrusted PR, least privilege and pinned actions;
- protected human-gated signing/store/Production outside default CI.

## SHOULD after baseline

Change-aware jobs, safe cache, full main regression, selected artifacts, timing/flake metrics and macOS iOS validation if iOS enters pilot.

## DEFER

Nightly matrices, extensive sharding, self-hosted runners, full device cloud, automatic store promotion, automatic Production migrations, broad mutation/fuzz and multi-app jobs before Merchant runtime exists.

OWNER_DECISION_REQUIRED: select provider/budget; the technical recommendation is minimal hybrid CI.
