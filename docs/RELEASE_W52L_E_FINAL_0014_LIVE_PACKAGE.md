# W52L-E final 0014 public activation package

The dedicated package is ready for a separate live activation decision. The
exact frozen public APK passed its physical public-OFF gate. No live database
connection, backup, migration, activation or rollback ran in this wave.

- Authoritative main: `c75c17c6ebe8683b1d652a2fab05ed7700739453`.
- Branch: `astra-release/w52l-e-final-0014-live-package`.
- Production project: `mefhfvrgkwciubeajjeb`; required PostgreSQL 17.6.
- Runtime seal SHA-256: `86d9b475013ad534322678b35aef0624742b32efe24e1eb050fe9a4879b8245a` (58 runtime inputs).
- [Operator procedure](../tool/production_public_activation/live/README.md).
- [Sanitized structured evidence](data/w52l_e_final_0014_live_package_validation.json).

## Execution and recovery contract

The original W52L-A activation and rollback SQL are unchanged. Activation
publishes only the reviewed set: 24 roots, 325 nodes, 247 assignable leaves,
eligible aliases and 14 eligible products; six gated products stay excluded.
The exact SQL and 0014 ledger commit in one locked transaction. 0012, 0013 and
0015 remain intact. The existing W52L-B compatibility layer independently
attests all four 0015 functions, owners, signatures, definitions, grants and
ledger before adapting only its two reviewed metadata queries.

Strict future preflight requires public OFF, 0014 absent, exact schema/security,
policy and legacy/data fingerprints, current counts, zero enabled unexpired
tester leases and actual frozen APK/AAB bytes. Immediately before activation,
the executor creates a fresh custom backup outside Git and checks its bytes,
TOC, provenance, maximum 900-second age and unchanged baseline. It repeats the
gates under locks. No arbitrary SQL or generic database push is exposed.

Rollback restores public OFF and staged publication and removes only the exact
0014 ledger row. It retains 0015 and verifies its OFF denial, all original data,
private tester rows and unreviewed fields. It rejects rollback before apply,
repeated rollback and drift. Lost commit acknowledgment is reconciled through
a fresh verified connection; only an exact active state permits 0014 rollback.
Ambiguous state stops for review. The APK is not needed for emergency rollback.

Private preview remains installed; cleanup is **REMOVE_AFTER_PUBLIC_SMOKE**.
This wave creates or renews no tester lease.

## Frozen artifact and physical observation

Package `com.esnaftavar.app`, version `1.0.0+3`, runtime
`PRODUCTION_PUBLIC_CANONICAL`; public=true, preview=false.

- APK SHA-256: `04d71bfd25920c171fd25f27416ee22f74f851608bb3c79b1561dc4966827f64`.
- AAB SHA-256: `17e361684eab4aea6432bfa47a00af543777107c8bf7d0ccd472341b9e77cc79`.
- Signing certificate SHA-256: `3B:83:D9:8A:B8:D3:2E:0F:3B:99:30:FA:83:76:36:E0:E9:E1:32:19:78:4F:FC:A3:9C:EF:8C:AE:82:A6:66:9B`.
- Artifacts remain under `<RELEASE_ROOT>/w52l-d/1.0.0+3-main-4cc2bcf/` outside Git.

The exact APK upgraded the connected POCO X7 Pro with app data preserved.
Installed package/version, certificate and readback hash matched. Launch showed
“Katalog şu anda kullanılamıyor. Lütfen tekrar deneyin”; the Product Owner also
confirmed this message. No legacy/private-preview fallback, crash or ANR was
observed in the foreground UI, process and app-scoped logs during this smoke.
This controlled unavailable state is expected while public access is OFF.
No rebuild, resign, uninstall or app data reset occurred. Screenshots and raw
device material remain outside Git; no device serial is included.

The physical online app check was explicitly requested, so access is recorded
as **phone read only**, not a blanket claim of zero Production access. Desktop
Production API access and Production database access/write were all absent.

