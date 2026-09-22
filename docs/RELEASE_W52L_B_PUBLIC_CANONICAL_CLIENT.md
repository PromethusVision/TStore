# W52L-B — Production public canonical Flutter client

Implemented on authoritative main `1e5d91c4cef330663301ea5cabf934e94ac238ee`, task branch `astra-release/w52l-b-public-canonical-client`. Production project identity: `mefhfvrgkwciubeajjeb`. This wave performs no live Production/Development access, public activation, release build, artifact freeze, or main merge.

## Runtime and customer behavior

Production now has an explicit `ESNAFTAVAR_PRODUCTION_CANONICAL_PUBLIC=true` path. The default remains the existing legacy entrypoint. Private preview remains a separate explicit selection; requesting both public and preview throws before SDK initialization. Development canonical still has its own entrypoint and verifier. A missing or denied public contract never selects one of those other modes.

`ProductionPublicTaxonomyAdapter` verifies the exact Production HTTPS origin, runtime object, one-row capability array and additive read-facade object. It requires public ON, preview disabled/not required, 24 public roots, generation 1, `production-taxonomy-client-v1`, `canonical-v1.0.0`, `production-taxonomy-rpc-v1`, seven features/evidence fields and the policy-aware product scope. Public proof does not relax the existing v2/preview predicate. No tester identity, Auth login or allowlist is part of this proof.

The adapter reuses canonical DTOs, repositories, browsing, search and navigation. It translates only the seven explicitly supported taxonomy operations to the Production public v1 endpoints. Each customer read rechecks publication and contract; wrong identity/shape/version, missing RPC, permission error or public OFF invalidates access. A gate removes the customer app and its navigation on a failed check or session change, with a controlled retry. Old in-flight responses cannot reopen or invalidate a newer session.

Public product reads and public seller/shop projections use dedicated repositories. Existing preview product mapping validation was extracted into a shared RPC repository without changing preview semantics. Listing, exact-leaf/descendant scopes, paging, detail, search, featured and brand filters use the public facade. Seller comparison and shop listings validate the same canonical product projection. Owner shop management retains its existing authenticated path; it is never a customer-read fallback. Other customer features and accepted visuals are unchanged.

## Additive backend contract

The immutable 0012 product RPC does not expose the complete customer product/detail/seller/shop contract. New migration `20260922001500_0015_production_public_customer_reads.sql` adds exactly four stable functions:

| Function | Purpose | Security |
| --- | --- | --- |
| `production_public_read_capabilities_v1` | Publication/read-contract proof | Definer; fixed search path; no customer data |
| `production_public_products_v1` | Product projection, scope, paging, detail, search and filters | Invoker; existing RLS plus canonical eligibility |
| `production_public_listings_v1` | Seller comparison and shop-product projections | Invoker; same eligibility; active/available seller and shop |
| `production_public_shops_v1` | Active customer shop projection | Invoker; existing shop RLS |

Execute privileges are explicitly revoked from PUBLIC and client/server roles, then granted only to `anon` and `authenticated`. No table, column, policy, canonical data, role or write grant is added or altered. All four RPCs deny while public is OFF. Product and listing eligibility uses actual shadow assignments, exact assignable leaf visibility and original qualification gates; no name/index inference occurs. Paging is deterministic with an ID tie-breaker and bounded page size. Seller queries do not truncate eligibility to the first product page.

0014 is reserved by the reviewed W52L-A publication package; 0015 is the next additive schema number. Generic migration push is not a permitted Production execution method. 0012 and 0013 remain byte-identical after LF normalization.

## Activation package compatibility and rollback

The W52L-A sealed runtime and activation/rollback SQL are unchanged. Its package hash remains `6ec54cc42daa4f8d166bc1fc0f56982d42e0c4050c214b8ce307a6f6fc45c584`.

The new `tool/production_public_client` readiness executor attests every added function's exact definition, signature, owner and ACL against an oracle derived from a fresh real-backup restore, plus the exact 0015 ledger payload. Only then does a narrowly scoped compatibility view omit those four known functions and that one ledger row from the two exact inventory queries used by the original W52L-A validator. Every other query and row remains unchanged. Unknown functions, altered definitions/grants, changed ledger content, RLS or canonical write privileges still fail. No arbitrary metadata normalization occurs.

