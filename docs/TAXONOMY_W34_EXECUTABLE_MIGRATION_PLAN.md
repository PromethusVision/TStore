# Wave 34 — Executable Canonical Taxonomy Migration Plan

Status: **PLAN ONLY — NOT AUTHORIZED FOR DEVELOPMENT OR PRODUCTION APPLY**
Strategy: **OM-R06=B — stable-ID staged migration with rollback and dependency-aware demo retirement**

## 1. Required artifacts and roles

Before an apply candidate can exist, prepare and independently review:

1. a versioned 24-L1 canonical node manifest with allocated opaque UUIDs;
2. explicit level, parent, ordering, assignability, lifecycle, policy class, and
   professional-review state for every node;
3. a legacy-to-canonical relationship manifest covering all 651 legacy nodes;
4. a product reassignment manifest with one decision per current product;
5. a separate alias/synonym manifest;
6. a migration file in the canonical active migration chain, generated only
   after the draft in this wave is reviewed;
7. client changes compatible with both legacy and staged canonical rows;
8. a Development backup/restore point and rollback evidence.

Suggested separation of duties:

- taxonomy owner/integration: signs off the versioned source package;
- backend agent: implements schema, RLS/RPC, import, validation, and rollback;
- customer client agent: implements tree/search/browse compatibility;
- QA/integration: validates counts, mappings, old/new clients, and rollback;
- Product Owner/professional reviewers: decide only remaining product/policy
  questions; their approval does not grant remote apply authority.

## 2. Stop conditions before any remote apply

Stop if any is true:

- target project identity is not the exact authorized Development project;
- working tree or migration chain contains unrelated changes;
- remote migration history differs from the reviewed baseline;
- no fresh logical backup/PITR restore point exists;
- full 24-L1 runtime manifest is missing or has duplicate IDs/source keys/paths;
- any node lacks parent/level/assignability/policy/review state;
- the 24 unresolved legacy rows are not closed or explicitly quarantined;
- a SPLIT row uses an arbitrary first-successor mapping;
- any active product has no one-to-one reviewed target or quarantine decision;
- policy-sensitive nodes would be published before professional clearance;
- old and new client compatibility has not passed locally;
- rollback has not been rehearsed against the same candidate package.

## 3. Phase 0 — backup and read-only preflight

1. Verify repository commit, CLI version, exact Development ref, and linked
   project identity without changing remote state.
2. Record remote migration history, Postgres version/extensions, table/column/
   constraint/index/RLS/policy/function signatures, and row counts.
3. Export a restorable schema and data backup using an approved secure location;
   record an encrypted artifact hash, not secret contents.
4. Export explicit snapshots of:
   - categories;
   - product ID/category ID pairs;
   - category image references;
   - demo-tagged products and their listings;
   - migration history and relevant function definitions.
5. Prove restore into a disposable environment before proceeding.

Deliverable: signed preflight report with observed counts and restore evidence.

## 4. Phase 1 — additive schema

Create one reviewed canonical migration that:

1. adds nullable compatibility columns to `categories`;
2. adds alias and predecessor/successor tables with RLS enabled and no public
   mutation grants;
3. adds hierarchy validation and supporting indexes;
4. adds security-invoker category/root/children/descendant lookup primitives;
5. introduces fail-closed public catalog gating without activating new nodes;
6. backfills legacy rows with a distinct legacy taxonomy version/state;
7. validates constraints only after the backfill reports zero invalid rows.

Do not delete or rename existing columns. Existing categories remain available
to the old client during this phase.

## 5. Phase 2 — stable-ID allocation and canonical import

Stable IDs are allocated once in the reviewed manifest, not generated ad hoc by
SQL. The import must be deterministic and idempotent:

- the same `source_key` always refers to the same UUID;
- rerun either produces no changes or a declared conflict;
- display names, slugs, and paths do not determine UUIDs;
- every parent appears in the package before or within the same transaction as
  its child;
- all canonical nodes enter as `staged`, `is_active = false`;
- only leaves explicitly approved for assignment set `is_assignable = true`;
- policy/professional-review pending nodes remain unpublished.

Validate exact manifest totals, level totals, parent paths, maximum depth four,
duplicate sibling/slug/source key zero, and cycle count zero.

## 6. Phase 3 — legacy relationship import

Import each legacy node once into the relationship graph. Required handling:

- KEEP/RENAME/MOVE/RENAME_AND_MOVE: one reviewed successor;
- MERGE: many predecessors may resolve to one successor while retaining aliases;
- SPLIT: all possible successors are recorded, but no product is reassigned
  until a deterministic classification rule or manual decision exists;
