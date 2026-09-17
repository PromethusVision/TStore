# W52J-B — Production execution package

Result: **PASS**. The final dedicated 0012 package passed two fresh real-backup rehearsals, both operational rollbacks, and 18 failure cases. **Ready to retry W52J-A: YES**, subject to that future task's Production authorization and live preflight. Production and Development were not accessed in W52J-B.

## Scope and immutable inputs

- Branch: `astra-release/w52j-b-production-execution-package`.
- Authoritative base: `2343658ee0331a20b3bfc021ed4270764943e3a8`.
- W52H: `0c0161e36cd7489f9ea8fac1c03f4abc5d988895`.
- W52H-R: `04f6a05890aedfd320b3f1c6ee05ed6ece30b013`.
- W52J-A safe stop: `816bfb9e611bdf32200d2cd41d7d0c18d48a86a4`.
- Authorized future project: `mefhfvrgkwciubeajjeb`; database and execution role: `postgres`; exact server version: `17.6`.
- Original W52H-R custom-format backup SHA-256: `83029c3871ce1689851b08beb2690be202d7d22d79bcdbdda3b5eadd46c64b10`. Original archive remains external and unchanged.
- Frozen original 0012, normalized UTF-8/LF SHA-256: `a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834`.
- Derived execution payload SHA-256: `0983f9dec3f4621136add373be147005e4c6101c0de5886a8c10dc79527f12d3`.
- Final execution bundle SHA-256: `3d124524bf1f7e3b30cd592c1c457e048aad5bc7a896e47401cd29a6e5b85e11`.

No client, migration-chain, activation, shared coordination, Production config, or historical evidence file was modified. New implementation is confined to `tool/production_taxonomy/execution/`; new evidence is confined to this document and `docs/data/w52j_b_*`.

## Previous guards and the reviewed replacement

The original SQL contains an outer `BEGIN`/`COMMIT` and an internal DO guard requiring `esnaftavar.w52h.execution_scope=local-rehearsal`. It also checks an advisory lock, the legacy data shape, the exact nine historical ledger entries, and absence of canonical objects. The old real-copy helper additionally checks the fixed local Docker endpoint, pinned image, no network or published ports, and read-only original archive mount. Thus neither an ordinary Production SQL editor nor generic migration application was an authorized execution path.

The previous `rollback.sql` has its own local-only DO guard. It is a soft rollback: disable public/preview flags, stage nodes, disable aliases, preserve staged objects. The synthetic W52H helper manufactured the nine baseline ledger rows; W52H-R instead restored the nine real ledger rows. Neither proved insertion/removal of a standard 0012 migration record. That was the correct reason for the W52J-A stop.

This package selects architecture **B: a new, explicitly derived execution artifact**. `common.mjs::payload()` reads the frozen original, verifies its hash, removes only its outer transaction boundaries, and substitutes only the exact local guard with the new execution-context guard. It checks that reversing those substitutions reconstructs the original hash. All schema, data, policy, RPC, mapping, and remaining guard SQL is unchanged. The old 0012 and old rollback retain their original guards.

The new payload is generated deterministically in memory and passed over one persistent psql session. It is not a new pending migration. There is no `db push`, pending-migration iterator, 0010/0011 application, or manual SQL paste step. The immutable bundle covers the execution modules, derived contract, frozen mapping, and every upstream input consumed by the contract checks. The expected bundle hash is an explicit CLI argument; file drift stops execution.

An isolated pilot restored the real archive and applied the **unchanged** W52H SQL under its legitimate local-only guard. Its actual catalogs establish the expected before/after fingerprints and allowlist of nine new tables and 17 new functions. This pilot is separate from the two final-package rehearsals.

## One future Production path

Entry point: `node tool/production_taxonomy/execution/cli.mjs`.

Four explicit operations are available: `preflight`, `apply-0012`, `postflight`, and `rollback-0012`. There is no default operation. All require the future task's authorization flag, exact project, expected bundle hash, psql 17 executable, trusted CA file, and externally provisioned libpq password-file path. Password values are never command arguments or output. psql runs with `-X`, `-w`, `ON_ERROR_STOP=1`, and pipe-only SQL input; raw SQL/error buffers are suppressed from result output.