Installation and exact ledger insertion share one transaction under the existing locks. Public activation runs the original 0014 payload and validators through this attested view. Rollback first executes original 0014 rollback, then may remove only the four 0015 functions and its exact ledger. No CASCADE is used. The readiness executor rejects live/unverified transports; a future live execution package and separate authorization remain required.

Future controlled ordering:

1. Verify target, immutable inputs, expired preview leases and exact live schema/security/ledger/data baseline.
2. Take and verify a fresh prewrite backup.
3. Install additive 0015 while public OFF; write its exact ledger atomically.
4. Verify facade definitions/grants, legacy compatibility and OFF denial for anonymous and normal authenticated customers.
5. Apply reviewed 0014 public activation with the attested compatibility layer.
6. Validate real public client contracts, 24 roots, 14 eligible/6 excluded products and old-client flows. Roll back 0014 on failure; remove 0015 only after OFF is proved.

The private bridge is not used by the public client. Its existing records and security contract are preserved. No cleanup or tester lease change is bundled into this wave.

## Validation evidence

Final machine-readable results are in `docs/data/w52l_b_public_client_validation.json`. Local rehearsal uses the suitable frozen real Production archive SHA-256 `8d98258430fbb7eeccc8ead4e09efa59189aad84e961bb754fe223f07c3fcbc8`, PG17.6, a pinned image, network `none`, no published ports and a read-only archive mount. The newer archive's known metadata suitability rejection remains documented in W52L-A; no ACL repair is used to force it to match.

Fresh restore reconstructs unchanged 0012/0013, installs 0015 OFF, applies reviewed 0014, then executes actual Flutter repositories and the Supabase Dart/PostgREST client against real local PostgREST. A nonce-protected host-loopback relay carries only allowlisted RPCs into the isolated container; it does not synthesize responses. Anonymous and ordinary authenticated roles use ephemeral local test credentials, with zero tester allowlist rows. No live credential/config is loaded.

The integration exercises roots, L2/L3/L4, breadcrumbs, descendants, exact leaves, alias/search, all 14 product details and their seller projections, paging, root/leaf product scopes, all six gated details and sellers, shop lists/detail/products, search, featured and brand filtering. The real archive has no assigned product brands, so the real brand filter's empty result is tested without seeding; unit tests additionally verify populated filter request routing. The same running Flutter adapters are tested after actual local 0014 rollback, and new authorization also fails OFF.

Legacy Home, general/category listing, detail, seller comparison, shop detail/listings and search are compared by exact full-response hashes for both roles before, during and after activation. After both rollbacks the schema/security, canonical rows and all 69 original archive data sections must match. Tests deliberately alter facade grants/ledger, introduce an unrelated function and grant a canonical write privilege inside rolled-back local transactions; all must be rejected.

The full suite retains its six existing skips. The migration inventory test adds exactly the new Production-only filename; no assertion is weakened or test skipped. Separate real-server integration is explicitly invoked outside default test discovery and adds no conditional skip.

To reproduce locally, provide `W52KB_DOCKER` (Docker executable), `W52KB_DUMP` (the exact hash-pinned archive above), and an external `W52LB_PROOF_DIR`. Set `W52KB_CONTAINER=w52kb-lbprepare` and run `node tool/production_public_client/prepare-local.mjs` to derive the oracle; then run `node tool/production_public_client/seal.mjs`. For the fresh integration, use `W52KB_CONTAINER=w52kb-lbproof`, a new external proof directory and `W52LB_FLUTTER` pointing to the existing `flutter.bat`; run `node tool/production_public_client/rehearse.mjs`. The pinned cached image and reviewed local PostgREST binary source container must already be available. These commands restore local copies only; they load no Production config or credential. Tests stop their containers and remove the ephemeral relay fixture; remove only those stopped task containers before repeating a fresh restore. Detailed responses remain outside Git. Check `node --test tool/production_public_client/package.test.mjs tool/production_public_activation/package.test.mjs` separately.

## Exact future signed public build recipe

Run only in the later approved build wave, from the accepted integrated source. Existing owner signing properties and keystore must remain outside every checkout. The current external signing mechanism validates the pinned certificate/private key; it has no debug-key fallback. Version allocation and release artifact freeze belong to that later wave.

