# W52K-B — Production canonical private preview bridge

The additive private preview bridge and Flutter adapter are implemented and
rehearsed on an isolated real Production backup. Public clients retain the
legacy runtime. Public canonical activation is not needed and remains OFF.
No live Production or Development connection, live write, or APK/AAB build was
performed in this wave.

Base: `a1acc9fe626ae3add5109d73190603bb808718af`.
Branch: `astra-release/w52k-b-production-canonical-preview-bridge`.
Production project identity: `mefhfvrgkwciubeajjeb`.
This report concerns readiness for a separate Production write decision, not
evidence that the new bridge is already deployed.

## Identity and authorization

Discovery found existing Supabase Auth sessions, signed JWT subject/role,
profile roles, and the ordinary login/logout flow. The staged 0012 preview flag
is global and disabled. There was no suitable per-tester server allowlist.
Profile/user metadata and a local build flag cannot authorize this preview.

0013 adds `production_preview_private.testers`: Auth user UUID primary key and
foreign key, `enabled=false` by default, grant time and mandatory expiry. A
lease must be positive and at most 30 days. The schema/table are inaccessible
to PUBLIC, anon, authenticated and service_role; table RLS has no client policy.
The migration creates an empty allowlist. Only a separately authorized database
operator can provision a specific tester UID, enable it and set its expiry.
This wave has not authorized any live account.

Every exposed preview RPC requires a signed authenticated session and a matching
enabled, unexpired server membership. JWT signature validation belongs to the
existing Supabase/PostgREST authentication boundary. The RPC uses `auth.uid()`
and `auth.role()`; it ignores caller metadata claiming preview permission.
Anonymous requests, ordinary authenticated users, spoofed metadata, invalid
signatures, revoked testers and expired testers were denied on the local copy.

Threat model: an attacker may copy the APK, change its flag, call RPCs directly,
know category UUIDs, or edit their own profile metadata. None grants membership.
An authorized tester can read staged taxonomy and reviewed mappings. A stolen
authorized session has the tester's read access until session/membership expiry
or revocation; no static privileged key is introduced. The database operator
and existing JWT verifier are trusted boundaries. This bridge adds no canonical
write RPC and no Auth/Storage mutation endpoint. Login/logout reuse existing
application services.

## Server contracts

New artifact: `20260919001300_0013_production_canonical_private_preview.sql`.
0012 and the sealed W52J-B/C execution bundle remain unchanged. 0010/0011 are
neither applied nor represented as applied in Production.

| Operation | Contract |
| --- | --- |
| Capability | `taxonomy_capabilities_v2` |
| Roots / children / descendants | `taxonomy_roots_v2`, `taxonomy_children_v2`, `taxonomy_descendants_v2` |
| Breadcrumb / qualified leaf | `taxonomy_breadcrumb_v2`, `taxonomy_exact_leaf_v2` |
| Search / aliases | `taxonomy_search_context_v2`, `taxonomy_resolve_alias_v2` |
| Exact owner mapping review | `production_preview_mappings_v1` |
| Product listing / scope / detail | `production_preview_products_v1` |

The facade reuses frozen 0012 DTO/hierarchy semantics and presents the existing
Flutter `taxonomy-client-v1`, `canonical-v1.0.0`, `taxonomy-rpc-v2` contract.
It does not forward to the globally disabled legacy preview switch. Instead,
private identity authorization is evaluated for each read. All 15 functions are
STABLE with fixed `search_path=pg_catalog,public`. The five internal helpers
have no client EXECUTE grant. Only the ten facade operations grant EXECUTE to
authenticated, then check membership. Anonymous EXECUTE is revoked. No existing
RLS policy, grant or legacy function is relaxed.

Capability additionally proves `preview_authorized=true`, current subject,
exact project ref, `public_enabled=false`, bridge version
`production-private-preview-v1`, and exact product RPC identity. Its
`preview_enabled=true` is a caller-scoped capability, not the stored global
flag. The stored public and preview activation flags remain false. The guard
requires both flags OFF and fails if public activation is attempted. It also
requires the frozen 20 mapping rows and complete coverage of existing products.

