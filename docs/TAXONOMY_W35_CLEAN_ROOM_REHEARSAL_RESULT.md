# Wave 35 — Clean-Room Taxonomy Migration Rehearsal Result

Status: **PASS — LOCAL POSTGRESQL-WASM + CROSS-ENGINE REHEARSAL**
Base: `origin/main@737cadd0a662b338a63ab51412c87b1520282d26`

## 1. Safety and environment

- Supabase remote, Development, Production, Auth, Storage, and Realtime access:
  **none**.
- Network operation performed: only the task-required Git `fetch origin`.
- Primary database: disposable in-memory PostgreSQL 18.3 via PGlite 0.5.5.
- Primary runtime: Node.js `24.19.0`.
- Independent cross-check: Python `3.12.13` + SQLite `3.53.1`.
- Native PostgreSQL/Supabase CLI/Docker/Podman/WSL: **not available**.
- PGlite came from an already-local cache; no package download/install occurred.
- Rehearsal database and UUIDv4 values: temporary and deleted after the run.
- Production stable-ID allocation manifest: **not generated or committed**.

The existing repository PGlite validator also replayed all nine active
migrations and returned 23 public tables plus the expected review/storage
contracts.

## 2. Source validation

| Measure | Result |
|---|---:|
| Canonical nodes | 1,563 |
| L1 / L2 / L3 / L4 | 24 / 244 / 1,096 / 199 |
| Terminal leaves | 1,245 |
| Unique planning keys | 1,563 |
| Missing parent | 0 |
| Orphan | 0 |
| Cycle | 0 |
| L5 | 0 |
| Legacy locators | 651 |
| Successor edges | 1,000 |
| Split locators / split successor edges | 210 / 591 |
| Alias locators | 651 |
| Alias target edges | 1,000 |

## 3. Current-schema and representative data

The harness reconstructed category/product/shop-listing FKs and delete rules,
plus representative review, wishlist, Cart V2, and verified transaction item
dependencies.

Synthetic baseline:

- 11 legacy categories;
- 13 products;
- 13 listings;
- one shop;
- one review, wishlist, cart item, and verified transaction item.

The 13 product roles cover all required actions and two demo-like listings. No
real PII or remote identifier was used.

## 4. Forward migration runs

Two complete forward runs passed on PostgreSQL-WASM. Each run also performed a
second import inside the same transaction to test idempotency. The independent
SQLite harness produced the same structural and disposition counts.

| Measure | Run 1 | Run 2 |
|---|---:|---:|
| Canonical nodes | 1,563 | 1,563 |
| Active safe candidates | 313 | 313 |
| Assignable safe leaves | 247 | 247 |
| Legacy locator coverage | 651 | 651 |
| Successor edges | 1,000 | 1,000 |
| Split locators / edges | 210 / 591 | 210 / 591 |
| No-target history rows | 32 | 32 |
| Relationship rows including no-target | 1,032 | 1,032 |
| Legacy alias locators | 651 | 651 |
| Controlled search synonyms | 3 | 3 |
| Alias target edges | 1,000 | 1,000 |
| Policy/professional leakage | 0 | 0 |

The allocation-ledger checksum stayed identical across both cycles inside each
clean room. Already seeded planning keys did not receive new IDs.

PostgreSQL RLS checks:

- anon-visible canonical categories: exactly 313 safe active nodes;
- direct anon access to all four allocation/alias/relationship administrative
  taxonomy tables: denied;
- regulated/legal-review/professional-review active leakage: zero.

## 5. Product reassignment

Each forward run produced:

| Disposition | Count |
|---|---:|
| Automatic safe one-to-one | 6 |
| Reviewed exact split successor | 1 |
| Manual review quarantine | 2 |
| Policy review quarantine | 2 |
| Retire/out tombstone quarantine | 2 |
| Total quarantined | 6 |
| Total representative products | 13 |

The undecided split product remained on its original synthetic category and was
excluded by active quarantine. No first-child or nearest-name mapping occurred.

## 6. Alias and redirect behavior

Passed cases:

