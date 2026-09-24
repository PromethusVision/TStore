# W52L-C LIVE — 0015 public read facade Production deployment

Result: **PASS**. Under the Product Owner's explicit live-write authorization, the
unchanged main-integrated W52L-C executor installed only 0015 and its exact ledger
entry. Public canonical activation remains **OFF**; 0014 remains absent.

## Authority and frozen execution

- Authoritative main: `2fd0686ecd966171f79c485607d0136c117b1519` (fetched and verified before work).
- Branch: `astra-release/w52l-c-live-0015-deploy`. Initial worktree: CLEAN.
- Production target: `mefhfvrgkwciubeajjeb`; PostgreSQL 17.6.
- Runtime seal: `992d13ee5c891464cf7f443b22df83944dbdd4ce15176e5efa98a7f6b704b3fb` (52 inputs, unchanged).
- 0015 source SHA-256 (LF): `53559e2608fbbcdfedc22112db899340283a782239a6847930842961ba119aa6`.
- Migration: `20260922001500_0015_production_public_customer_reads.sql`.
- No runtime artifact was changed or resealed. Every mutation went through the
  reviewed dedicated CLI; external helpers only scheduled it and performed
  additional read-only comparisons.

## Preflight, backup and commit

The sealed READ ONLY preflight passed before any write transaction. It verified
the exact target, existing 0012/0013, absent 0014/0015, OFF flags, schema/security
baseline, policy gates, ledger, legacy reads and staged canonical contracts.
Supplemental checks recorded the complete requested counts and eight legacy HTTP
flows before deployment. No tester login, refresh or lease change was performed.

The sealed deployment took a **new full logical custom-format backup** outside the
repository, verified its bytes/TOC/identity/freshness and compared the baseline
before and after the backup. It repeated strict preflight under the reviewed locks,
then atomically committed four exact facade functions and the exact 0015 ledger
statement. The sealed independent postflight and further read-only live checks
passed. No generic database push or unrelated migration ran.

| Backup property | Recorded value |
| --- | --- |
| Completed UTC | 2026-09-24T21:38:28.584Z |
| Source PostgreSQL | 17.6 |
| pg_dump | 17.11 |
| Bytes | 1377936 |
| SHA-256 | `d665277d9bdce8bad801f645b78691e151256f5feded95ca5cf48a0f046325e8` |
| Table-data entries | 79 |
| Sanitized location | `<USER_HOME>/EsnaftavarBackups/w52l-0015-live/EsnaftaVar-Production-W52L-0015-20260924T213714433Z.dump` |

## Fail-closed, compatibility and security

All four definitions, signatures, owners, ACLs and ledger payload matched the
reviewed oracle. PUBLIC EXECUTE is revoked; only intended anon/authenticated
non-owner EXECUTE grants exist. The capability function has a fixed definer
search path; the three read functions remain invokers preserving RLS.

While OFF, all four facade calls were denied with SQLSTATE 42501 for both SQL
roles. Anonymous live HTTPS GET calls returned 401/403 and 42501. An existing
non-authorized customer's subject was also exercised under the authenticated
database role in a READ ONLY transaction: all four calls were denied. This
last check used server role/claims, not an Auth login or a saved tester JWT; no
UID was recorded. Missing RPC endpoints were not accepted as successful denial.

| Legacy HTTP flow | HTTP | Rows | Full response hash before/after |
| --- | --- | --- | --- |
| home | 200 | 4 | IDENTICAL |
| listing | 200 | 20 | IDENTICAL |
| category | 200 | 5 | IDENTICAL |
| details | 200 | 1 | IDENTICAL |
| sellers | 200 | 15 | IDENTICAL |
| shop | 200 | 1 | IDENTICAL |
| shop_listings | 200 | 5 | IDENTICAL |
| search | 200 | 2 | IDENTICAL |

Legacy SQL contracts passed for anon/authenticated. No table write grant,
canonical write exposure, policy or RLS change was introduced. Full rowset
fingerprints across 68 public, Auth, Storage and private-preview
tables were identical before and after deployment; only server-side fingerprints
and counts were retained. Auth/Storage metadata also matched. 0012, 0013, the
private bridge and tester allowlist remain unchanged.

Data integrity: products **20/20**, listings **285/285**, shops **57/57**, canonical
nodes **1563/1563**, roots **24/24**, terminal leaves **1245/1245**, owner mappings
**20/20**, eligible products **14/14**, gated products **6/6**. Product and listing
orphans: **0**. No taxonomy, product, listing or shop data mutation occurred.

## Cleanup and next boundary

Rollback was not required. The sealed package tests passed 25/25 and external
handoff tests passed 12/12. Child and owner PowerShell PGPASSWORD state was cleared.
No password, JWT, UID, key, personal path, raw backup or binary build artifact is
included. Development was not accessed; no APK/AAB was built.

The backend is ready for the separate final public-canonical build task. Public
activation is still a separate decision: **0014 is not authorized by this result**.
See [sanitized validation evidence](data/w52l_c_live_0015_validation.json).

```text
W52L_C_LIVE_0015_DEPLOY: PASS
PRODUCTION_WRITE_AUTHORIZED: YES
AUTHORITATIVE_MAIN: 2fd0686ecd966171f79c485607d0136c117b1519
TARGET_PROJECT: mefhfvrgkwciubeajjeb
LIVE_PREFLIGHT: PASS
FRESH_PREWRITE_BACKUP: PASS
FRESH_BACKUP_SHA256_RECORDED: YES
0012_STATE: PASS
0013_STATE: PASS
0014_APPLIED: NO
0015_APPLIED: YES
0015_LEDGER: PASS
PUBLIC_CANONICAL_ACTIVATION: OFF
PUBLIC_READ_CAPABILITIES_RPC: PASS
PUBLIC_PRODUCTS_RPC: PASS
PUBLIC_LISTINGS_RPC: PASS
PUBLIC_SHOPS_RPC: PASS
PUBLIC_OFF_FAIL_CLOSED: PASS
LEGACY_SQL_CONTRACT: PASS
LEGACY_HTTP_CONTRACT: PASS
SECURITY_GRANTS_VALID: PASS
RLS_POLICIES_UNCHANGED: PASS
POST_DEPLOY_PRODUCTS: 20/20
POST_DEPLOY_LISTINGS: 285/285
POST_DEPLOY_SHOPS: 57/57
CANONICAL_NODES: 1563/1563
OWNER_MAPPINGS: 20/20
ELIGIBLE_PRODUCTS: 14/14
GATED_PRODUCTS: 6/6
PRIVATE_PREVIEW_BRIDGE_CHANGED: NO
0012_CHANGED: NO
0013_CHANGED: NO
ROLLBACK_TRIGGERED: NO
ROLLBACK_RESULT: NOT_REQUIRED
PRODUCTION_LEFT_0015_READY_PUBLIC_OFF: YES
PRODUCTION_WRITE_PERFORMED: YES
PGPASSWORD_CLEARED: YES
READY_FOR_FINAL_PUBLIC_CANONICAL_BUILD: YES
READY_FOR_0014_PUBLIC_ACTIVATION: NO
```
