# Wave 38B Strict Canonical Backend Contract

Status: LOCAL/STAGED CANDIDATE — NOT APPLIED REMOTELY

## Versions and naming

- Client contract: `taxonomy-client-v1`
- Taxonomy data: `canonical-v1.0.0`
- RPC contract: `taxonomy-rpc-v2`
- RPC generation: 2
- Candidate identifier: `20260830001100_0011_canonical_taxonomy_contract_v2`

The suffix describes the RPC generation, not a new taxonomy dataset. All existing `*_v1` functions remain in place. The candidate neither replaces nor drops them.

## Endpoint set

| Endpoint | Purpose |
|---|---|
| `taxonomy_capabilities_v2(client, taxonomy)` | exact compatibility and preview-state proof |
| `taxonomy_roots_v2(client, taxonomy, preview)` | ordered visible roots |
| `taxonomy_children_v2(parent, client, taxonomy, preview)` | ordered direct children |
| `taxonomy_descendants_v2(category, client, taxonomy, preview)` | server-recursive descendants |
| `taxonomy_exact_leaf_v2(category, client, taxonomy, preview)` | exact assignable-leaf qualification |
| `taxonomy_breadcrumb_v2(category, client, taxonomy, preview)` | ordered root-to-node path |
| `taxonomy_resolve_alias_v2(locator, client, taxonomy, preview)` | explicit alias outcome |
| `taxonomy_search_context_v2(term, client, taxonomy, preview)` | strict node plus authoritative path and match context |

All read endpoints require exact client and taxonomy version arguments. Invalid or mismatched versions fail closed. UUID inputs use native UUID parameters; malformed UUIDs are rejected before any result is produced. Unknown valid UUIDs return no row rather than a guessed node.

## Strict node response

Every hierarchy response carries:

`id`, `parent_id`, `name`, `slug`, `level`, `lifecycle_state`, `is_assignable`, `policy_class`, `professional_review_status`, `taxonomy_version`, `has_children`, `sort_order`, `is_public_active`, `is_pilot_active`, and `preview_context`.

`has_children` is calculated by the server from the frozen hierarchy. Preview does not rewrite `lifecycle_state` or `is_assignable`: a previewed staged node remains staged and non-assignable when stored that way. `is_public_active` remains false and `is_pilot_active` remains false throughout the rehearsal.

## Hierarchy and leaf semantics

- The server remains hierarchy-authoritative.
- Descendants are returned by one recursive endpoint; the client need not recursively fan out.
- Breadcrumbs are ordered L1 through target and consist of the same strict node shape.
- Exact-leaf qualification is a product-scope operation, not a generic structural-leaf lookup. It requires a visible node, `is_assignable=true`, no child in the same taxonomy version, a policy class other than `EXCLUDED`, and a professional-review state other than `pending` or `rejected`.
- Container/leaf truth comes from `has_children`, not name or level inference.

The frozen 0010 baseline intentionally has 1,245 structural leaves and zero assignable nodes. Consequently, preview navigation can expose all structural leaves while `taxonomy_exact_leaf_v2` correctly returns zero authoritative product scopes. A local transaction proved the positive path by temporarily making one normal staged leaf assignable; the endpoint returned exactly that leaf and rollback restored the baseline digest.

`STRUCTURAL PREVIEW != PRODUCT ASSIGNABILITY`: roots, children, descendants, breadcrumb, and search may describe a staged non-assignable leaf, but that does not qualify it for product assignment.

## Alias contract

The resolver returns `alias_locator`, `resolution_state`, nullable `direct_target_category_id`, `taxonomy_version`, `alias_kind`, `matched_via_alias`, and `target_count`.

- `RESOLVED`: exactly one target edge and a direct target.
- `AMBIGUOUS`: at least two target edges and no arbitrary direct target.
- `TOMBSTONE`: zero targets and no direct target.
- `UNRESOLVED`: zero targets and no direct target.

An invalid graph fails with `W38_ALIAS_GRAPH_INVALID`. Non-preview calls expose only active resolved aliases whose target is publicly visible. An authorized preview may read the frozen staged alias registry, including all four explicit states, without activating aliases or categories.

## Search contract

Each search row returns:

- `matched_node`: strict node object;
- `path`: non-empty strict-node array ending at `matched_node`;
- `alias_context`: null or `{matched_text, locator}`;
- `taxonomy_version`, `match_kind`, and `matched_via_alias`.

Canonical exact-name/slug matches are preferred. Resolved alias matches are included only when their target is visible in the selected context. Search does not reconstruct a path on the client and never promotes ambiguous aliases to a match.

## Capability contract

Capability success proves exact versions, the seven required feature values, and the seven required evidence values expected by Wave 38A. It additionally reports RPC generation, lifecycle/policy/alias/path metadata, preview support/state, public/pilot/preview root counts, and product-scope proof: `product_scope_contract=exact-leaf-visible-assignable-policy-eligible`, `product_scope_requires_assignable=true`, and `product_scope_policy_fail_closed=true`.

Merely finding an RPC is insufficient. Any missing config, version mismatch, or malformed contract state raises an explicit fail-closed error.

## Compatibility and non-goals

The v1 set remains 7/7 callable after apply and after rollback. This candidate does not activate canonical Customer runtime, change taxonomy rows, allocate UUIDs, authorize products, or waive policy/professional review.
