# Merchant A+B acceptance delivery — 2026-10-15

Baseline: `e51149ab7c204c00f798c3172bbd32fba7fa853f` (integrated Slice B).
Task branch: `agent/merchant-ab-acceptance`.
Authority/boundaries: canonical §5.2. Main merge belongs to Integration Agent.

## Outcome

The previous PGlite-only database evidence is now supplemented by **real
PostgreSQL 17.11 + pgcrypto + observed contention between independent
connections**. All 16 database groups passed. This is a synthetic local fixture
with Auth/Storage table stand-ins; managed-service acceptance remains OPEN.

No application-runtime defect was demonstrated by these checks. Therefore this
delivery adds reproducible acceptance tooling/evidence and records scope; it
does not change Flutter runtime, dependencies, navigation, Customer UI, existing
SQL migrations or product behavior. No new migration/proposal is needed.

## Evidence matrix

| Gate | Result | Evidence / boundary |
| --- | --- | --- |
| Real PostgreSQL / pgcrypto | PASS | Native PostgreSQL 17.11; extension membership plus standard SHA-256/HMAC vectors; unchanged migration bytes |
| Independent connection contention | PASS | First transaction held; second observed in `pg_blocking_pids`; committed outcomes asserted |
| QR single claim / purchase | PASS | Scan + manual code converge; double completion yields one purchase/event; exact amount and real allocation digest |
| Return bounds / idempotency | PASS | Concurrent excessive returns reject; identical retry appends once; original quantity/amount preserved |
| Access / lifecycle | PASS in native fixture | Two-session admission race, foreign shop denial, owner/role changes, stale price, cart edit/delete, deadline after lock wait, committed attempt quota, flag-off drain, terminal device revocation |
| Photo slot concurrency | PASS in native fixture | Six-slot cap serializes; foreign merchant denied |
| Managed Auth provenance / real logout | **OPEN** | Executable local HTTP suite prepared; Docker unavailable before service startup |
| Storage HTTP / fresh-session signed image | **OPEN** | Executable catalog → listing → upload → publish → fresh Customer signed download → retirement journey prepared; not successfully run |
| Flutter regressions | PASS | 227 related unit/widget/golden tests; analyzer clean |
| Harness isolation / transport | PASS | 3 tests: endpoint restrictions, container identity/binding rules, actual loopback HTTP and no redirect following |
| Physical Customer ↔ Merchant QR | **OPEN / later phase** | No physical-device acceptance claim |

Detailed, dated native proof and migration hashes:
[merchant_ab_native_acceptance.json](data/merchant_ab_native_acceptance.json).
Commands, guards, fixture provenance and reproducible setup:
[acceptance tool README](../tool/merchant_acceptance/README.md).

## Environment finding

Docker Desktop 4.91.0 fails before its Linux engine becomes available. The
current attempt reproduced Windows AF_UNIX error 1920 at
`Docker/run/sailor-ingest.sock` (cannot access/rename socket). Explorer, Windows
process launch and Shell launch comparisons did not establish a working engine.
An [upstream Codex report](https://github.com/openai/codex/issues/52698) describes
a matching MSIX/AppData virtualization failure; that is a possible cause, not a
confirmed diagnosis of this machine. No data deletion, factory reset, WSL
deregistration, reboot, permission/manifest change or remote fallback was used.
Failed Docker Desktop processes were stopped; the prior runtime backup remains.

The independently downloaded official EDB portable PostgreSQL distribution
provided the native proof without installing a Windows service. It used a fresh
random-password cluster on literal loopback and stopped after each run. Scratch
data/logs remain ignored and are excluded from the commit.

## Validation performed

- `node tool/merchant_acceptance/native.mjs <portable-bin>`: **16 groups PASS**.
- `node --test tool/merchant_acceptance/safety.test.mjs`: **3 PASS**.
- Managed acceptance command: **BLOCKED (exit 2), before any database connection** because
  the Docker engine was absent. Its journey is not labeled PASS or mocked over.
- `flutter analyze --no-pub`: **No issues found**.
- Focused Flutter run: `test/unit/merchant`, `test/unit/cart`,
  `test/unit/purchases`, `test/unit/shop/listing_hero_test.dart`,
  `test/widget/merchant`, `test/widget/cart/cart_qr_session_bottom_sheet_test.dart`,
  `test/widget/purchases`: **227 PASS**.
- No new app build or visual redesign: app/runtime files are unchanged; relevant
  existing widget/golden regressions passed. This does not repeat the baseline's
  full-suite or platform-build acceptance claims.

## Integration handoff and remaining work

Review/merge this task branch through Integration Agent. Changes are limited to
`tool/merchant_acceptance`, its sanitized native evidence and the four related
documentation files. Canonical and slice documents are the only shared product
coordination surfaces touched. No schema-chain conflict or Flutter dependency
change is introduced. npm dependencies are pinned **tool-only** (`pg`, Supabase
CLI); downloaded binaries, node_modules, credentials and scratch are not tracked.

To close the remaining gate, first restore a working local Docker engine, then
run the documented isolated managed acceptance command. Keep its named project
and loopback guards intact. Fix any actual managed-service mismatch before
claiming A+B acceptance. Do not interpret this report as permission for remote
migration, feature activation, physical acceptance, or a new product slice.
