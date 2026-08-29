# Wave 36 — Backend Taxonomy Query Contract

Status: **VERSIONED RPC/READ PROPOSAL — STAGING TOOLING ONLY**
Remote activation: **none**

## 1. Common publication rules

All customer-facing queries are server-authoritative and versioned. Public rows
must satisfy:

- matching requested taxonomy version;
- `lifecycle_state='active'` and `is_active=true`;
- exact parent graph and maximum depth four;
- policy/publication gating appropriate to the operation;
- no access to allocation, alias-edge, predecessor/successor, or import tables.

Stable UUID is identity. Name, slug, path, and breadcrumb are presentation.
Containers may be visible but not assignable. A category's existence never
authorizes a product/listing or regulated sale.

The staging compiler installs seven candidate function signatures locally so
the contract can be tested. Naming/activation in the active migration chain
still requires Integration/backend review.

## 2. ROOTS

Candidate: `taxonomy_roots_v1(p_taxonomy_version text)`

Returns public L1 rows only, ordered by `sort_order,id`. The canonical package
may structurally contain 24 roots while a rollout exposes fewer. Home must not
request every active category.

## 3. CHILDREN

Candidate: `taxonomy_children_v1(p_parent_id uuid, p_taxonomy_version text)`

Returns immediate public children in deterministic order. Unknown/inactive
parents return an empty set; the server does not search by similar name.

## 4. DESCENDANTS

Candidate:
`taxonomy_descendants_v1(p_category_id uuid, p_taxonomy_version text)`

Returns active assignable descendants, including the start node when it is an
assignable leaf. Server recursion is bounded by the enforced L1–L4 hierarchy.
Clients do not download/recurse across all 1,563 nodes.

Container browsing uses this ID set or a future server-side product browse RPC.
Performance/URL limits must be measured in an authorized Development rehearsal.

## 5. EXACT_LEAF

Candidate: `taxonomy_exact_leaf_v1(p_category_id uuid, p_taxonomy_version text)`

Returns a row only when the UUID is active, assignable, `NORMAL`, and
`professional_review_status='not_required'`. A container, staged category,
regulated/pending node, or wrong version returns empty. Exact leaf lookup does
not broaden to children/parents.

## 6. BREADCRUMB

Candidate:
`taxonomy_breadcrumb_v1(p_category_id uuid, p_taxonomy_version text)`

Returns active ancestors ordered L1 to leaf. Breadcrumb is derived on read and
is never identity. A moved category retains UUID while its derived breadcrumb
changes.

## 7. ALIAS RESOLUTION

Candidate:
`taxonomy_resolve_alias_v1(p_alias_slug text, p_taxonomy_version text)`

Only `LEGACY_REDIRECT + RESOLVED + active` may return one active canonical row.

| Alias state | Public behavior |
|---|---|
| `RESOLVED` | exact canonical UUID when target is publicly active |
| `AMBIGUOUS` | empty/fail closed; classification or customer disambiguation required |
| `TOMBSTONE` | retired/outcome response in a future explicit contract; no redirect |
| `UNRESOLVED` | empty/fail closed; operator/policy queue |

The function is a narrow security-definer projection with fixed `search_path`;
it does not expose the underlying administrative alias/edge tables.

## 8. SEARCH TAXONOMY CONTEXT

Candidate:
`taxonomy_search_context_v1(p_term text, p_taxonomy_version text)`

Matches active canonical exact label/slug and controlled resolved synonyms.
Legacy redirects do not automatically become synonyms. Ambiguous aliases do
not produce a single target. This V1 exact-normalized contract is intentionally
small; fuzzy/full-text ranking belongs to a separately measured search design.

## 9. Product/listing projection boundary

These seven functions describe taxonomy navigation/resolution. Public catalog
reads must additionally prevent an active product/listing from leaking through
an inactive, unassignable, policy-blocked, or quarantined category.

Two implementation options remain for backend review:

1. descendant IDs from the RPC plus a bounded PostgREST product filter; or
2. a security-invoker catalog browse RPC that applies category/product/shop/
   listing gates server-side.

The second is preferred if Development measurements show URL-size/performance
or consistency problems. No option is activated here.

## 10. RLS and grants

- `categories` stays readable only through active-row RLS/public functions.
- Direct read/mutation on allocations, aliases, alias targets, relationships,
  and import runs remains revoked from `anon` and `authenticated`.
- Alias/search security-definer functions must own only the narrow projection,
  pin `search_path`, validate version, and never accept arbitrary SQL/path.
- Merchant/client roles receive no taxonomy mutation authority.
- Admin UI is not authorization; future writes require server-side capability
  checks and audit evidence.

## 11. Required contract tests

Test fixtures must cover:

- staged package returns zero public roots;
- active root/child ordering;
- L2, L3, and L4 leaf paths;
- visible non-assignable container;
- descendant scope without cross-domain leakage;
- exact normal leaf versus inactive/policy/pending/container;
- breadcrumb after rename/move;
- exact legacy redirect;
- ambiguous split, tombstone, unresolved alias;
- controlled search synonym distinct from redirect;
- wrong/missing version and malformed UUID;
- anon denial for five administrative tables;
- schema/function signatures and grants;
- old-client compatibility during the declared cutover window.

## 12. Local evidence

The Wave 36 PGlite rehearsal installed all seven candidate signatures,
confirmed zero public roots for staged input, denied direct anon access to five
administrative tables, and reconciled all structural/alias/relationship counts.
Managed Supabase query plans, locks, and client integration remain future
authorized gates.
