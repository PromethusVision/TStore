# W52L-C: dedicated 0015 execution package

This package installs the immutable W52L-B read facade while public activation
stays OFF. W52L-C authorizes preparation and isolated rehearsal only. It does
**not** authorize a Production connection, backup, deployment or rollback.
A separate live-deploy decision is required before any command below is used
against Production. Never use generic `supabase db push` for this operation.

## Frozen inputs

| Input | Value |
| --- | --- |
| Required main | `449f10ae72da912b83688d6b7b8a0d04d810bb51` |
| Target | `mefhfvrgkwciubeajjeb` |
| Runtime seal SHA-256 | `992d13ee5c891464cf7f443b22df83944dbdd4ce15176e5efa98a7f6b704b3fb` |
| 0015 source SHA-256 (LF) | `53559e2608fbbcdfedc22112db899340283a782239a6847930842961ba119aa6` |
| Ledger statement SHA-256 (LF) | `3b8d31ba0c37dd87dac8f04de8e108762bc8d106e5fe26b6b0d2ca835b3b3d5c` |
| Ledger version | `20260922001500` |
| Ledger name | `0015_production_public_customer_reads` |

`seal.json` inventories the complete transitive runtime import closure, SQL,
rollback and frozen metadata/oracles. Its externally reviewed digest is mandatory;
do not rebuild the seal to bypass a mismatch. Rehearsal scripts, test fixtures and
reports are deliberately excluded from the deployed runtime inventory.

## Operations and stop conditions

- `preflight`: one READ ONLY transaction. Exact verified target, PostgreSQL 17.6,
  database/user `postgres`, original 0012/0013 ledger and schema/security/data
  contracts, no active tester lease, public/preview OFF, no 0014, no 0015 ledger
  or unledgered facade. Existing expired tester records remain untouched.
- `deploy`: repeats the read-only preflight, takes a new custom-format backup,
  verifies its bytes, digest, TOC, identity and age (at most 900 seconds), then
  compares the complete before/after backup fingerprint. The backup and its
  metadata must be new files outside every Git checkout. A forged receipt,
  missing/corrupt backup or changed baseline stops before applying SQL.
- Installation runs in one READ WRITE transaction with the shared deployment
  advisory lock and core/preview table locks. It repeats preflight under those
  locks, creates exactly four functions, inserts one ledger record containing
  the exact executable SQL body, validates the installed state, checks unchanged
  data, and notifies PostgREST. Only then does it commit. The outer BEGIN/COMMIT
  in the immutable SQL file are replaced by this encompassing transaction.
- `postflight`: independent READ ONLY validation of definitions, signatures,
  owner/ACL fingerprint, ledger payload, fixed search paths, RLS, unchanged legacy
  baseline, zero canonical client write grants, public/preview OFF and SQLSTATE
  `42501` for all four functions as both `anon` and `authenticated`.
- `rollback`: first requires the fully attested installed state, public OFF and
  no 0014. It drops only the four exact signatures, without CASCADE, and removes
  only the exact 0015 ledger row in one transaction. It validates the original
  baseline before commit. It does not remove 0012/0013, restore a whole database,
  edit taxonomy or toggle activation. Rollback before apply or twice is rejected.
- A lost COMMIT acknowledgment never causes a blind reapply. The executor uses
  a fresh connection to inspect state. An intact baseline needs no action; an
  exactly attested 0015 installation can be rolled back. Any unknown/drifted state
  stops for review. A failed preflight/reapply attempt cannot trigger teardown.

The strict frozen baseline may reject later legitimate Production changes. That
is a safe stop requiring a separate audit; this package never normalizes or
repairs Production to fit its expectations.

## Future authorized operator procedure (not executed in W52L-C)

Use the repository's Node runtime and `cli.mjs`, not a new migration mechanism.
The live transport pins `db.mefhfvrgkwciubeajjeb.supabase.co:5432`, `postgres`, TLS
`verify-full`, a separately verified CA, and reviewed PostgreSQL 17 client binary
hashes. It ignores inherited `PG*` connection settings and disables passfiles.
No publishable key, JWT, tester login, service-role key or URL credential is used.

