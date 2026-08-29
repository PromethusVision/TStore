# Wave 34 — Development Dry-Run Plan

Status: **COMMAND PLAN FOR A FUTURE AUTHORIZED TASK — NOT EXECUTED**

## 1. Authorization and identity gate

Use only the exact EsnaftaVar Development project explicitly authorized in the
future task. Replace placeholders at runtime through the approved CLI/session;
never write credentials or access tokens to source, logs, fixtures, or this
document.

PowerShell preflight from the repository root:

```powershell
git status --short --branch
git rev-parse HEAD
git rev-parse origin/main
supabase --version
supabase projects list
supabase migration list --linked
```

Before any linked command, independently verify that the linked project ref and
API URL equal the authorized Development values. Stop on mismatch. Production
must not be linked or queried by this task.

CLI flags can change; record `supabase --version` and verify each command with
`supabase <command> --help` before execution.

## 2. Local clean-room rehearsal

This section targets a disposable local Supabase instance, not remote data.

```powershell
supabase start
supabase db reset
flutter test --no-pub test/unit/supabase/canonical_migrations_contract_test.dart
```

For the future candidate migration:

1. copy the reviewed, executable migration—not the guarded docs draft—into the
   active migration chain on its own implementation branch;
2. regenerate only synthetic/canonical fixtures with no Production IDs or PII;
3. replay the full migration chain from zero;
4. run SQL invariant checks and client contract tests;
5. rehearse R0, R1, R2, and R3 rollback levels;
6. repeat reset/apply to prove idempotent import behavior.

Expected local checks:

- nine existing migrations still replay in order before the new candidate;
- exact schema/table/function/grant/RLS contract test is updated deliberately;
- canonical import counts match the reviewed manifest;
- active Home roots equal the intended rollout subset, not all rows;
- maximum depth is four, cycles/orphans/duplicate source keys are zero;
- all active products have one assignable policy-cleared category;
- split mappings with no rule remain quarantined;
- old/new client contract fixtures both pass during compatibility stage.

After the future additive schema and staged import exist locally, run equivalent
read-only SQL assertions (the implementation task may place these in a test
file). Each query must return zero rows unless a count is explicitly requested:

```sql
-- Exact totals are compared to the signed import manifest, not hard-coded here.
select taxonomy_version, level, lifecycle_state, count(*)
from public.categories
group by taxonomy_version, level, lifecycle_state
order by taxonomy_version, level, lifecycle_state;

select source_key, count(*)
from public.categories
where source_key is not null
group by source_key
having count(*) <> 1;

select child.id, child.source_key, child.level, parent.level as parent_level
from public.categories child
left join public.categories parent on parent.id = child.parent_id
where child.taxonomy_version = '<CANDIDATE_VERSION>'
  and (
    (child.level = 1 and child.parent_id is not null)
    or (child.level > 1 and parent.id is null)
    or (child.level > 1 and child.level <> parent.level + 1)
  );

with recursive ancestry as (
  select id as origin_id, id, parent_id, array[id] as visited, false as cycle
  from public.categories
  where taxonomy_version = '<CANDIDATE_VERSION>'
  union all
  select a.origin_id, p.id, p.parent_id, a.visited || p.id,
         p.id = any(a.visited)
  from ancestry a
  join public.categories p on p.id = a.parent_id
  where not a.cycle and cardinality(a.visited) <= 5
)
select distinct origin_id
from ancestry
where cycle or cardinality(visited) > 4;

select p.id as product_id, p.category_id
from public.products p
left join public.categories c on c.id = p.category_id
where p.is_active
  and (
    c.id is null
    or not coalesce(c.is_assignable, false)
    or c.lifecycle_state <> 'active'
    or not c.is_active
  );

select r.predecessor_source_locator
from public.taxonomy_node_relationships r
where r.action = 'SPLIT'
group by r.predecessor_source_locator
having count(*) < 2;
```

The cycle query deliberately caps traversal above the contractual depth. The
implementation test should additionally fail on any candidate node with
`level > 4` through the database check constraint.

## 3. Read-only Development profile

After explicit authorization, gather and save a redacted report:

