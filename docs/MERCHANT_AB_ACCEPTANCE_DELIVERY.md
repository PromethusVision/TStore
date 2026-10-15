# Merchant A+B acceptance delivery — 2026-10-15

Baseline: `e51149ab7c204c00f798c3172bbd32fba7fa853f` (integrated Slice B).
Task branch: `agent/merchant-ab-acceptance`.
Authority/boundaries: canonical §5.2. Main merge belongs to Integration Agent.

## Outcome

**Local A+B managed Auth/Storage acceptance is now PASS.** After the Product
Owner restored Docker, 21 groups passed against actual local Auth, PostgREST,
Storage and PostgreSQL 17.11. The independent native PostgreSQL proof also passed
all 16 groups again. Physical two-device acceptance remains OPEN.

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
| Access / lifecycle | PASS in both runtimes | Two-session admission race, foreign shop denial, owner/role/active-shop changes, stale price, cart edit/delete, deadline after lock wait, committed attempt quota, flag-off drain, terminal device revocation |
| Photo slot concurrency | PASS in both runtimes | Six-slot cap serializes; foreign merchant denied |
| Managed Auth provenance / real logout | **PASS locally** | Auth-issued JWT/session relation; forged signature rejection; real logout removes session and prevents claimed QR completion/reconciliation with the still-signed token |
| Storage HTTP / fresh-session signed image | **PASS locally** | Catalog → listing → upload → publish → fresh Customer batch signed URL → actual byte download → retirement; foreign and duplicate uploads denied |
| HTTP QR / purchase / return | **PASS locally** | Actual authenticated HTTP cart/QR/manual claim, repeat completion = one purchase, fresh Customer evidence and repeat return = one append |
| Flutter regressions | PASS from prior task revision | 227 related tests at b014b70a; no Flutter changes since; analyzer rerun clean on this continuation |
| Harness isolation / transport | PASS | 5 tests: endpoint/container restrictions, literal-loopback HTTP, no redirect following, explicit Docker binding and bootstrap stream/header delivery |
| Physical Customer ↔ Merchant QR | **OPEN / later phase** | No physical-device acceptance claim |

Detailed, dated proof and unchanged migration hashes:
[native report](data/merchant_ab_native_acceptance.json) and
[managed report](data/merchant_ab_managed_acceptance.json). The latter also records
service image IDs and verified literal-loopback bindings. Its 21 groups include
the 16 database groups; do not count them as 37 distinct behaviors.
Commands, guards, fixture provenance and reproducible setup:
[acceptance tool README](../tool/merchant_acceptance/README.md).

## Environment history and resolved harness issues

The earlier blocked task observed Docker Desktop 4.91.0 failing before its Linux
engine became available. That attempt reproduced Windows AF_UNIX error 1920 at
`Docker/run/sailor-ingest.sock` (cannot access/rename socket). Explorer, Windows
process launch and Shell launch comparisons did not establish a working engine.
An [upstream Codex report](https://github.com/openai/codex/issues/52698) describes
a matching MSIX/AppData virtualization failure; that is a possible cause, not a
confirmed diagnosis of this machine. No data deletion, factory reset, WSL
deregistration, reboot, permission/manifest change or remote fallback was used.
Failed Docker Desktop processes were stopped; the prior runtime backup remains.

The Product Owner subsequently restored Docker. This continuation verified a
working Docker 29.8.2 Linux engine. The documented bridge loopback default was
not honored on this Windows host, including in a separate empty-container probe.
The guard stopped the first stack before application migration/fixture writes.
A short-lived local socket proxy now sets `HostIp=127.0.0.1` explicitly before
DB/API creation; project labels/network, allowed service names, expected ports
and unexposed Auth/Storage bootstrap jobs are checked. Actual daemon bindings
are still independently inspected before connecting. No global Docker change
or remote fallback was introduced. Initial proxy bootstrap/stream issues were
fixed and covered with an actual socket test, including headers-before-output.

The first managed journey passed 19 groups then exposed a test assertion error:
`qr_capabilities_v2` reports metadata and intentionally checks `auth.uid()`, not
live session state. The corrected test claims a real QR before logout, then
asserts SQLSTATE 28000 on completion/reconciliation and zero resulting purchases.
The complete 21-group rerun passed on a new fixture. No runtime authorization
change was needed.

The independently downloaded official EDB portable PostgreSQL distribution
provided the native proof without installing a Windows service. It used a fresh
random-password cluster on literal loopback and stopped after each run. Scratch
data/logs remain ignored and are excluded from the commit.

A concurrent native rerun failed during initialization, before server startup;
no native server remained running. Its original error lacked useful diagnostics.
Initialization now has a bounded 180-second allowance and private failure-stage
diagnostics. The fresh sequential rerun passed all 16 groups and stopped normally.

## Validation performed

- `node tool/merchant_acceptance/native.mjs <portable-bin>`: **16 groups PASS**.
- `node --test tool/merchant_acceptance/*.test.mjs`: **5 PASS**.
- Managed acceptance command: **21 groups PASS**, fresh isolated Supabase fixture;
  real managed services, pgcrypto and observed contention, no mocks substituted.
- `flutter analyze --no-pub`: **No issues found**, rerun this continuation.
- Prior revision's focused Flutter run: `test/unit/merchant`, `test/unit/cart`,
  `test/unit/purchases`, `test/unit/shop/listing_hero_test.dart`,
  `test/widget/merchant`, `test/widget/cart/cart_qr_session_bottom_sheet_test.dart`,
  `test/widget/purchases`: **227 PASS** at b014b70a; no Flutter runtime/test changes
  in this continuation, so this unchanged suite was not repeated.
- All acceptance JavaScript files pass syntax checking; diff whitespace checked.
- No new app build or visual redesign: app/runtime files are unchanged; relevant
  existing widget/golden regressions passed. This does not repeat the baseline's
  full-suite or platform-build acceptance claims.

## Integration handoff and remaining work

Review/merge this task branch through Integration Agent. Changes are limited to
`tool/merchant_acceptance`, its sanitized native/managed evidence and the four related
documentation files. Canonical and slice documents are the only shared product
coordination surfaces touched. No schema-chain conflict or Flutter dependency
change is introduced. npm dependencies are pinned **tool-only** (`pg`, Supabase
CLI); downloaded binaries, node_modules, credentials and scratch are not tracked.

All owned test services are stopped; fixture volumes/logs are retained. No current
Auth/Storage blocker remains for this locally tested Development-track baseline.
Keep physical two-device J, authorized remote migration/activation and provider
configuration separate. Main is still e51149ab; Integration Agent must review and
merge the full task branch (including b014b70a and this continuation). This report
does not authorize C–J, Production writes or a main merge by this agent.