- old slug/name exact redirect;
- rename and moved-path evidence;
- merge alias;
- split ambiguity without direct target;
- retire/out tombstones;
- unresolved alias;
- controlled search synonym as a separate alias kind.

### Draft problem found and fixed

The Wave 34 draft's mandatory single alias target could not represent 210 split
aliases or 32 no-target records. The docs-only draft was hardened to use one
alias locator plus zero/one/many target edges and explicit resolution state. The
registry action was also aligned to the source enum `OUT`, and a hierarchy
trigger draft was added.

The hardened draft remains under `docs/sql/`, retains its abort guard, and was
not moved into `supabase/migrations/`.

## 7. Rollback rehearsal

Two complete PostgreSQL-WASM rollback runs and two independent SQLite rollback
runs passed.

| Check | Run 1 | Run 2 |
|---|---:|---:|
| Product mapping mismatch | 0 | 0 |
| Dangling product category FK | 0 | 0 |
| Relationship/history rows preserved | 1,032 | 1,032 |
| Tombstone/no-target rows preserved | 32 | 32 |
| Canonical active after rollback | 0 | 0 |
| Canonical assignable after rollback | 0 | 0 |

Products, listings, reviews, wishlist, cart, and verified evidence retained
their baseline counts. The 1,563 canonical rows intentionally survived as
staged/inactive history instead of being destructively deleted.

## 8. Failure injection

All ten injections passed on PostgreSQL-WASM and independently in SQLite:

| Injection | Result |
|---|---|
| Missing parent FK | PASS |
| Duplicate slug | PASS |
| Category cycle | PASS |
| Invalid L5 level | PASS |
| Unknown policy enum | PASS |
| Split without product decision | PASS — quarantine |
| Orphan manifest parent | PASS |
| Duplicate alias locator | PASS |
| Bad product category FK | PASS |
| Mid-migration exception | PASS — transaction rollback, no partial marker |

Final `foreign_key_check` returned zero rows.

## 9. Local query sanity

Each query ran 30 times on local PostgreSQL-WASM. These are local query sanity
measurements, not managed Supabase or Production performance claims.

| Query | Rows | Median ms | P95 ms |
|---|---:|---:|---:|
| 24 structural roots | 24 | 0.4080 | 0.7359 |
| Children | 14 | 0.3243 | 0.4288 |
| Descendants | 88 | 1.5187 | 1.9075 |
| Breadcrumb | 2 | 0.4672 | 0.7875 |
| Products in descendant scope | 5 | 1.4509 | 2.1223 |
| Alias lookup | 1 | 0.6472 | 0.9851 |

## 10. Remaining Development unknowns

The following remain mandatory before any Development migration apply:

1. separately authorized read-only Development schema/data/migration profile;
2. managed Supabase version/extension/grant and query-plan reconciliation;
3. Development backup and proven restore point;
4. actual product mapping inventory and manual/policy quarantine queue;
5. final public product/listing projection or RPC policy contract;
6. client compatibility implementation and regression tests before activation;
7. explicit Development migration authority.

This local run closes the PostgreSQL clean-room engineering gate but does not
replace the live read-only preflight, backup, real-data mapping, or activation
gates.

## 11. Result flags

`LOCAL_CLEAN_ROOM_CREATED: PASS`

`FULL_CANONICAL_IMPORT: PASS`

`LEGACY_BRIDGE_REHEARSAL: PASS`

`SPLIT_REASSIGNMENT_MODEL: PASS`

`POLICY_FAIL_CLOSED: PASS`

`ROLLBACK_REHEARSAL: PASS`

`IDEMPOTENCY_REHEARSAL: PASS`

`FAILURE_INJECTION: PASS`

`REMOTE_ACCESS_PERFORMED: NO`

`READY_FOR_DEVELOPMENT_MIGRATION_AFTER_LIVE_PREFLIGHT: YES`

Scope of `YES`: additive/staged Development migration after the live preflight,
backup/restore, drift reconciliation, and explicit apply authorization pass.
Public activation remains **NO** until client and policy gates pass.