```text
project_ref/url identity
remote migration versions
Postgres version/extensions
categories schema, constraints, indexes, triggers, RLS/policies/grants
products/shop_products/review/QR/verified-purchase FK dependencies
counts by active/demo/manual ownership
category image references
function/RPC signatures and grants
```

Recommended SQL is read-only catalog/count inspection only. Do not use service
role in a client, source file, terminal transcript, or committed script. If the
available role cannot inspect required metadata, stop and obtain an approved
secure operator route rather than weakening permissions.

## 4. Backup and restore proof

In the authorized task, create a secure Development backup using the exact CLI
version's documented dump command. A representative form is:

```powershell
supabase db dump --linked --schema public --file <SECURE_LOCAL_BACKUP_PATH>
```

The operator must verify current CLI syntax, include required auth-owned data
only when approved, encrypt/protect the file, record a SHA-256 hash, and restore
it into a disposable environment. The backup path and contents stay outside Git.

No migration apply proceeds until restore has been demonstrated.

## 5. Candidate dry-run and diff

Where supported by the recorded Supabase CLI version, inspect the future active
migration without applying it:

```powershell
supabase db push --linked --dry-run
```

If `--dry-run` is unavailable, do not substitute a real push. Use local replay,
schema diff, and a transaction-scoped Development rehearsal only after a
separate explicit apply authorization.

Review generated SQL/diff for:

- only additive W34 schema objects before activation;
- no table/category/product hard delete;
- no UUID generation for canonical payload rows;
- no use of display name/slug/path as immutable identity;
- no change to product/listing/review/QR evidence IDs;
- no public grants on relationship/administrative import data;
- no immediate `is_active=true` default for imported canonical rows;
- bounded locks and measured execution plan.

## 6. Authorized Development apply sequence

This is a future gate, not authorization from this document:

1. announce/freeze taxonomy and catalog classification writes;
2. rerun identity, drift, backup, and manifest-hash checks;
3. apply additive schema only;
4. verify old client and RLS behavior;
5. import canonical rows staged/inactive;
6. import alias/lineage manifests and validate counts;
7. load product mapping snapshot; stop on zero/multiple successors;
8. apply product FK mapping and validate all dependent joins;
9. deploy/test compatible client;
10. activate a policy-cleared subset in parent-first order;
11. run postchecks and physical pilot-critical smoke;
12. rehearse/retain rollback window before any broader activation.

## 7. Targeted validation matrix

### Database

- schema, constraints, indexes, triggers, RLS, grants, functions;
- root/children/descendant queries and EXPLAIN plans;
- active/staged/retired and assignable/container combinations;
- alias versus search-synonym resolution;
- merge/split/retire lineage;
- concurrent catalog read during staged writes;
- idempotent rerun and interrupted-import recovery.

### Client

- Home roots only;
- variable L1–L4 traversal and back navigation;
- container descendant products and exact leaf products;
- Turkish synonym/alias search;
- inactive/policy-blocked visibility;
- product/shop/cart serializers with category joins;
- empty/error/slow-network/background/resume;
- old-client compatibility during the declared support window.

### Commercial evidence

- wishlist/cart/listing identity unchanged;
- reviews and aggregates unchanged;
- QR exact-shop, replay, expiry, and immutable snapshot tests unchanged;
- verified transaction/product evidence unchanged;
- demo mapping accounts for all 20 products and 285 inherited listing joins.

## 8. Required results before Production planning

- Development migration and rollback each pass twice from a clean restore;
- exact pre/post count and hash report;
- zero unresolved active-product mappings;
- zero public policy leakage;
- old/new client compatibility decision documented;
- performance baseline for root/child/descendant/search queries;
- professional-review/policy publication allowlist signed off;
- exact artifact, physical acceptance, and Production change/rollback owners
  identified.

## 9. Current readiness

The plan is executable after prerequisites are supplied, but the repository is
**not ready for an authorized Development migration apply** today because the
full stable-ID manifest, complete 24-L1 runtime materialization, 24 unresolved
legacy decisions, live Development profile, and restore proof remain open.

It is ready for a separately authorized **read-only Development preflight and
local clean-room rehearsal**.
