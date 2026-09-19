# W52K-BX dedicated preview bridge execution package

This package prepares a future, separately authorized Production operation. W52K-BX itself permits **no live connection or write**. It does not activate public canonical browsing or build an RC.

The authority is main `afac64f92e3b706a864b36b0e72d27dcf75ef07f`. Read the release evidence and its package SHA-256 before any future execution. `manifest.json` has a path, UTF-8/LF byte size, SHA-256 and role for every protected input. The externally reviewed SHA-256 of the manifest binds the entire inventory. Do not rebuild a seal on the deployment machine to resolve a mismatch: stop and review/rehearse a new package.

## Scope and trust boundary

`seal.mjs` inventories explicit roots and every transitive literal local module import. Node built-ins are the only external modules; dynamic imports are prohibited. Explicit data inputs include the existing owner mappings, canonical import, qualification and source metadata actually read by the validators. Documentation is included only when consumed as runtime data. Rehearsal code and offline tests are protected as separately labelled support inputs.

Unrelated evidence, this README and the BX result documents are outputs, not live inputs. The earlier W52J-B bundle and its mismatching broad evidence scan remain unchanged for historical verification. BX neither calls nor suppresses that obsolete check. The new BX seal protects the old reviewed 0012 engine dependencies used solely to reconstruct the pre-0012 backup during local rehearsals. No 0012 application is reachable from the Production CLI.

The manifest does not hash itself; its hash must be supplied independently from reviewed evidence. The trusted Node installation and approved PostgreSQL client/CA are operator prerequisites. The CLI validates supplied psql and CA hashes before connecting. The owner plan and backup are external runtime inputs: the plan is bound by an explicit SHA-256; the backup is verified against its metadata, target, age, magic bytes, size and SHA-256. These inputs are never copied into the repository.

## Future owner input

Prepare an external UTF-8 JSON plan containing exactly these keys:

```json
{
  "project_ref": "mefhfvrgkwciubeajjeb",
  "user_ids": ["<OWNER_APPROVED_EXISTING_AUTH_UID>"],
  "expires_at_utc": "<EXPLICIT_FUTURE_UTC_ISO_TIMESTAMP>"
}
```

One to ten unique exact Auth UUIDs are supported. Expiry is mandatory, in the future, at most 30 days away and also checked against the database clock. The referenced users must already exist. No Auth account, email, password, metadata or session is created or changed by the executor. Only the local rehearsal harness creates and removes disposable identities.

Supply a temporary process `PGPASSWORD` through the owner's established secure local prompt. Never put a password in a command, argument, plan, transcript or script. The Node process removes its inherited copy after passing it to the child; the owner must remove their own PowerShell environment copy in `finally`. No credential is printed. The bridge/client never receives a DB password or service-role key.

## Future commands, after separate live authorization

Run from the reviewed repository root. The variables below are owner-reviewed external paths/hashes, not literals embedded in the package. `$Node`, `$Psql` and `$Ca` identify the approved local tool/CA; `$Plan` points outside the checkout. `$PackageSha` comes from the release evidence, not an automatic reseal.

```powershell
$Bridge = 'tool/production_preview_bridge/execution/cli.mjs'
$Common = @('--production-authorized', '--package-sha256', $PackageSha,
  '--psql', $Psql, '--psql-sha256', $PsqlSha,
  '--ca', $Ca, '--ca-sha256', $CaSha)
$Owner = @('--plan', $Plan, '--plan-sha256', $PlanSha)

# Read-only. Does not automatically continue to backup or deploy.
& $Node $Bridge preflight @Common @Owner

# Later approved apply: requires a verified fresh prewrite backup, supplied
# by the existing backup workflow. This executor never creates a live backup.
& $Node $Bridge deploy-0013 @Common @Owner --backup $Backup --backup-metadata $BackupMetadata

& $Node $Bridge postflight @Common @Owner

# Remove exactly the listed leases; expired plans are accepted for removal.
& $Node $Bridge revoke-testers @Common @Owner

# Bridge-only rollback, including its one ledger entry. No UID input required.
& $Node $Bridge rollback-0013 @Common
& $Node $Bridge validate-rollback @Common
```