The sole remote transport is the direct hostname `db.mefhfvrgkwciubeajjeb.supabase.co`, port 5432, with TLS `verify-full`, the supplied trusted CA, database `postgres`, and role `postgres`. Inherited `PG*` connection overrides are removed. Database, session role, exact server version, historical ledger, legacy row hashes, and schema fingerprints are checked again in the transaction. The target GUC carries the checked context; it is not claimed to independently attest server identity. Endpoint identity comes from the fixed host and verified TLS connection.

W52J-B did not test live DNS, IPv6/direct-host reachability, TLS certificates, or credentials. Those are explicit future preflight gates. No pooler or alternate-host fallback is supported by this reviewed package. A failed gate means stop, rather than improvise a new transport.

Example future invocation, from the reviewed repository root; named variables refer to private external files and contain no embedded credentials:

```powershell
$BundleHash = '3d124524bf1f7e3b30cd592c1c457e048aad5bc7a896e47401cd29a6e5b85e11'
$Common = @('--production-authorized', '--project', 'mefhfvrgkwciubeajjeb',
  '--bundle-hash', $BundleHash, '--psql', $PsqlExecutable,
  '--ca', $TrustedCaFile, '--passfile', $PrivatePassFile)
$Backup = @('--backup', $FreshArchive, '--backup-metadata', $FreshMetadata)
node tool/production_taxonomy/execution/cli.mjs preflight @Common @Backup
# Continue only after PASS and within the new W52J-A authorization.
node tool/production_taxonomy/execution/cli.mjs apply-0012 @Common @Backup
node tool/production_taxonomy/execution/cli.mjs postflight @Common
# Operational rollback, only when the future task calls for it:
node tool/production_taxonomy/execution/cli.mjs rollback-0012 @Common
```

These commands were **not run against Production** in this wave. The local harness invokes the same engine, payload, validators, ledger handling and rollback through an independently attested, network-disabled Docker transport. It does not impersonate a remote TLS connection or set the old local guard in the future executor.

## Backup and read-only preflight

Future apply/preflight require a fresh custom-format full backup and separate JSON metadata, both outside the repository. Required metadata fields:

| Field | Required value or validation |
| --- | --- |
| `project_ref` | `mefhfvrgkwciubeajjeb` |
| `database` | `postgres` |
| `source_pg_version` | `17.6` |
| `format` | `CUSTOM` |
| `tool_version` | Actual `17.x` dump tool version |
| `completed_at_utc` | Actual successful dump completion time, ISO UTC |
| `size_bytes` | Exact archive byte size |
| `sha256` | Exact archive SHA-256 |

The wrapper reads the archive privately, verifies `PGDMP` magic, byte size, hash and metadata identity, and requires age at most 15 minutes (maximum 30 seconds future clock skew). Identity fields are an operator attestation accompanying the backup; the archive hash is not a cryptographic attestation of its source database. The future backup must come from the separately authorized, exact target backup procedure. This package does not produce a live backup or fabricate metadata for the historical W52H-R archive.

Each local rehearsal creates a new pre-write `pg_dump` of the restored real copy in the private disposable container and uses this same metadata validator. The historical archive is used unchanged for every restore, never relabeled as a fresh Production backup.

The standalone preflight runs in `REPEATABLE READ READ ONLY`. It verifies 4 categories, 20 products, 285 listings, 57 shops, no orphans, exact original product/category references, all five legacy table hashes including brands, full public catalog fingerprints (columns, constraints, indexes, functions, triggers, policies, owners, ACLs and RLS), the actual ledger column contract and nine historical rows, absence of 0010/0011/0012 and unledgered canonical objects, frozen owner mapping inputs, and both anon/authenticated legacy SQL contracts. Any baseline drift requires a separately reviewed update and rehearsal; this package does not adapt to drift live.

## Atomic apply and actual migration ledger

The restored table is **`supabase_migrations.schema_migrations`**, with these observed columns in actual order:

| Column | PostgreSQL type | Nullable | Default |
| --- | --- | --- | --- |
| `version` | `text` | NO | none |
| `statements` | `text[]` | YES | none |
| `name` | `text` | YES | none |

