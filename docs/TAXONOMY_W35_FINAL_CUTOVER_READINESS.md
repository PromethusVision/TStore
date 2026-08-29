# Wave 35 — Taxonomy Development Cutover Readiness

**Date:** 2026-08-29

**State:** `PASS — READY FOR A SEPARATELY AUTHORIZED DEVELOPMENT BOOTSTRAP TASK`

**Runtime state:** `PREPARED BUT NOT WIRED / TAXONOMY NOT ACTIVE`

This document reconciles the live Development read-only preflight, disposable
local migration rehearsal, and backward-compatible Customer client preparation.
It does not authorize a Development write, create an active migration, allocate
runtime UUIDs, activate taxonomy nodes, or grant any Production authority.

## 1. Integrated evidence

| Source | Final HEAD | Integration merge | Result |
|---|---|---|---|
| Development read-only preflight | `7e622d3ddb378aeadbaa8c9d602d73c7f745aea9` | `a41f86a` | PASS |
| Local clean-room rehearsal | `aef1639eb7fc3ce9bebd7cc57695c2f2cbf35566` | `4c0ccc5` | PASS |
| Customer variable-depth preparation | `544b7882ebd2525632a9431ea2a911165dad8687` | `a7dc332` | PASS |

Integration base was `origin/main@737cadd0a662b338a63ab51412c87b1520282d26`.
All three sources merged normally with `--no-ff` and without conflict.

## 2. Cross-source reconciliation

| Question | Reconciled result |
|---|---|
| Exact Development | `EsnaftaVar Development` / `tnipyxnvhgelwdpykyez`; Healthy after the previously authorized resume. |
| Live schema | 9/9 canonical migration names, 23 public tables, RLS 23/23, 52 policies, 29 public functions. |
| Live application data | All 23 public application tables empty; categories/products/shops/listings `0/0/0/0`. |
| Storage | Three canonical buckets, zero objects. |
| Existing category UUID preservation | Zero current category rows, therefore zero current UUIDs to preserve. |
| Product/split/manual migration load | Products zero; 210 split locators and all 24 unresolved legacy locators have zero live Development impact. |
| Static canonical graph | 1,563 nodes; L1/L2/L3/L4 `24/244/1096/199`; 1,245 leaves. |
| Legacy bridge | 651/651 locators and 1,000/1,000 successor edges; 210 splits / 591 split edges. |
| Local database rehearsal | PGlite/PostgreSQL-WASM PASS and independent SQLite cross-check PASS. |
| Forward / rollback / idempotency | `2/2`, `2/2`, PASS. |
| Failure injection | `10/10 PASS`; arbitrary first-child split mapping `0`; policy leakage `0`. |
| Client preparation | L1–L4, container/leaf, root/children/descendants/breadcrumb, exact-leaf/descendant scopes and fallback PASS. |
| Current runtime behavior | Unchanged. No repository, PostgREST, DI, navigation or backend-column cutover wiring was added. |
| Native recovery | Free plan has no scheduled backup, PITR, restore-to-new-project, or native restorable point. |
| Production | Not accessed by Source A and not touched by this integration. |

No concrete taxonomy-facing drift invalidates the clean-room model. The live
ledger version-stamp lineage difference for migrations `0001`–`0008` and the
platform-managed `public.rls_auto_enable()` function remain documented. The
rehearsal is representative of the taxonomy-sensitive schema and empty data
baseline; it is not a claim that PGlite is the managed Supabase service.

## 3. Stable identity contract

The Product Owner decision is final:

1. surviving semantic identity preserves the existing `categories.id` UUID;
2. a genuinely new node receives a trusted, backend-controlled UUIDv4;
3. rename or semantic-preserving move preserves UUID;
4. split uses explicitly allocated successor UUIDs and never an arbitrary child;
5. merge preserves predecessor/successor history;
6. retired IDs remain tombstones and are never reused;
7. planning keys, names, slugs and paths are not runtime identity.

Development currently has no category rows. Its initial canonical bootstrap will
therefore allocate predominantly new UUIDv4 values. No runtime UUID was allocated
or committed during this integration.

## 4. Empty Development bootstrap risk

`EMPTY_DEVELOPMENT_BOOTSTRAP_RISK: ACCEPTABLE_FOR_A_SEPARATE_BOUNDED_AUTHORIZATION`

The lack of a native backup is not irrelevant and is not treated as a PASS. It is
materially different from a Production data migration because Development has no
application rows, no category/product/shop/listing data and no Storage objects.
Within the taxonomy application-data/schema scope, the empty environment can be
reconstructed from:

- the repository's canonical `0001`–`0009` migration chain;
- the future reviewed active taxonomy migration;
- the 1,563-node canonical manifest and 651/1,000 legacy bridge artefacts;
- a reviewed, versioned planning-key-to-UUIDv4 allocation ledger;
- reviewed seed/import manifests and rehearsal scripts.