These are separate invocations, not an automatic sequence. Check the exit status after each. Unknown/duplicate flags fail. There is no arbitrary SQL, pending migration runner, generic `db push`, skip-seal option, automatic rollback or automatic backup in the live CLI.

The fixed endpoint is `db.mefhfvrgkwciubeajjeb.supabase.co:5432`, database/user `postgres`, TLS `verify-full`. The password is passed only through the child environment. Inherited `PG*` settings are removed; the child defaults to read-only transactions. Database identity additionally requires PostgreSQL **17.6**, `postgres` database/session user and the exact existing 0012 ledger payload and schema.

## Transaction and validation contract

Apply starts with a separate repeatable-read READ ONLY preflight. Any failure ends before the write transaction. The READ COMMITTED write transaction obtains the existing canonical rollout advisory lock plus locks on the legacy, ledger and canonical tables, then repeats the checks against a fresh snapshot.

The exact frozen 0013 source changes only by removing the outer `BEGIN/COMMIT` for caller-owned transaction boundaries. Bridge SQL, its one deterministic ledger row, the runtime-approved expiring leases and the full post-validator commit atomically. The ledger contains exactly one statement: the normalized executor body. Any error before commit rolls back the entire operation. Loss of the commit acknowledgement returns an explicit unknown-outcome error requiring read-only reconciliation; do not blindly reapply.

Preflight verifies the package and frozen rollback, exact target/version, 0012 entry, historical ledger, complete public catalog, Auth helper definitions, relevant column ACLs, roles/memberships, default grants, schemas, extensions, event triggers, legacy data/queries, source-derived canonical identities/mappings, staged state and public OFF. Unexpected bridge objects or ledger presence refuse reapply. Postflight additionally matches the exact bridge/private schema fingerprint, minimal grants, stable functions with fixed search paths, private RLS allowlist, caller-dependent preview DTOs, 24 roots, L2/L3/L4, breadcrumb, alias/search, 20 mappings/14 eligible products and six preserved policy gates. Both anon and non-listed authenticated roles are denied across all ten facade RPCs.

SQL role checks in the future live validator prove server authorization; they do not manufacture a live Auth JWT. The local rehearsals additionally use real PostgREST with ephemeral local JWTs to test the HTTP boundary, including an invalid signature.

The frozen product RPC remains SECURITY INVOKER; local positive/negative restrictive-policy tests demonstrate product RLS. There is no client mutation RPC, private table/schema grant or public activation switch introduced by BX. Canonical table contents are hashed in full before/after apply and rollback, including existing timestamps.

Rollback performs read-only reconciliation first, checks exact bridge ownership/schema/ledger, drops only the frozen bridge additions with `RESTRICT`, removes only its exact ledger row and validates the original 0012 staged baseline before commit. It refuses rollback-before-apply and rollback-twice. Existing canonical nodes, mappings, legacy records and the 0012 entry remain intact. A dependent external object or drift aborts rollback; no CASCADE is used.

## Local reproduction

The sealed `rehearse.mjs` imports only the guarded local transport, never the Production transport. Supply the existing `W52KB_DOCKER`, `W52KB_DUMP`, `W52KB_CONTAINER` environment variables and `W52KBX_PACKAGE_SHA256` plus an external `W52KBX_PROOF_DIR`. Container names are restricted to `w52kb-bxone` and `w52kb-bxtwo` for final runs (or `w52kb-bxprepare` for contract preparation). Each final run creates a fresh network-disabled PG17.6 container from the pinned image, with no published ports and one read-only backup mount.

The newest available archive is the verified W52J-A retry **pre-0012** dump. All 958 archive entries and all 69 table-data sections are restored. Unchanged reviewed 0012 is reconstructed locally before testing the bridge. This is not a newly fetched live backup or a claim that the source archive already contains 0012.

Each final run uses the same deploy/revoke/rollback engines as the live CLI and the same package hash, exercises the failure suite, compares legacy HTTP, removes local fixture identities and verifies all 69 archive table-data sections again (preserving the separately checked 0012 ledger entry). No failed clone is repaired into a successful proof.

`node --test tool/production_preview_bridge/execution/package.test.mjs` tests the offline input/transport/seal gates. It temporarily changes one runtime file and adds an unrelated evidence probe, verifies the respective refusal/acceptance, and restores/removes its own probes in `finally`.
