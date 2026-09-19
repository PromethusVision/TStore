# W52K-BZ — exact live schema/security differential

**Audit PASS; live retry remains NOT READY.** All 30 differing catalog properties are identified: 21 deterministic serialization differences, three equivalent platform role-setting representations, and **six semantic security differences**. Public canonical activation is **OFF**, read live in a TLS-verified READ ONLY transaction. No Production write, Auth mutation, backup or bridge retry occurred.

## Exact cause

The previous stop compares `stable(snapshot(db))` with `stable(contract.before)` in the main-integrated BX validator. The snapshot is seven public-catalog hashes plus 15 security hashes. The serialization sorts object keys recursively but preserves array order and textual ACL order. Each component uses SHA-256. File input normalizes CRLF to LF; query-returned definitions and settings are otherwise compared exactly.

The seven public components match. Five security components differ: `schemas`, `roles`, `defaults`, `authFunctions`, `extensions`. Row order and the database locale/provider/collation version match; this is not the earlier constraint-ordering defect.

| Difference | Objects / property cells | Classification and consequence |
| --- | ---: | --- |
| Default-privilege ACL entry order | 19 | Same aclexplode privilege tuples, including grantor and grant option. Serialization false positives. |
| auth.jwt() ACL entry order | 1 | Identical definition, owner and effective EXECUTE permissions. Serialization false positive. |
| authenticator rolconfig key order | 1 | Same unique keys and values. Serialization false positive. |
| Three platform-admin rolconfig representations | 3 | Explicit live log_statement=none equals inherited none proven with actual local role connections; Auth timeout 60000 ms equals 1min. Equivalent in these measured environments. |
| graphql / graphql_public schema ACLs | 2 | Live grants USAGE to anon/authenticated/service_role and grantable USAGE to postgres; sealed restore is owner-only. Real privilege difference. |
| pg_stat_statements / pgcrypto / uuid-ossp owner | 3 | Live postgres; sealed restore supabase_admin. Real administrative-authority difference. Versions and schemas match. |
| supabase_read_only_user rolconfig | 1 | Live defaults READ ONLY; restored login defaults READ WRITE. Live has the stronger safeguard. |

Counts refer to catalog property cells: a full ACL or settings array is one property. Every EXPECTED/LIVE value, schema, object name, relevance flag and classification appears in [the 30-row machine-readable diff](data/w52k_bz_schema_security_diff.json). The six material differences concern the restored oracle versus live metadata; this is **not** a claim that Production suffered an unauthorized security change.

## Fingerprint coverage and limits

| Area | Exact included input / boundary |
| --- | --- |
| Tables, sequences, views | Public relation name/kind/owner/RLS enabled/forced/ACL; private-preview relation equivalents. View SQL is supplemental, not an original hash input. |
| Columns and types | Public and private column ordinal, SQL/UDT type, nullability and default; standalone public type definitions are supplemental. |
| Constraints and indexes | Public PK/FK/check/unique definitions and validation; index definitions; private-preview constraints and indexes. |
| Functions and RPCs | Public identity arguments, return signature, pg_get_functiondef, owner and ACL; Auth and private function metadata. Definition text carries volatility, SECURITY DEFINER and search_path; separate explicit metadata also matches. |
| Triggers and policies | Public non-internal triggers and policies; private equivalents; global event-trigger metadata. Auth row-trigger definitions are supplemental in this audit. |
| Grants, roles, schemas | Schema owner/ACL, all role attributes plus rolconfig, named memberships/grantors/options, global default ACLs, scoped column ACLs. Names replace object/role OIDs. |
| Extensions | Name, version, schema and owner. The original fingerprint does not capture every platform module's runtime behavior. |
| Ledger | Ledger schema, historical entries and exact 0012 payload are separate earlier guards, not inputs to this failing snapshot. This audit reads version/name/count/hash metadata only. |
| Auth / Storage / managed schemas | All non-pg/non-information schemas contribute owner/ACL. Auth functions, global roles/default grants and scoped column grants contribute; Auth user/session rows do not. Storage table bodies/rows/policies are not broadly included. |
| Ordering / volatile values | Public constraints explicitly use COLLATE C; most other SQL sorts use database collation. Arrays and ACL text order remain significant. OIDs, PIDs, account rows and capture timestamps are not fingerprint inputs; semantic owner/settings/version changes are not discarded. |

## Exact expected source and why both real copies passed

The newest existing Production archive is the W52J retry prewrite backup completed 2026-09-19 00:06:07 UTC, SHA-256 `8d98258430fbb7eeccc8ead4e09efa59189aad84e961bb754fe223f07c3fcbc8`. It was written by pg_dump 17.11 from PG17.6 and predates 0012. A fresh isolated PG17.6 restore used the exact original pipeline, all 958 TOC entries, owner/ACL restoration and unchanged 0012 reconstruction. Its recovered 22 component hashes match the sealed expected baseline **exactly**.

The image is `supabase/postgres@sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00`, with network none, no ports and a read-only archive mount. Source database ICU/locale metadata was reconstructed exactly.

The archive contains no global role DDL. Roles/settings instead come from the separate W52H-R metadata captured on September 16. That source lacks the live read-only-user default and explicit logging entries. Its set_config/ALTER ROLE FROM CURRENT reconstruction normalizes the Auth timeout to 1min and reorders settings. Default ACL and Auth function ACL restoration also changes entry order without changing permissions.