This is an empty-Development reconstruction strategy, not a Production analogy
and not proof of Supabase native restore. It does not assert that every managed
project setting or external secret is restorable from Git. The next task must
record owner acceptance of this bounded recreation strategy and stop if a fresh
pre-apply check finds any application data or material drift.

## 5. Migration rehearsal review

- `docs/sql/TAXONOMY_W34_MIGRATION_DRAFT.sql` remains under `docs/sql`; no file was
  added to `supabase/migrations` and the active chain remains exactly `0001`–`0009`.
- The guarded draft was not executed as-is. The PGlite harness removed the guard
  only in memory and exercised the resulting SQL in a disposable local database.
- The rehearsal scripts import no network, Supabase, HTTP or remote database
  client. UUIDv4 values are ephemeral local fixtures; no Production/runtime UUID
  manifest is committed.
- Alias resolution retains `RESOLVED`, `AMBIGUOUS`, `TOMBSTONE` and `UNRESOLVED`
  states with a separate zero/one/many target-edge table.
- Apply-twice idempotency, two forward cycles, two rollback cycles, ten failure
  injections, quarantine and transaction rollback guards remain present and pass.
- Policy-sensitive/professional-review nodes remain fail-closed.

## 6. Customer code review

- New code is a pure domain abstraction and is referenced only by its tests.
- Existing `CategoryModel`, repository queries, Home source, Cubit/DI wiring and
  navigation remain unchanged; no absent backend column is queried.
- Current-runtime fallback preserves the existing exact category filter and marks
  that it has no canonical hierarchy evidence.
- Canonical and legacy ID mismatch fails closed.
- Runtime taxonomy paths or names are not hard-coded. The 24 canonical L1 labels
  and long Turkish labels exist only as contract/stress fixtures.
- The Home change is a narrow functional overflow/tap regression test; it does not
  introduce UI Kit redesign or cosmetic scope.
- Integration validation: targeted hierarchy/Home `24/24 PASS`, full suite
  `1243 PASS / 0 FAIL / 6 explicit live skips`, analyzer `0 issues`.

## 7. Development write readiness

The evidence is sufficient for the Product Owner to authorize a separate,
Development-only, single-writer bootstrap implementation task. It is not ready
for an immediate remote apply. That task must complete these prerequisites before
its first remote mutation:

1. receive explicit Product Owner authorization scoped to exact Development ref
   `tnipyxnvhgelwdpykyez` and accept the empty-environment recreation strategy;
2. create and review a production-style, versioned UUIDv4 allocation manifest for
   the Development bootstrap without deriving IDs from names/slugs/paths;
3. generate one active migration from the hardened draft and reviewed payloads,
   keeping a single SQL/migration owner;
4. rerun exact identity, ledger/hash, zero-row, drift and single-writer pre-apply
   gates immediately before apply;
5. freeze the exact backend schema/RLS/RPC and client capability/cutover/rollback
   sequence.

Because live Development has zero products, manual product reclassification and
split-product mapping do not block the initial additive schema plus staged,
inactive canonical import. The 18 anchor-only assignability decisions and all
policy/professional review gates can also remain fail-closed during staged
existence. They do block public activation or assignability until explicitly
resolved. Client wiring and taxonomy activation remain separate later gates.

`READY_FOR_DEVELOPMENT_WRITE_AUTHORIZATION: YES`

Scope of `YES`: a separately authorized Development-only implementation/bootstrap
task with the five mandatory pre-write prerequisites above. It does not mean
`READY_FOR_REMOTE_APPLY_NOW`, which remains **NO**.

## 8. Safety ledger

- New Development remote access during integration: **NO**.
- Development remote write during integration: **NO**.
- Production access/write during integration: **NO**.
- Migration apply: **NO**.
- Active migration created: **NO**.
- Runtime UUID allocated: **NO**.
- Taxonomy activated or wired: **NO**.
- Figma/UI Kit/demo data changed: **NO**.

`W35_CUTOVER_READINESS_INTEGRATION: PASS`

`LIVE_DEVELOPMENT_PREFLIGHT: PASS`

`LOCAL_MIGRATION_REHEARSAL: PASS`

`CUSTOMER_VARIABLE_DEPTH_PREP: PASS`

`EMPTY_DEVELOPMENT_BOOTSTRAP_RISK_ACCEPTABLE_FOR_NEXT_AUTHORIZATION: YES`

`READY_FOR_DEVELOPMENT_WRITE_AUTHORIZATION: YES`

`REMOTE_WRITE_PERFORMED: NO`

`PRODUCTION_TOUCHED: NO`

`TAXONOMY_RUNTIME_ACTIVE: NO`
