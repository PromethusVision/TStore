# Wave 36B-R — Exact Frozen Bootstrap Artifact Replay

Status: **PASS — LOCAL REPLAY ONLY**

This report binds the existing Wave36B compiler/tooling to the exact frozen
Wave36A package. It grants no Development, Production, Supabase, migration, or
activation authority.

## 1. Safety boundary

- Source access: read-only Git objects.
- Database engine: isolated local PGlite 0.5.5 / PostgreSQL 18.3 WASM.
- Remote database, Development, Production, Supabase CLI, Auth, Storage, and
  Realtime access: none.
- Source branch merge: none.
- Active migration directory: unchanged.
- Frozen payload modification: no.
- Category UUID allocation or regeneration: no.

The source files were read with `git cat-file blob`. They were not checked out,
rewritten, reordered, or subjected to line-ending normalization.

## 2. Frozen source lineage

| Evidence | Value |
|---|---|
| Source ref | `origin/agent1/w36-exact-taxonomy-bootstrap-package` |
| Exact source HEAD | `d9c45a1c2acd94fe0bfa52b16772718142c0664a` |
| Taxonomy version | `canonical-v1.0.0` |
| Frozen aggregate SHA-256 | `095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406` |
| Superseded metadata | `9687878401513881335a5a1479cdf53e2b4b3108debb3d28297444f3e2808091` — rejected |
| Compiler branch input HEAD | `46c8660c16b252709df05ac327409c284139a970` |

## 3. Exact payload verification

Counts exclude the header. Hashes and bytes cover exact committed Git blobs.

| Payload | Rows | Bytes | SHA-256 |
|---|---:|---:|---|
| `TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv` | 1,563 | 902,393 | `52c35da75129c4c21e4492f658e28452123baeb2532e373c347458762937549d` |
| `TAXONOMY_W36_ALIAS_IMPORT.csv` | 651 | 319,248 | `eb03acf1e6d71912dc1e277cd5e615432df64e670da9f11b900749ef864306cb` |
| `TAXONOMY_W36_ALIAS_TARGET_EDGES.csv` | 1,000 | 280,473 | `9bdeb8748198070379b647f029aa609dfed2cec5c48ba9e6df4d1fdceacdd5e0` |
| `TAXONOMY_W36_CATEGORY_IMPORT.csv` | 1,563 | 355,124 | `4c3fa47f1174312606bea59dc5c1629730bd8ba826ce85d61fd0508d6738db78` |
| `TAXONOMY_W36_DEVELOPMENT_UUID_ALLOCATION.csv` | 1,563 | 619,495 | `83220cd7b1fa78e8672f6a137cdc20158692bf9406ce62c9133e589db2f27de2` |
| `TAXONOMY_W36_SUCCESSOR_IMPORT.csv` | 1,032 | 580,652 | `1858ebaf9488693e791f3c36c2c7ee5032a1fef20750f576ac2745244b5fb0b3` |

The canonical `filename|row_count|lowercase_sha256\n` preimage is exactly 639
UTF-8 bytes. Its SHA-256 is the frozen aggregate above. All 6/6 individual
hashes, byte counts, row counts, preimage length, and aggregate digest passed.

## 4. Package invariants

| Invariant | Result |
|---|---:|
| Nodes | 1,563 |
| L1 / L2 / L3 / L4 | 24 / 244 / 1,096 / 199 |
| Leaves | 1,245 |
| UUIDv4 / unique category UUIDs | 1,563 / 1,563 |
| Alias records | 651 |
| Alias target edges | 1,000 |
| Relationship rows / successor edges | 1,032 / 1,000 |
| Split locators / split edges | 210 / 591 |
| Publicly visible / pilot active | 0 / 0 |
| Policy leakage | 0 |

The source and normalized category UUID sequences both hash to
`88f4da68b6b86b458bdc4593e54796fce87fcb14f8fdab2fd50f1fdbe421dd45`.
Sequence and set equality both passed. The adapter's deterministic UUIDv5
administrative IDs for alias/relationship import keys are the unchanged
Wave36B compiler contract; they are not category stable-ID allocation or
replacement.

## 5. Compiler lineage

