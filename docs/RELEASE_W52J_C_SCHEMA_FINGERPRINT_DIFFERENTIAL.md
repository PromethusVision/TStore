# W52J-C — live schema fingerprint differential audit

The root cause is **BENIGN_EXPECTED_VARIANCE**: the original constraint query sorted text relation names using the database's default collation. The W52J-B restore used libc; Production uses ICU en-US. On the newest real backup under the observed ICU environment, the unchanged old executor reproduced `W52JB_SCHEMA_FINGERPRINT` **after the payload** and rolled back. Exactly ten constraint records changed position; all 161 constraint records and every other fingerprinted schema field were identical.

Production was accessed only through a verified-TLS `REPEATABLE READ READ ONLY` catalog transaction. No Production DML, DDL, migration retry, rollback, Auth write, Storage write or Development access occurred. The Product Owner confirmed temporary PGPASSWORD cleanup. Live remains at four categories, 20 products, 285 listings, 57 shops, nine historical ledger entries, and no canonical tables.

## Evidence provenance and limits

- Authoritative main: `fb4d4dffe5dccc39437cd3898e68d92b642bdce0`; prior live evidence: `9819e24`.
- Actual live manifest: 2026-09-18T22:48:23.507Z; all seven existing baseline catalog hashes matched W52J-B.
- Original expected state was recovered from the exact W52J-B real Production backup; its pre/post hashes matched the frozen contract before any correction.
- Newest prewrite backup SHA-256: `e89b13e4481d4a5e2c6b60181df290791455b0dc39acec99fadc184112879b65`.
- Database declaration recovered from that archive: `LOCALE_PROVIDER = icu`, `ICU_LOCALE = 'en-US'`, UTF8, en_US.UTF-8. Local ICU version 153.121 matches observed live metadata.
- The failed Production transaction's temporary catalog no longer exists. The post-payload differential below is an explicitly labeled **local reproduction on the real backup**, not a fabricated live post-apply snapshot. Baseline live comparisons are actual readonly Production observations.

## Exact original fingerprint algorithm

`catalog.mjs` reads seven arrays from the `public` namespace. Each row retains the database-returned field values. `stable()` sorts JSON object keys lexically, preserves array order, and serializes scalars with JSON.stringify. Each complete array is SHA-256 hashed as UTF-8; the seven named hashes are compared exactly with `contract.catalog_before` or `contract.catalog_after`. No row is omitted from a group.

| Group | Included fields | Original ordering |
|---|---|---|
| relations | name, relkind r/p/v/m/S, owner, RLS/forced state, raw ACL | relation name |
| columns | table, column, ordinal, data type, UDT name, nullability, default | table, ordinal |
| constraints | relation text, name, kind, validation state, pg_get_constraintdef | relation text under database collation, constraint name |
| indexes | table name, index name, index definition | table, index |
| functions | name, identity arguments, return type, full pg_get_functiondef, owner, raw ACL | name, identity arguments |
| triggers | relation, non-internal trigger name, full pg_get_triggerdef | relation text, trigger name |
| policies | schema, table, policy, permissiveness, roles array, command, USING, WITH CHECK | table, policy |

Views contribute relation/column/index metadata; the original fingerprint does not separately hash view definitions. Column type names are included, but independent type definitions are not. Extensions, database locale/provider, schema ownership, default privileges, event triggers and server settings were outside these seven hashes. Ledger columns and nine historical version/name/statement-MD5/cardinality records are checked **separately**. Legacy row hashes and mapping checks are also separate from schema fingerprinting. The expanded audit manifest records the relevant omitted metadata without silently expanding or weakening the production guard.

There was no ACL sorting, SQL-definition whitespace normalization, locale normalization, or identifier rewriting. Raw ACL order, grantors and grant options remained significant and remain unchanged by this correction.

## Exact differing constraint records

Indices are zero-based positions in the 161-row post-payload constraint array. The old libc expected array places `taxonomy_aliases` before `taxonomy_alias_targets`; ICU places the target table first.

| Object | Old expected position | Live-ICU reproduction position | Definition |
|---|---:|---:|---|
| `public.taxonomy_aliases.taxonomy_aliases_alias_kind_alias_locator_taxonomy_version_key` | 123 | 126 | identical |
| `public.taxonomy_aliases.taxonomy_aliases_alias_kind_check` | 124 | 127 | identical |
| `public.taxonomy_aliases.taxonomy_aliases_alias_locator_check` | 125 | 128 | identical |
| `public.taxonomy_aliases.taxonomy_aliases_check` | 126 | 129 | identical |
| `public.taxonomy_aliases.taxonomy_aliases_direct_target_category_id_fkey` | 127 | 130 | identical |
| `public.taxonomy_aliases.taxonomy_aliases_pkey` | 128 | 131 | identical |
| `public.taxonomy_aliases.taxonomy_aliases_resolution_state_check` | 129 | 132 | identical |
| `public.taxonomy_alias_targets.taxonomy_alias_targets_alias_id_fkey` | 130 | 123 | identical |
| `public.taxonomy_alias_targets.taxonomy_alias_targets_pkey` | 131 | 124 | identical |
| `public.taxonomy_alias_targets.taxonomy_alias_targets_target_category_id_fkey` | 132 | 125 | identical |

