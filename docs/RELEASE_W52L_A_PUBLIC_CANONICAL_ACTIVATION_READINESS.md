# W52L-A — Public canonical activation readiness

**Release readiness: FAIL / controlled hold.** The server publication candidate can be rehearsed without changing 0012, the private bridge, legacy data or security rules. Authoritative main does **not** contain a Production public canonical Flutter runtime. Turning off the private-preview define selects legacy mode. A final public canonical build recipe therefore cannot truthfully be supplied for this source revision.

Authoritative main: `513ab9ce7fcec517bbad9922743a629d1512e9b6`. Task branch: `astra-release/w52l-a-public-canonical-activation-readiness`. No Production or Development access, live backup, live write, APK/AAB build, device operation, merge or publication was performed in this wave.

## Exact activation mechanism

The installed, immutable [0012](../supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql) owns the Production public contract. Its `_production_taxonomy_visible_v1` requires `public_enabled=true`, `p_preview=false`, active lifecycle and `is_active=true` for the entire ancestor chain, plus `policy_gate=PASS` and `professional_gate=PASS` in `canonical_category_qualification`. A flag-only update is insufficient.

`production_taxonomy_assignment_visible_v1` additionally requires an assignable terminal `LEAF_ASSIGNABLE_CANDIDATE`. The invoker-security `production_taxonomy_products_v1` joins `products`, the RLS-protected `product_canonical_assignments`, and visible descendants. Legacy `products.category_id` remains unchanged; the returned JSON projects the canonical ID and retains `legacy_category_id`.

The reviewed candidate [activate.sql](../tool/production_public_activation/activate.sql) changes only:

| Relation | Exact change |
| --- | --- |
| `canonical_categories` | Publish 325 nodes: all 24 eligible roots, eligible containers and leaves whose entire ancestry passes both gates. Set `is_active=true`, `lifecycle_state=active`; only 247 qualified terminal leaves become `is_assignable=true`. The other 1,238 nodes remain staged and unassignable. |
| `production_taxonomy_config` | Set the single `public_enabled` flag to true; leave preview settings and all contract versions unchanged. |
| `taxonomy_aliases` | Set `is_active=true` only for `RESOLVED` aliases whose direct target is publicly visible. Preserve every alias locator, target, edge, resolution state and taxonomy version. |
| `supabase_migrations.schema_migrations` | Insert exactly `20260922001400 / 0014_public_canonical_activation` with the exact SQL payload in one `statements` entry. |

No policy classification, professional-review status, qualification, hierarchy, name, mapping, timestamp, product, listing, shop, grant, RLS rule or function is edited. Empty eligible roots intentionally remain visible: limiting publication to ancestors of eligible leaves would not establish the required 24-root contract.

The dedicated [executor](../tool/production_public_activation/executor.mjs) repeats strict preflight under locks. [Policy validation](../tool/production_public_activation/policy.mjs) independently derives the exact publication set from the frozen category and qualification CSVs. The [state oracle](../tool/production_public_activation/state-oracle.json) checks all nine canonical tables. Only cross-install creation/update/import timestamps are excluded from that structural oracle; every timestamp and other non-publication field is separately compared within each real execution.

## Public API and current client gap

The actual public server contract is:

| Item | Exact value / signature |
| --- | --- |
| Project / host | `mefhfvrgkwciubeajjeb` / `mefhfvrgkwciubeajjeb.supabase.co` |
| Client / taxonomy | `production-taxonomy-client-v1` / `canonical-v1.0.0` |
| RPC contract / generation | `production-taxonomy-rpc-v1` / `1` |
| Runtime | `production_taxonomy_runtime_v1()` returns one JSON object; verify public ON, preview OFF and product scope RPC. |
| Capability | `production_taxonomy_capabilities_v1(p_client_contract_version,p_taxonomy_version)` returns a one-row array via PostgREST; require 24 public roots, zero preview/pilot roots and fail-closed product gates. |
| Tree | `production_taxonomy_roots_v1`, `children_v1`, `descendants_v1`, `exact_leaf_v1`, `breadcrumb_v1`, all with the `production_taxonomy_` prefix and `p_preview=false`. Children use `p_parent_id`; descendants, exact leaf and breadcrumb use `p_category_id`. |
| Alias / taxonomy search | `production_taxonomy_resolve_alias_v1(p_alias_locator,...)` and `production_taxonomy_search_context_v1(p_term,...)`. |
| Product scope | `production_taxonomy_products_v1(p_category_id UUID,p_client_contract_version TEXT,p_taxonomy_version TEXT,p_limit INT=20,p_offset INT=0)`. Category is mandatory; limit 1–100; offset nonnegative. Returns product ID, canonical category ID/path and projected product JSON. |
| Authorization | Anonymous and ordinary authenticated reads work identically; no tester UID, allowlist, preview session or private bridge is required. |