The mapping endpoint returns all 20 exact owner mappings, including eligibility
metadata for six review-gated mappings. Product reads expose the 14 eligible
products and withhold those six. Preview assignability is a computed projection
of staged leaf qualification plus all ancestor policy/professional gates; no
stored lifecycle/assignability/approval is updated. Product scope uses server
UUID joins and hierarchy traversal. There is no name/index guessing or client
translation. Product JSON carries canonical `category_id`, retained
`legacy_category_id`, canonical category name and unchanged product identity.

The product endpoint is SECURITY INVOKER, preserving products/brands RLS. A
temporary restrictive policy on the isolated copy hid an otherwise eligible
product, proving the facade did not bypass RLS. UUID/type, paging, sort, exact
leaf, visibility and mapping checks fail closed. Home rating sorting and each
eligible exact-leaf product scope passed real HTTP checks.

## Flutter adapter and accepted UI

`main_production.dart` keeps legacy as its default. The explicit
`ESNAFTAVAR_PRODUCTION_CANONICAL_PREVIEW` opt-in selects a private access gate;
it grants no server authorization. Configuration must be Production and the
exact approved project before Supabase initialization. No Development fallback
is possible through this path.

`ProductionPreviewTaxonomyAdapter` extends the existing canonical RPC adapter.
It validates the complete capability and current subject before DI selects
the existing canonical repository, category cubit and domain models.
`ProductionPreviewProductRepository` uses the one stable server projection for
listing and detail and also implements the existing taxonomy-scoped interface.
Capability/data errors never report a legacy fallback as preview success.

The gate uses the existing login screen. Missing/denied capability displays a
controlled light-theme diagnostic with retry/account switch. Logout/account
changes remove the application, routes and cached cubits before configuring a
new identity. Responses arriving for a previous identity are rejected. A small
AuthCubit disposal guard prevents an in-flight sign-out from emitting after
the gate has closed that cubit. Category/brand reads also discard late responses
after disposal. Every Auth event invalidates the adapter's authorization
generation, including re-login as the same user; old capability and data
responses cannot cross that boundary.

Real-copy payloads passed the existing Flutter domain parsing and category
cubit, including 24 roots, L2/L3/L4, breadcrumb, exact leaf, descendants,
search/alias and canonical product details. Widget verification rendered the
existing Home limit of eight and the All categories list of 24. Category icon
V1, light-only pilot, contrast fixes, Reward V1 and Cart V2 semantics were not
redesigned. Seller Comparison and Shop Details continue using unchanged product
IDs and existing legacy relationships, verified on the real copy. The custom
24-category visual pack remains deferred.

## Real Production copy and rollback evidence

Newest available local archive:
`<USER_HOME>/EsnaftavarBackups/w52j-live-retry/EsnaftaVar-Production-W52J-RETRY-20260919T000554886Z.dump`.
Completed 2026-09-19T00:06:07.492Z, 537274 bytes, CUSTOM format, pg_dump 17.11,
source PG17.6. SHA-256:
`8d98258430fbb7eeccc8ead4e09efa59189aad84e961bb754fe223f07c3fcbc8`.

This is the latest pre-0012 backup, not a claimed post-0012 dump. All 958 TOC
entries and all 69 table-data sections were restored, including roles,
ownership/ACLs, database settings and ICU locale. The unchanged sealed engine
then reconstructed current staged 0012 on that copy. No synthetic category or
product dataset substituted for the archive. Only two disposable local Auth
identities were fixtures, removed before final integrity checks.

Pinned PostgreSQL image:
`supabase/postgres@sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00`.
Isolation: local Docker named pipe, network none, zero exposed ports, read-only
archive mount. Local PostgREST ran on container loopback using random ephemeral
test signing material. No Production credential was loaded.

Final database rehearsal: 2026-09-19T01:21:20.271Z–01:22:40.159Z, PASS.
Authorized: 24 roots, L2/L3/L4, breadcrumb, search/alias, exact 20 mappings,
14 eligible products / six safely gated, and per-product detail checks.
Anonymous, normal authenticated and metadata-spoofing users were denied on
every one of the ten operations. Eight legacy HTTP contracts for each of anon
and authenticated retained identical responses before/after apply and rollback.