- RETIRE: historical identity remains resolvable but not assignable;
- OUT_OF_PRODUCT_TAXONOMY: historical reference is retained, no sellable target;
- UNRESOLVED: blocks activation for affected products/nodes.

Import legacy redirects separately from search synonyms.

## 7. Phase 4 — product reassignment

1. Materialize a pre-change mapping snapshot:
   `(product_id, old_category_id, proposed_category_id, rule/evidence, reviewer)`.
2. Require exactly one approved assignable target for every active product.
3. Quarantine products with zero or multiple possible targets; do not publish
   them through an arbitrary ancestor or first successor.
4. Update only `products.category_id` in bounded batches or one reviewed
   transaction sized from Development measurements.
5. Preserve product UUID, listing UUID, price, stock, wishlist/cart links,
   reviews, QR items, and verified transaction evidence.
6. Validate before/after counts and referential integrity after each batch.

`shop_products` needs no direct taxonomy update because it references the
unchanged product UUID. Public visibility must nevertheless respect the new
product/category gate.

## 8. Phase 5 — demo mapping and retirement

The four demo category UUIDs are not canonical IDs. Map all 20 demo products to
reviewed canonical targets. The existing simulation has lower-node uncertainty
for specific Electronics/Computer products; those rows need exact leaf evidence
before apply.

Do not execute the legacy cleanup script after customers or merchants have
created dependent activity. Instead:

1. preserve products/listings used by the pilot;
2. reassign their category FK while keeping their IDs;
3. mark old demo categories inactive/retired only when dependency counts are
   zero or all dependencies are mapped;
4. retain legacy redirect/relationship records;
5. update seed generator, manifest, cleanup, and contract tests in a separate
   reviewed code change.

## 9. Phase 6 — alias, search, and RPC adaptation

Server contract:

- get public L1 roots;
- get active children for one node;
- resolve descendant assignable node IDs;
- resolve canonical node by UUID and approved legacy redirect;
- search canonical labels and controlled synonyms;
- return breadcrumb plus taxonomy version;
- exclude staged/retired/policy-blocked nodes and their products.

The minimal client-compatible direction is to keep existing product response
shape, obtain descendant IDs through a trusted RPC, then apply a PostgREST
`in` filter. If Development performance or URL limits are unsuitable, replace
that with a security-invoker product-browse RPC and an explicit Dart adapter.

## 10. Phase 7 — client compatibility rollout

Ship schema-compatible client code while canonical rows are still staged:

1. root-only Home category load;
2. variable-depth child navigation;
3. descendant product browsing for containers;
4. exact filtering at assignable leaves;
5. breadcrumb, alias/search, inactive, empty, and error states;
6. old/new serializer compatibility;
7. removal of label-as-identity demo helpers only after replacement coverage.

Test at least one L1->L2 leaf, L1->L2->L3 leaf, and L1->L2->L3->L4 leaf,
plus move, merge, split/quarantine, inactive, regulated, alias, and rollback
fixtures.

## 11. Phase 8 — Development activation

Activation is a separate authorized change window:

1. freeze catalog/category writes or establish an auditable delta strategy;
2. rerun preflight and product-map drift checks;
3. activate policy-cleared canonical containers and leaves in parent-first order;
4. retire legacy categories only after reassignment checks pass;
5. run exact row/count/path/visibility/RLS/RPC/client smoke checks;
6. keep rollback window and elevated monitoring open;
7. record exact migration, manifest version, app commit, and backup hash.

No Production action is implied by Development success.

## 12. Validation contract

Required postconditions:

- every canonical UUID/source key appears once;
- parent/level/path consistency and max depth four pass;
- staged/retired nodes are unavailable to public queries;
- only assignable, policy-cleared leaves receive products;
- every pre-existing active product is mapped or explicitly quarantined;
- product/listing/review/wishlist/cart/QR/verified-evidence IDs and counts are
  unchanged except for approved product category FKs;
- no active public listing leaks through blocked category state;
- alias and relationship counts reconcile with source manifests;
- Home exposes roots only and browse/search return expected descendants;
- old client behavior is either preserved during the window or explicitly
  blocked by a separately approved minimum-version gate;
- rollback rehearsal restores the exact pre-cutover category assignment.

## 13. Production prerequisites

Production needs a distinct authorization, fresh backup/restore proof, actual
production read-only profile, drift-free package, signed artifact/client
compatibility evidence, physical acceptance, professional policy closure,
change window, monitoring, and rollback authority. Development apply approval
does not authorize Production.
