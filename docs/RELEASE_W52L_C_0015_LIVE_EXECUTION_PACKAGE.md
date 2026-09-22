# W52L-C — 0015 public read facade execution package

**Result: PASS. Ready for a separate live-deploy decision.** No Production or
Development connection, live backup, live write, public activation, Flutter
change or rebuild occurred in this wave.

Required `origin/main` was fetched and verified at
`449f10ae72da912b83688d6b7b8a0d04d810bb51`. Work started from a clean isolated
checkout on `astra-release/w52l-c-0015-live-execution-package`.

The new executor installs the existing, unchanged
`20260922001500_0015_production_public_customer_reads.sql` while both public and
preview flags remain OFF. It adds exactly these reviewed functions:

- `production_public_read_capabilities_v1`
- `production_public_products_v1`
- `production_public_listings_v1`
- `production_public_shops_v1`

There are no changes to 0012, 0013, the activation-only 0014 package, 0015 SQL,
taxonomy/data, table grants, RLS policies or Flutter. New files are confined to
`tool/production_public_client/live/` and this wave's two evidence documents.

## Execution contract

The [operator runbook](../tool/production_public_client/live/README.md) describes
the exact future commands and secure local credential procedure. The CLI has
only `preflight`, `deploy`, `postflight` and `rollback`; it has no activation or
arbitrary SQL operation. No generic database push is used.

The preflight requires the exact verified Production identity, PostgreSQL 17.6,
frozen 0012/0013 ledger and schema/security/data contracts, no active private
tester lease, OFF flags, absent 0014 and absent 0015. All drift fails closed.
Live transport, when separately authorized, uses the fixed direct hostname,
TLS `verify-full`, pinned client tools and CA, and temporary owner-session
credentials. That transport was not connected to Production in this wave.

Deployment creates and checks a fresh custom archive with a verified TOC,
digest, size, identity and maximum 15-minute age. It compares the full baseline
before/after backup and again under locks. Four function definitions and the
exact single-statement 0015 ledger row commit atomically after validation.
An independent READ ONLY postflight follows. Notifications commit with the DDL.

Rollback verifies the exact installed definitions, signatures, owners, ACLs and
ledger before removing only the four functions and 0015 ledger row atomically.
It uses no CASCADE and performs no taxonomy or activation writes. Uncertain
COMMIT outcomes are reconciled on a fresh connection; only a fully attested
installation can be automatically removed. Unknown states stop for review.

## Frozen artifacts

| Artifact | SHA-256 |
| --- | --- |
| New runtime seal | `992d13ee5c891464cf7f443b22df83944dbdd4ce15176e5efa98a7f6b704b3fb` |
| Unchanged 0015 source (LF) | `53559e2608fbbcdfedc22112db899340283a782239a6847930842961ba119aa6` |
| Exact 0015 ledger statement (LF) | `3b8d31ba0c37dd87dac8f04de8e108762bc8d106e5fe26b6b0d2ca835b3b3d5c` |
| Unchanged W52L-B seal | `ad0d1c6c51ac2d2bd064df78f099d2659fc4575949d529e10ffc4f4bdc595a69` |
| Suitable real Production rehearsal archive | `8d98258430fbb7eeccc8ead4e09efa59189aad84e961bb754fe223f07c3fcbc8` |

The new seal covers 52 runtime inputs, including transitive imported validators,
transport, backup and transaction code, immutable SQL, rollback and exact oracles.
Tests and reports cannot alter its digest. LF normalization is explicit, making
verification independent of Windows checkout line endings.

## Two independent real-copy rehearsals

Both restores used the same suitable historical Production archive in separate
fresh containers running the pinned PostgreSQL 17.6 image:
`supabase/postgres@sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00`.
Containers had no network, no published ports and a read-only archive mount.
All 958 selected archive objects were restored with zero omissions, plus the
reviewed platform/event-trigger reconstruction. The unchanged approved 0012/0013
payloads recreated the current staged baseline on each historical restore.
The 0014 activation payload was never executed.

