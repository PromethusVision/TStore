# Wave 38 Development Canonical Taxonomy RPC Contract Inventory

Date: 2026-08-30

Environment: **EsnaftaVar Development only**

Project ref: `tnipyxnvhgelwdpykyez`

Mode: read-only catalog and RPC smoke inspection

## Executive result

Development contains all seven expected conceptual RPCs and grants their execution to `anon` and `authenticated`. The deployed data version is `canonical-v1.0.0`, but the backend does not publish an authoritative `taxonomy-client-v1` capability response. Several RPC response shapes also omit fields required by the Wave 36 client contract. The deployed contract is therefore **BLOCKING_CONTRACT_MISMATCH** for `CANONICAL_V1_RUNTIME`; an RPC call merely succeeding is not accepted as capability proof.

The concrete Flutter adapter added in Wave 38 maps the deployed shapes exactly. It does not invent lifecycle, policy, hierarchy, alias-state, path, or taxonomy-version evidence.

## Development state reverified

| Check | Read-only result |
|---|---:|
| Migration ledger | 10/10; latest canonical bootstrap `0010` |
| Canonical rows | 1,563 |
| L1 / L2 / L3 / L4 | 24 / 244 / 1,096 / 199 |
| Data taxonomy version | `canonical-v1.0.0` |
| Staged/inactive | 1,563 / 1,563 |
| Public active | 0 |
| `anon` direct category visibility | 0 |
| `authenticated` direct category visibility | 0 in the current staged state |
| Canonical admin-table grants to app roles | none observed |

## Exact endpoint inventory

All functions are in schema `public`, are `STABLE`, have `search_path=public`, and revoke execution from `PUBLIC` before granting `EXECUTE` to both `anon` and `authenticated`.

| Capability | Exact function and arguments | Exact returned columns | Security | Staged behavior |
|---|---|---|---|---|
| Roots | `taxonomy_roots_v1(p_taxonomy_version text)` | `id uuid, parent_id uuid, name text, slug text, level smallint, is_assignable boolean, sort_order integer, taxonomy_version text` | invoker | Filters to active + `is_active`; empty now |
| Children | `taxonomy_children_v1(p_parent_id uuid, p_taxonomy_version text)` | same eight root/child columns | invoker | Filters to active + `is_active`; empty now |
| Descendants | `taxonomy_descendants_v1(p_category_id uuid, p_taxonomy_version text)` | `id uuid, level smallint, is_assignable boolean` | invoker | Recursive server query; returns only active assignable nodes; empty now |
| Exact leaf | `taxonomy_exact_leaf_v1(p_category_id uuid, p_taxonomy_version text)` | `id uuid, name text, slug text, taxonomy_version text` | invoker | Requires active, assignable, `NORMAL`, review-not-required; empty now |
| Breadcrumb | `taxonomy_breadcrumb_v1(p_category_id uuid, p_taxonomy_version text)` | `id uuid, parent_id uuid, name text, slug text, level smallint` | invoker | Active ancestry only; empty now |
| Alias | `taxonomy_resolve_alias_v1(p_alias_slug text, p_taxonomy_version text)` | `category_id uuid, canonical_slug text, resolution_state text` | definer | Exposes only active `RESOLVED` redirects; ambiguous/tombstone/unresolved are indistinguishable empty results |
| Search | `taxonomy_search_context_v1(p_term text, p_taxonomy_version text)` | `category_id uuid, name text, slug text, match_kind text` | definer | Exact canonical/alias match against active nodes only; empty now |

There is no deployed product-listing query RPC. `taxonomy_exact_leaf_v1` and `taxonomy_descendants_v1` qualify taxonomy IDs; they do not return products. The client must not label their output as product data.

## Wave 36 assumption comparison

| Endpoint | Classification | Difference |
|---|---|---|
| Roots | `BLOCKING_CONTRACT_MISMATCH` | Missing `lifecycle_state`, `policy_class`, `professional_review_status`, and authoritative `has_children`/`is_leaf`. |
| Children | `BACKWARD_COMPATIBLE_ADAPTER_DIFFERENCE` + blocking shape | Domain `categoryId` maps to `p_parent_id`; response has the same missing strict node fields as roots. |
| Descendants | `BACKWARD_COMPATIBLE_ADAPTER_DIFFERENCE` + blocking shape | Existing RPC avoids client fan-out, but returns only ID, level, assignability; no full versioned nodes. |
| Exact leaf | `BACKWARD_COMPATIBLE_ADAPTER_DIFFERENCE` | Safely qualifies a public normal leaf and returns a version, but is only one half of product-scope qualification. No product query endpoint exists. |
| Breadcrumb | `BLOCKING_CONTRACT_MISMATCH` | Missing lifecycle/policy/assignability/node-shape and taxonomy-version fields. |
| Alias | `BLOCKING_CONTRACT_MISMATCH` | No input locator/version echo; no ambiguous, tombstone, or unresolved outcome contract; empty cannot be interpreted safely. |
| Search | `BLOCKING_CONTRACT_MISMATCH` | Missing full matched node, breadcrumb path, leaf/container signal, alias context, and taxonomy version. |
| Capability proof | `BLOCKING_CONTRACT_MISMATCH` | No authoritative response declaring client contract version, signatures, shapes, and semantic evidence. |

## Live read-only smoke evidence

The seven RPCs were invoked in transaction-local `anon` and `authenticated` role contexts with `canonical-v1.0.0`. All returned zero rows, matching the deliberate 0-active staged state. Additional results:

- unknown valid UUID: zero rows;
- wrong taxonomy version: zero roots;
- ambiguous alias `temel-gida`: zero rows;
- tombstone alias `pet-saglik-destek-urunu`: zero rows;
- unresolved alias `medikal-konfor-ayakkabisi`: zero rows;
- malformed UUID: PostgreSQL `22P02`;
- RLS direct-category visibility under `anon`: zero canonical rows.

Empty active projections are therefore expected, not a backend health failure. They also cannot prove missing response columns or hidden alias outcomes.

## Safety

No row, lifecycle state, migration, RLS policy, function, grant, Auth, Storage, or Realtime setting was changed. Production was not accessed.
