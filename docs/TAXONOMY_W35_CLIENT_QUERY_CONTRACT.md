# Wave 35 — Client Taxonomy Query Contract

Status: **QUERY/FIXTURE DESIGN — NO FLUTTER OR REMOTE IMPLEMENTATION**

## 1. General contract

- Stable category UUID is the only runtime identity.
- Name, slug, and path are mutable presentation/search fields.
- Public reads return only active lifecycle/publication state.
- Containers may be visible but not assignable.
- Products bind only to active, assignable, policy-cleared leaves.
- A canonical node's existence does not authorize publication or sale.
- Every query must retain RLS/security-invoker behavior; clients do not receive
  administrative relationship/import tables.

The examples use PostgreSQL parameter notation conceptually. Exact RPC/view
names and grants remain an implementation task.

## 2. Roots

Structural audit expects exactly 24 canonical roots. A public client receives
only roots enabled for the current rollout.

```sql
select id, name, slug, level, sort_order, taxonomy_version
from public.categories
where parent_id is null
  and level = 1
  and lifecycle_state = 'active'
  and is_active = true
order by sort_order, id;
```

Home must call this root contract, not the legacy all-active-category query.

## 3. Children

```sql
select id, parent_id, name, slug, level, is_assignable, sort_order,
       taxonomy_version
from public.categories
where parent_id = :parent_category_id
  and lifecycle_state = 'active'
  and is_active = true
order by sort_order, id;
```

An empty result is a valid leaf/container state, not an instruction to fall
back to a similarly named category.

## 4. Descendants

```sql
with recursive descendants as (
  select id, parent_id, level, is_assignable
  from public.categories
  where id = :category_id
    and lifecycle_state = 'active'
    and is_active = true
  union all
  select child.id, child.parent_id, child.level, child.is_assignable
  from public.categories as child
  join descendants as parent on child.parent_id = parent.id
  where child.lifecycle_state = 'active'
    and child.is_active = true
)
select id
from descendants
where is_assignable = true;
```

The server should expose this through a security-invoker RPC or public catalog
view. The client must not recursively fetch the entire 1,563-node graph.

## 5. Exact leaf and products

```sql
select id, name, slug, taxonomy_version
from public.categories
where id = :category_id
  and lifecycle_state = 'active'
  and is_active = true
  and is_assignable = true
  and policy_class = 'NORMAL'
  and professional_review_status = 'not_required';
```

Product-by-category scope uses the exact leaf or descendant-ID set. Public
product/listing projection must additionally exclude quarantined, inactive, or
policy-blocked classification. A product must never be assigned to the first
child of an ambiguous split.

## 6. Breadcrumb

```sql
with recursive breadcrumb as (
  select id, parent_id, name, slug, level
  from public.categories
  where id = :category_id
  union all
  select parent.id, parent.parent_id, parent.name, parent.slug, parent.level
  from public.categories as parent
  join breadcrumb as child on child.parent_id = parent.id
)
select id, name, slug, level
from breadcrumb
order by level;
```

Breadcrumb is derived presentation. It is not stored as immutable identity.

## 7. Legacy redirect and alias resolution

First resolve the locator row:

```sql
select id, resolution_state, direct_target_category_id
from public.taxonomy_aliases
where alias_kind = 'LEGACY_REDIRECT'
  and locale = 'tr-TR'
  and is_active = true
  and lower(alias_slug) = lower(:legacy_slug);
```

Behavior by state:

| State | Client/server behavior |
|---|---|
| `RESOLVED` | Resolve only `direct_target_category_id`; preserve canonical UUID. |
| `AMBIGUOUS` | Do not redirect. Use product discriminator/manual selection; candidate edges are administrative evidence. |
| `TOMBSTONE` | Show retired/out-of-scope outcome; never choose a nearest category. |
| `UNRESOLVED` | Fail closed and route to manual/policy handling. |

Candidate targets for administrative split review live in
`taxonomy_alias_targets`; this table should not be broadly exposed to clients.

## 8. Search synonyms

`SEARCH_SYNONYM` is a separate controlled lookup:

```sql
select direct_target_category_id
from public.taxonomy_aliases
where alias_kind = 'SEARCH_SYNONYM'
  and resolution_state = 'RESOLVED'
  and is_active = true
  and locale = 'tr-TR'
  and lower(alias_text) = lower(:search_term);
```

A historical redirect is not automatically a synonym, and an ambiguous split
term must not produce a single search target.

## 9. Required fixtures

Client/repository tests need fixtures for:

- 24 structural roots versus rollout-active roots;
- L2, L3, and L4 terminal leaves;
- visible non-assignable containers;
- inactive/staged and retired nodes;
- regulated/legal-review fail-closed nodes;
- exact redirect, renamed slug/path, moved node, merge, ambiguous split,
  tombstone, and unresolved alias;
- descendant product filtering and no cross-domain leakage;
- malformed/missing node and slow/error responses;
- taxonomy version mismatch and rollback-compatible responses.
