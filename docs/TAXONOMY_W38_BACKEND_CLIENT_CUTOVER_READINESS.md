# Wave 38 Backend / Client Cutover Readiness

Date: 2026-08-30

Scope: local Flutter code plus read-only Development verification

## Readiness summary

| Gate | State | Evidence |
|---|---|---|
| Actual Development RPC inventory | PASS | 7/7 exact signatures, return columns, security modes, grants, and staged behavior recorded. |
| Concrete low-level Supabase adapter | PASS | Seven exact RPC calls, typed deployed-shape DTOs, server recursion, safe validation, deterministic error classes. |
| Strict Wave 36 repository compatibility | BLOCKED | Deployed response shapes omit required server-owned fields and outcomes. |
| Capability proof implementation | PASS / current proof unavailable | Proof requires feature set plus seven explicit evidence classes; current inventory returns no proof. |
| Environment-aware DI | PASS | Development may register only the low-level deployed adapter; canonical repositories require proof and explicit verified bindings. |
| Legacy default | PASS | Both Development and Production entrypoints explicitly request legacy. |
| Canonical runtime active | NO | No global switch or implicit activation exists. |
| Live read-only smoke | PASS | Expected zero active rows under anon/auth; error and RLS behavior verified. |
| Wave 38B readiness | NO | Classification C prerequisites remain. |

## Client architecture

The cutover boundary has three distinct layers:

1. **Deployed contract adapter** — calls only the real `taxonomy_*_v1` functions and maps only fields they actually return.
2. **Capability verifier** — compares an inventoried backend against exact RPC signatures, strict response fields, grants/safety gates, contract version, and semantic evidence. It emits no proof when any blocker exists.
3. **Environment DI planner** — keeps legacy as the default; an explicit Development acceptance request fails closed without a compatible proof. Even with proof, strict taxonomy and product-scope bindings must be supplied explicitly.

This separation prevents the current low-level adapter from being mistaken for the richer canonical repository contract.

## Error and version behavior

- invalid local UUID/text input is rejected before the RPC;
- `22P02`, `42501`, missing-function/PostgREST contract errors, malformed payloads, and other remote failures map to deterministic non-secret error kinds;
- returned version fields are compared with `canonical-v1.0.0` where the deployed response includes a version;
- endpoints that omit version are not presented as version-proof evidence;
- response errors do not include raw backend details or credentials.

## Existing Wave 36 behavior retained

Wave 36 fixture tests continue to cover 24 roots, L2/L3/L4 leaves, recursive container navigation, breadcrumbs, exact/descendant domain scopes, search path and alias context, lifecycle/policy blocks, and version mismatch. Wave 38 adds deployed-shape and capability/DI tests; it does not weaken those richer expectations to match the current backend.

## Exact remaining Wave 38B work

1. Complete the backend contract change listed in `TAXONOMY_W38_ACCEPTANCE_ACTIVATION_REQUIREMENT.md`.
2. Re-run Development-only signature, response-shape, grant/RLS, lifecycle, alias, search, and version smoke.
3. Feed the authoritative inventory/capability response into the verifier.
4. Implement the strict adapter binding from the accepted backend payloads to the existing Wave 36 repository.
5. Supply a verified product-scope repository if the backend defines product retrieval; do not confuse taxonomy ID qualification with product results.
6. Build an explicitly selected Development acceptance configuration; Production stays legacy.
7. Execute real 24-root, recursive browse, breadcrumb, search, exact/descendant product listing, inactive/retired/policy, back navigation, and legacy rollback tests.
8. If any proof or acceptance gate fails, stop canonical startup rather than falling back silently.

## Safety record

- Development reads: **YES, limited to allowed read-only inventory/smoke**
- Development writes: **NO**
- Production access: **NO**
- taxonomy activation: **NO**
- migration/RLS/RPC/grant mutation: **NO**
- service-role/server secret usage: **NO**
