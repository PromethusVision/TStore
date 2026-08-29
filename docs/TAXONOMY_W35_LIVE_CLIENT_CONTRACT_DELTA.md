# Wave 35A-R — Live Development vs Wave 35C Client Contract Delta

**Client source:**
`origin/agent3/w35-customer-variable-depth-taxonomy-prep@544b7882ebd2525632a9431ea2a911165dad8687`

**State:** `PASS — CLIENT PREPARATION ASSUMPTIONS HOLD; CUTOVER STILL BLOCKED`

The source branch was inspected read-only and was not merged. Flutter/runtime
files were not changed by this task.

## Live contract reconciliation

| Contract area | Live evidence | Wave 35C implication |
|---|---|---|
| Current category transport | Only legacy columns exist: ID/name/description/image/parent/order/active/timestamps | Correctly remains on unchanged `CategoryModel`; speculative canonical fields must not be queried. |
| Canonical capability fields | Level, kind, lifecycle, assignability, version and lineage are absent | Separate versioned DTO/view/RPC remains required before wiring. |
| Root/children reads | Current RLS exposes any active category; no root/child endpoint | Pure hierarchy seam remains valid, but Home must not switch until a filtered contract exists. |
| Descendant products | Product repository can only use current exact `category_id`; no descendant RPC/view | `DESCENDANTS` scope must stay inactive until bounded server support exists. |
| Alias/redirect | No alias registry or authoritative resolver exists | No rename/move/split fallback may be enabled; first-child resolution stays prohibited. |
| Policy fail-closed | Category/product policies only test legacy `is_active` | Canonical lifecycle/assignability/policy gates require new server contract before activation. |
| Stable identity | UUID PK/FKs match the prepared model; names/paths are presentation | Wave 35C stable-ID assumptions remain valid. |
| Product/listing relation | Listing has no category FK; taxonomy flows through preserved product ID | Cart, QR, review, wishlist and seller-comparison identities remain compatible. |
| Current data | Categories/products/listings are empty | Old runtime shows a valid empty state; no live product mapping tests are possible from this baseline. |
| Demo/media | No demo rows and no Storage objects | Wave 35C demo/media cutover tasks have no current live migration workload. |

## Backend requirements before client cutover

1. Additive canonical category fields and explicit capability/taxonomy version.
2. RLS-safe root, children, breadcrumb and bounded descendant product reads.
3. Authoritative alias state response with ambiguous/tombstone/unresolved
   semantics.
4. Public product/listing projection that enforces active, assignable and
   policy-cleared classification.
5. Separate canonical DTO adapter while preserving old-schema/new-app and staged-
   schema/old-app compatibility.
6. Controlled Development wiring and regression against non-empty canonical
   fixtures before activation.

The live profile introduces no contradiction requiring Wave 35C domain-model
changes. It confirms why the prepared seams must remain disconnected today.

`CLIENT_CONTRACT_LIVE_PARITY: PASS`

`VARIABLE_DEPTH_CLIENT_ASSUMPTIONS_CHANGED: NO`

`DEVELOPMENT_BACKEND_CONTRACT: REQUIRED`

`DEVELOPMENT_CUTOVER_WIRING: NOT_STARTED`

`RUNTIME_MODIFIED: NO`
