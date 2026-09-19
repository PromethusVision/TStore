# W52J-A live retry — Production side-by-side rollout

Production project `mefhfvrgkwciubeajjeb` completed the authorized 0012 rollout at 2026-09-19T00:06:48.708Z. Legacy runtime remains operational; the canonical backend is staged and validated. Public and preview activation remain OFF.

## Execution and authorization

The authoritative main revision is `d30d8b3569807d32b5934e27e790d38fcc2161b2`. The unmodified main-integrated W52J-B/W52J-C engine applied the frozen 0012 payload and its standard migration-ledger entry in one persistent PostgreSQL transaction; commit was acknowledged. Neither 0010 nor 0011 ran. No generic migration push, manual ledger repair, Development access, or client rebuild occurred.

The Product Owner entered the password locally through a secure PowerShell prompt. A private temporary PGPASSWORD transport invoked the same sealed engine and validators with the exact Production direct host and verified TLS. The existing passfile-only CLI transport was not modified. Passwords were not written into scripts, evidence, command arguments, or the repository. The owner wrapper clears PGPASSWORD in its final cleanup; the Product Owner confirmed PGPASSWORD_CLEARED: YES.

Read-only target, ledger, schema, mapping, and legacy checks passed before backup. The reviewed complete preflight includes a fresh-backup requirement, so it ran after backup. The W52J-C engine then repeated it in a READ ONLY transaction before opening READ WRITE, and repeated it under the reviewed write locks before sending the payload. The reviewed deterministic COLLATE "C" constraint ordering was retained; no schema field or ACL check was removed. The extra orchestration passed a network-isolated real-backup PG17.6 rehearsal, including a forced post-apply failure and automatic reviewed rollback.

## Frozen hashes

- Execution bundle: `f491e08aae3241f218fa2d3bced6ea05ff68d2fa46589d5892f77b62f0ee0cf0`
- Original 0012 normalized source: `a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834`
- Reviewed transaction payload: `0983f9dec3f4621136add373be147005e4c6101c0de5886a8c10dc79527f12d3`

## Fresh backup

- Outside-repository path: `<USER_HOME>/EsnaftavarBackups/w52j-live-retry/EsnaftaVar-Production-W52J-RETRY-20260919T000554886Z.dump`
- Completed UTC: 2026-09-19T00:06:07.492Z
- Source PostgreSQL: 17.6
- pg_dump version / format: 17.11 / CUSTOM
- Bytes: 537274
- SHA-256: `8d98258430fbb7eeccc8ead4e09efa59189aad84e961bb754fe223f07c3fcbc8`

The archive exists, is non-empty, passed the reviewed archive/hash checks, and was rehashed when this evidence was generated. The dump is not committed.

## Validation scope

All 20 products, 285 listings, 57 shops, and four legacy categories matched the frozen baseline. Legacy SQL contracts passed as anon and authenticated; eight live publishable-key HTTP GET contracts returned HTTP 200 and matched their pre-apply row hashes. No live Auth session or Auth/Storage write was used.

Canonical validation confirmed 1,563 nodes, 24 roots, 1,245 terminal leaves and 20 exact owner mappings. Level counts were 24 / 244 / 1,096 / 199. All mapped breadcrumbs matched, alias targets remained valid, and the 14 potentially eligible / six review-gated classification was preserved. All nodes remain staged; no canonical customer visibility was enabled.

The reviewed RLS/ACL/schema fingerprint passed. Canonical client write grants and exposed privileged private taxonomy helpers were zero. Roots, children, descendants, breadcrumb, exact-leaf, product-scope, alias and search requests remained fail-closed for anon and authenticated roles.

Physical W52C smoke was NOT_RUN because no Android device was connected. This is recorded separately from the passing SQL/HTTP contracts. No rollback was required on Production.

## Result

```text
W52J_A_LIVE_RETRY: PASS
PRODUCTION_WRITE_AUTHORIZED: YES
AUTHORITATIVE_MAIN: d30d8b3569807d32b5934e27e790d38fcc2161b2
TARGET_PROJECT: mefhfvrgkwciubeajjeb
LIVE_PREFLIGHT: PASS
SCHEMA_FINGERPRINT_PRE_WRITE: PASS
SCHEMA_FINGERPRINT_FIX_MAIN: PASS
DETERMINISTIC_COLLATION_MAIN: PASS
FINGERPRINT_PRE_WRITE_GATE_MAIN: PASS
PRE_WRITE_BASELINE: categories=4, products=20, listings=285, shops=57
FRESH_PREWRITE_BACKUP: PASS
FRESH_BACKUP_SHA256_RECORDED: YES
0012_HASH_VERIFIED: PASS
0010_APPLIED: NO
0011_APPLIED: NO
0012_APPLIED: YES
0012_LEDGER_ENTRY: PASS
POST_MIGRATION_PRODUCTS: 20/20
POST_MIGRATION_LISTINGS: 285/285
POST_MIGRATION_SHOPS: 57/57
CANONICAL_NODES: 1563/1563
CANONICAL_ROOTS: 24/24
TERMINAL_LEAVES: 1245/1245
OWNER_MAPPINGS: 20/20
ORPHAN_PRODUCTS: 0
ORPHAN_LISTINGS: 0
BROKEN_PARENT_CHAINS: 0
DUPLICATE_CANONICAL_UUIDS: 0
POLICY_REVIEW_GATES_PRESERVED: PASS
OLD_W52C_SQL_CONTRACT: PASS
OLD_W52C_HTTP_CONTRACT: PASS
OLD_W52C_PHYSICAL_DEVICE_POST_MIGRATION: NOT_RUN
CANONICAL_STAGED_BACKEND_CONTRACT: PASS
SECURITY_RLS_CHECK: PASS
PUBLIC_CANONICAL_ACTIVATION_PERFORMED: NO
ROLLBACK_TRIGGERED: NO
ROLLBACK_RESULT: NOT_REQUIRED
PRODUCTION_LEFT_IN_SAFE_SIDE_BY_SIDE_STATE: YES
PRODUCTION_WRITE_PERFORMED: YES
READY_FOR_NEW_CANONICAL_PRODUCTION_CLIENT_BUILD: YES
READY_FOR_PUBLIC_CANONICAL_ACTIVATION: NO
```

Machine-readable evidence: [w52j_a_live_retry_validation.json](data/w52j_a_live_retry_validation.json). Only sanitized evidence is in scope for the task branch; no main merge or force push.
