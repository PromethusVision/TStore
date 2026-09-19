# W52K-BX — Preview bridge execution package

Result: **PASS — ready for the Product Owner's Production write decision.** No live Production or Development connection, backup, deployment, tester grant, public activation or signed RC build occurred in this wave.

Authoritative base: `afac64f92e3b706a864b36b0e72d27dcf75ef07f`.
Task branch: `astra-release/w52k-bx-preview-bridge-execution-package`.

The dedicated package is in [tool/production_preview_bridge/execution](../tool/production_preview_bridge/execution/README.md). [Machine-readable evidence](data/w52k_bx_execution_package_validation.json) contains both independent local proofs, the failure matrix and sanitized isolation timestamps/hashes.

## New authoritative seal

Package/manifest SHA-256:

`6349204e78cb548c556fef5abfdbc1787ff701919b8b541d3ac4a5c4698bf147`

The deterministic [manifest](../tool/production_preview_bridge/execution/manifest.json) protects **36 files**, each with path, normalized UTF-8/LF byte size, SHA-256 and role. It includes executable roots, transitive local imports, frozen SQL, rollback, authorization, schema/security contracts and data actually consumed by validators. Imported code is protected in full even when only selected exports are used. Local rehearsal support is also sealed. Node built-ins are the only external modules.

The old recorded bundle remains unchanged at `f491e08aae3241f218fa2d3bced6ea05ff68d2fa46589d5892f77b62f0ee0cf0`. Every previously recorded member still matches. Its broad evidence glob additionally picks up `docs/data/w52k_a_canonical_production_rc_validation.json`, producing the reported mismatch. BX creates a new reviewed inventory; it does not suppress the mismatch, alter that historical bundle or delete evidence. No old live CLI or bypass option is used.

Unrelated documentation/results are outside the live-input scope. An automated probe proved that a changed runtime file is rejected and an added unrelated evidence file leaves the new seal valid. The manifest hash is supplied externally from reviewed evidence; there is no automatic reseal in a live operation.

| Frozen artifact | SHA-256, LF-normalized |
| --- | --- |
| Unchanged 0012 source | `a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834` |
| Exact existing 0013 bridge source | `9b56e249a6e3054b8303742ca4bcc41d40e216de9c1a62a72193e4bae81091a4` |
| 0013 executor body | `a6713ff41aaa1c210530c995eb8ba92cb6412cf6bdb6357ab7404b0c8de7a563` |
| Existing bridge-only rollback source | `fa138b7d9c42086323e10ef9e05985bc71f65357fc3c4a81e38dbdaab52104d4` |
| Rollback executor body | `b3b010c842d96a3ee9d7b006ec1664597db7bc7032c4beadb1c62a527e1c32e2` |

Only outer transaction boundaries are removed from 0013 and rollback; the dedicated executor owns the transaction. Their original guards, authorization semantics, facade, product scope, grants and fail-closed behavior are unchanged. No migration, Flutter source or existing test was modified.

## Execution and removal

The CLI exposes only `preflight`, `deploy-0013`, `postflight`, `revoke-testers`, `rollback-0013` and `validate-rollback`. It has no generic migration command. Exact target is `mefhfvrgkwciubeajjeb`, direct DB hostname `db.mefhfvrgkwciubeajjeb.supabase.co`, PostgreSQL 17.6, database/session user `postgres`, TLS `verify-full`.

Before any write, the mandatory separate READ ONLY preflight checks the externally supplied package hash, rollback readiness, identity, existing exact 0012 ledger payload, historical ledger, public and security schema fingerprints, legacy queries/data, staged canonical backend and public OFF. A fresh verified backup is additionally required for deploy. The locked write transaction repeats the checks against a fresh snapshot.

The bridge, its deterministic one-statement ledger entry, approved temporary leases and complete post-validator commit **in one transaction**. Pre-commit failure rolls all of them back. An unknown commit acknowledgement requires read-only reconciliation and refuses blind continuation.

The owner supplies exact existing Auth UID(s) and a mandatory UTC expiry in an external plan bound by SHA-256. No real UID is checked in. Each lease must be in the future and no more than 30 days away. Auth JWT plus the private server table authorizes preview; expired, revoked, non-listed or anonymous access is denied. The executor neither creates live Auth users nor handles their email/password/session. Revocation removes only the exact approved UID leases, including expired leases.

Rollback reconciles exact bridge ownership/schema/ledger first, uses the frozen `RESTRICT` drops and removes only the matching 0013 ledger row. It validates the original 0012 staged state before commit. Before-apply and repeated rollback are explicit safe refusals. No CASCADE, 0012 rollback or canonical activation is available.

## Two independent real-copy rehearsals

The newest available local Production backup was the W52J-A retry prewrite archive, completed **2026-09-19 00:06:07.492 UTC**, 537274 bytes, CUSTOM format, pg_dump 17.11, source PostgreSQL 17.6:

`8d98258430fbb7eeccc8ead4e09efa59189aad84e961bb754fe223f07c3fcbc8`

It predates 0012. Each fresh local restore applied the unchanged reviewed 0012 with the existing engine, whose actual inputs are covered by the new BX seal. This was local baseline reconstruction, not a live replay and not a claim that the archive already held 0012.

Both independent instances used pinned image `supabase/postgres@sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00`, network `none`, no published ports and a read-only original backup mount. All **958 archive entries** and **69 table-data sections** were restored. Separate hashed instance identities and timestamps are in the JSON evidence.

