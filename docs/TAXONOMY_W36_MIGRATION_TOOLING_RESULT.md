# Wave 36B — Taxonomy Migration Compiler & Tooling Result

Status: **TOOLING PASS — EXACT WAVE36A PACKAGE REPLAY PASS**
Base: `origin/main@b3cc14ebed42ab66d689fe6688c2e75e23c43e68`
Branch: `agent2/w36-taxonomy-migration-compiler`

## 1. Safety

- Supabase, Development, Production, Auth, Storage, and Realtime access: none.
- Git fetch is the only input-network operation; task-branch push publishes
  reports/tooling only and does not access an application environment.
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
- 16-case fail-closed failure matrix.

Generated artifacts stay in caller-selected staging/temp directories:

- `forward.sql`;
- `rollback.sql`;
- `postcheck.sql`;
- `artifact_manifest.json`.

The same package generated the same artifact-set SHA in two independent
compiler runs.

## 3. Rehearsal input

Authoritative read-only source:

`origin/agent1/w36-exact-taxonomy-bootstrap-package@d9c45a1c2acd94fe0bfa52b16772718142c0664a`

The six source files were extracted through `git cat-file blob`, avoiding
checkout and line-ending transformations. Every raw-byte SHA, byte count, and
CSV row count matched the source manifest. The canonical 639-byte aggregate
preimage reproduced:

`095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406`

The historical `9687878401513881335a5a1479cdf53e2b4b3108debb3d28297444f3e2808091`
value is superseded and was not accepted as an alternative digest.

Exact compiler evidence:

- upstream frozen package SHA:
  `095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406`;
- normalized compiler-package SHA:
  `9934ed6f44636aed83399e25e6c8e627d0fca8295c5fe622052c1ac15b9a56ff`;
- artifact-set SHA:
  `fe3b34cb0a9138be0d4ba81f96baac0271816273d310fd16b6a803baa0c47000`;
- migration-history SHA:
  `515393550dc68dac111287e4504b2bcf21f1d441d4901e20677000561066875d`;
- schema-contract SHA:
  `2d4f885ba82b516b119323420399d9433c8eaec0c7384623becf74165f40b4cd`.

The source category UUID sequence and normalized compiler-input UUID sequence
both hash to
`88f4da68b6b86b458bdc4593e54796fce87fcb14f8fdab2fd50f1fdbe421dd45`.
Payload modification and category UUID regeneration were both zero. Source
branch merge count remains zero.

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
ledger, applied the exact compiled artifact from the frozen package, ran
postchecks, then rolled back to zero application rows while preserving the
migration ledger and platform sentinel.

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

All 16 cases failed closed:

1. bad UUID;
2. duplicate UUID;
3. missing parent;
4. cycle/invalid parent graph;
5. L5;
6. invalid policy;
7. duplicate alias UUID;
8. ambiguous alias missing target edges;
9. split relationship without a target;
10. checksum mismatch;
11. unexpected non-empty target;
12. migration-history mismatch;
13. schema-contract mismatch;
14. planning key used as runtime UUID;
15. assignable container;
16. injected mid-transaction failure.

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

Artifact-integrity and local-replay blockers are closed. Remaining gates are
operational and require separate authority:

1. A freshly authorized read-only Development snapshot must be captured and
   pass the offline JIT precheck; this task did not access Development.
2. Integration must review this source HEAD, exact package digest, normalized
   package manifest, and generated SQL outside the active migration chain.
3. The Development single-writer/write-freeze window, restore point, execution
   operator, and rollback trigger must be confirmed.
4. Development recreation/apply needs separate explicit authority.
5. Managed Supabase/PostgreSQL grants, query plans, and client compatibility
   remain post-apply/pre-activation validation gates.

## 9. Flags

`MIGRATION_INPUT_CONTRACT: PASS`

`MIGRATION_COMPILER: PASS`

`JIT_PRECHECK_TOOL: PASS`

`LOCAL_APPLY_HARNESS: PASS`

`POSTCHECK_AUTOMATION: PASS`

`ROLLBACK_HARNESS: PASS`

`EMPTY_DEVELOPMENT_RECREATION_PLAN: PASS`

`EXACT_ARTIFACT_REHEARSAL: PASS`

`FAILURE_MATRIX: PASS`

`BACKEND_QUERY_CONTRACT: PASS`

`REMOTE_ACCESS_PERFORMED: NO`

`READY_FOR_FINAL_PREAPPLY_REVIEW: YES`

This readiness authorizes review only. It does not authorize a Development or
Production connection, snapshot capture, apply, activation, or rollback.
