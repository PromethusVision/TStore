# W52K-B final retry live private preview result

The CB-sealed private preview bridge was deployed to Production after read-only preflight and a fresh logical backup. Stage A installed only the bridge and ledger; its default-deny gate passed before Stage B granted one exact runtime tester a one-hour lease. All final integrity, security, legacy and authorized preview checks passed. Public activation remains OFF.

## Authority and immutable inputs

- Main: `56347831d1abfa1a8aaf60c5b58c504d8efbdf5b`
- Branch: `astra-release/w52k-b-live-final-retry`
- Production: `mefhfvrgkwciubeajjeb`, PostgreSQL 17.6, exact-host TLS verification.
- Seal: `e87a1a2b0a7eb19c0b11640c95eb617f5f1fce6fd207d0a28d900c63f6f4f2a7`; 39 runtime/security inputs. No live reseal or repository runtime change.
- GraphQL grants, the three extension owners, effective read-only role setting, semantic baseline and material security guards passed. The fingerprint guard was not weakened.
- 123 current package/validator/security tests and 14 external offline flow/observation cases passed.

## New pre-write backup

- Started UTC: 2026-09-20T15:26:57.983Z
- Completed UTC: 2026-09-20T15:27:11.507Z
- Source/tool: PostgreSQL 17.6 / pg_dump 17.11
- Format: full logical CUSTOM archive; 78 table-data sections.
- Size: 1333735 bytes.
- SHA-256: `70d85d3da72ef272630d02307ba6362a8ba15daf92a30396d78d3ee759ea65d9`
- External location: `<USER_HOME>/EsnaftavarBackups/w52k-live-final-retry/EsnaftaVar-Production-W52K-B-FINAL-RETRY-20260920T152657983Z.dump`

## Validation and final state

- Counts: 20 products, 285 listings, 57 shops, 1,563 canonical nodes, 24 roots, 1,245 terminal leaves, 20/20 owner mappings. Orphan products/listings: 0/0.
- Authorized capability: HTTP 200 with exactly one JSON-array item, validated by the sealed validateAuthorizedPreview through client.preview. Subject, project and contract matched; public activation was OFF. The historical object-only parser was not executed.
- Malformed capability handling failed closed in the 90 validator tests within 123 passing current package/security tests; no malformed Production data was injected.
- Real authenticated HTTP and sealed SQL checks cover recursive L2/L3/L4, breadcrumbs, capability, search/alias and product scope. Policy scope remains 14 eligible products plus 6 gated mappings.
- Anonymous RPC calls were denied. Non-listed authenticated SQL role controls were denied without creating another Auth account.
- Wrong contract failed closed in SQL and authenticated HTTP (400/P0001).
- Expiry check: the exact installed allowlist predicate was evaluated read-only at the real lease boundary; before expiry allows, at/after expiry denies. This is a live-predicate boundary check, not an expired-lease RPC attempt. The grant was not altered or expired during validation.
- Legacy SQL and anonymous/tester HTTP contracts passed; pre/post HTTP hashes matched.
- RLS, policies, function grants, SECURITY DEFINER/search_path, GraphQL grants, extension owners and the read-only role matched the sealed security baseline.
- 0012 remained unchanged; 0010/0011 remained absent. No customer-data or Storage mutation, Development access, public activation, client secret addition or APK/AAB build.
- No containment or rollback was needed. The normal tester session is preserved. Temporary database credentials were cleared by child and owner cleanup.
- Tester lease expires UTC: **2026-09-20T16:28:15.912Z**. The authenticated session expires UTC: **2026-09-20T16:19:37.000Z**. Access needs both to remain valid.

## TASK_RESULT

```text
W52K_B_LIVE_FINAL_RETRY: PASS
PRODUCTION_WRITE_AUTHORIZED: YES
AUTHORITATIVE_MAIN: 56347831d1abfa1a8aaf60c5b58c504d8efbdf5b
TARGET_PROJECT: mefhfvrgkwciubeajjeb
TESTER_SESSION_VALID_NOW: PASS
TESTER_UID_RESOLVED: YES
TESTER_PROJECT_IDENTITY_MATCH: PASS
LIVE_PREFLIGHT: PASS
SECURITY_BASELINE: PASS
SEALED_PACKAGE: PASS
SEAL_SHA256: e87a1a2b0a7eb19c0b11640c95eb617f5f1fce6fd207d0a28d900c63f6f4f2a7
FRESH_PREWRITE_BACKUP: PASS
FRESH_BACKUP_SHA256_RECORDED: YES
STAGE_A_BRIDGE_APPLIED: YES
BRIDGE_LEDGER: PASS
STAGE_A_DEFAULT_DENY: PASS
STAGE_A_TESTER_DENIED: PASS
STAGE_A_ANON_DENIED: PASS
STAGE_A_NON_PREVIEW_DENIED: PASS
STAGE_B_ALLOWLIST_APPLIED: YES
ALLOWLIST_EXPIRY_ENFORCED: PASS
AUTHORIZED_PREVIEW: PASS
AUTHORIZED_PREVIEW_RESPONSE_SHAPE: SINGLE_ITEM_JSON_ARRAY
ROOTS_24: PASS
RECURSIVE_L2_L3_L4: PASS
BREADCRUMB: PASS
SEARCH_ALIAS: PASS
PRODUCT_MAPPING_20_20: PASS
PRODUCT_SCOPE: PASS
ANONYMOUS_PREVIEW_DENIED: PASS
AUTHENTICATED_NON_PREVIEW_DENIED: PASS
LEGACY_SQL_CONTRACT: PASS
LEGACY_HTTP_CONTRACT: PASS
SECURITY_RLS_CHECK: PASS
POST_DEPLOY_PRODUCTS: 20/20
POST_DEPLOY_LISTINGS: 285/285
POST_DEPLOY_SHOPS: 57/57
CANONICAL_NODES: 1563/1563
PUBLIC_CANONICAL_ACTIVATION: OFF
0012_CHANGED: NO
CONTAINMENT_TRIGGERED: NO
ALLOWLIST_REMOVED_ON_FAILURE: NOT_REQUIRED
ROLLBACK_TRIGGERED: NO
ROLLBACK_RESULT: NOT_REQUIRED
PRODUCTION_LEFT_WITH_PRIVATE_PREVIEW_READY: YES
PRODUCTION_WRITE_PERFORMED: YES
PGPASSWORD_CLEARED: YES
READY_FOR_W52K_C_SIGNED_CANONICAL_RC: YES
READY_FOR_PUBLIC_CANONICAL_ACTIVATION: NO
```

Only this sanitized Markdown and the accompanying JSON validation record belong in this branch. No UID, email, password, token, key value, raw backup, device identifier or absolute local user path is included.
