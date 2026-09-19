# W52K-CA — security baseline reconciliation

**PASS. Two fresh real-copy staged rollouts and rollbacks passed with the same new seal. No Production or Development access occurred.** The six real metadata differences are explicitly reconstructed locally; the 24 proven representation differences compare semantically.

## Reconciled reference

Authoritative main: c978ed774be26eafdb7f60fbeff40fca1b21bad8 (W52K-BZ integration). The versioned runtime [security baseline](../tool/production_preview_bridge/execution/security-baseline.json) records every expected security object, the six reviewed property changes, the BZ capture hash and normalization rules. It is derived from the existing verified READ ONLY capture of 2026-09-19 16:41 UTC; CA opens no Production connection. All 15 reconstructed semantic security components match that object-level reference. The seven public catalog components before and after bridge installation are unchanged from the prior package.

| Reconstructed property | Verified expectation | Local-only action |
| --- | --- | --- |
| graphql and graphql_public ACLs | Owner supabase_admin; USAGE for anon/authenticated/service_role; grantable USAGE for postgres; exact grantor/options retained | Explicit schema grants after complete archive restore |
| pg_stat_statements, pgcrypto, uuid-ossp owner | postgres; exact original version and namespace | Guarded reconstruction of the three named extension owner fields and ownership dependencies |
| supabase_read_only_user default | default_transaction_read_only=on | Explicit role default; actual local login proves on |

The original archive remains unmodified. All 958 TOC entries and 69 data sections are restored. PostgreSQL 17 has no [ALTER EXTENSION OWNER operation](https://www.postgresql.org/docs/17/sql-alterextension.html), so the reviewed local helper explicitly reconstructs those three catalog owner properties and their ownership dependencies. It checks the exact previous owner, namespace and version first, requires network none/pinned image/no ports/read-only archive guards, and does not promote roles or change extension member objects. This is a declared automated reconstruction stage before rehearsal, not a manual SQL repair inside the rollout. The live CLI cannot import or invoke this helper; its hash is nevertheless in the new seal.

## Normalization and retained checks

PostgreSQL aclexplode supplies semantic schema/default/Auth-function ACL tuples. Stable tuple ordering preserves object identity, grantee, grantor, privilege and grant option. Role settings use unique sorted keys; duplicate keys fail. Only the audited Auth idle timeout is converted to exact integer milliseconds. Three audited admin logging values normalize to effective none only when explicit, or when a none server default and absence of relevant database overrides prove inheritance. Session/client/user masking, different logging and database read-only overrides fail closed.

GraphQL ACLs and owners, extension identities/owners and the read-only role default have explicit assertions in addition to the fingerprint. All RLS enabled/forced state, policies, function definitions/signatures, SECURITY DEFINER/search_path, grants and unchanged 0012 checks remain. Stage A/B default-deny, authorized tester, ordinary-user/anon denial, staged-only canonical data, legacy reads and public OFF gates are unchanged. No broad exclusions, arbitrary live-hash adoption or security guard bypass was introduced.

## Validation

- 33 Node tests pass, including semantic ACL/config boundaries, guarded inheritance, identity, seal tampering and live-CLI isolation from reconstruction. Syntax, diff and secret/PII checks pass.
- Each fresh copy executes 28 existing identity/deployment/containment failure cases plus 14 new material prewrite cases and four benign variance cases. All material cases stop with **zero write-capable executor transactions**. No failure leaves preview authorization active.
- Material cases cover GraphQL grant removal/addition/grant option, extension owner, read-only default and database override, changed logging, RLS, policy, canonical write grant, RPC grant/signature, SECURITY DEFINER and search_path.
- Benign ACL order, role-key order, timeout spelling and proven explicit/inherited logging each pass the actual read-only preflight twice with an identical semantic snapshot.
- Both complete nominal sequences use runtime synthetic identity, corrected preflight, Stage A/default deny, Stage B/authorized preview, unauthorized denial, canonical and legacy checks, containment, authorization removal, bridge rollback and final validation. SQL and local HTTP checks verify 24 roots, L2–L4 browse and 14 eligible products.
- Both rollbacks remove authorization and bridge objects, reconcile the bridge ledger, preserve 0012/legacy/canonical data and leave public activation OFF. The 69 original archive data sections still match.
- Flutter suite/analyzer: NOT_RUN; no client, Flutter, migration or bridge payload changes.

The same seal is checked before and after both runs: **7fd358e2322064cff30dbb678a4b16af0ee4179643e5cf391e6d551a49afb168** (38 inputs). Tests/evidence/README are outside the runtime seal. The new package supersedes earlier BX/BY seals; it does not authorize a live deployment by itself. Full per-case results, HTTP statuses and independent container hashes are in [validation evidence](data/w52k_ca_security_baseline_validation.json). Task-created local containers were removed after identity/isolation checks; the source archive hash remains unchanged.

## Next authorized live retry

The package is ready for a separately authorized live retry. It must repeat current session/target/backup and complete preflight gates; this result does not assert that a cached tester session is still valid or that live metadata has remained unchanged since BZ. Newly explicit database-role override checks will be evaluated there. No live backup, Auth refresh, deployment, allowlist, ledger or activation operation ran in CA.

## TASK_RESULT

```text
W52K_CA_SECURITY_BASELINE_RECONCILIATION: PASS
LIVE_SECURITY_BASELINE_RECONCILED: PASS
GRAPHQL_SCHEMA_GRANTS_RECONCILED: PASS
EXTENSION_OWNERS_RECONCILED: PASS
READ_ONLY_ROLE_SETTING_RECONCILED: PASS
BENIGN_REPRESENTATION_NORMALIZATION: PASS
MATERIAL_SECURITY_CHECKS_PRESERVED: PASS
FINGERPRINT_GUARD_WEAKENED: NO
MATERIAL_DRIFT_STOPS_BEFORE_WRITE: PASS
REAL_PRODUCTION_COPY_REHEARSAL_1: PASS
REAL_PRODUCTION_COPY_REHEARSAL_2: PASS
ROLLBACK_REHEARSAL_1: PASS
ROLLBACK_REHEARSAL_2: PASS
PREVIEW_AUTH_LEFT_ACTIVE_AFTER_FAILURE: 0
NEW_SEAL_READY: PASS
0012_CHANGED: NO
PRODUCTION_ACCESSED: NO
PRODUCTION_WRITE_PERFORMED: NO
READY_FOR_W52K_B_LIVE_RETRY: YES
```