Apply uses one persistent psql connection and one explicit `READ COMMITTED` transaction. It validates identity, acquires the common advisory lock and `SHARE ROW EXCLUSIVE` locks on the five legacy tables and migration ledger, then runs preflight using a fresh snapshot after those locks. Lock timeout is 3 seconds; per-statement timeout is 120 seconds. These locks keep legacy reads available while briefly excluding writers. The task must remain a controlled rollout window.

Execution order is: locked preflight → exact derived payload → full postconditions → insert exactly one ledger row → verify that row and total count 10 → COMMIT. No intermediate commit exists.

The inserted row is exactly:

- `version = 20260916001200`
- `name = 0012_production_canonical_side_by_side`
- `statements = text[]` containing one element: the exact executed payload, hash `0983f9dec3f4621136add373be147005e4c6101c0de5886a8c10dc79527f12d3`.

The transaction wrapper and runtime checks are not misrepresented as historical migration statements. All nine historical entries retain their original names, statement hashes and counts. No 0010/0011 record is synthesized. An existing 0012 row is an explicit already-applied stop, including when objects are absent. SQL/validation/ledger-write failures roll back schema, staged data and the 0012 record together. A lost COMMIT acknowledgement produces `W52JB_COMMIT_OUTCOME_UNKNOWN_RECONCILE_READ_ONLY`; the operator must reconcile with read-only validators before any further mutation and must not blindly retry.

## Post-apply and operational rollback

The standalone postflight is read-only. Before apply commits, the same checks verify 1,563 exact source nodes, 24 roots, 1,245 terminal leaves, maximum depth 4, complete parent paths, no duplicate UUIDs, all 20 exact approved terminal product mappings, policy/review metadata, original product references and all legacy rows/contracts. Both public and preview flags remain false; every canonical node remains inactive, unassignable and staged. Both customer roles see no canonical roots, products, mappings, alias results or search results. The nine added tables grant neither customer role INSERT, UPDATE or DELETE. Public catalog fingerprints also protect all RLS, ACL and RPC definitions.

Rollback uses the same target transport, identity checks, locks, transaction and exact ledger-payload verification. It requires the expected applied schema fingerprint, refusing unrelated schema additions or changed definitions. It disables the public/preview configuration inside the transaction, then removes only the fixed nine-table/17-function allowlist derived from the original-artifact pilot. Every drop uses **RESTRICT**, never CASCADE. Dependency ordering is resolved inside savepoints; an external dependency or unexpected error aborts the entire rollback.

Only the verified 0012 ledger row is removed. Before commit, the original full public schema, nine historical ledger entries, five legacy data hashes and both legacy role contracts must match the baseline. Legacy product/category foreign keys never moved. A call before apply or after completed rollback returns `ALREADY_BASELINE_NO_OP` only if the complete baseline matches. Missing ledger with residual objects, changed schemas, altered ledger payload, or baseline drift refuses rollback. This is operational rollback; full archive restore remains separate disaster recovery.

## Real-copy proof and failure cases

Both final rehearsals used separate newly initialized PostgreSQL 17.6 clusters from the pinned Supabase image `supabase/postgres@sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00`. Each had network mode `none`, no published ports, TCP listening disabled, no privileged container, and only the original archive mounted read-only. Source role attributes/memberships, Supautils settings, original owners and ACLs were restored. The execution role was the source-shaped `postgres` role, not a promoted superuser.

All 958 listed archive entries were restored without omissions: 951 ordinary objects and seven event triggers restored under their original owners. All 69 TABLE DATA entries were compared with the original archive in memory. All six previously captured source fingerprints matched. Only counts and hashes were emitted.

Each final run passed preflight, exact apply, ledger verification, read-only postflight, SQL contracts, local PostgREST HTTP contracts, exact rollback, ledger restoration, and comparison of all 69 original TABLE DATA entries again. The PostgREST process ran only inside the isolated container and used an ephemeral local test signing key. Eight legacy HTTP contracts for each of anon/authenticated were identical before apply, after apply and after rollback: categories, product listing, category listing, product detail, seller comparison, shop detail, shop listing, and search. This is a local server simulation; no phone test or live Production API test was performed.