| Check | Fresh copy 1 | Fresh copy 2 |
| --- | --- | --- |
| Same final seal before and after | PASS | PASS |
| Read-only preflight | PASS | PASS |
| Atomic bridge + ledger + runtime UID lease | PASS | PASS |
| Post-validator and caller-role contracts | PASS | PASS |
| Real PostgREST: 10 authorized RPCs | HTTP 200 | HTTP 200 |
| Normal authenticated / anonymous, all 10 RPCs | DENIED | DENIED |
| Invalid local JWT signature | DENIED | DENIED |
| Legacy HTTP before/after deployment | PASS | PASS |
| Runtime exact-UID revocation | PASS | PASS |
| Bridge-only rollback and read-only validation | PASS | PASS |
| 0012 full ledger, canonical rows and legacy data preserved | PASS | PASS |
| All 69 archive table-data sections rechecked after fixture removal | PASS | PASS |
| Legacy HTTP after rollback; preview endpoint unavailable | PASS / HTTP 404 | PASS / HTTP 404 |
| Manual SQL repair | NO | NO |

Each final copy retained **1563 canonical nodes, 24 roots, 1245 terminal leaves, 20/20 mappings**, public OFF, 4 legacy categories, 20 products, 285 listings and 57 shops. Preview exposed 14 eligible products and preserved six policy-gated products. Recursive L2/L3/L4, breadcrumb, alias/search, exact leaf and product details passed. Products remain subject to invoker RLS, demonstrated with positive control and a rollback-only restrictive policy.

Preparatory attempts caught and corrected three validation/harness issues: the restored Auth profile trigger required a disposable email field; a column drift fixture reached the data gate before the schema gate; and a valid first category branch ended at L3. The final validator selects a real eligible L4 ancestry. Failed clones were discarded, and both final proofs ran the same sealed package from fresh restores. Bridge SQL was never repaired or changed.

## Failure and regression results

**20 distinct database/executor scenarios passed on each copy (40 executions):** wrong target, wrong package hash, missing UID, invalid UID, expired approval, excessive lease, rollback before apply, missing 0012, public ON, schema drift, 0012 ledger payload drift, injected failure after bridge DDL, reapply, anonymous preview, authenticated non-preview, wrong contract, expired allowlist entry, restrictive product RLS, runtime UID revocation and rollback twice.

The injected mid-transaction error proved that bridge DDL and ledger leave no partial application. Controlled mutations exist only in the network-isolated harness and are rolled back. They are not options or test hooks in the Production engine.

| Regression | Result |
| --- | --- |
| Offline package/authorization/seal tests | 15 PASS / 0 FAIL / 0 SKIP |
| Targeted Flutter preview/client tests | 38 PASS / 0 FAIL / 0 SKIP |
| Full Flutter suite | **2134 PASS / 0 FAIL / 6 existing SKIP** |
| Flutter analyzer | PASS — no issues |

No service-role key, DB password or static privileged secret was added to the client. Preview functions are STABLE with fixed search paths and minimal grants. The private allowlist has no client schema/table grant. No customer/Auth/Storage mutation endpoint was introduced. Evidence contains no real tester UID, password, token, session, raw backup, personal data or absolute local user path. No APK/AAB is included.

## Decision boundary

This package is ready for the **future controlled Production write decision**. Its evidence is from isolated restored copies. It does not assert a new live health check. Future execution still requires the approved external UID/expiry plan, trusted psql/CA hashes, temporary owner-session credentials, fresh verified backup and successful current live read-only preflight. Drift stops the operation; it is never normalized away.

```text
W52K_BX_EXECUTION_PACKAGE: PASS
NEW_SEAL_READY: PASS
SEAL_RUNTIME_SCOPE_CORRECT: PASS
PREVIEW_BRIDGE_ARTIFACT_FROZEN: PASS
PRODUCTION_BRIDGE_EXECUTOR_READY: PASS
BRIDGE_LEDGER_METHOD_READY: PASS
REAPPLY_PROTECTION: PASS
TEMP_UID_ALLOWLIST_READY: PASS
UID_EXPIRY_ENFORCED: PASS
PREFLIGHT_VALIDATOR_READY: PASS
POST_DEPLOY_VALIDATOR_READY: PASS
BRIDGE_ROLLBACK_READY: PASS
REAL_PRODUCTION_COPY_REHEARSAL_1: PASS
REAL_PRODUCTION_COPY_REHEARSAL_2: PASS
ROLLBACK_REHEARSAL_1: PASS
ROLLBACK_REHEARSAL_2: PASS
FAILURE_INJECTION_CASES: 20
FAILURE_INJECTION_SUITE: PASS
LEGACY_RUNTIME_AFTER_BRIDGE: PASS
CANONICAL_BACKEND_AFTER_BRIDGE: PASS
AUTHORIZED_PREVIEW: PASS
AUTHENTICATED_NON_PREVIEW_DENIED: PASS
ANONYMOUS_PREVIEW_DENIED: PASS
PUBLIC_CANONICAL_ACTIVATION: OFF
FULL_FLUTTER: 2134 PASS / 0 FAIL / 6 SKIP
ANALYZER: PASS
0012_CHANGED: NO
PRODUCTION_ACCESSED: NO
PRODUCTION_WRITE_PERFORMED: NO
READY_FOR_PREVIEW_BRIDGE_PRODUCTION_WRITE_DECISION: YES
```