The current client is incompatible in several independent places:

1. [main_production.dart](../lib/main_production.dart), `main()`: preview true selects `productionPreviewApplication`; preview false selects `TaxonomyDependencyConfiguration.legacy`. There is no public canonical branch.
2. [TaxonomyDependencyPlanner.resolve](../lib/core/dependency_injection/taxonomy_dependency_configuration.dart): only legacy, Development-only canonical acceptance and Production private preview exist. The Development acceptance path rejects Production; it must not be used as a workaround.
3. [SupabaseCanonicalTaxonomyRpcAdapter](../lib/features/shop/data/services/supabase_canonical_taxonomy_rpc_adapter.dart) calls `taxonomy_*_v2` with `taxonomy-client-v1`, not the public Production v1 facade.
4. [TaxonomyBackendContractProof.supportsCanonicalV1](../lib/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart) requires generation 2, `taxonomy-rpc-v2`, preview support and `exact-leaf-visible-assignable-policy-eligible`. Public Production advertises generation 1, no preview support and `production-shadow-mapping-policy-eligible-v1`. A simple RPC rename does not fix capability validation.
5. [ProductionPreviewTaxonomyAdapter.authorize](../lib/features/shop/data/services/production_preview_taxonomy_adapter.dart) requires login, a matching authorized subject and public OFF. [ProductionPreviewProductRepository](../lib/features/shop/data/repositories/production_preview_product_repository.dart) sends `p_product_id`, `p_term`, brand/featured/sort and exact-leaf arguments absent from the public v1 product RPC. Real local PostgREST returns **404 / PGRST202** for the preview detail signature against the public function.
6. [setupServiceLocator](../lib/core/dependency_injection/service_locator.dart) binds canonical Production products only through the authorized preview path. Public product detail, global product search, featured/brand reads, paging and seller/shop projections need an explicit reviewed canonical repository contract; falling back to the legacy product repository would bypass the intended canonical scope.

No Flutter code was changed. Backend API tests are not reported as a successful new Flutter client or device smoke.

## Compatibility matrix

The legacy checks execute the W52C-style REST queries for anonymous and ordinary authenticated callers. Six SQL flows and eight real HTTP flows include Home, general/category listing, detail, seller comparison, shop detail/listings and search. Results are compared by full response hashes before, during and after publication.

| Client / contract | Before activation | After activation | After rollback |
| --- | --- | --- | --- |
| Installed legacy W52C-style client | PASS: 4 legacy roots, 20 products; all six required flows | PASS: identical legacy data, RPC/REST shape and result hashes | PASS: identical hashes |
| New public canonical **Flutter client on current main** | FAIL: no selectable runtime | FAIL: runtime/bindings/proof/product signatures are absent or incompatible | FAIL: runtime absent; a future proper client must fail closed |
| Public canonical **server API** on the local copy | PASS: OFF, no public roots/mappings/products | PASS: 24 roots; L2/L3/L4, breadcrumb, alias/search and 14 eligible products | PASS: OFF and prior visibility restored |
| Existing private-preview client | Requires a valid private lease while public is OFF | FAIL CLOSED: the bridge requires public OFF | Original bridge retained; an independently valid lease would again be required |

The six gated products remain excluded from canonical assignment/product reads. The existing legacy contract still returns its original 20 products; this candidate does not retroactively change legacy product RLS or retire old clients.

## Policy and private preview

All 1,563 category identities and policy/review fields, 1,245 terminal leaves, 20 owner mappings, 20 products, 285 listings and 57 shops remain intact. Exactly 14 mapped products are eligible; six remain gated. The regulated/pending milk branch stays unpublished/unassignable in the public API. Preview may display locked metadata that the public API deliberately does not expose.

The immutable [0013 bridge](../supabase/migrations/20260919001300_0013_production_canonical_private_preview.sql), `_w52kb_assert_contract_v2`, explicitly rejects public ON. It is **not** a diagnostics path while public activation is ON. Keep its schema, functions and expired allowlist rows temporarily so rollback preserves the staged environment. Recommended disposition: **REMOVE_AFTER_SMOKE**, in a separate authorized cleanup only after the final public client and public smoke pass. Bridge required after activation: **NO**. Tester allowlist required after activation: **NO**.