There were no manual SQL repairs between proof steps. An initial development run passed; after strengthening rollback schema-drift refusal and post-lock snapshot semantics, both final proofs were rerun from new real-backup restores with the final hash above. The earlier run is not used for final readiness.

The separate real-copy failure suite passed **18/18** cases:

1. Wrong target identity.
2. Wrong legacy baseline count.
3. 0012 marked without its objects.
4. Unexpected 0010 ledger entry.
5. Unexpected 0011 ledger entry.
6. Missing mapping after payload execution.
7. SQL failure before completion.
8. Ledger insertion failure after successful schema/data validation.
9. Missing fresh backup.
10. Stale backup.
11. Rollback before apply.
12. Reapply after committed 0012.
13. Rollback with an unrelated dependent view/schema drift.
14. Rollback called twice.
15. Wrong Production project rejected before opening a connection.
16. Missing future Production authorization rejected before opening a connection.
17. Wrong reviewed bundle hash.
18. Backup hash mismatch.

Fault injection exists only in the local harness. No Production fault switch exists. Failed transactional tests restored the baseline or preserved the already-applied state as appropriate; no partial corruption remained.

## Validation and evidence

| Check | Result |
| --- | --- |
| Original 0012 hash and reverse semantic reconstruction | PASS |
| SQL static mutation allowlist and transaction-boundary checks | PASS |
| Actual SQL execution/parser validation on PG 17.6 twice | PASS |
| Dedicated package and exact standard-ledger method | PASS |
| Read-only preflight/postflight | PASS |
| Real-copy rehearsal 1 / rollback 1 | PASS / PASS |
| Real-copy rehearsal 2 / rollback 2 | PASS / PASS |
| Failure injection | PASS, 18 cases |
| Secret, PII and absolute local user-path scan | PASS |
| Git diff whitespace check | PASS |
| Flutter/analyzer | Not required; no client changes |

Machine-readable evidence:

- `docs/data/w52j_b_execution_package_validation.json` — final decision and required result fields.
- `docs/data/w52j_b_original_artifact_equivalence.json` — original-artifact pilot and semantic reconstruction.
- `docs/data/w52j_b_first_rehearsal.json` and `w52j_b_second_rehearsal.json` — independent final proofs and HTTP hashes.
- `docs/data/w52j_b_failure_injection.json` — individual case outcomes.
- `docs/data/w52j_b_static_validation.json` — package seal, static and privacy checks.
- `tool/production_taxonomy/execution/contract.json` and `bundle.json` — measured contract and frozen execution inputs.

Offline verification: `node tool/production_taxonomy/execution/validate.mjs --complete`.

Local reproduction requires the pinned existing Docker image, original external W52H-R archive, and the previously verified local PostgREST binary in the W52H-R proof container. Set `W52JB_DOCKER`, `W52JB_DUMP`, and a fresh allowlisted `W52JB_CONTAINER` name (`w52jb-first-<suffix>`, `w52jb-second-<suffix>`, or `w52jb-failure-<suffix>`). Run `rehearse.mjs first`, `rehearse.mjs second`, or `failures.mjs` in the execution directory through Node. These scripts reject existing container names, restore afresh, and stop their containers on completion. Do not regenerate the pilot contract or reseal an edited bundle as a substitute for review and both rehearsals.

Local environment note: Docker initially failed on inaccessible stale Windows socket files. Only zero-length temporary socket directories were renamed and preserved, then Docker was restarted. No factory reset, image/volume reset, original archive modification, Production access, or Development access occurred.

Operational references: [psql error/transaction behavior](https://www.postgresql.org/docs/17/app-psql.html), [libpq TLS verification](https://www.postgresql.org/docs/17/libpq-ssl.html), [Supabase direct database connections](https://supabase.com/docs/guides/database/connecting-to-postgres).

## Final decision

`READY_TO_RETRY_W52J_A_PRODUCTION_ROLLOUT: YES`

`PRODUCTION_ACCESSED: NO`

`PRODUCTION_WRITE_PERFORMED: NO`

This is package readiness. Future Production execution remains subject to explicit W52J-A authorization, exact target/backup/preflight PASS, and the reviewed hash. Public activation, client runtime changes, seed expansion and 0010/0011 rollout are outside this package.