## Isolated current-state rehearsal

A clean restore of the frozen real Production archive ran on pinned PostgreSQL
17.6 with network disabled, no host ports and a read-only archive mount.
Reviewed 0012, 0013 and 0015 reconstructed the supplied current state. No manual
SQL repair was used. A synthetic expired tester fixture was used only locally;
an initial fixture preparation attempt stopped on its missing email, which was
corrected in the harness before the final clean restore.

The final rehearsal passed preflight, fresh local backup, exact atomic
activation/ledger, independent postflight and rollback. Both anon and
authenticated roles passed capabilities, 24 roots, L2/L3/L4, breadcrumb,
alias/search, listing/detail, seller comparison and shop flows. All 14 eligible
products were reachable; six gated products remained excluded. Public write
attempts were denied. Legacy HTTP results matched before activation, while
active and after rollback. 0015 stayed installed and returned OFF denial after
rollback. All 69 original archive data sections and complete final fingerprints
matched. The private expired lease and all unreviewed fields were preserved.

The existing real Flutter repositories ran through Supabase/PostgREST against
this isolated copy: **3 passed, 0 failed, 0 skipped**, including invalidation of
cached and fresh public runtime after rollback with no fallback. No Flutter
source changed and no release artifact was built.
Client code, assets, Android inputs, dependency lock and integration test match
the frozen build source. The intervening pubspec change only records version
1.0.0+3, which matches the frozen release artifact.

## Quality and failure containment

- Package/activation/0015 regression tests: **29 passed, 0 failed, 0 skipped**.
- Failure injection: **31 passed**, each proving exact state preservation.
- Includes wrong target/authority/seal/SQL/APK, forged or expired backup, absent
  0012/0015, already-applied 0014, facade definition/grant/ledger drift, public ON,
  active tester, node/root/mapping/policy/legacy/RLS/write-grant drift, partial
  activation and rollback, lost commit acknowledgment (committed and aborted),
  rollback before apply and twice.
- Runtime syntax, unchanged reviewed SQL, seal, diff whitespace and secret/PII
  checks passed. Seal excludes rehearsal helpers and unrelated documentation.
- No publishable key, token, password, private key, tester UID, device serial,
  absolute local user path or APK/AAB is included in the commit.

Readiness is based on the supplied live baseline, isolated proof and physical
OFF observation. Future live preflight and backup remain mandatory. Post-ON
physical smoke belongs to the separately authorized activation task.

## TASK_RESULT

```text
W52L_E_FINAL_0014_LIVE_PACKAGE: PASS
CURRENT_0015_STATE_SUPPORTED: PASS
PUBLIC_ACTIVATION_EXECUTOR_READY: PASS
PUBLIC_ACTIVATION_ROLLBACK_READY: PASS
LEGACY_CLIENT_AFTER_ACTIVATION: PASS
FINAL_PUBLIC_CLIENT_CONTRACT: PASS
PRIVATE_PREVIEW_ACTIVE_LEASE_BLOCKED: PASS
FROZEN_PUBLIC_APK_GATE: PASS
PHYSICAL_PUBLIC_OFF_CHECK: PASS
REAL_PRODUCTION_COPY_REHEARSAL: PASS
ROLLBACK_REHEARSAL: PASS
FAILURE_INJECTION_SUITE: PASS
NEW_SEAL_READY: PASS
ELIGIBLE_PRODUCTS: 14/14
GATED_PRODUCTS: 6/6
FAILURE_INJECTION_CASES: 31
0012_CHANGED: NO
0013_CHANGED: NO
0015_CHANGED: NO
PRODUCTION_ACCESSED: YES_PHONE_READ_ONLY
PRODUCTION_DATABASE_ACCESSED: NO
PRODUCTION_WRITE_PERFORMED: NO
REBUILD_PERFORMED: NO
READY_FOR_0014_PUBLIC_ACTIVATION_WRITE_DECISION: YES
```
