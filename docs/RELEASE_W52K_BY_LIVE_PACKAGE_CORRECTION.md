# W52K-BY — Live preview package correction

W52K-BY passes local readiness validation. The existing tester identity is resolved only at future runtime; bridge installation and tester authorization are separate transactions; rollback closes preview access before checking or removing bridge objects. No live Production or Development access occurred.

Authority: `ddb0bef7c0d0941c736d708540aafed815903dcd`. Branch: `astra-release/w52k-by-preview-live-package-correction`. No main merge or force push.

## Corrected execution contract

- Existing session: exact SDK-owned project cache key, UUID/issuer/subject/expiry validation, then server-verified current user. Only boolean gate results leave the helper. The actual owner identity was not read or resolved in BY. Missing, expired or phone-only sessions stop before write; the owner must use the intended existing account with the supported desktop cache.
- Stage A: unchanged 0013 bridge and exact ledger in one transaction, with **zero allowlist rows**. Independent committed-state SQL and HTTP checks deny tester, ordinary authenticated user and anonymous caller. Legacy reads and staged canonical data remain valid; public activation stays OFF.
- Stage B: separate transaction after repeating Stage A checks; one exact runtime UID, default one-hour lease, maximum 24 hours. The unchanged SQL table has a 30-day backstop; BY applies the stricter 24-hour executor and stored-row validation gates. No client write grant is added.
- Standalone removal: exact UID only, idempotent; Auth user and 0012 remain intact.
- Rollback: separately committed UID removal, separately committed EXECUTE revocation, then exact bridge teardown using RESTRICT and 0013 ledger reconciliation. Broader bad state cannot block the first containment steps. Core schema/RLS/data/public-flag drift is preserved and reported separately.
- Structural teardown failure: EMERGENCY_CONTAINMENT with access closed; retain the external fresh backup. Loss of DB connectivity/authority is reported as CONTAINMENT_FAILED rather than falsely claiming access was revoked.

## Two independent real-copy rehearsals

Both final runs restored all 958 archive entries and 69 data sections into fresh, network-disabled PostgreSQL 17.6 containers using the same runtime seal. No ports were published. The original backup was mounted read-only. It is the newest existing local archive, completed 2026-09-19 00:06:07 UTC; it predates 0012, so unchanged reviewed 0012 was reconstructed locally before BY. This is not a fresh live backup or live Auth proof.

Source archive SHA-256: `8d98258430fbb7eeccc8ead4e09efa59189aad84e961bb754fe223f07c3fcbc8`.

Both runs exercised the same deployStaged executor used by the future CLI, full SQL and HTTP contracts, standalone removal twice, rollback, final legacy checks and all 69 original data sections. Each fault case starts from a cloned checkpoint, without manual SQL repairs. Synthetic Auth identities/tokens remain local and are absent from evidence.

Nominal counts: 4 legacy categories, 20 products, 285 listings, 57 shops, 1563 staged canonical nodes, 24 canonical roots, 1245 terminal leaves and 20 owner mappings. Preview exposes 14 eligible products; 6 remain gated. L2/L3/L4, breadcrumbs, alias/search and exact-leaf scopes pass.

## Failure matrix

28 distinct scenarios passed in each fresh copy: 56 final executions, **0 active preview authorizations left after failure**. Public-ON fault cases preserve the injected flag; they do not silently switch it OFF.

