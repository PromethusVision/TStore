# W52L-E LIVE: activation rolled back; supplemental observer defect

**Outcome: ROLLED_BACK. Production remains public OFF.** The exact sealed 0014
activation and ledger committed successfully, but an assistant-created
supplemental observer used a private-preview predicate in public mode and
reported a false eligibility failure. The authorized sealed 0014 rollback then
passed. This was not a successful public launch and no live retry was made.

- Authoritative main: `3e7d68bb5ee62c90d774053e00b238f4b61cdd73`.
- Evidence branch: `astra-release/w52l-e-live-0014-activation`.
- Project: `mefhfvrgkwciubeajjeb`; PostgreSQL 17.6.
- Unchanged runtime seal: `86d9b475013ad534322678b35aef0624742b32efe24e1eb050fe9a4879b8245a` (58 inputs).
- Exact activation SQL SHA-256: `719af6150d7d94f24a1378e982667ee8732678e6a18a6624c0fe2ac323be279e`.
- Safe error: `W52LE_W52LE_ELIGIBILITY_14_6`.
- [Structured evidence](data/w52l_e_live_0014_activation_validation.json).

## What ran

The Product Owner authorized only exact reviewed 0014 activation and its ledger,
plus the sealed 0014 rollback on critical failure. Exact live preflight passed:
0012/0013/0015, 0014 absence, public OFF, no active tester lease, frozen artifact,
counts, mappings, policy gates, legacy SQL/HTTP, schema, RLS and grants. All four
0015 functions failed closed while OFF.

A fresh full logical custom backup was verified outside Git, then its baseline
was rechecked. The sealed executor atomically committed exact 0014 and ledger;
its active-state SQL validation passed, including 24 roots, 325 published nodes,
247 assignable leaves, 14 public products, six exclusions and the four facade
functions. The supplemental observer also reached its sealed active-state read
before failing in its separate coverage classification.

No generic migration push, manual repair, tester lease change, bridge removal,
taxonomy remapping, product/listing/shop edit or Development access occurred.
The sealed package, 0012, 0013 and 0015 were not modified.

## Exact root cause and responsibility

The local helper `<LOCAL_RUNTIME>/observe.mjs`, `coverage()`, counted eligibility
with `public._w52kb_assignable` in both OFF and ON states. That private-preview
function calls `_w52kb_visible_v2`, whose unchanged 0013 contract requires every
ancestor to remain `staged`. Approved 0014 publication changes eligible nodes
to `active`. Therefore the helper was not valid for the post-activation state.
This mistake was introduced by the assistant in the supplemental observer,
outside the sealed activation package.

Relevant source contracts:

- [0013 private-preview predicates](../supabase/migrations/20260919001300_0013_production_canonical_private_preview.sql).
- [0012 public visibility predicate](../tool/production_taxonomy/adapter_contract.sql).
- [Sealed public validator](../tool/production_public_activation/live/validators.mjs).

An isolated, network-disabled PostgreSQL 17.6 differential used the unchanged
four predicate definitions and repository source data (1563 nodes, 20 mappings),
with the exact reviewed 325/247 publication set:

| Local state | Preview predicate eligible | Public predicate visible |
| --- | ---: | ---: |
| OFF / staged | 14 | 0 |
| ON / published | 0 | 14 |
| OFF / restored | 14 | 0 |

The failed live observer did not persist its numeric result. Its inferred 0/20
classification is supported by attested function definitions and reproduced
locally; it is not presented as a separately captured live numeric result.
The double `W52LE_` error prefix is incidental error wrapping, not the cause.

The 24 preparation checks had passed but mocked the observer's data coverage.
They did not run that new observer through an actual published-state transition.
The earlier sealed-package rehearsal did not include this later helper. This
coverage gap explains why those checks did not detect the mistake.

## Rollback and final state

Only the sealed 0014 rollback ran. It restored OFF/staged publication and removed
only the 0014 ledger row. Exact preflight and restored fingerprints match.
All 68 compared public/Auth/Storage/private-preview
table summaries and Auth/Storage metadata match. Legacy HTTP hashes match before
activation and after rollback; active-state supplemental HTTP was not reached.

- Products/listings/shops preserved: **20 / 285 / 57**.
- Canonical nodes/roots/terminal leaves: **1563 / 24 / 1245**.
- Owner mappings: **20/20**; policy eligibility remains **14 / 6**.
- Public roots/published nodes/assignable leaves now: **0 / 0 / 0**.
- Product and listing orphans: **0**.
- 0012/0013/0015 and tester allowlist: unchanged.
- Four exact 0015 functions, grants and RLS: preserved.
- Fresh GET-only recheck: all eight legacy reads HTTP 200; all four public facade
  calls HTTP 401 with SQLSTATE 42501, as expected while OFF.
