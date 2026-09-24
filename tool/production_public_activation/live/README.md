# W52L-E final 0014 public activation package

This package supports the current 0012 + 0013 + 0015 Production state and the
frozen public client 1.0.0+3. W52L-E authorizes preparation, isolated rehearsal
and the explicitly requested phone OFF check. It does **not** authorize running
the live database commands below. Obtain the separate live-activation decision
before connecting, backing up, activating or rolling back Production.

## Immutable inputs

- Required main: `c75c17c6ebe8683b1d652a2fab05ed7700739453`.
- Project: `mefhfvrgkwciubeajjeb`; PostgreSQL 17.6; database/role `postgres`.
- `../activate.sql` and `../rollback.sql` are the unchanged reviewed W52L-A
  semantics. Exact hashes are in `runtime-manifest.json`.
- 0015 definitions, signatures, owner, ACLs and exact ledger are attested by
  the unchanged W52L-B `activationView`/`verifyFacade` compatibility layer.
  Only its two exact metadata queries project out independently attested 0015
  additions for the original activation validators. Other drift remains visible.
- `artifact-contract.json` pins both final signed binaries, package/version,
  public=true/preview=false, certificate and reviewed W52L-D evidence digest.
  Every activation requires the actual external APK and AAB bytes to match.
- `physical-public-off.json` records the exact APK upgrade, controlled gate
  and observed absence of crash/ANR. Live activation requires this sealed PASS.
  Local rehearsal can never turn its test-only transport into a live proof.

The externally reviewed digest of `seal.json` must be supplied by the operator.
The seal covers the complete runtime import closure, reviewed SQL and required
oracles, artifact contract, physical proof and runtime manifest. It excludes
test/rehearsal helpers and unrelated documentation. Do not regenerate a seal
during live execution to bypass a mismatch.

## Operations

- `preflight`: READ ONLY, exact target/TLS/database/PG identity; 0012/0013/0015
  exact and 0014 absent; public/preview OFF; zero enabled, unexpired tester
  leases; frozen source counts, policy/review gates, aliases, mappings, legacy
  reads and hashes, schema/security/RLS, exact facade/grants, all eight OFF
  denial calls, and final artifact bytes. It performs no backup or write.
- `activate`: explicit authorization, seal, SQL and artifact gates; read-only
  preflight; a new custom backup outside every Git checkout; byte/hash/TOC/tool
  and age verification (maximum 900 seconds); unchanged full fingerprint
  before/after backup. No external or forged backup receipt is accepted by CLI.
  The transaction acquires the reviewed shared advisory lock, core table locks
  and tester-table lock, repeats all gates, then executes only reviewed 0014
  and its exact ledger row. Validation occurs before commit. No generic db push.
- `postflight`: independent READ ONLY check of the exact active state, 24 roots,
  325 published nodes, 247 assignable leaves, exact policy-approved aliases,
  recursive/breadcrumb contracts, 14 eligible products, six excluded products,
  all four 0015 functions for anon/authenticated without a tester, product/detail,
  seller/shop/search projections, legacy compatibility and security fingerprints.
- `rollback`: requires the exact active state and exact 0014 ledger. One locked
  transaction executes the unchanged 0014 rollback and removes only its ledger
  row. It preserves 0012/0013/0015, all unreviewed fields including timestamps,
  private tester rows and legacy data. It validates public OFF, staged taxonomy
  and 0015 OFF denial before commit. Before activation or twice is rejected.
  Rollback does not require the APK files to remain available in an emergency.

Unknown commit acknowledgment never causes a blind retry. A fresh connection
reconciles state: exact OFF baseline needs no action; exact active state permits
the sealed 0014-only rollback; any ambiguous/drifted state stops for review.
No other migration or whole-database restore is exposed.

The bridge remains installed and untouched. Its cleanup disposition is
**REMOVE_AFTER_PUBLIC_SMOKE**. No tester login, refresh, new lease or renewal is
part of this package.

## Future separately authorized operator procedure

Use the existing reviewed PostgreSQL client binaries and CA. Set non-secret
PowerShell variables `$taskNode`, `$taskPsql`, `$taskPsqlHash`, `$taskCa`,
`$taskCaHash`, `$taskPgDump`, `$taskPgDumpHash`, `$taskPgRestore`,
`$taskPgRestoreHash`, `$taskBackup`, `$taskBackupMetadata`, `$taskApk`, `$taskAab`,
`$taskSeal` and `$taskSqlHash` from the reviewed local inventory and sealed
manifest. The two backup destinations must be distinct new external files.
Binary and CA hashes must come from the reviewed inventory, not a replacement.
The target host is fixed to `db.mefhfvrgkwciubeajjeb.supabase.co:5432` with TLS
`verify-full`; inherited PG connection settings and passfiles are ignored.

From the approved checkout root, prepare arguments without any password:

```powershell
$taskEntry = Join-Path (Get-Location) 'tool/production_public_activation/live/cli.mjs'
$taskCommon = @(
  '--production-authorized', '--project-ref', 'mefhfvrgkwciubeajjeb',
  '--seal-sha256', $taskSeal, '--sql-sha256', $taskSqlHash,
  '--psql', $taskPsql, '--psql-sha256', $taskPsqlHash,
  '--ca', $taskCa, '--ca-sha256', $taskCaHash,
  '--apk', $taskApk, '--aab', $taskAab
)
```

Read the password only into the owner's process environment using a hidden
local prompt. For a connection/preflight-only check, use:

```powershell
$taskSecure = Read-Host 'Production DB password (local hidden input)' -AsSecureString
$taskPointer = [IntPtr]::Zero
try {
  $taskPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($taskSecure)
  [Environment]::SetEnvironmentVariable('PGPASSWORD', [Runtime.InteropServices.Marshal]::PtrToStringBSTR($taskPointer), 'Process')
  & $taskNode $taskEntry preflight @taskCommon
  if ($LASTEXITCODE -ne 0) { throw 'Activation preflight stopped; inspect safe status only' }
} finally {
  [Environment]::SetEnvironmentVariable('PGPASSWORD', $null, 'Process')
  if ($taskPointer -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($taskPointer) }
  $taskSecure.Dispose()
}
```

STOP after this read-only command unless the separate live task authorizes the
write. When authorized, obtain a fresh hidden password with the same cleanup
block and replace only its invocation with:

```powershell
& $taskNode $taskEntry activate @taskCommon --pg-dump $taskPgDump --pg-dump-sha256 $taskPgDumpHash --pg-restore $taskPgRestore --pg-restore-sha256 $taskPgRestoreHash --backup $taskBackup --backup-metadata $taskBackupMetadata
```

`postflight @taskCommon` and `rollback @taskCommon` use the same hidden prompt
and cleanup pattern when separately authorized. Never put a literal password in
history, files, transcripts or chat. Raw connection/SQL errors are suppressed;
the child clears its environment and PowerShell finally clears the owner's.

## Local validation

Run `node --test tool/production_public_activation/live/package.test.mjs` and
`node tool/production_public_activation/live/seal.mjs verify <reviewed-digest>`.
`rehearse.mjs` is test-only and requires the pinned real archive, PG17.6 image,
network-disabled Docker transport with no host ports, external proof directory,
and read-only archive mount. It reconstructs reviewed 0012/0013/0015, exercises
this exact activation/rollback package, failure injection and the existing real
Flutter/PostgREST public repository tests through a loopback-only relay. The
final state retains 0015 with OFF denial. Synthetic expired leases and fault
mutations exist only on this isolated copy. No manual SQL repair is allowed.
