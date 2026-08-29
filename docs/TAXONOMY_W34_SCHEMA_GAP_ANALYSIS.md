# Wave 34 — Canonical Taxonomy Schema Gap Analysis

Status: **DESIGN ONLY — OWNER STRATEGY OM-R06=B PRESERVED**

## 1. Decision frame

OM-R06=B approves a stable-ID, staged migration with rollback and
dependency-aware demo retirement. It does not authorize ID allocation, schema
mutation, Development/Production access, taxonomy activation, or demo cleanup.

The smallest defensible design reuses `categories.id` as the immutable canonical
node ID. Adding a second `stable_id` would create two competing identities and
is not recommended.

## 2. Gap matrix

| Requirement | Current state | Minimal future contract | Priority |
|---|---|---|---|
| Immutable stable ID | UUID PK exists | Reuse `categories.id`; allocate canonical UUIDs in a separately approved versioned import artifact | P0 |
| Source/import identity | None | Unique immutable `source_key` for deterministic import reconciliation; not customer-facing | P0 |
| Variable L1–L4 depth | Nullable parent only | Explicit `level` 1–4 plus cycle/parent-level validation | P0 |
| Slug | None | Mutable unique canonical slug; prior slugs retained as redirects | P1 |
| Leaf/assignability | Not represented | Explicit `is_assignable`; structural leaf is derived or validated separately | P0 |
| Lifecycle | `is_active` only | `staged`, `active`, `retired`; keep `is_active` as the compatibility/publication gate during cutover | P0 |
| Policy metadata | None | Five canonical classes: NORMAL, AGE_RESTRICTED, REGULATED, LEGAL_REVIEW_REQUIRED, EXCLUDED | P0 |
| Professional-review status | None | Explicit review state and routing evidence; unresolved/regulatory nodes fail closed | P0 |
| Taxonomy version | None | Version on nodes/import package and client responses | P1 |
| Aliases | None | Alias table with alias type, locale, target node, lifecycle | P0 |
| Predecessor/successor | None | Directed lineage table with action and optional classification rule | P0 |
| Split safety | None | One predecessor may have many successors; never select the first child implicitly | P0 |
| Hierarchy integrity | Only FK | Reject cycles, self-parenting, level mismatch, and depth >4 | P0 |
| Public publication | `is_active` only | Staged nodes remain inactive; public reads require active lifecycle/publication | P0 |
| Product assignment | Nullable exact FK | Assign only to active, assignable, policy-cleared node; quarantine/manual queue otherwise | P0 |
| Descendant browse | Exact category filter | Trusted recursive descendant lookup/RPC with active-node filtering | P0 |
| Alias search | Client name match | Server-side canonical label/approved synonym resolution | P1 |
| Breadcrumb/path | None | Derive from parent graph; path is mutable presentation, never identity | P1 |

## 3. Recommended minimal physical additions

### Additive columns on `categories`

- `source_key text` — deterministic import locator;
- `slug text` — mutable canonical URL/search token;
- `level smallint` — 1 through 4;
- `lifecycle_state text` — staged/active/retired;
- `is_assignable boolean` — whether products may bind directly;
- `policy_class text` — canonical policy class;
- `professional_review_status text` — not-required/pending/approved/rejected;
- `taxonomy_version text` — import/version provenance.

During the compatibility window these are initially additive and nullable for
legacy rows. Constraints become validated/not-null only after backfill and
preflight. `is_active` remains the old-client visibility gate; new staged rows
must be imported with `is_active = false`.

### Permanent supporting tables

`taxonomy_aliases` should distinguish:

- `LEGACY_REDIRECT`: a previous node name/slug/path resolving historical
  references;
- `SEARCH_SYNONYM`: a controlled customer search term, which is not an identity
  redirect.

`taxonomy_node_relationships` should preserve predecessor/successor edges for
KEEP, RENAME, MOVE, RENAME_AND_MOVE, MERGE, SPLIT, RETIRE, and alias-only
history. Split rows may have multiple successors and require explicit product
classification or manual review.

A temporary staging/import mapping can be used during the authorized migration,
but does not need to become a customer-facing permanent table.

## 4. Deliberately omitted complexity

- No closure table is required at a maximum depth of four; a recursive CTE or
  security-invoker RPC is sufficient initially.
- No immutable path or name-derived UUID is allowed.
- No per-language category table is required for Turkish-only V1.
- No general-purpose rule engine is required. Policy class and professional
  review state are sufficient gates for the first staged migration.
- No arbitrary `jsonb` metadata bucket should replace enforceable core fields.

## 5. RLS and publication gaps

Current RLS allows active products even when their category is inactive, and
active listings even when product/category state is unsuitable. The canonical
cutover needs one of these server-authoritative patterns:

1. security-invoker public catalog views/RPCs that join category publication
   gates; or
2. tightened product/listing SELECT policies with indexed category existence
   checks.

The preferred V1 direction is a small set of public catalog RPCs/views for root,
children, descendant IDs, and public products. It centralizes policy and avoids
duplicating recursive logic in clients. Exact performance must be measured in
Development before choosing policies versus views.

Containers can be visible without being assignable. A policy-sensitive leaf is
not published merely because its parent is visible. Professional review and the
ordinary-sector allowlist remain separate from taxonomy membership.

## 6. Client gaps

Required client adaptation before activation:

- Category entity/model: parent ID, level, slug, lifecycle/public visibility,
  assignability, version, and breadcrumb/path response support.
- Repository: root and child reads, descendant filtering, alias resolution, and
  deterministic ordering.
- Home: request/render only L1 roots (or explicitly curated discovery), never
  all active nodes.
- Browse: L1/L2/L3 container selection must query descendant assignable leaves;
  an exact-node query is only valid at a leaf.
- Search: resolve canonical labels and controlled synonyms server-side; do not
  treat label or slug as stable identity.
- Product/detail/shop/cart serializers: preserve current joined
  `categories(name)` shape during compatibility or add explicit adapters.
- Presentation helpers: retire label-keyed demo mappings after canonical UI
  support exists.
- Tests: variable depth, container/leaf distinction, inactive/policy-blocked
  nodes, aliases, moves, splits, descendants, and rollback compatibility.

Importing and activating the full tree before these changes would break Home,
category search, and browsing even though the old serializer ignores additive
database columns.

## 7. Canonical data package gaps

These are blockers for an authorized remote migration apply:

1. No allocated production canonical UUID manifest exists.
2. Wave 34A supplies one complete 1,563-node planning manifest, but it is not a
   production-ID allocation/import package and authorizes no activation.
3. Eighteen L2 anchors outside the two detailed anchor subtrees are structurally
   present, but their terminal/assignable/activation flags still require an exact
   runtime qualification freeze against the earlier owner-final L2 sources.
4. Twenty-four legacy reconciliation rows remain unresolved.
5. Split mappings require product-level deterministic classification or manual
   review; a first-successor fallback is prohibited.
6. Policy/professional-review publication gates are not all closed.
7. The current live Development schema, row counts, collisions, and migration
   history have not been read in this task.

## 8. Gap conclusion

The schema can evolve additively without changing product/listing identities.
The highest risk is not DDL; it is activating an incomplete import against a
flat client and ambiguous product mappings. Therefore the correct next task is
an authorized Development preflight and local dry run—not a remote apply.
