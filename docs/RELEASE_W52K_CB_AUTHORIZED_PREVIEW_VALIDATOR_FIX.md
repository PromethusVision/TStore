# W52K-CB authorized preview response-shape fix

**PASS — package ready for a separately authorized live retry. No live Production or Development access occurred.**

The capability validator now accepts exactly one JSON object inside a JSON list. The live executor's existing HTTP preview gate calls this validator, so deployment/postflight and the isolated rehearsal share the same parsing and semantic checks. Bridge SQL, Stage A/B, identity/expiry, containment/rollback, 0012, taxonomy and Flutter/client code are unchanged.

## Exact failure and correction

The previous external `<LOCAL_RUNTIME>/w52k-live-final-runtime/supplemental.mjs` checked `capability.body?.preview_authorized` as if the body were an object. `GET /rest/v1/rpc/taxonomy_capabilities_v2` returns HTTP 200 and a one-element JSON array because its reviewed SQL returns `SETOF jsonb`. The current client already requires a one-row List. The extra parser caused the false failure recorded in commit `b46e04241ec0a7f817dd32fc3ed0307b42dc353d`.

The corrected sealed validator requires HTTP 200, a list with exactly one plain object, the exact reviewed field set and scalar types/values, matching runtime subject and project, client/taxonomy/RPC versions, authorized private preview, public activation OFF, 24 preview roots, zero public/pilot roots, expected capability/evidence sets and the existing product-scope contract. Missing/unknown fields, malformed rows, duplicate/missing/unknown features and ambiguous multiple rows fail closed. No returned subject is included in evidence.

The former external parser is superseded and kept only as historical evidence. A future runner must use the corrected sealed `client.preview(db,true)` gate (or its exported `validateAuthorizedPreview` function) and must not rerun the old object-only expression. No backend or client workaround is needed.

## Quality and unchanged security

- Validator regressions: **90/90 PASS**, including the previous false failure, valid one-row response, forbidden multi-row/empty/object responses, malformed types, unauthorized/error statuses, wrong versions/project/subject, public ON and capability semantics.
- Current live package/security tests: **33/33 PASS**. Total required offline checks: **123/123 PASS**. Integration tests prove the real HTTP preview path invokes the new validator.
- Additional archived BX package suite: **14/15**, with `W52JB_BX_SEALED_INPUT_DRIFT`. The same failure was reproduced on the authoritative main runtime. This is an existing archived-package manifest mismatch; no test or unrelated manifest was altered.
- Existing SQL, Stage A/B, expiry, RLS/security, rollback and client files are byte/content unchanged against main. Of the old 38 seal inputs, only `live_v2/http.mjs` changes; the new validator adds one input. All other 37 inputs are unchanged.
- `git diff --check`, seal verification and secret/PII scan pass. Flutter analysis/tests are not needed because no client code changed.

## Real backup selection — explicit limitation

The newest available full archive (completed 2026-09-19 18:47:49 UTC, SHA-256 `97dfe3451c56946b4bcf81040d265c9d5909c57602c1d07da961ba1931f18626`, 1,333,576 bytes, 1,066 TOC entries / 78 data sections) was first restored into a fresh network-disabled PG17.6 copy. It stopped before bridge application at `W52JB_SCHEMA_FINGERPRINT_APPLIED_RELATIONS`.

A read-only differential against the previously captured, hash-pinned catalog found exactly two differences: `canonical_categories` and `canonical_category_qualification` restored with null ACL metadata instead of the explicitly stored owner-only ACL. The unchanged strict fingerprint rejects that representation. No SQL repair, grant change, fingerprint relaxation or new normalization was introduced to make it pass.

The complete rehearsal therefore used the newest **suitable** real archive supported by the unchanged restore method: completed **2026-09-19 00:06:07.493 UTC**, PostgreSQL 17.6 / pg_dump 17.11, **537,274 bytes**, SHA-256 `8d98258430fbb7eeccc8ead4e09efa59189aad84e961bb754fe223f07c3fcbc8`. All 958 TOC entries were restored; none were omitted. The existing approved isolated bootstrap applied unchanged 0012 to this pre-0012 copy and reconstructed only the previously reviewed local platform metadata. Both original backups remained unchanged.