Old post-constraints hash: `f921f80f276ebe639dc5cfc2437a609942ffd857ae762803a971f6d5dbccd37e`. ICU/C-ordered hash: `46317008300232f9fd6f1418794f7e3de204e923995fac5545ce6790c44aec16`. The other six post-state hashes match exactly. No PK/FK/unique/check constraint, column, type, index, RPC, trigger, policy, grant or ownership changed in this differential. Full expected/reproduced values and migration/security relevance are in the structured diff.

The manifest also records 26 supplemental metadata differences: database provider/version, three session/container settings, 19 raw default-ACL order differences and three extension-owner restoration differences. Effective default grants match exactly. An independent old-executor control using the live ACL ordering under libc passed, excluding ACL ordering as the failure cause. These supplemental differences were not added as guard exemptions.

## Why preflight passed and the narrow correction

The original readonly preflight already checked the existing schema's seven hashes. The 115 baseline constraint records have identical ordering under both providers; the ten affected records only appear after 0012 creates two taxonomy tables. The old restore's database creation omitted `LOCALE_PROVIDER`, so it trained the expected post-state hash on libc. A shared error tag concealed whether the failure was before or after payload execution.

The correction adds explicit `COLLATE "C"` to the two constraint ORDER BY keys. It preserves every row and field and changes only the expected post-constraints hash; the baseline constraints hash stays unchanged. The archive restore now uses its verified original CREATE DATABASE locale declaration.

Every `apply0012` invocation now completes the same full `readPreflight` in a READ ONLY transaction **before** opening READ WRITE. The locked preflight remains for race protection. Errors identify baseline/applied phase and the differing component. An intentional extra constraint was rejected as `W52JB_SCHEMA_FINGERPRINT_BASELINE_CONSTRAINTS`, with no READ WRITE transaction entered and no payload sent.

No fingerprint field was removed, no arbitrary mismatch was accepted, no ACL exception was added, and no guard was bypassed. The 0012 source and transaction payload are byte-for-byte unchanged after existing LF normalization.

## Latest-backup validation

Two independent clean, network-disabled PG17.6 restores of the newest real archive preserved ICU en-US/153.121, all 958 TOC entries and all 69 table-data entries. Both passed readonly preflight, the exact corrected executor, atomic 0012+ledger commit, postflight, legacy SQL/HTTP, staged canonical checks, rollback, and full restored-baseline comparison.

Both apply results: 20 products, 285 listings, 57 shops, 1,563 canonical nodes, 24 roots, 1,245 terminal leaves, 20 exact mappings, zero product/listing orphans, zero broken chains and zero duplicate UUIDs. All mapped breadcrumbs matched; policy classification remained 14 potentially eligible / six gated. Public and preview activation remained OFF. After rollback, counts, all 69 table-data checks and legacy contracts matched the starting archive; 0012 and its sole ledger entry were absent.

Only local copies ran migration/rollback. No client files changed; Flutter analyzer is not applicable. New sealed execution bundle: `f491e08aae3241f218fa2d3bced6ea05ff68d2fa46589d5892f77b62f0ee0cf0`. Unchanged 0012 source: `a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834`. Unchanged payload: `0983f9dec3f4621136add373be147005e4c6101c0de5886a8c10dc79527f12d3`.

## Result and retry boundary

```text
SCHEMA_FINGERPRINT_ROOT_CAUSE_IDENTIFIED: YES
DIFFERING_OBJECT_COUNT: 10
DIFFERENCE_CLASSIFICATION: BENIGN_EXPECTED_VARIANCE
LIVE_PREFLIGHT_FINGERPRINT_GAP_IDENTIFIED: YES
FINGERPRINT_NOW_RUNS_BEFORE_WRITE: PASS
FINGERPRINT_GUARD_WEAKENED: NO
0012_MODIFIED: NO
LATEST_PRODUCTION_BACKUP_REHEARSAL: PASS
SECOND_CLEAN_REHEARSAL: PASS
ROLLBACK_REHEARSAL: PASS
PRODUCTION_ACCESSED: READ_ONLY
PRODUCTION_WRITE_PERFORMED: NO
READY_FOR_W52J_A_LIVE_RETRY: YES
```

DIFFERING_OBJECT_COUNT counts ten reordered constraint records; semantic schema drift count is zero. Readiness applies to the corrected, tested package on this task branch. A future explicitly authorized W52J-A must use this revision/new bundle hash and pass fresh live preflight and backup gates. W52J-C did not retry Production.

[Structured diff and sanitized manifests](data/w52j_c_schema_fingerprint_diff.json) · [Validation and both rehearsal results](data/w52j_c_schema_fingerprint_validation.json).

PostgreSQL references: [database locale metadata](https://www.postgresql.org/docs/17/catalog-pg-database.html), [default privileges apply during object creation](https://www.postgresql.org/docs/17/catalog-pg-default-acl.html), [ACL grant/grant-option semantics](https://www.postgresql.org/docs/17/ddl-priv.html).
