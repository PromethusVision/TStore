# Wave 36 — Taxonomy Migration Input Contract

Status: **COMPILER CONTRACT — EXACT WAVE36A PACKAGE REPLAY PASS**
Tooling: `tool/taxonomy_migration/`
Remote access: **not implemented**

## 1. Purpose and trust boundary

The compiler consumes a reviewed, external UUID/import package and emits an
exact staging migration artifact. It does not invent runtime identity, make
taxonomy decisions, activate nodes, assign products, or connect to Supabase.

The package is data plus evidence. Its SHA-256 covers every input file and the
package manifest. Review/apply authority remains separate. A valid package is
necessary but not sufficient for a Development apply.

Planning keys, Turkish names, slugs, and paths are mutable locators. None may be
used as a runtime UUID. Runtime UUIDs must be allocated upstream, reviewed once,
and supplied explicitly.

## 2. Directory contract

Every package contains exactly the following required payloads plus
`package_manifest.json`:

| File | Purpose | Required identity |
|---|---|---|
| `categories.csv` | Complete L1–L4 structural graph | supplied `CATEGORY_ID` UUID |
| `uuid_allocations.csv` | Planning-key to stable-ID ledger | one row per category |
| `aliases.csv` | Legacy redirect/search synonym locator | supplied `ALIAS_ID` UUID |
| `alias_targets.csv` | Zero/one/many alias target edges | alias + category UUID |
| `relationships.csv` | Predecessor/successor evidence | supplied `RELATIONSHIP_ID` UUID |
| `activation.csv` | Staged qualification and policy state | category UUID + planning key |

CSV is UTF-8, comma-delimited, quoted, header-exact, and row-order independent.
The compiler sorts accepted records before rendering SQL.

## 3. Exact columns

### `categories.csv`

`CATEGORY_ID, PLANNING_KEY, PARENT_CATEGORY_ID, NAME, SLUG, LEVEL, SORT_ORDER, LEAF_YN, TAXONOMY_VERSION`

- UUID is explicit and opaque.
- L1 parent is blank; L2–L4 parent UUID must exist in the same package.
- `LEVEL` is 1–4 only and parent level is exactly `level - 1`.
- `LEAF_YN` must agree with the actual child graph.
- name, slug, planning key, UUID, and normalized slug are unique where required.

### `uuid_allocations.csv`

`PLANNING_KEY, CATEGORY_ID, TAXONOMY_VERSION, ALLOCATION_SOURCE`

Exactly one row must match every category. The compiler does not accept missing,
extra, reallocated, or name-derived IDs.

### `aliases.csv`

`ALIAS_ID, ALIAS_KIND, ALIAS_LOCATOR, ALIAS_TEXT, ALIAS_SLUG, ALIAS_PATH, SOURCE_ALIAS_TYPE, RESOLUTION_STATE, DIRECT_TARGET_CATEGORY_ID, LOCALE, TAXONOMY_VERSION, IS_ACTIVE`

Kinds are `LEGACY_REDIRECT` and `SEARCH_SYNONYM`. States are:

- `RESOLVED`: exactly one edge and the same direct target;
- `AMBIGUOUS`: at least two candidate edges and no direct target;
- `TOMBSTONE`: no edge/direct target;
- `UNRESOLVED`: no edge/direct target.

A legacy redirect is not automatically a search synonym.

### `alias_targets.csv`

`ALIAS_ID, TARGET_CATEGORY_ID`

Edges must reference package-owned alias/category UUIDs. Duplicate edges fail.
Zero/one/many edges preserve retire, exact, and ambiguous semantics without a
first-child fallback.

### `relationships.csv`

`RELATIONSHIP_ID, PREDECESSOR_SOURCE_LOCATOR, SUCCESSOR_CATEGORY_ID, ACTION, TARGET_STATE, CLASSIFICATION_RULE, CONFIDENCE, TAXONOMY_VERSION`

Actions:

`KEEP, RENAME, MOVE, RENAME_AND_MOVE, MERGE, SPLIT, RETIRE, ALIAS_ONLY, OUT, UNRESOLVED`

Target states:

`CANONICAL_FINAL, NO_TARGET_YET, POLICY_REVIEW, OUT_OF_SCOPE`

`RETIRE`, `OUT`, and `UNRESOLVED` may have a blank successor. `SPLIT` must
retain all supplied successor edges and a non-arbitrary classification rule.
Some legacy source rows use `SPLIT` with one current candidate; that remains
split evidence and does **not** authorize product auto-assignment.

### `activation.csv`

`CATEGORY_ID, PLANNING_KEY, LIFECYCLE_STATE, IS_ACTIVE, IS_ASSIGNABLE, POLICY_CLASS, PROFESSIONAL_REVIEW_STATUS, QUALIFICATION_STATE`

