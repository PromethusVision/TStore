# Wave 38B Strict Contract Requirement Matrix

Status: LOCAL CANDIDATE — NOT DEPLOYED

This matrix is derived from the integrated Wave 38A Dart DTOs and capability verifier, not from prose alone. The proposed backend contract is additive and targets client contract `taxonomy-client-v1`, taxonomy data `canonical-v1.0.0`, and RPC contract `taxonomy-rpc-v2` generation 2.

## Node payload

| Client requirement | Source-of-truth expectation | v2 response | Result |
|---|---|---|---|
| `id` | non-empty UUID text | UUID | MATCH |
| `parent_id` | nullable UUID text | UUID/null | MATCH |
| `name` | non-empty text | text | MATCH |
| `slug` | non-empty text | text | MATCH |
| `level` | integer 1–4 | smallint 1–4 | MATCH |
| `lifecycle_state` | `staged`, `active`, or `retired` | exact stored value | MATCH |
| `is_assignable` | boolean | exact stored value | MATCH |
| `policy_class` | supported policy enum | exact stored value | MATCH |
| `professional_review_status` | supported review enum | exact stored value | MATCH |
| `taxonomy_version` | non-empty, proof-matching text | `canonical-v1.0.0` | MATCH |
| `has_children` | boolean node-shape evidence | server-computed boolean | MATCH |
| `sort_order` | optional integer | integer | MATCH |

The v2 node also returns `is_public_active`, `is_pilot_active`, and `preview_context`. They are operational truth fields and do not replace lifecycle, assignability, or policy fields.

## Hierarchy, alias, and search

| Requirement | v2 proof | Result |
|---|---|---|
| Roots | server-authoritative ordered L1 list | MATCH |
| Children | direct children by UUID | MATCH |
| Descendants | one recursive server call; no client fan-out | MATCH |
| Exact leaf/product scope | target is visible, `is_assignable=true`, policy/review eligible, and has no children | MATCH |
| Breadcrumb | ordered root-to-target strict nodes | MATCH |
| Alias | `RESOLVED`, `AMBIGUOUS`, `TOMBSTONE`, `UNRESOLVED`; target count included | MATCH |
| Ambiguity | no first-match fallback; graph invariant enforced | MATCH |
| Search node | nested strict `matched_node` | MATCH |
| Search path | non-empty server-built root-to-node path | MATCH |
| Alias search context | matched text and alias locator when applicable | MATCH |
| Version consistency | result and nested nodes use requested taxonomy version | MATCH |

## Capability proof

| Wave 38A field/evidence | v2 response | Result |
|---|---|---|
| `contract_version` | `taxonomy-client-v1` | MATCH |
| `taxonomy_version` | `canonical-v1.0.0` | MATCH |
| Seven required features | exact seven-value set | MATCH |
| Seven required evidence values | exact seven-value set | MATCH |
| RPC generation | `taxonomy-rpc-v2`, generation 2 | MATCH, additional proof |
| Preview state | supported/enabled booleans and root counts | MATCH, additional proof |
| Lifecycle/policy/path/alias metadata | explicit booleans | MATCH, additional proof |
| Product-scope semantics | explicit assignability and policy fail-closed booleans | MATCH, additional proof |

The corrected candidate treats structural navigation and product scope separately. On the unchanged 0010 baseline, all 1,245 leaves remain available to authorized structural preview but all return zero from exact-leaf qualification because all are non-assignable. Permanent local regression coverage proves non-assignable leaves, assignable containers, excluded/pending/retired candidates, disabled preview, and nonexistent UUIDs fail closed; an isolated transaction proves one eligible assignable leaf succeeds and then rolls back.

## Bounded client work

The strict DTOs and capability DTO already parse the proposed response shapes. Two bounded wiring updates remain for a later authorized client task:

1. bind the Supabase RPC caller to the eight `*_v2` endpoints and pass client version plus explicit preview intent;
2. bind capability verification/runtime selection to `taxonomy_capabilities_v2` and the strict DTO path instead of the deployed v1 DTO path.

These are `ADAPTER_UPDATE_REQUIRED`, not backend blockers. Backend blockers: **0**.