Prepare the following **non-secret** variables in the owner's PowerShell session:
`$taskNode` (Node executable), `$taskPsql`, `$taskPsqlHash`, `$taskCa`,
`$taskCaHash`, `$taskPgDump`, `$taskPgDumpHash`, `$taskPgRestore`,
`$taskPgRestoreHash`, `$taskBackup`, `$taskBackupMetadata`. Tool/CA paths must be
absolute external paths. The two backup paths must be distinct new external files
with existing parent directories. Hashes must come from the reviewed local tools
and CA, not from an untrusted replacement at execution time.

From the approved checkout root, build arguments without a password:

```powershell
$taskEntry = Join-Path (Get-Location) 'tool/production_public_client/live/cli.mjs'
$taskCommon = @(
  '--production-authorized',
  '--project-ref', 'mefhfvrgkwciubeajjeb',
  '--seal-sha256', '992d13ee5c891464cf7f443b22df83944dbdd4ce15176e5efa98a7f6b704b3fb',
  '--sql-sha256', '53559e2608fbbcdfedc22112db899340283a782239a6847930842961ba119aa6',
  '--psql', $taskPsql, '--psql-sha256', $taskPsqlHash,
  '--ca', $taskCa, '--ca-sha256', $taskCaHash
)
```

Read the password only in the owner's hidden local prompt. For a connection and
preflight-only check, use this block; it never starts a backup or deployment:

```powershell
$taskSecure = Read-Host 'Production DB password (local hidden input)' -AsSecureString
$taskPointer = [IntPtr]::Zero
try {
  $taskPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($taskSecure)
  [Environment]::SetEnvironmentVariable('PGPASSWORD', [Runtime.InteropServices.Marshal]::PtrToStringBSTR($taskPointer), 'Process')
  & $taskNode $taskEntry preflight @taskCommon
  if ($LASTEXITCODE -ne 0) { throw '0015 preflight stopped; inspect safe status only' }
} finally {
  [Environment]::SetEnvironmentVariable('PGPASSWORD', $null, 'Process')
  if ($taskPointer -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($taskPointer) }
  $taskSecure.Dispose()
}
```

STOP after this check unless the separate live task explicitly authorizes the
deployment. For that authorized operation, obtain a fresh hidden password using
the same try/finally pattern and replace only the invocation with:

```powershell
& $taskNode $taskEntry deploy @taskCommon --pg-dump $taskPgDump --pg-dump-sha256 $taskPgDumpHash --pg-restore $taskPgRestore --pg-restore-sha256 $taskPgRestoreHash --backup $taskBackup --backup-metadata $taskBackupMetadata
```

`deploy` itself performs the fresh backup and postflight; an old archive cannot
be passed as deployment proof. `postflight @taskCommon` and `rollback @taskCommon`
use the same hidden-password cleanup block when separately authorized. The CLI
prints safe codes and clears its process environment; the PowerShell finally
block clears the owner's environment. Keep private backup bytes/metadata and
local paths outside the repository. Never paste a password into a command,
chat, file, transcript or command history. Raw SQL/connection stderr is suppressed.

## Offline validation

Run `node --test tool/production_public_client/live/package.test.mjs` and
`node tool/production_public_client/live/seal.mjs verify <reviewed-seal-sha256>`.
`rehearse.mjs` is local-test-only: it requires the hash-pinned real archive,
the reviewed isolated PG17.6 Docker image, no network/ports, a read-only backup
mount, and an external proof directory. It rebuilds the already-approved 0012/0013
baseline on the historical restore; it never executes the 0014 activation payload.
Two independent restores exercise the same sealed install/rollback/validators.
Negative flag/ledger fixtures are transactionally discarded on the local copy.
PostgREST checks use only container loopback and synthetic local roles.