```powershell
$productionConfig = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'EsnaftaVar\production\production_client_config.json'
if (-not (Test-Path -LiteralPath $productionConfig -PathType Leaf)) { throw 'External Production config missing' }
if ([string]::IsNullOrWhiteSpace($env:ESNAFTAVAR_SIGNING_PROPERTIES)) { throw 'Set the existing external signing-properties path; never enter passwords here' }
if (-not (Test-Path -LiteralPath $env:ESNAFTAVAR_SIGNING_PROPERTIES -PathType Leaf)) { throw 'External signing properties missing' }

dart run tool/production_release_preflight.dart --mode=release "--config=$productionConfig" --target=lib/main_production.dart
if ($LASTEXITCODE -ne 0) { throw 'Production config preflight failed' }

flutter build apk --release --flavor production --target lib/main_production.dart "--dart-define-from-file=$productionConfig" --dart-define=ESNAFTAVAR_PRODUCTION_CANONICAL_PUBLIC=true --dart-define=ESNAFTAVAR_PRODUCTION_CANONICAL_PREVIEW=false
if ($LASTEXITCODE -ne 0) { throw 'Signed public APK build failed' }

flutter build appbundle --release --flavor production --target lib/main_production.dart "--dart-define-from-file=$productionConfig" --dart-define=ESNAFTAVAR_PRODUCTION_CANONICAL_PUBLIC=true --dart-define=ESNAFTAVAR_PRODUCTION_CANONICAL_PREVIEW=false
if ($LASTEXITCODE -ne 0) { throw 'Signed public AAB build failed' }
```

Only the external Production manifest supplies URL/publishable key/Auth callback configuration. No key, password, token, UID or absolute personal path appears here. Build does not connect to the database and does not require activation during compilation. Runtime requires public publication plus installed 0015; until then the resulting public build deliberately shows controlled unavailability. No APK/AAB was built or frozen in W52L-B. Physical public-device smoke and store acceptance remain later release checks.

## Result

See the final validation JSON for exact task result keys, test counts, hashes and execution timestamps. Code shared with other work is limited to Production bootstrap, dependency wiring, canonical runtime capability, category state mode and the factored product repository. No UI redesign, dependency upgrade or backend live action is included.

Final verification: **2177 PASS / 0 FAIL / 6 existing SKIP**, analyzer PASS; public-define targeted **43 PASS**, real Flutter/PostgREST **3 PASS**, backend package **13 PASS**, and four real metadata/grant drift rejections PASS. New facade seal: `ad0d1c6c51ac2d2bd064df78f099d2659fc4575949d529e10ffc4f4bdc595a69`.

```text
W52L_B_PUBLIC_CANONICAL_CLIENT: PASS
PRODUCTION_PUBLIC_RUNTIME_IMPLEMENTED: PASS
PUBLIC_CAPABILITY_VERIFIER: PASS
PUBLIC_TAXONOMY_ADAPTER: PASS
PUBLIC_PRODUCT_CONTRACT: PASS
ADDITIVE_BACKEND_FACADE_READY: PASS
PRODUCT_LISTING_PUBLIC: PASS
PRODUCT_DETAIL_PUBLIC: PASS
SELLER_COMPARISON_PUBLIC: PASS
SHOP_DETAILS_PUBLIC: PASS
SEARCH_PUBLIC: PASS
NO_LEGACY_FALLBACK: PASS
NO_DEVELOPMENT_FALLBACK: PASS
NO_PRIVATE_PREVIEW_REQUIREMENT: PASS
PUBLIC_OFF_FAIL_CLOSED: PASS
LEGACY_CLIENT_AFTER_LOCAL_ACTIVATION: PASS
REAL_COPY_PUBLIC_ACTIVATED_INTEGRATION: PASS
ANALYZER: PASS
FINAL_PUBLIC_BUILD_RECIPE_READY: PASS
ADDITIVE_BACKEND_FACADE_REQUIRED: YES
ELIGIBLE_PRODUCTS: 14/14
GATED_PRODUCTS_EXCLUDED: 6/6
FULL_FLUTTER: 2177 PASS / 0 FAIL / 6 existing SKIP
PRODUCTION_ACCESSED: NO
PRODUCTION_WRITE_PERFORMED: NO
READY_FOR_PUBLIC_FACADE_DEPLOY_DECISION: YES
READY_FOR_FINAL_PUBLIC_BUILD: YES
0012_CHANGED: NO
```