Preflight refuses activation while any enabled private lease is unexpired. It does not revoke, renew, insert or delete a live lease. Local proof uses a synthetic expired lease to verify preservation; its UID never enters evidence.

## Transactions, rollback and live boundary

Read checks run in `REPEATABLE READ READ ONLY`. Activation/rollback use one persistent session and a `READ COMMITTED` write transaction with a shared existing advisory-lock key, `SHARE ROW EXCLUSIVE` locks over the core/canonical/ledger tables and private tester table, 3-second lock timeout and 120-second statement timeout. Identity is checked against exact project, database `postgres`, non-superuser session role `postgres` and PostgreSQL 17.6. Preflight requires the unchanged 0012/0013 ledger payloads, approved schema/security fingerprint, frozen data, public OFF and exact policy/source state.

The exact [rollback](../tool/production_public_activation/rollback.sql) first validates the known active state and exact 0014 ledger, then atomically sets public OFF, aliases inactive, all nodes staged/unassignable and removes only that exact activation ledger row. It preserves 0012, 0013, private-preview data and every taxonomy/core row. A rollback before activation or a second rollback is refused. An unknown commit acknowledgment is reported as unknown; the executor never assumes that rollback succeeded or blindly retries.

Rollback deliberately refuses unexpected schema/data drift. This is the exact reviewed-state rollback, not a generic repair tool. A later live package must also supply an authorized connection/backup/HTTP handoff and independently reconcile an ambiguous commit.

**This seal is a readiness/rehearsal candidate, not a deploy authorization.** Its runtime manifest has `live_write_enabled=false`; the executor rejects every non-isolated write transport before database work. The server activate/rollback implementations are complete for the rehearsed state, but final live executability is withheld until the missing public client contract is resolved and a later authorized live package is resealed. No generic `db push`, unrelated migration or live runner was used.

## Real backup selection and proof limits

The newest local full archive, completed 2026-09-20, SHA-256 `70d85d3da72ef272630d02307ba6362a8ba15daf92a30396d78d3ee759ea65d9` (1,333,735 bytes), was restored into its own fresh PG17.6 container. All **1,066 TOC entries / 78 data sections** were restored/compared, without omissions. Strict post-0012 validation rejected the relation ACL fingerprint: `canonical_categories` and `canonical_category_qualification` restore with null ACL metadata instead of the approved explicit owner-only ACL. No repair, normalization extension, grant change or fingerprint weakening was introduced.

The next newer archive `97dfe3451c56946b4bcf81040d265c9d5909c57602c1d07da961ba1931f18626` already has the same documented unsuitability in the main-integrated [W52K-CB evidence](RELEASE_W52K_CB_AUTHORIZED_PREVIEW_VALIDATOR_FIX.md). It was not reclassified as suitable.

Both full rehearsals use the newest suitable archive supported by the unchanged approved restore: **2026-09-19 00:06:07 UTC**, **537,274 bytes**, SHA-256 `8d98258430fbb7eeccc8ead4e09efa59189aad84e961bb754fe223f07c3fcbc8`. Each independently restores all **958 TOC entries / 69 data sections**, applies the unchanged approved 0012/0013 payloads locally and uses only the previously reviewed six-property platform-security reconstruction. This is a real backup plus deterministic staged-backend reconstruction, not a claim to have freshly snapshotted current live Production.

Containers use pinned `supabase/postgres@sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00`, PostgreSQL 17.6, network `none`, no published ports and read-only backup mounts. The database executor remains non-superuser. PostgREST is reachable only over container loopback. Test credentials/identity are synthetic and local; global network fetch is disabled. No manual SQL repair is used.

Local adapter copies only substitute the exact task container/archive metadata and account for unchanged 0012/0013 scaffold ledger rows during original-archive comparison. Original source roles, owners, memberships, ACLs, all data sections and security validators remain enforced. These test adapters and proof files are excluded from the runtime seal.

## W52L-B build contract: blocked, not invented

The existing Android flavor/entry point is `production` / `lib/main_production.dart`. The external Production config provides `SUPABASE_PRODUCTION_URL`, `SUPABASE_PRODUCTION_ANON_KEY`, `PRODUCTION_PROJECT_REF`, `PRODUCTION_AUTH_SITE_URL`, `PRODUCTION_AUTH_WEB_REDIRECT_URL` and `PRODUCTION_AUTH_MOBILE_CALLBACK_URL`. Keep the key outside the repository; the project must resolve only to `mefhfvrgkwciubeajjeb`.