- Six write-authorization probes were denied with 42501 under anon/authenticated.
  They used EXPLAIN without ANALYZE inside READ ONLY transactions; no probe DML ran.

## Backup and credential cleanup

- Location: `<USER_HOME>/EsnaftavarBackups/w52l-0014-live/EsnaftaVar-Production-W52L-0014-20260925T003013550Z.dump`.
- SHA-256: `ebbd10a9aa518ebacfb306bda6853647271e78ffa440a0baab0b2c1efabd3183`.
- Size: 1392016 bytes; 79 table data entries.
- Backup completed UTC: `2026-09-25T00:31:29.112Z`.
- Source PostgreSQL 17.6; verified client tools 17.11.
- Local archive bytes were rehashed after rollback and matched the receipt.

Child and owner process PGPASSWORD cleanup were both verified. No password,
JWT, publishable key, tester UID, device serial, private user data, raw connection
string, backup or APK/AAB is included in these two evidence files.

## Physical acceptance and next action

The connected POCO X7 Pro already had the exact frozen signed `1.0.0+3` APK;
hash, package/version and certificate matched. No rebuild or reinstallation was
needed. **Public-ON physical smoke was NOT_RUN** because activation rolled back.
Crash/ANR results for that unperformed smoke are NOT_RUN, not fabricated PASS.

The saved attempt prevents the existing owner command from silently re-entering.
No helper or sealed-package repair was applied and no activation was retried.
The next correction must use a state-appropriate classifier in the supplemental
observer: public visibility for ON, staged eligibility for OFF, preserving strict
14/6 checks. Validate the complete actual handoff on an isolated current-state
real copy through OFF -> ON -> OFF before another live attempt. No Production
schema/data repair or change to reviewed activation SQL is indicated.

Private preview cleanup is **not ready**. Keep 0013 and its allowlist unchanged;
disposition remains REMOVE_AFTER_PUBLIC_SMOKE for a separate future task.

## TASK_RESULT

The four RPC PASS flags refer to the sealed SQL validation that succeeded while
ON, followed by validated OFF denial after rollback; they do not claim current
public availability. `0014_LEDGER: PASS` means its exact rollback removal was
verified. Evidence integration readiness refers only to this failed-attempt
report, not readiness to activate or remove private preview.

```text
W52L_E_LIVE_0014_ACTIVATION: FAIL
EXECUTION_OUTCOME: ROLLED_BACK
PRODUCTION_WRITE_AUTHORIZED: YES
AUTHORITATIVE_MAIN: 3e7d68bb5ee62c90d774053e00b238f4b61cdd73
TARGET_PROJECT: mefhfvrgkwciubeajjeb
SEALED_LIVE_PREFLIGHT: PASS
FRESH_PREWRITE_BACKUP: PASS
FRESH_BACKUP_SHA256_RECORDED: YES
0012_STATE: PASS
0013_STATE: PASS
0015_STATE: PASS
0014_APPLIED: NO
0014_LEDGER: PASS
PUBLIC_CANONICAL_ACTIVATION: OFF
PUBLIC_ROOTS: 0/24
PUBLISHED_NODES: 0/325
ASSIGNABLE_LEAVES: 0/247
ELIGIBLE_PRODUCTS: 14/14
GATED_PRODUCTS_EXCLUDED: 6/6
CURRENT_PUBLIC_ELIGIBLE_PRODUCTS_VISIBLE: 0/14
PUBLIC_READ_CAPABILITIES_RPC: PASS
PUBLIC_PRODUCTS_RPC: PASS
PUBLIC_LISTINGS_RPC: PASS
PUBLIC_SHOPS_RPC: PASS
PUBLIC_CUSTOMER_FLOW: FAIL
PUBLIC_HTTP_CUSTOMER_FLOW: NOT_RUN
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
PRIVATE_PREVIEW_BRIDGE_CHANGED: NO
0012_CHANGED: NO
0013_CHANGED: NO
0015_CHANGED: NO
ROLLBACK_TRIGGERED: YES
ROLLBACK_RESULT: PASS
PHYSICAL_PUBLIC_ON_SMOKE: NOT_RUN
CRASH: NOT_RUN
ANR: NOT_RUN
PRODUCTION_WRITE_PERFORMED: YES
PGPASSWORD_CLEARED: YES
PRODUCTION_LEFT_PUBLIC_CANONICAL_ON: NO
READY_FOR_PUBLIC_ACTIVATION_EVIDENCE_INTEGRATION: YES
READY_FOR_PRIVATE_PREVIEW_CLEANUP: NO
CUSTOMER_V1_PUBLIC_CANONICAL_GATE: FAIL
SEALED_PACKAGE_CHANGED: NO
LIVE_RETRY_PERFORMED: NO
REBUILD_PERFORMED: NO
```
