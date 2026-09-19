# W52K-B final live retry — rolled back safely

**Final result: ROLLED_BACK. Private preview is not active and W52K-C is not ready.**

The CA-sealed live preflight, new logical backup, Stage A/default-deny, Stage B and standalone sealed postflight all passed. An agent-added external read-only observer then failed at `W52KBY_HTTP_CAPABILITY_IDENTITY`. The approved containment-first bridge-only rollback completed successfully. This was an observer response-shape error; no Production schema or permission failure was observed.

## Cause and coverage limit

The extra observer treated the capability HTTP body as a single object. The sealed `taxonomy_capabilities_v2` function returns `SETOF jsonb`, and the existing client explicitly accepts a one-element List before reading the capability object. The observer therefore rejected the expected array shape. A synthetic local reproduction confirmed the false failure and correct one-row decoding. No real subject or raw capability payload was retained.

The 12 offline wrapper cases covered orchestration and expiry-guard checks but did not cover this capability response shape. The error belongs to the supplemental observer introduced for this attempt. The sealed executor and current application decoder were unchanged. No new deployment was started after rollback.

## Authority and immutable package

- Main: `5bc328c5e72199b62c754c77a20fb2490eb46bbf`
- Branch: `astra-release/w52k-b-live-retry-final`
- Production: `mefhfvrgkwciubeajjeb`; PostgreSQL 17.6; exact-host TLS verification.
- Seal: `7fd358e2322064cff30dbb678a4b16af0ee4179643e5cf391e6d551a49afb168`; 38 runtime/security inputs. No reseal, relaxed guard, migration edit or client edit.
- GraphQL effective grants, pg_stat_statements/pgcrypto/uuid-ossp owners, effective read-only role setting, semantic baseline and material security guards passed.
- 33 existing package/security tests passed. The wrapper's 12 cases passed with the coverage gap described above.

## Fresh pre-write backup

- Started UTC: 2026-09-19T18:47:33.511Z
- Completed UTC: 2026-09-19T18:47:49.417Z
- Source/tool: PostgreSQL 17.6 / pg_dump 17.11.
- Full logical CUSTOM archive, 78 table-data sections, 1333576 bytes.
- SHA-256: `97dfe3451c56946b4bcf81040d265c9d5909c57602c1d07da961ba1931f18626`
- External location: `<USER_HOME>/EsnaftavarBackups/w52k-preview-live-final/EsnaftaVar-Production-W52K-B-FINAL-20260919T184733511Z.dump`

## Checks completed before containment

- Stage A atomically installed bridge and ledger without a tester. Anonymous, non-listed authenticated and exact tester controls were denied before Stage B.
- Stage B separately granted only the runtime-resolved existing tester a 3600-second lease, within the 24-hour limit.
- Sealed postflight: capability, 24 roots, L2/L3/L4, breadcrumbs, search/alias, 20 mappings, 14 eligible products and 6 gated products passed. Anonymous and non-listed authenticated controls were denied.
- Extra real-session HTTP recursive/breadcrumb checks and the read-only exact-guard expiry boundary check completed before the capability observer error. These preceding checks are inferred from its sequential execution and exact failure code.
- The expiry check evaluated the installed predicate at the actual lease boundary; it was not an expired-lease RPC test. Wrong-contract SQL denial passed; the supplemental wrong-contract HTTP request was not reached.

## Recovery and final state

Containment first removed tester authorization, then revoked bridge execution privileges, then removed only the bridge objects and bridge ledger. The sealed rollback returned `ROLLED_BACK`, `COMMIT_ACKNOWLEDGED`, `bridge_removed=true`, `preview_access_disabled=true`, and `core_health=PASS`.

- Bridge and bridge ledger: absent. Tester allowlist: removed. Private preview: unavailable.
- 0012: unchanged. 0010/0011: absent. Public canonical activation: OFF.
- Counts verified by sealed postflight and recovery baseline: 20 products, 285 listings, 57 shops, 1,563 canonical nodes, 24 roots, 1,245 terminal leaves, 20/20 mappings. Orphan products/listings: 0/0.
- Final RLS/security baseline passed. Legacy HTTP readings after rollback returned 200 and exactly matched preflight row counts/content hashes for both anonymous and tester sessions.
- No customer-data, Storage, unrelated migration or Development action; no APK/AAB build. Only the explicitly authorized Auth re-login, bridge/ledger/allowlist and their containment/teardown occurred.
- The Product Owner confirmed `CHILD_PGPASSWORD_CLEARED: YES` and `PGPASSWORD_CLEARED: YES`. Normal tester session remains intact.

A future retry must correct and fully test the external observer's one-row-list handling, then rerun current gates with a new backup. This failure does not call for a migration, client patch or changed seal.

## TASK_RESULT

Stage/contract PASS values below describe completed checks during this attempt; applied objects and the lease were subsequently removed. `AUTHORIZED_PREVIEW: FAIL` represents failed overall acceptance by the supplemental observer, while the sealed preview checks had passed. Current readiness is NO.

```text
W52K_B_LIVE_FINAL: ROLLED_BACK
PRODUCTION_WRITE_AUTHORIZED: YES
AUTHORITATIVE_MAIN: 5bc328c5e72199b62c754c77a20fb2490eb46bbf
TARGET_PROJECT: mefhfvrgkwciubeajjeb
TESTER_SESSION_VALID_NOW: PASS
TESTER_UID_RESOLVED: YES
TESTER_PROJECT_IDENTITY_MATCH: PASS
LIVE_PREFLIGHT: PASS
SECURITY_BASELINE: PASS
SEALED_PACKAGE: PASS
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
AUTHORIZED_PREVIEW: FAIL
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
CONTAINMENT_TRIGGERED: YES
ALLOWLIST_REMOVED_ON_FAILURE: YES
ROLLBACK_TRIGGERED: YES
ROLLBACK_RESULT: PASS
PRODUCTION_LEFT_WITH_PRIVATE_PREVIEW_READY: NO
PRODUCTION_WRITE_PERFORMED: YES
PGPASSWORD_CLEARED: YES
READY_FOR_W52K_C_SIGNED_CANONICAL_RC: NO
READY_FOR_PUBLIC_CANONICAL_ACTIVATION: NO
```

Only this sanitized Markdown and its JSON validation record are included in the branch. No UID, email, password, key value, token, raw backup, device identifier or absolute local user path is included.
