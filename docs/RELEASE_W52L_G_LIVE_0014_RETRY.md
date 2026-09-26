# W52L-G LIVE: public canonical activation passed

**Result: PASS. Production remains public canonical ON; 0014 is applied.**
The exact sealed activation and ledger committed atomically. The integrated
W52L-F observer classified OFF and ON correctly, and all critical backend/public
customer validations passed. **No rollback was triggered.**

The POCO was not connected before or after activation. Public-ON physical smoke,
crash and ANR checks are **NOT_RUN**. The customer release gate remains
**PENDING_PHYSICAL** and private preview cleanup is **not ready**.

- Authoritative main: `1202da02c63b4c84d35bfa795d1c48278925a9af`.
- Evidence branch: `astra-release/w52l-g-live-0014-retry`.
- Production project: `mefhfvrgkwciubeajjeb`; PostgreSQL **17.6**.
- Activation seal: `86d9b475013ad534322678b35aef0624742b32efe24e1eb050fe9a4879b8245a`; **58 unchanged inputs**.
- Corrected observer: `4f8711f877069b7e903a1be22e44550bb998bbdf85664e7fb9978c5ca04fc521`.
- [Structured evidence](data/w52l_g_live_0014_retry_validation.json).

## Authorization and execution

The Product Owner explicitly authorized exact sealed 0014 plus its exact ledger,
and sealed rollback only for a real critical failure. The dedicated executor was
used without SQL changes, resealing, generic migration push or manual repair.
0012, 0013, 0015, the preview bridge, tester allowlist, taxonomy mappings and
product/listing/shop data were preserved. Development was not accessed.

Before write, exact target, PG version, migration ledgers, four 0015 definitions,
grants, RLS/security, legacy SQL/HTTP, staged taxonomy and absence of an unexpired
preview lease passed. Frozen APK/AAB hashes and the actual APK signature/version
passed. The corrected OFF observer reported 14 eligible, 6 gated, zero public
visibility, and expected 42501 denials from all four 0015 functions.

A new full custom-format backup was created outside Git. Readable TOC, source
identity, bytes, SHA-256 and freshness passed. The sealed executor repeated its
mutation-sensitive baseline checks after backup and under transaction locks,
then committed the unchanged reviewed 0014 and exact ledger atomically.

The sealed active-state validator and corrected ON observer both passed. ON used
the reviewed public visibility/assignability predicate; staged/private-preview
eligibility was not used as an ON rollback criterion.

| Check | Result |
| --- | --- |
| Public roots | 24/24 |
| Published nodes | 325/325 |
| Assignable leaves | 247/247 |
| Eligible products publicly visible | 14/14 |
| Gated products excluded | 6/6 |
| Total products / listings / shops preserved | 20 / 285 / 57 |
| Canonical nodes / mappings preserved | 1563 / 20 |
| Product/listing orphans and broken parent chains | 0 |

## Public reads, security and preservation

All four exact 0015 public RPCs passed: capabilities, products, listings and shops.
Anonymous GET-only live customer checks passed for Home/All Categories contracts,
24 roots, L2/L3/L4, breadcrumb, alias resolution, search, product listing/details,
seller comparison and shop details. No tester login, Auth session, preview lease,
private-preview authorization, legacy taxonomy fallback or Development fallback
was used by these checks. SQL also verified anon/authenticated role parity with
no tester identity.

The public facade returned **198 eligible listing rows** and **57 active shops**;
the database's **285 total listing rows** remained unchanged. These are different
scopes, not missing data.

Canonical write grants remained zero across nine RLS-protected tables. Six
read-only EXPLAIN-without-ANALYZE permission probes denied UPDATE, DELETE and
INSERT under anon/authenticated (SQLSTATE 42501); probe DML was not executed.
The exact facade grants, policies, invoker semantics and definer search path passed.

All **68 protected application/Auth/Storage/private table summaries** and protected
metadata matched before/after, excluding only the reviewed publication fields
whose exact values were separately validated. Legacy SQL passed, and all eight
legacy HTTP result hashes matched. No private preview removal or allowlist change
was made. Rollback was **NOT_REQUIRED**, and Production was deliberately left ON.

A separate completion check rehashed the backup, confirmed the same 58 input bytes
and corrected observer identity, and made three anonymous read-only HTTP requests:
runtime, public capability and roots all returned **HTTP 200**, public ON, 24 roots,
and no tester/preview requirement. No additional Production write occurred.

## Backup, frozen client and cleanup

