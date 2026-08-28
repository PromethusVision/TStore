# CI Master Blueprint

**State:** PROPOSED — NO WORKFLOW CONFIGURATION

## Recommended V1

- untrusted PR: clean checkout, locked dependencies, format/diff/static, analyzer, deterministic tests, secret/dependency scan; no secrets or remote mutation;
- main: repeat gates, full regression, Android compile contract, iOS static/native validation when funded, local migration chain;
- release: protected human trigger, external signing, immutable artifact/hash/provenance, exact-artifact evidence;
- Production: human-authorized migration/store/rollback only, never default automation.

Start coarse and cheap. Add cache, shards, nightly, macOS and multi-app jobs only from measured need. Preserve first failures; quarantine is narrow and expiring. Pin third-party actions immutably and isolate environments/credentials.

Entry points: [platform options](CI_PLATFORM_OPTIONS.md), [PR gate](CI_PR_GATE_MODEL.md), [main gate](CI_MAIN_GATE_MODEL.md), [release gate](CI_RELEASE_GATE_MODEL.md), [secret handling](CI_SECRET_HANDLING.md), [automation boundaries](CI_AUTOMATION_SAFETY_BOUNDARIES.md).

`CI_CONFIGURATION_CREATED: NO`
