# Wave 37A — Ledger Guard Fix Result

Status: **LOCAL PASS — READY FOR INTEGRATION REVIEW, NOT REMOTE APPLY**

Branch base: `origin/main@41ea6bd0042dcd83a2bae056d3aa98f4b44d4308`

Frozen source: `d9c45a1c2acd94fe0bfa52b16772718142c0664a`

## 1. Correction result

- The compiler no longer compares full repository filenames with ledger
  `name` values.
- The manifest records the explicit verified nine-row `(version, name)` ledger
  contract and its deterministic SHA.
- Generated SQL validates exact pairs and rejects duplicates, malformed rows,
  missing/unexpected rows, version mismatch, and name mismatch.
- Repository filename parsing is path-free, locale-free, and separately tested.
- Migration SQL hashing is reproducible across checkout line endings.
- Artifact loading now verifies each generated file byte count/SHA and the
  artifact-set SHA before replay.
- A local-only candidate preparation command binds the reviewed migration
  identifier without writing to `supabase/migrations/` or accessing Supabase.

## 2. Frozen package verification

| Invariant | Result |
|---|---:|
| Upstream aggregate SHA | `095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406` |
| Nodes | 1,563 |
| L1 / L2 / L3 / L4 | 24 / 244 / 1,096 / 199 |
| Leaves | 1,245 |
| UUIDv4 unique | 1,563 / 1,563 |
| Aliases | 651 |
| Alias target edges | 1,000 |
| Split locators / edges | 210 / 591 |
| Public/pilot active | 0 |
| Policy leakage | 0 |
| Payload changed | NO |
| UUID regenerated | NO |

## 3. New executable freeze

- normalized package SHA:
  `f73d6c0f432dd788a4f47a807280017fb068d3cdc21455e8d277a0767511f0a2`
- artifact-set SHA:
  `840ab06907f40ae938f22302b7aeebc0da46c04149d9d6f219f7559197f02341`
- compiler forward SHA:
  `1c8a3b7ad210ac5447ad8caff96b20de14467658bc8af09bd8c2856ff2d02d73`
- identifier-bound local candidate SHA:
  `40fade490cde5f31b5c649ada301852b2abb40c0979a4f2e45bcd735b4f876b8`
- compiler contract: `w37-ledger-pair-compiler-v2`
- intended migration identifier:
  `20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap`

The candidate exists only in an ephemeral local staging path. It was not added
to the active migration chain.

## 4. Exact local rehearsal

Engine: isolated PGlite/PostgreSQL WASM.

| Exercise | Result |
|---|---:|
| Fresh rebuild | 3/3 PASS |
| Forward apply | 3/3 PASS |
| Rollback | 3/3 PASS |
| Idempotent second apply | 2/2 PASS |
| Postcheck | 3/3 PASS |
| Ledger fixture matrix | 11/11 PASS |
| Complete failure matrix | 27/27 PASS |

Every forward run produced the exact node/depth/leaf/alias/relationship counts,
zero orphan/cycle/duplicate errors, zero public/policy leakage, protected five
administrative tables from anonymous access, and validated seven query/RPC
contracts. Every rollback returned all package-owned application/taxonomy rows
to zero while retaining the nine-row migration ledger and unrelated platform
sentinel.

## 5. Ledger-specific matrix

Passed cases:

1. exact 9/9 pairs accepted;
2. same version/wrong name rejected;
3. same name/wrong version rejected;
4. missing historical migration rejected;
5. unexpected migration rejected;
6. duplicate version rejected;
7. duplicate name rejected;
8. duplicate pair rejected;
9. full filename in `name` rejected;
10. reordered exact pair-set accepted deterministically;
11. malformed ledger row rejected.

The parser unit matrix separately rejected malformed repository filenames and
path-bearing inputs. It completed 13/13 cases.

## 6. Failure matrix

All 27 cases failed closed where rejection was expected. In addition to the
existing structural, UUID, parent, depth, policy, alias/split, non-empty target,
migration/schema drift, ownership, and transaction cases, it now includes:

- frozen package SHA mismatch;
- active artifact byte/SHA mismatch;
- ledger version mismatch;
- ledger name mismatch;
- missing historical migration;
- unexpected historical migration;
- duplicate version/name/pair;
- malformed/full-filename ledger row.

The injected mid-transaction failure left zero partial categories.

## 7. Remaining pre-apply gates

Artifact-integrity and local ledger-contract blockers are closed. These gates
remain open:

1. Integration reviews this branch, corrected ledger mapping, new hashes, and
   staged candidate body.
2. A fresh Product Owner Development-write confirmation is required because the
   executable artifact identity changed. Previous authority is not inherited.
3. A newly authorized read-only Development snapshot must be captured and pass
   the corrected offline precheck.
4. Single writer, write freeze, restore point, execution operator, rollback
   trigger, and post-apply monitoring must be confirmed.
5. Integration creates/reviews any future active migration entry; this task did
   not add one.

## 8. Safety

- Development accessed: NO
- Production accessed: NO
- Supabase remote API accessed: NO
- Auth/Storage/Realtime accessed: NO
- Remote write/apply: NO
- Active migration chain changed: NO
- Taxonomy activated: NO
- Frozen payload/UUID changed: NO

## 9. Readiness flags

`SUPABASE_LEDGER_CONTRACT: PASS`

`MIGRATION_HISTORY_GUARD_FIXED: PASS`

`FROZEN_CATEGORY_PACKAGE_PRESERVED: PASS`

`UUID_ALLOCATION_PRESERVED: YES`

`ARTIFACT_HASH_LINEAGE_RECONCILED: PASS`

`EXACT_LOCAL_REHEARSAL: PASS`

`LEDGER_FAILURE_MATRIX: PASS`

`REMOTE_ACCESS_PERFORMED: NO`

`ACTIVE_MIGRATION_CHAIN_CHANGED: NO`

`READY_FOR_W37_RETRY_INTEGRATION: YES`

This readiness is for Integration review and a separately authorized controlled
retry only. It is not Development or Production apply authority.