`ESNAFTAVAR_PRODUCTION_CANONICAL_PREVIEW=true` is forbidden for the future public release. False or omission currently creates a legacy build. **No existing exact define/config set selects public canonical mode, so no runnable final public build command is supplied.** There is no tester-specific requirement in the public server API.

Before W52L-B, implement and test an explicit Production public bootstrap, capability verifier and category/product bindings against the public contract above. It must reject wrong project, OFF/missing/malformed capability and schema/permission failures without Development or legacy fallback; validate the 24-root projection and use canonical policy-filtered product scopes across listing, detail, search, sellers and shops. Resolve the missing public product-read signatures without weakening or editing 0012. Then run analyzer/full Flutter, server/client integration and a controlled public-build recipe review. No release build or backend deployment is authorized by this report.

## Validation and handoff

The machine-readable [validation record](data/w52l_a_public_activation_validation.json) contains the final package hash, independent restore identities, before/after HTTP hashes, policy counts, rollback proof, failure-case outcomes and the required task-result fields. The seal inventory contains only executable runtime/security dependencies, frozen inputs and runtime/state manifests; reports, local credentials, backups, test harnesses and generated evidence are excluded.

The required live decision and final build remain **NO** because a working public Flutter client does not exist on the pinned source. This readiness finding does not invalidate the completed server transition/rollback proof or legacy compatibility result.

Final verification: **8/8 package tests**, **17/17 failure/reapply cases**, **2/2 fresh real-copy activation and rollback rehearsals**. Each active HTTP proof performed 60 successful canonical RPC reads for each of anonymous and ordinary authenticated callers. All eight legacy HTTP flows matched before/after/rollback for both roles. Public write attempts returned 401/403. Active aliases: **148**. Full canonical rows, timestamps, expired private lease and all 69 original archive data sections were preserved/restored. No Flutter changes, so analyzer/full Flutter were not rerun.

New runtime seal: `6ec54cc42daa4f8d166bc1fc0f56982d42e0c4050c214b8ce307a6f6fc45c584` (**35 runtime/security inputs**). Both fresh successful runs verified this exact seal before and after. Executor/rollback PASS below means the complete isolated candidate; the manifest intentionally refuses live writes and does not constitute live readiness.

## TASK_RESULT

```text
W52L_A_PUBLIC_ACTIVATION_READINESS: FAIL
PUBLIC_ACTIVATION_MECHANISM_IDENTIFIED: PASS
PUBLIC_CLIENT_CONTRACT_READY: FAIL
LEGACY_CLIENT_AFTER_ACTIVATION: PASS
NEW_CANONICAL_CLIENT_AFTER_ACTIVATION: FAIL
POLICY_REVIEW_GATES_PRESERVED: PASS
ELIGIBLE_PRODUCTS: 14/14
GATED_PRODUCTS: 6/6
PRIVATE_PREVIEW_BRIDGE_POST_ACTIVATION: REMOVE_AFTER_SMOKE
PUBLIC_ACTIVATION_EXECUTOR_READY: PASS
PUBLIC_ACTIVATION_ROLLBACK_READY: PASS
REAPPLY_PROTECTION: PASS
REAL_PRODUCTION_COPY_REHEARSAL_1: PASS
REAL_PRODUCTION_COPY_REHEARSAL_2: PASS
ROLLBACK_REHEARSAL_1: PASS
ROLLBACK_REHEARSAL_2: PASS
FAILURE_INJECTION_CASES: 17
FAILURE_INJECTION_SUITE: PASS
FINAL_PUBLIC_BUILD_RECIPE_READY: FAIL
PUBLIC_CANONICAL_PREVIEW_REQUIRED_AFTER_ACTIVATION: NO
NEW_SEAL_READY: PASS
0012_CHANGED: NO
PRODUCTION_ACCESSED: NO
PRODUCTION_WRITE_PERFORMED: NO
READY_FOR_PUBLIC_CANONICAL_ACTIVATION_WRITE_DECISION: NO
READY_FOR_W52L_B_FINAL_PUBLIC_BUILD: NO
```

Repository checks: 12 JavaScript modules parse; runtime seal verifies; all 19 new files pass the secret/PII scan. Source backup hashes are unchanged. All four task-owned local containers were removed after verification; private proof files remain outside Git. `git diff --check` passes. Existing client, migration and release artifacts remain unchanged.