| Check | Restore 1 | Restore 2 |
| --- | --- | --- |
| Strict preflight and new local prewrite backup | PASS | PASS |
| Atomic 0015 and exact ledger installation | PASS | PASS |
| All four definitions, grants, RLS and OFF flags | PASS | PASS |
| SQL anon/authenticated denial (8 calls) | PASS | PASS |
| PostgREST anon/authenticated denial (8 calls) | PASS | PASS |
| Legacy SQL and HTTP response hashes unchanged | PASS | PASS |
| 0015-only atomic rollback | PASS | PASS |
| Complete final fingerprint equals initial fingerprint | PASS | PASS |
| Original archive data sections preserved | 69/69 | 69/69 |
| Failure cases, with no residual state change | 24/24 | 24/24 |
| Final runtime seal verification | PASS | PASS |

PostgREST returned `401/403` with SQLSTATE `42501` for every OFF facade call.
Legacy Home categories, product listings, category listings, product details,
seller comparison, shop details, shop listings and search retained identical
complete response hashes for both `anon` and `authenticated`, before installation,
after installation and after rollback. These HTTP calls used container loopback
and local test tokens only, not a Production endpoint or tester account.

PUBLIC EXECUTE was absent on all four functions. Only intended client roles
`anon` and `authenticated` had non-owner EXECUTE grants; `service_role` had none.
All four functions were STABLE with fixed `pg_catalog, public` search paths.
The capability function was DEFINER; the three data functions were INVOKER.
Nine canonical tables retained RLS and zero client write grants. The complete
schema/security snapshot and data hashes also matched the frozen baseline.

## Failure injection and quality

24 distinct cases ran on **each** clean copy (48 executions): wrong project,
missing authorization, wrong SQL hash, wrong seal, forged/missing backup, stale
backup, missing 0012, unexpected 0014 ledger, public already ON, rollback before
apply, failure after functions, failure after ledger, uncertain COMMIT aborted,
uncertain COMMIT committed, reapply, wrong definition, PUBLIC execute grant,
service-role execute grant, wrong ledger payload, disabled RLS, canonical write
grant, an OFF function incorrectly returning success, partial rollback and
rollback twice. Every case proved an unchanged full fingerprint after recovery.
The public-ON and 0014-ledger fixtures were discarded local transactions, not an
execution of the activation migration.

Package tests: **25 passed, 0 failed, 0 skipped** across W52L-A, W52L-B and the new
live package. SQL validation and rollback ran against real PostgreSQL 17.6.
JavaScript syntax, seal, `git diff --check` and secret/PII scan passed. Flutter
tests/analyzer are not applicable because no Dart or Flutter files changed.

Machine-readable counts, hashes, timings, status codes and failure evidence are
in [the sanitized validation record](data/w52l_c_0015_execution_validation.json).
No user path, password, token, tester UID, email, raw dump, APK or AAB is included.

## Decision boundary

This is readiness evidence, not a claim about the current live database state.
A separately authorized execution must pass live preflight and create a new
Production backup. It must stop on drift. Public activation remains a separate
decision and a separate activation-only package; this executor cannot perform it.

```text
W52L_C_0015_EXECUTION_PACKAGE: PASS
0015_ARTIFACT_FROZEN: PASS
0015_EXECUTOR_READY: PASS
0015_LEDGER_READY: PASS
REAPPLY_PROTECTION: PASS
POST_DEPLOY_VALIDATOR_READY: PASS
0015_ROLLBACK_READY: PASS
PUBLIC_OFF_FAIL_CLOSED: PASS
LEGACY_CLIENT_PRESERVED: PASS
SECURITY_GRANTS_VALID: PASS
REAL_PRODUCTION_COPY_REHEARSAL_1: PASS
REAL_PRODUCTION_COPY_REHEARSAL_2: PASS
ROLLBACK_REHEARSAL_1: PASS
ROLLBACK_REHEARSAL_2: PASS
FAILURE_INJECTION_CASES: 24
FAILURE_INJECTION_SUITE: PASS
NEW_SEAL_READY: PASS
0012_CHANGED: NO
0013_CHANGED: NO
0014_APPLIED: NO
PRODUCTION_ACCESSED: NO
PRODUCTION_WRITE_PERFORMED: NO
READY_FOR_0015_LIVE_DEPLOY_DECISION: YES
```