Rollback removed only the new 15 functions, private table/schema and exact
0013 ledger row. The complete 0012 catalog, ledger, canonical data, mappings and
legacy data snapshot matched before/after. All 69 original archive table-data
checks passed (the archive predates 0012, whose ledger row is separately
preserved and compared). Remaining counts: 4 legacy categories, 20 products,
285 listings, 57 shops, 1563 canonical nodes, 24 roots, 1245 terminal leaves,
20 mappings; no orphans or broken parent chains.

| Frozen artifact | SHA-256 (SQL normalized to LF) |
| --- | --- |
| Unchanged 0012 source | `a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834` |
| Unchanged recorded execution bundle | `f491e08aae3241f218fa2d3bced6ea05ff68d2fa46589d5892f77b62f0ee0cf0` |
| New 0013 | `9b56e249a6e3054b8303742ca4bcc41d40e216de9c1a62a72193e4bae81091a4` |
| Preview-only rollback | `fa138b7d9c42086323e10ef9e05985bc71f65357fc3c4a81e38dbdaab52104d4` |

**Existing bundle-inventory finding:** every file listed in the recorded
W52J-B/C seal still matches its frozen hash, as do 0012 and its reviewed payload.
However, the old `verifyBundle` utility expands a broad evidence-file glob.
Required base main already includes
`docs/data/w52k_a_canonical_production_rc_validation.json`, an extra evidence
document absent from that older seal. Therefore that utility's dynamic inventory
comparison currently fails on main. This was not introduced by W52K-B. The local
rehearsal called the unchanged engine directly on the isolated copy; no live CLI
ran or bypassed a seal. No engine, seal, historical evidence or 0012 was edited
to suppress this finding. A future authorized 0013 deployment needs its own
reviewed execution package and must not bypass the old live seal gate.

## Failure and automated checks

Fourteen server failure families passed: anonymous, normal authenticated,
spoofed metadata, invalid JWT signature, root used as exact leaf, wrong contract,
public-mode request, invalid UUID, unknown category, revoked tester, expired
tester, missing mapping, public activation conflict, and bridge unavailable
after rollback. Public activation OFF is the required successful private mode;
a public-mode request or incompatible activation state is rejected.

Eight additional client failure families passed: missing capability,
Development/wrong-project config, forged capability subject, incompatible
capability fields, logout/account change, stale capability response, stale
product response, and missing/malformed product mapping. Total: **22 named
failure families**, with 30 unauthorized HTTP denials across the first three
server families alone.

The original migration tests assumed a single 0001–0011 Development chain.
They now retain all original assertions for that chain, plus an exact inventory
covering every file and separate Production tests. The Production tests freeze
0012's hash and verify additive 0013, exact functions, allowlist, fixed paths,
grants and exact rollback. No assertion or test was removed and no skip added.
The already-resolved `crypto` 3.0.7 package is declared as a direct test
dependency for the immutable 0012 hash check; no package version was upgraded.

Final full Flutter suite: **2134 PASS / 0 FAIL / 6 documented SKIP**.
Analyzer: **PASS — no issues**. Metrics and named skipped tests are recorded in
`docs/data/w52k_b_preview_bridge_validation.json`. The six existing live-only
checks remain opted out; no Development service was contacted.
The five explicitly invoked real-copy Flutter checks passed separately from the
normal suite. Private captures, raw test logs and backup contents stay outside
Git. Four stopped task-only rehearsal containers were removed after validation;
the original archive and prior source container were preserved. Tracked
evidence contains counts/hashes/status only, no actual client key,
token, DB/signing password, private key, personal identity or absolute local
user path. No APK/AAB is included.

## Next decision and limits

Ready for Product Owner review of a controlled preview-bridge Production write
plan. That future operation must separately authorize live access/write,
revalidate identity and staged baseline, take a fresh backup, deploy only 0013
with atomic ledger handling, and authorize a real tester UID with expiry.
The rollback artifact must be bound to that same reviewed deployment.

**Not ready for a canonical RC build yet.** W52K-C follows deployment and its
authorized validation. This wave supplies local database, HTTP, Flutter and
widget evidence; it is not a live Supabase gateway or physical-phone test of
the new bridge. Main has not been merged, and public activation remains OFF.
