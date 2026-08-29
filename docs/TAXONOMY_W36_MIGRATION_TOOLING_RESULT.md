# Wave 36B — Taxonomy Migration Compiler & Tooling Result

Status: **TOOLING PASS — EXACT WAVE36A PACKAGE REJECTED FAIL-CLOSED**
Base: `origin/main@b3cc14ebed42ab66d689fe6688c2e75e23c43e68`
Branch: `agent2/w36-taxonomy-migration-compiler`

## 1. Safety

- Supabase, Development, Production, Auth, Storage, and Realtime access: none.
- Git fetch is the only remote operation performed before branch creation.
- Remote database mode, URL handling, project linking, and credentials are not
  implemented in the tool.
- Active migration directory is unchanged.
- No UUID allocation/import package intended for Development or Production is
  committed.
- Compiler and local harness reject remote/Production/Development flags.

## 2. Implemented tooling

`tool/taxonomy_migration/` provides:

- strict six-file input package validation and SHA verification;
- a deterministic SQL compiler;
- additive staged schema/query candidate generation;
- package-token and migration-history guards;
- dry, snapshot-driven JIT precheck validation;
- mandatory `--local` PGlite apply harness;
- structural/policy/alias/lineage/RLS/RPC postchecks;
- exact empty-bootstrap rollback;
- deterministic synthetic fixture generator;
- 15-case fail-closed failure matrix.

Generated artifacts stay in caller-selected staging/temp directories:

- `forward.sql`;
- `rollback.sql`;
- `postcheck.sql`;
- `artifact_manifest.json`.

The same package generated the same artifact-set SHA in two independent
compiler runs.

## 3. Rehearsal input

The branch `origin/agent1/w36-exact-taxonomy-bootstrap-package` was absent after
the task's initial `git fetch origin --prune`, so the first complete rehearsal
used an ephemeral package marked `SYNTHETIC_TEST_ONLY`.

The generator consumed the owner-reconciled Wave 34 structural/legacy sources,
assigned deterministic test-only UUIDs, and deleted the package after the run.
It did not create a production allocation manifest.

The exact branch later appeared at
`326f0976c8a7392eda4549d743872fa7c11630f5`. Read-only Git-blob verification
passed for all six CSV files. The package was nevertheless rejected before
normalization/compilation because its aggregate manifest digest is internally
inconsistent:

- declared aggregate:
  `9687878401513881335a5a1479cdf53e2b4b3108debb3d28297444f3e2808091`;
- recomputed using the manifest's documented sorted
  `filename|row_count|lowercase_sha256\n` algorithm:
  `095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406`.

The tool did not override this integrity failure or infer a replacement owner
artifact. Source branch merge count remains zero.

Input/package evidence:

- package SHA:
  `65bb70d00f74b1a2d5aa8bcb45201fecfe994cb2f3c2e205f79f88b7a8aa9332`;
- artifact-set SHA:
  `42f1450203ed88d6d6291660a6a8b6d6c94bdf4291778dedf07c3987c22658ca`;
- migration-history SHA:
  `515393550dc68dac111287e4504b2bcf21f1d441d4901e20677000561066875d`;
- schema-contract SHA:
  `2d4f885ba82b516b119323420399d9433c8eaec0c7384623becf74165f40b4cd`.

These hashes identify the synthetic rehearsal only; Integration must not treat
them as a Wave36A exact-package approval.

## 4. PostgreSQL-WASM cycles

Engine: local PGlite 0.5.5 / PostgreSQL 18.3 WASM.

| Exercise | Result |
|---|---:|
| Fresh rebuilds | 3/3 PASS |
| Forward applies | 3/3 PASS |
| Rollbacks | 3/3 PASS |
| Idempotent second applies | 2/2 PASS |
| Compiler determinism comparison | PASS |
| Remote access | 0 |

Every fresh cycle reconstructed the empty application baseline and migration
ledger, applied the exact compiled artifact, ran postchecks, then rolled back to
zero application rows while preserving the migration ledger and platform
sentinel.

## 5. Postcheck totals

| Check | Result |
|---|---:|
| Nodes | 1,563 |
| L1 / L2 / L3 / L4 | 24 / 244 / 1,096 / 199 |
| Leaves | 1,245 |
| Allocations | 1,563 |
| Aliases | 651 |
| Alias target edges | 1,000 |
| Relationship rows | 1,032 |
| Successor edges | 1,000 |
| Parent errors | 0 |
| Cycles/depth errors | 0 |
| Duplicate source keys/slugs | 0 / 0 |
| Public/policy leakage | 0 |
| Alias-state errors | 0 |
| Split-edge errors | 0 |
| Candidate query functions | 7/7 |
| Admin tables denied to anon | 5/5 |
| Staged public roots | 0 |

Exact category UUID, parent, name, slug, level, order, lifecycle, assignability,
policy, review state, and version were compared back to the loaded package.

## 6. Failure matrix

All 15 cases failed closed:

1. bad UUID;
2. duplicate UUID;
3. missing parent;
4. cycle/invalid parent graph;
5. L5;
6. invalid policy;
7. duplicate alias UUID;
8. ambiguous alias/split missing edges;
9. checksum mismatch;
10. unexpected non-empty target;
11. migration-history mismatch;
12. schema-contract mismatch;
13. planning key used as runtime UUID;
14. assignable container;
15. injected mid-transaction failure.

The injected database failure left zero category rows and preserved unrelated
platform metadata, proving transaction rollback rather than partial import.

## 7. Rollback semantics

The forward artifact has no delete. Rollback is deliberately narrower than a
general taxonomy down migration:

- exact package SHA and local-mode token required;
- zero dependent product rows required;
- exact full-or-zero package count required;
- only package/version-owned taxonomy rows removed;
- categories removed child-first;
- repository migration ledger/platform metadata retained;
- additive nullable schema retained for diagnosis.

This is suitable only for the observed empty Development bootstrap model after
a fresh authorized JIT precheck. It is not a Production rollback design.

## 8. Remaining gates

Before final pre-apply review:

1. Wave36A must reissue a reviewed manifest whose aggregate digest matches its
   six Git blobs and documented algorithm; that exact package must then pass the
   same compiler, 3/3/3 cycles, 2 idempotent applies, and failure matrix.
2. A freshly captured read-only Development snapshot must pass the offline JIT
   precheck; this task did not capture one.
3. Integration must review the exact package and generated SQL outside the
   active migration chain.
4. Development recreation/apply needs separate explicit authority.
5. Managed PostgreSQL 17/Supabase grants, query plans, and client compatibility
   remain pre-activation gates.

## 9. Flags

`MIGRATION_INPUT_CONTRACT: PASS`

`MIGRATION_COMPILER: PASS`

`JIT_PRECHECK_TOOL: PASS`

`LOCAL_APPLY_HARNESS: PASS`

`POSTCHECK_AUTOMATION: PASS`

`ROLLBACK_HARNESS: PASS`

`EMPTY_DEVELOPMENT_RECREATION_PLAN: PASS`

`EXACT_ARTIFACT_REHEARSAL: FAIL`

`FAILURE_MATRIX: PASS`

`BACKEND_QUERY_CONTRACT: PASS`

`REMOTE_ACCESS_PERFORMED: NO`

`READY_FOR_FINAL_PREAPPLY_REVIEW: NO`

Reason for `NO`: the compiler/tooling is ready, but the external exact Wave36A
package failed its aggregate immutability check and therefore was not replayed.