| Scenario | Observed outcome | Active preview authorizations afterward |
| --- | --- | --- |
| tester_uid_missing | W52KBY_TESTER_UID_MISSING_OR_INVALID | 0 |
| invalid_uid | W52KBY_TESTER_UID_MISSING_OR_INVALID | 0 |
| tester_session_wrong_project | W52KBY_TESTER_PROJECT_IDENTITY_MISMATCH | 0 |
| expired_tester_session | W52KBY_SESSION_EXPIRED_SIGN_IN_EXISTING_ACCOUNT | 0 |
| invalid_session_signature | W52KBY_TESTER_SESSION_INVALID | 0 |
| wrong_package_hash | W52KBY_PACKAGE_HASH | 0 |
| public_activation_on_before_apply | W52JB_BX_PUBLIC_ACTIVATION_OFF | 0 |
| schema_fingerprint_drift_before_apply | W52JB_BX_0012_SCHEMA_DRIFT | 0 |
| missing_0012 | W52JB_0012_LEDGER_ENTRY_MISMATCH | 0 |
| allowlist_expiry_invalid | W52KBY_LEASE_MUST_BE_POSITIVE_AT_MOST_24_HOURS | 0 |
| bridge_deployed_default_deny_fails | ROLLED_BACK | 0 |
| anonymous_gains_preview | ROLLED_BACK | 0 |
| normal_auth_gains_preview | ROLLED_BACK | 0 |
| public_activation_after_stage_a | ROLLED_BACK_CORE_DRIFT | 0 |
| schema_fingerprint_drift_after_stage_a | ROLLED_BACK_CORE_DRIFT | 0 |
| rls_drift_after_stage_a | ROLLED_BACK_CORE_DRIFT | 0 |
| product_integrity_mismatch | ROLLED_BACK_CORE_DRIFT | 0 |
| listing_integrity_mismatch | ROLLED_BACK_CORE_DRIFT | 0 |
| bridge_ledger_inconsistency | ROLLED_BACK | 0 |
| bridge_ledger_missing | ROLLED_BACK | 0 |
| teardown_dependency_emergency | EMERGENCY_CONTAINMENT | 0 |
| insertion_failure | ROLLED_BACK | 0 |
| partial_stage_b_failure | ROLLED_BACK | 0 |
| invalid_stored_expiry | ROLLED_BACK | 0 |
| rollback_before_apply | ROLLED_BACK | 0 |
| allowlist_removal_twice | PASS | 0 |
| bridge_rollback_twice | ROLLED_BACK | 0 |
| public_activation_after_stage_b | ROLLED_BACK_CORE_DRIFT | 0 |

## Seal and verification

New runtime seal SHA-256: `9c13e4052ada602fa2cda4bb40725c1d800d6e84eb8b0de8274675d7fa39fe9c` (33 files). It includes executors, identity helper, containment, validators, manifest, immutable SQL and actual runtime data dependencies. Unrelated evidence, tests and this report do not invalidate it. Runtime tampering is rejected. Previous BX inputs and 0012/0013 sources are unchanged.

- Offline package tests: 23 PASS, 0 FAIL.
- Targeted Flutter preview/auth tests: 38 PASS, 0 FAIL.
- Full Flutter suite: 2134 PASS, 0 FAIL, existing 6 SKIP.
- Flutter analyzer: PASS, no issues.
- No UI/client changes, APK/AAB builds or uploads.
- No real UID, JWT, password, service-role key, DB credentials or absolute local user paths are committed.

## Future live retry boundary

READY means the corrected package and local evidence are ready for a separately authorized live retry. It does not mean that the real tester is already resolved or that live drift has been checked. Future gates still require the actual existing owner session, pinned client/CA, exact target, fresh verified external backup and current preflight. See [operator interface](../tool/production_preview_bridge/live_v2/README.md) and [machine-readable evidence](data/w52k_by_live_package_validation.json).

## TASK_RESULT

```text
W52K_BY_LIVE_PACKAGE_CORRECTION: PASS
TESTER_IDENTITY_HANDOFF_READY: PASS
UID_RUNTIME_ONLY: PASS
STAGE_A_BRIDGE_ONLY_DEPLOY: PASS
STAGE_A_DEFAULT_DENY_VERIFIED: PASS
STAGE_B_ALLOWLIST_SEPARATE_TRANSACTION: PASS
ALLOWLIST_EXPIRY_ENFORCED: PASS
STANDALONE_ALLOWLIST_REMOVAL: PASS
CONTAINMENT_FIRST_ROLLBACK: PASS
ROLLBACK_NO_LONGER_BLOCKED_BY_TRIGGER_STATE: PASS
REAL_PRODUCTION_COPY_REHEARSAL_1: PASS
REAL_PRODUCTION_COPY_REHEARSAL_2: PASS
FAILURE_INJECTION_SUITE: PASS
NEW_SEAL_READY: PASS
LEGACY_RUNTIME_PRESERVED: PASS
CANONICAL_STAGED_BACKEND_PRESERVED: PASS
FAILURE_INJECTION_CASES: 28
PREVIEW_AUTH_LEFT_ACTIVE_AFTER_FAILURE: 0
PUBLIC_CANONICAL_ACTIVATION: OFF
FULL_FLUTTER: 2134 PASS / 0 FAIL / 6 SKIP
ANALYZER: PASS
0012_CHANGED: NO
PRODUCTION_ACCESSED: NO
PRODUCTION_WRITE_PERFORMED: NO
READY_FOR_PREVIEW_BRIDGE_LIVE_DEPLOY_RETRY: YES
```
