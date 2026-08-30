# Wave 38B Client / Backend Compatibility Matrix

Status: READY FOR BOUNDED ADAPTER WORK AFTER BACKEND REVIEW

The comparison target is the Wave 38A code already integrated at base `231e5f27270f808c59cef445b4cca8931ac16cc2`.

## Matrix

| Area | Current Wave 38A expectation | Proposed v2 | Classification |
|---|---|---|---|
| Client contract version | `taxonomy-client-v1` | exact | MATCH |
| Taxonomy version | proof-bound non-empty version | `canonical-v1.0.0` | MATCH |
| Capability features | seven exact enum values | all seven | MATCH |
| Capability evidence | seven exact enum values | all seven | MATCH |
| Strict node fields | 11 required + optional sort order | all present | MATCH |
| Hierarchy shape | root/child/descendant/breadcrumb authority | server-authoritative | MATCH |
| Product-scope leaf qualification | strict visible + assignable + policy-eligible exact leaf | corrected server predicate and capability proof | MATCH |
| Alias states | four explicit states | four explicit states | MATCH |
| Search context | nested node, path, optional alias context | exact shape | MATCH |
| Lifecycle/policy truth | required and fail-closed | exact stored metadata | MATCH |
| RPC names and parameters | low-level deployed adapter calls `*_v1` | strict set is `*_v2`, adds client and preview inputs | ADAPTER_UPDATE_REQUIRED |
| Capability/runtime binding | strict DTO exists but live v1 adapter has no capability call | call v2 capability and bind strict DTO/runtime selection | ADAPTER_UPDATE_REQUIRED |

## Counts

- MATCH: **10**
- ADAPTER_UPDATE_REQUIRED: **2**
- BACKEND_BLOCKER: **0**

W38C correctly reduced the pre-correction assessment to MATCH 9 / ADAPTER 2 / BLOCKER 1 because non-assignable structural leaves qualified as product scopes. The corrected SQL and permanent local regression now restore the evidence-based count above: MATCH 10 / ADAPTER 2 / BLOCKER 0.

The adapter update count is architectural work items, not a count of touched methods. A later client task should change all seven calls atomically under one strict adapter binding and add the capability/preview gate atomically. Legacy runtime remains the default until that work and a separate Development acceptance are authorized.

## Cutover boundary

Backend deploy, server preview enablement, Development runtime selection, and Customer acceptance are separate gates. This candidate authorizes none of them. Failure of capability proof, preview state, response parsing, or taxonomy version must retain/fall back to the existing fail-closed legacy selection rather than partially mix v1 and v2 data.