| Artifact | SHA-256 / result |
|---|---|
| Frozen source package | `095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406` |
| Normalized compiler package | `9934ed6f44636aed83399e25e6c8e627d0fca8295c5fe622052c1ac15b9a56ff` |
| Deterministic artifact set | `fe3b34cb0a9138be0d4ba81f96baac0271816273d310fd16b6a803baa0c47000` |
| `forward.sql` | `b68d390fed6b4e4422572645b15b8e4e585bf5582031fda29a02a76807a21e00` / 1,181,798 bytes |
| `rollback.sql` | `49279498cd69b85b456b3c68f19eb4e5bbffb28d14f8b778b21393d0ae8087bf` / 2,167 bytes |
| `postcheck.sql` | `458faae89cb27d45469f66640e92ba5d3bf8e40f483092103568e957eddc3ce8` / 1,346 bytes |
| Compiler determinism | PASS across independent compilations |

The normalized package manifest records the exact source HEAD and aggregate.
No synthetic fixture data entered the exact run.

## 6. Exact local replay

| Exercise | Result |
|---|---:|
| Fresh rebuild | 3/3 PASS |
| Forward apply | 3/3 PASS |
| Rollback | 3/3 PASS |
| Idempotent second apply | 2/2 PASS |
| Category exactness after each forward | 3/3 PASS |
| Payload/UUID drift between cycles | 0 |

Each forward run produced 1,563 nodes, the exact depth/leaf counts, 651 aliases,
1,000 alias targets, 1,032 relationships, and 1,000 successor edges. Parent,
cycle/depth, source-key, slug, alias-state, and split-edge errors were zero.

## 7. Failure matrix

All 16 negative cases failed closed:

1. malformed UUID;
2. duplicate UUID;
3. missing parent;
4. cycle/invalid parent graph;
5. L5;
6. invalid policy;
7. duplicate alias UUID;
8. ambiguous alias missing edges;
9. split without target;
10. checksum mismatch;
11. unexpected non-empty target;
12. migration-history mismatch;
13. schema-contract mismatch;
14. planning key used as runtime UUID;
15. assignable container;
16. injected mid-transaction failure.

The mid-transaction injection left zero categories and preserved the platform
sentinel. No partial import survived.

## 8. Postcheck and rollback

Every forward run verified:

- no orphan, cycle, invalid depth, duplicate source key, or duplicate slug;
- correct alias state and predecessor/successor graph;
- zero public roots and zero public/policy leakage;
- five administrative tables denied to anonymous access;
- seven versioned query/RPC contract functions present;
- package category values equal to database category values.

Every rollback restored the pre-bootstrap local application state:

- categories, products, shops, shop products, allocations, aliases, targets,
  relationships, and import runs: zero;
- migration ledger: nine preserved rows;
- platform sentinel: one preserved row;
- dangling foreign keys, identity loss, and partial taxonomy residue: zero.

## 9. Development-candidate equivalence

`REHEARSED PACKAGE == CANDIDATE DEVELOPMENT PACKAGE` is proven for the frozen
artifact identified by source HEAD and aggregate SHA. The exact six Git blobs
were the only upstream inputs; the manifest-bound adapter and deterministic
compiler produced the exercised SQL. No generated taxonomy or synthetic
fixture was substituted.

This equivalence is artifact lineage, not remote state acceptance. It does not
prove current Development emptiness, schema drift absence, managed Supabase
behavior, or grant apply authority.

## 10. Remaining operational blockers

1. Capture a freshly authorized read-only Development snapshot and pass the
   offline JIT precheck.
2. Integration review the exact source HEAD, aggregate, compiler package, and
   generated SQL.
3. Confirm Development restore point, single writer/write freeze, operator,
   execution window, rollback trigger, and evidence retention.
4. Obtain separate explicit Development apply authority.
5. After an authorized apply, validate managed grants, query plans, client
   compatibility, and keep all nodes staged until separate activation review.

There is no remaining frozen-package integrity or local-replay blocker.

## 11. Result flags

`EXACT_PACKAGE_VERIFICATION: PASS`

`EXACT_ARTIFACT_REHEARSAL: PASS`

`FRESH_REBUILD: PASS`

`FORWARD_APPLY_REHEARSAL: PASS`

`ROLLBACK_REHEARSAL: PASS`

`IDEMPOTENCY_REHEARSAL: PASS`

`FAILURE_MATRIX: PASS`

`POLICY_FAIL_CLOSED: PASS`

`REHEARSED_ARTIFACT_EQUALS_DEVELOPMENT_CANDIDATE: YES`

`REMOTE_ACCESS_PERFORMED: NO`

`READY_FOR_FINAL_PREAPPLY_REVIEW: YES`