Bootstrap contract requires:

- `LIFECYCLE_STATE=staged`;
- `IS_ACTIVE=NO` for every node;
- only structural leaves may be assignable;
- policy enum is one of `NORMAL`, `AGE_RESTRICTED`, `REGULATED`,
  `LEGAL_REVIEW_REQUIRED`, `EXCLUDED`;
- professional state is `not_required`, `pending`, `approved`, or `rejected`;
- non-normal/pending rows use `FAIL_CLOSED_PENDING_REVIEW`.

This file records qualification; it does not grant public activation.

## 4. Package manifest and SHA contract

`package_manifest.json` records:

- `contract_version=w36-taxonomy-package-v1`;
- package kind (`EXACT_CANONICAL_BOOTSTRAP` or explicit test-only kind);
- taxonomy version;
- exact Development project ref expectation;
- empty-target requirement;
- counts for categories/levels/leaves/allocations/aliases/edges/relationships;
- current migration filenames and individual SHA-256 hashes;
- migration-history aggregate SHA and schema-contract SHA;
- row count and SHA-256 for every CSV;
- aggregate `package_sha256` over the canonical manifest content.

Changing one byte, count, filename, runtime contract, or target ref invalidates
the package. Generated artifact manifests separately bind forward, rollback,
and postcheck SQL to the source package SHA.

## 5. Fail-closed rejections

The validator rejects at minimum:

- missing file/row/allocation/activation;
- malformed or duplicate UUID;
- planning key in a UUID field;
- duplicate planning key, slug, alias locator, or edge;
- missing/wrong-level parent, cycle, depth five;
- leaf/container contradiction;
- invalid lifecycle, policy, professional, alias, action, or target state;
- active bootstrap node or assignable container;
- policy-sensitive row presented as approved/public;
- resolved alias with zero/multiple targets;
- ambiguous alias with fewer than two targets;
- split relationship missing supplied successor evidence;
- unknown alias/category/successor reference;
- checksum, row-count, version, project-ref, migration, or schema drift.

No validation failure is downgraded to a warning.

## 6. Determinism and idempotency

For the same byte-identical package:

- compiler output has the same artifact-set SHA;
- no timestamp or random UUID enters SQL;
- inserts are ordered deterministically;
- forward apply is one transaction;
- same package/version may be replayed idempotently;
- a partial/different/unowned existing import is rejected;
- product, shop, and listing rows must remain empty for this bootstrap path.

The forward artifact contains no hard delete. The separately generated rollback
uses exact package/version scoping only for the approved empty-environment
bootstrap model.

## 7. Exact package status

The authoritative read-only package is:

`origin/agent1/w36-exact-taxonomy-bootstrap-package@d9c45a1c2acd94fe0bfa52b16772718142c0664a`

Its six exact committed Git blobs independently reproduce the documented
639-byte aggregate preimage and current package SHA-256:

`095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406`

The historical `9687878401513881335a5a1479cdf53e2b4b3108debb3d28297444f3e2808091`
value remains superseded metadata and is not accepted by the adapter. The
adapter preserved the complete category UUID sequence, emitted the normalized
compiler input, and the exact package passed deterministic compilation, three
fresh local PGlite forward/rollback cycles, two idempotent second applies, all
postchecks, and the fail-closed matrix.

No payload byte or category UUID was regenerated, no source branch was merged,
and no remote environment was accessed. Exact replay evidence is recorded in
`TAXONOMY_W36_EXACT_ARTIFACT_REPLAY.md`.

## 8. Offline JIT snapshot shape

`jit_precheck.mjs` accepts a JSON file captured by a separately authorized,
read-only environment inspection. It does not capture or query remote state:

```json
{
  "snapshot_kind": "AUTHORIZED_READ_ONLY_CAPTURE",
  "project_ref": "tnipyxnvhgelwdpykyez",
  "counts": {
    "categories": 0,
    "products": 0,
    "shops": 0,
    "shop_products": 0
  },
  "migration_files": [
    { "name": "<exact migration filename>", "sha256": "<64 hex>" }
  ],
  "migration_history_sha256": "<package-declared hash>",
  "schema_contract_sha256": "<package-declared hash>",
  "single_writer": {
    "observed": true,
    "writer_count": 1,
    "write_freeze_declared": true
  },
  "drift": {
    "detected": false,
    "unexpected_objects": []
  }
}
```

The exact migration list and both hashes must equal the package manifest. The
tool outputs `DRY_NO_APPLY`; flags that imply apply, URL, token, Development,
Production, or remote access are rejected.