For GraphQL schemas, the archive contains CREATE SCHEMA and ownership statements but no top-level schema GRANT/REVOKE statements. Its GraphQL event helpers grant access when pg_graphql is created, but that extension is absent from this archive's extension creation sequence. The local schemas therefore remain owner-only. Extension CREATE statements contain no owner restoration and run under supabase_admin, producing the observed three owner differences.

BX/BY computed and checked their oracle against this same restore process. Two fresh restores therefore reproduced the same local metadata and both passed; neither established equality with the complete live platform-security metadata. The live preload module list also exceeds the local harness list; that supplemental difference is not itself in the failing hash.

This establishes the reproduction gap, not the historical time at which each live setting/grant arose. No causal audit trail was captured, so tester-account causation remains NOT_PROVEN. The fingerprint never selects auth.users/auth.sessions rows. Auth/public data-trigger metadata also matches; ordinary account row changes cannot by themselves change these catalog-only hash inputs.

## Security decision and narrow correction plan

The current guard is preserved. GraphQL grants, extension ownership and the read-only-role safeguard cannot be silently normalized away. No live hash was adopted as a new trusted baseline, no auth/security schema was excluded, and no package was resealed.

The correction plan is to reproduce independently reviewed live security metadata faithfully in the local restore, then normalize only proven representation differences: semantic ACL tuples, unique GUC keys and typed timeout units. Explicit-versus-inherited logging needs an effective-value assertion. Owners, grants, grant options, RLS, policies, signatures, SECURITY DEFINER/search_path, public OFF and both staged denial gates must remain enforced before any write-capable executor. Production should not be modified to imitate the incomplete clone.

All public relation/RLS/ACL, policy, RPC and 0012 metadata matches the original expectations. The preview bridge is absent, so this audit does not claim a live preview RPC denial test after deployment. Existing Stage A/B security and denial assertions remain unchanged in the 33-file sealed package.

## Tests and conditional rehearsal status

- Deterministic metadata reader: two equivalent mocked captures, 68 SELECT calls checked; no application/Auth row query.
- Exact expected recovery: every sealed component hash matched the fresh real-copy metadata.
- Object/property validation: all 30 differences accounted for; after the proven benign equivalences, exactly the six semantic security differences remain.
- Real isolated PostgreSQL fault tests: RLS disabled, canonical INSERT grant added, policy added, and RPC renamed each fail the unchanged sealed preflight before any write-capable transaction or bridge payload.
- ACL reorder and timeout spelling variations produce deterministic semantic PASS in the analysis-only comparator. The unchanged live guard still refuses their raw representation drift; no corrected live guard is claimed.
- All six fault tests leave zero active preview authorizations and zero executor write-capable transactions. Injected setup changes occur only in network-disabled local copies.
- Actual restored role connections prove inherited logging none and the missing read-only default. No Flutter/client code changed, so Flutter tests are not applicable.

Full corrected Stage A/B deployment, a second clean corrected rollout and bridge rollback rehearsals are **NOT_RUN**: six material security discrepancies make acceptance ineligible. Metadata recovery and prewrite fault tests are deliberately not represented as successful full rollout rehearsals. A new live retry remains blocked pending reconciliation of the expected source and two complete subsequent rehearsals.

## TASK_RESULT

```text
W52K_BZ_SCHEMA_SECURITY_DIFFERENTIAL: PASS
ROOT_CAUSE_IDENTIFIED: YES
DIFFERING_OBJECT_COUNT: 30
DIFFERING_PROPERTY_COUNT: 30
DIFFERENCE_CLASSIFICATION: MATERIAL_SECURITY_DRIFT
MATERIAL_SCHEMA_DIFFERENCE_COUNT: 0
MATERIAL_SECURITY_DIFFERENCE_COUNT: 6
TESTER_ACCOUNT_CAUSED_DRIFT: NOT_PROVEN
REAL_COPY_GAP_EXPLAINED: YES
PUBLIC_CANONICAL_ACTIVATION_CURRENT: OFF
FINGERPRINT_CORRECTION_REQUIRED: YES
FINGERPRINT_GUARD_WEAKENED: NO
EXPLICIT_RLS_POLICY_GRANT_CHECKS_PRESERVED: PASS
PRE_WRITE_GATE_PRESERVED: PASS
MATERIAL_MISMATCH_STOPS_BEFORE_WRITE: PASS
0012_CHANGED: NO
LATEST_REAL_COPY_REHEARSAL: NOT_RUN
SECOND_CLEAN_REHEARSAL: NOT_RUN
ROLLBACK_REHEARSAL: NOT_RUN
PRODUCTION_ACCESSED: READ_ONLY
PRODUCTION_WRITE_PERFORMED: NO
READY_FOR_W52K_B_LIVE_RETRY: NO
```

Validation evidence: [w52k_bz_schema_security_validation.json](data/w52k_bz_schema_security_validation.json). Only three sanitized evidence documents belong to this change; runtime code and 0012 are unchanged. The owner confirmed PGPASSWORD_CLEARED: YES. All three task-created isolated containers were removed after their stopped identity and read-only archive mount were checked; the source archive hash is unchanged. No secrets, tester UID, row data or absolute local user paths are included.
