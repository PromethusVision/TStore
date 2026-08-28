# Customer App TODO and Debt Inventory

Status: PASS — no unmanaged TODO markers

Exact `TODO`, `FIXME`, and `HACK` scan across application, tests, platforms, tools, and Supabase artifacts returned zero hits.

Broader words such as temporary/legacy/deprecated were reviewed by cluster rather than counted as TODOs:

| Cluster | Classification | Action |
| --- | --- | --- |
| Legacy orders and legacy review evidence | FUNCTIONAL_DEBT / intentional compatibility | Keep isolated; no V1 route. |
| Chat fallback functions named legacy | FUNCTIONAL_DEBT | Preserve until optional aggregate RPC compatibility is retired deliberately. |
| Legacy HTTPS media support | COMPATIBILITY | Keep while existing rows may reference safe HTTPS media. |
| Icons compatibility shim | COMPATIBILITY | Keep; release tree-shaking regression is covered. |
| Temporary SQL tables in deterministic seed | FALSE_POSITIVE | Transaction-local implementation, not debt. |
| Temporary/failure strings in tests | TEST_ONLY | Fixtures, not runtime markers. |
| Web deprecated-library ignore | TOOLCHAIN_DEBT | Isolated conditional web sanitizer; revisit with Flutter web API migration. |
| Dormant postal address/avatar/Dio/location helpers | DEAD_CODE CANDIDATE | Do not revive without contract review; cleanup separately. |

`TODO_DEBT_INVENTORY: PASS`  
`BLOCKING_TODO: 0`
