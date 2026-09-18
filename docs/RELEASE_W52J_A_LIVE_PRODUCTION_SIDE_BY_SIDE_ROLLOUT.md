# W52J-A live Production rollout — rolled back

The authorized attempt against Production project `mefhfvrgkwciubeajjeb` ended **ROLLED_BACK** at 2026-09-18T22:33:41.809Z. The sealed executor stopped on `W52JB_SCHEMA_FINGERPRINT`. No application commit was acknowledged. Production is verified back at its original operational legacy baseline; canonical taxonomy is **not installed** and public activation remains OFF.

## Execution and failed gate

The authoritative main revision was `fb4d4dffe5dccc39437cd3898e68d92b642bdce0`. Both readonly baseline checks and the complete reviewed preflight passed: PG17.6, four categories, 20 products, 285 listings, 57 shops, frozen schema/legacy fingerprints, 20/20 mapping inputs, nine historical ledger entries, and absent 0010/0011/0012. All ten final prewrite gates passed after a fresh full logical backup.

The unmodified main-integrated W52J-B `apply0012` engine was invoked. It keeps the frozen SQL and the 0012 ledger insert in one persistent transaction. A schema fingerprint check failed inside that operation; the engine rolled the transaction back. The reviewed `rollback0012` then returned **ALREADY_BASELINE_NO_OP**, verified the original catalog and nine unchanged historical ledger entries, and made no cleanup changes. A separate readonly baseline check and all legacy HTTP comparisons passed afterward.

The sealed validator emits the same fingerprint error from both its pre-payload and post-payload legacy checks. It did not retain component-level hashes or the failure site. Therefore the exact differing catalog component and whether payload execution was reached are **unknown**. No live retry, relaxed fingerprint, manual SQL repair, or migration adaptation was attempted after this failure.

`PRODUCTION_WRITE_PERFORMED: YES` is a conservative record of invoking the authorized READ WRITE executor. It does not mean that migration changes committed: **durable Production change is NO**, 0012 is absent, and the final catalog/legacy-data/ledger checks match the original baseline.

## Credential transport and preflight order

The Product Owner entered the password locally via a secure PowerShell prompt. Private orchestration used temporary process PGPASSWORD with the exact Production direct host, TLS verify-full and a pinned CA, invoking the same sealed engine and validators. The repository's passfile-only transport, reviewed SQL, ledger logic and rollback code were unchanged. No credential was written into scripts, command arguments, evidence, or the repository. Cleanup removes PGPASSWORD from both execution processes.

The reviewed complete preflight requires a fresh backup. Accordingly, readonly target/ledger/legacy/schema checks ran first, followed by the fresh backup, complete reviewed preflight, and the executor's locked preflight. The first, earlier attempt had safely stopped before backup/write at an HTTP check. A subsequent owner-process readonly HTTP precheck and the live pre-apply HTTP checks passed. That earlier stop is retained in the JSON evidence.

## Backup and frozen hashes

- Outside-repository archive: `<USER_HOME>/EsnaftavarBackups/w52j-live-prewrite/EsnaftaVar-Production-W52J-LIVE-20260918T223258694Z.dump`
- Completed UTC: 2026-09-18T22:33:14.012Z
- Source PostgreSQL: 17.6
- pg_dump: 17.11; CUSTOM format; no schema/table exclusions
- Size: 537274 bytes
- Backup SHA-256: `e89b13e4481d4a5e2c6b60181df290791455b0dc39acec99fadc184112879b65`
- Execution bundle SHA-256: `3d124524bf1f7e3b30cd592c1c457e048aad5bc7a896e47401cd29a6e5b85e11`
- Original normalized 0012 SHA-256: `a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834`
- Reviewed payload SHA-256: `0983f9dec3f4621136add373be147005e4c6101c0de5886a8c10dc79527f12d3`

The non-empty archive passed the reviewed validator and was independently rehashed. The dump remains outside the repository.

## Verified final state

Legacy SQL checks passed as anon and authenticated. All eight live HTTP GET contracts returned HTTP 200 and matched their pre-apply row hashes: Home, Product Listing, category listing, Product Details, Seller Comparison, Shop Details, shop listings and Search. Counts remain four categories, 20 products, 285 listings and 57 shops, with zero product/listing orphans. The frozen baseline includes the original RLS/ACL/schema and data fingerprints. No Auth or Storage API write was used.

Canonical tables and mappings are absent after rollback. Zero canonical counts below mean **not installed**, not a completed staged validation. Canonical policy and hierarchy postchecks are NOT_APPLIED. Public activation was never performed. Physical smoke is NOT_RUN because no Android device was connected.

The extra private orchestration had passed local, network-isolated PG17.6 real-copy tests, including a forced post-apply failure and reviewed rollback. Those local passes do not override this failed live gate. The next work is to isolate the fingerprint discrepancy in a controlled diagnostic; no further Production mutation is authorized by this result.

## Task result

```text
W52J_A_LIVE_PRODUCTION_ROLLOUT: ROLLED_BACK
LIVE_PREFLIGHT: PASS
PRE_WRITE_BASELINE: categories=4, products=20, listings=285, shops=57
FRESH_PREWRITE_BACKUP: PASS
FRESH_BACKUP_SHA256_RECORDED: YES
0012_HASH_VERIFIED: PASS
0010_APPLIED: NO
0011_APPLIED: NO
0012_APPLIED: NO
0012_LEDGER_ENTRY: NOT_APPLIED
POST_MIGRATION_PRODUCTS: 20/20
POST_MIGRATION_LISTINGS: 285/285
POST_MIGRATION_SHOPS: 57/57
CANONICAL_NODES: 0/1563
CANONICAL_ROOTS: 0/24
TERMINAL_LEAVES: 0/1245
OWNER_MAPPINGS: 0/20
ORPHAN_PRODUCTS: 0
ORPHAN_LISTINGS: 0
BROKEN_PARENT_CHAINS: NOT_APPLIED
POLICY_REVIEW_GATES_PRESERVED: NOT_APPLIED
OLD_W52C_SQL_CONTRACT: PASS
OLD_W52C_HTTP_CONTRACT: PASS
OLD_W52C_PHYSICAL_DEVICE_POST_MIGRATION: NOT_RUN
CANONICAL_STAGED_BACKEND_CONTRACT: FAIL
SECURITY_RLS_CHECK: PASS
PUBLIC_CANONICAL_ACTIVATION_PERFORMED: NO
ROLLBACK_TRIGGERED: YES
ROLLBACK_RESULT: PASS
PRODUCTION_LEFT_IN_SAFE_SIDE_BY_SIDE_STATE: NO
PRODUCTION_WRITE_PERFORMED: YES
READY_FOR_NEW_CANONICAL_PRODUCTION_CLIENT_BUILD: NO
READY_FOR_PUBLIC_CANONICAL_ACTIVATION: NO
```

Machine-readable evidence: [w52j_a_live_production_post_migration_validation.json](data/w52j_a_live_production_post_migration_validation.json). Only these sanitized result files belong in the task-branch commit. No main merge or force push.