- Backup: `<USER_HOME>/EsnaftavarBackups/w52lg-0014-live/EsnaftaVar-Production-W52LG-0014-20260926T003228049Z.dump`.
- SHA-256: `bb3aa7d659de92b443d76d660363611806d17b65e3908438d48acff6a6a87e54`.
- Size: **1386870 bytes**; **79 table-data entries**.
- Backup completed UTC: `2026-09-26T00:33:59.664Z`.
- Live execution completed UTC: `2026-09-26T00:38:15.157Z`.
- Source PostgreSQL 17.6; verified client tools 17.11.
- APK: `04d71bfd25920c171fd25f27416ee22f74f851608bb3c79b1561dc4966827f64`.
- AAB: `17e361684eab4aea6432bfa47a00af543777107c8bf7d0ccd472341b9e77cc79`.
- Package/version: `com.esnaftavar.app`, `1.0.0+3`.
- Signing certificate SHA-256: `3B83D98AB8D32E0F3B9930FA837636E0E9E13219784FFCA39CEF8CAE82A6669B`.
- Runtime: `PRODUCTION_PUBLIC_CANONICAL`; no rebuild, reinstall or data clear.

Child and owner PowerShell process PGPASSWORD cleanup were verified, including
the owner cleanup receipt. No password, publishable key, JWT, UID, private key,
service-role secret, device serial, raw connection string, backup or APK/AAB is
included in these evidence documents. Local user paths are anonymized.

## Physical acceptance and quality

ADB reported zero connected, unauthorized or offline devices at the final check.
The sealed preflight reused the earlier W52L-E public-OFF physical acceptance
receipt; that historical PASS does not represent a public-ON physical test.
No physical launch, Home-eight-card check, all-category screen, navigation,
crash or ANR result is claimed. Device absence did not roll back a healthy backend.
The next acceptance step is physical public-ON smoke with the same frozen APK.
Leave 0013 installed; its separate disposition remains REMOVE_AFTER_PUBLIC_SMOKE.

Preexecution checks: **53 PASS**, zero failures/skips, covering the external secure
handoff, integrated observer and unchanged activation/facade packages. Only the
two sanitized evidence documents change in Git. Secret/PII scan and
`git diff --check` passed. No Flutter source changed; no Flutter rebuild or full
suite rerun was required. No main merge or force push was performed.

## TASK_RESULT

`PUBLIC_CUSTOMER_FLOW: PASS` refers to live SQL/HTTP customer contracts.
Physical acceptance remains explicitly pending.

```text
W52L_G_LIVE_0014_RETRY: PASS
PRODUCTION_WRITE_AUTHORIZED: YES
AUTHORITATIVE_MAIN: 1202da02c63b4c84d35bfa795d1c48278925a9af
TARGET_PROJECT: mefhfvrgkwciubeajjeb
SEALED_PACKAGE_HASH: 86d9b475013ad534322678b35aef0624742b32efe24e1eb050fe9a4879b8245a
CORRECTED_OBSERVER_IDENTITY: 4f8711f877069b7e903a1be22e44550bb998bbdf85664e7fb9978c5ca04fc521
LIVE_PREFLIGHT: PASS
STATE_A_OFF_CLASSIFIER: PASS
FRESH_PREWRITE_BACKUP: PASS
FRESH_BACKUP_SHA256_RECORDED: YES
0012_STATE: PASS
0013_STATE: PASS
0015_STATE: PASS
0014_APPLIED: YES
0014_LEDGER: PASS
PUBLIC_CANONICAL_ACTIVATION: ON
STATE_B_ON_CLASSIFIER: PASS
PUBLIC_ROOTS: 24/24
PUBLISHED_NODES: 325/325
ASSIGNABLE_LEAVES: 247/247
ELIGIBLE_PRODUCTS_VISIBLE: 14/14
GATED_PRODUCTS_EXCLUDED: 6/6
PUBLIC_READ_CAPABILITIES_RPC: PASS
PUBLIC_PRODUCTS_RPC: PASS
PUBLIC_LISTINGS_RPC: PASS
PUBLIC_SHOPS_RPC: PASS
PUBLIC_CUSTOMER_FLOW: PASS
LEGACY_SQL_CONTRACT: PASS
LEGACY_HTTP_CONTRACT: PASS
PUBLIC_WRITES_DENIED: PASS
SECURITY_GRANTS_VALID: PASS
RLS_POLICIES_VALID: PASS
POST_ACTIVATION_PRODUCTS: 20/20
POST_ACTIVATION_LISTINGS: 285/285
POST_ACTIVATION_SHOPS: 57/57
CANONICAL_NODES: 1563/1563
OWNER_MAPPINGS: 20/20
0012_CHANGED: NO
0013_CHANGED: NO
0015_CHANGED: NO
PRIVATE_PREVIEW_BRIDGE_CHANGED: NO
ROLLBACK_TRIGGERED: NO
ROLLBACK_RESULT: NOT_REQUIRED
PHYSICAL_PUBLIC_ON_SMOKE: NOT_RUN
CRASH: NOT_RUN
ANR: NOT_RUN
PRODUCTION_WRITE_PERFORMED: YES
PGPASSWORD_CLEARED: YES
PRODUCTION_LEFT_PUBLIC_CANONICAL_ON: YES
CUSTOMER_V1_PUBLIC_CANONICAL_GATE: PENDING_PHYSICAL
READY_FOR_LIVE_RETRY_EVIDENCE_INTEGRATION: YES
READY_FOR_PRIVATE_PREVIEW_CLEANUP: NO
```