## Complete fresh isolated rehearsal

One complete successful fresh PG17.6 rehearsal used a pinned image, network mode `none`, no exposed ports and a read-only backup mount. Parent-process network fetches were also disabled. Auth identities and signatures were synthetic and local only.

Sequence passed: preflight → Stage A → committed default-deny for anonymous, non-listed and tester → separate Stage B → corrected authorized capability parsing → 24 roots / L2-L4 / breadcrumb / search-alias / 20 mappings and product scope → unauthorized/expired denial → legacy/security checks → exact tester removal → containment-first bridge rollback → final validation.

The real local PostgREST capability response was validated as `SINGLE_ITEM_JSON_ARRAY`, one row, correct subject/contract, preview authorized, public OFF and 24 roots. Product scope remained 14 eligible products and 6 gated mappings.

Final counts: 20 products, 285 listings, 57 shops, 1,563 canonical nodes, 24 roots, 1,245 terminal leaves, 20 mappings; orphan products/listings 0/0. Legacy HTTP results before/after were identical, and all 69 source data sections matched after synthetic-user cleanup. Rollback returned `ROLLED_BACK` with `core_health=PASS`; preview access was removed. No manual SQL repair occurred. Both task-owned containers were removed.

## New seal and handoff

- Authoritative main: `5bc328c5e72199b62c754c77a20fb2490eb46bbf`.
- Branch: `astra-release/w52k-cb-authorized-preview-validator-fix`.
- New seal SHA-256: `e87a1a2b0a7eb19c0b11640c95eb617f5f1fce6fd207d0a28d900c63f6f4f2a7`.
- Runtime/security inputs: **39**. Seal verifier and unrelated sealed files are unchanged.
- Readiness concerns the corrected package. The next authorized live retry still needs current identity/session, strict Production preflight and a new pre-write backup. This task did not access or change Production, did not activate public taxonomy and did not build an APK/AAB.

## TASK_RESULT

```text
W52K_CB_AUTHORIZED_PREVIEW_VALIDATOR_FIX: PASS
ROOT_CAUSE_CONFIRMED: PASS
ACTUAL_RESPONSE_SHAPE: JSON_ARRAY_EXACTLY_ONE_CAPABILITY_OBJECT
ARRAY_RESPONSE_HANDLING: PASS
MALFORMED_RESPONSE_FAIL_CLOSED: PASS
UNAUTHORIZED_FAIL_CLOSED: PASS
PUBLIC_ACTIVATION_GUARD_PRESERVED: PASS
BRIDGE_SQL_CHANGED: NO
STAGE_A_CHANGED: NO
STAGE_B_CHANGED: NO
ROLLBACK_CHANGED: NO
0012_CHANGED: NO
REAL_PRODUCTION_COPY_REHEARSAL: PASS
AUTHORIZED_PREVIEW: PASS
ROOTS_24: PASS
RECURSIVE_L2_L3_L4: PASS
PRODUCT_MAPPING_20_20: PASS
PRODUCT_SCOPE: PASS
ANONYMOUS_PREVIEW_DENIED: PASS
AUTHENTICATED_NON_PREVIEW_DENIED: PASS
ROLLBACK_REHEARSAL: PASS
NEW_SEAL_READY: PASS
NEW_SEAL_SHA256: e87a1a2b0a7eb19c0b11640c95eb617f5f1fce6fd207d0a28d900c63f6f4f2a7
NEW_SEAL_INPUT_COUNT: 39
CLIENT_CODE_CHANGED: NO
PRODUCTION_ACCESSED: NO
PRODUCTION_WRITE_PERFORMED: NO
READY_FOR_W52K_B_LIVE_FINAL_RETRY: YES
```
