# Merchant local acceptance — A+B and optional C

## Guarded pilot preparation (J2)

`pilot_preparation.mjs <new-owned-run> <Flutter-SDK>` rehearses a populated
Development0001–0011 baseline upgrade, atomic unchanged0016/0017, independent
explicit category activation and the actual18-checkpoint repository journey.
It preserves policy/review metadata and tests failure, replay, drift and competing
preparation. Existing runner defaults are unchanged. Only literal owned loopback
is accepted. Start a fresh stack; stop it afterward while retaining its data.

`prepare_pilot.mjs new-review-name [explicit-leaf-uuid ...]` is offline-only and
creates a new ignored review bundle with source-bound proof and file hashes.
Without explicit UUIDs, no category SQL is generated. There is no remote executor,
credential option or approval flag. Tokens prevent accidental SQL execution but
do not prove authorization or target identity. Do not run the candidate on a
hosted server with a mismatching baseline; never substitute its hash to bypass
review. The pinned Development observation is reproduced locally, including its
narrower privileges and managed RLS trigger, before an exact-match rehearsal.
This is a local mirror, not remote behavioral acceptance or apply permission.

Run `node --test tool/merchant_acceptance/*.test.mjs` before starting a stack;
the socket safety test binds the same API port. See
[J2 handoff](../../docs/MERCHANT_PILOT_PREPARATION_HANDOFF.md) and
[owner review packet](../../docs/MERCHANT_PILOT_APPROVAL_PACKET.md).

## Base-core pilot profile (J1)

`pilot.mjs` supplements the extended suites with the exact J0 default composition.
It uses only the Development track0001–0011 + catalog-media0016 + operations0017,
keeps candidate decisions OFF and omits downstream claims/rewards/provider schemas.
It never accepts a hosted URL or remote credentials and is not an apply tool.

After `npm ci` and the safety tests below, prepare/start a **new owned** stack:

```powershell
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <printed-run-directory>
node tool/merchant_acceptance/pilot.mjs <same-run-directory> <Flutter-SDK-directory>
node tool/merchant_acceptance/local.mjs stop <same-run-directory>
```

Flutter dependencies must already be resolved (`flutter pub get --offline` when
available). The runner calls the existing SDK's Flutter test snapshot with
`--no-pub`; the Dart journey lives outside `test/` so ordinary tests never connect.
All SDK HTTP requests use a literal-loopback, no-proxy, no-redirect transport.
Transient synthetic client credentials are confined to the owned ignored run and
removed in `finally`. The credential file contains no service-role key. Passing
client evidence is bound to the current run nonce; a failed runner never reports
acceptance. Diagnostic logs stay ignored and must not be published.

The read-only inspector snapshots schema/ACL/policies/triggers/constraints/Storage,
then rollback-only mutation tests prove drift rejection. The real SDK journey
covers onboarding through Customer image bytes, pending submissions, inbox CRUD
and legacy QR confirmation/replay rejection. It does not simulate claims-v2,
Realtime delivery, provider delivery, recovery mail or physical devices.

Passing sanitized evidence goes to
`docs/data/merchant_pilot_backend_acceptance.json` and
`docs/data/merchant_pilot_backend_contract.json`. The latter is the exact local
Development fixture fingerprint, not proof of a hosted server. An authorized
operator must review actual remote history, the special0014 executor and chosen
feature manifest separately. Never run generic `db push` from this list.

If this runner fails, retain its data, stop that exact stack and prepare a fresh
run. Do not reuse populated fixtures or import old passing evidence. The owned
network fallback described below applies when Docker's default pools are full.

This tool is a **synthetic, local-only test fixture**. It does not deploy anything,
read `.env`, link a Supabase project, use hosted credentials, reset a database,
delete Docker volumes, or implement deferred product capabilities.

Two evidence classes are deliberately separate:

1. `native.mjs`: real Windows PostgreSQL, pgcrypto and independent connections;
   **synthetic Auth/Storage tables**. It cannot accept managed Auth or Storage.
2. `acceptance.mjs`: an isolated Supabase CLI stack with actual Auth-issued JWTs,
   session rows, PostgREST and Storage HTTP. Its database race tests use independent
   PostgreSQL connections with the claims obtained from those Auth logins. HTTP
   checks separately verify signature rejection, provenance and actual logout.

Neither class demonstrates physical two-device QR acceptance or Production safety.

### Daily catalog recovery contract

`node tool/merchant_acceptance/acceptance.mjs <owned-run-directory> --catalog-recovery`
adds seven real Auth/PostgREST/Storage groups to A+B: exact-owner recovery reads,
stale optimistic revisions, duplicate listing/onboarding denial, pending upload
recovery, repeat publication, explicit retirement with object retention and exact
submission retry. Evidence is saved separately as
`docs/data/merchant_catalog_recovery_managed_acceptance.json`; previous delivery
evidence is not overwritten. Transport faults and same-account session races are
tested in Dart; this HTTP suite proves the server contracts they rely on.

## Install and self-check

Node 22+ and Docker Desktop are needed for the managed run. The native run needs
Windows PostgreSQL 17 binaries instead of Docker. From this directory:

```powershell
npm ci --no-audit --no-fund
npm test
```

These are tool-only pinned development dependencies; Flutter's dependency graph
is unchanged. The self-check briefly binds `127.0.0.1:55431`, so stop this task's
managed stack first. An unrelated port conflict is a failure, never a reason to
stop another process. On restricted agent hosts, local TCP/process/cache access
may require the normal execution approval mechanism.

## Native PostgreSQL proof

Obtain the portable Windows archive from the [official PostgreSQL Windows
page](https://www.postgresql.org/download/windows/) and its linked
[EDB binary download](https://www.enterprisedb.com/download-postgresql-binaries).
Extract `pgsql/bin`, `pgsql/lib` and `pgsql/share` into ignored task scratch.
No system installer or Windows service registration is needed.

This run used PostgreSQL 17.11, EDB file ID `1260616`, archive SHA-256
`80379b2c04d51c30225532e0ae04509899141e9957ed096fe749d7fd9df8f82f`.
It is local PostgreSQL 17 evidence, not an exact managed Production runtime clone.

From the repository root, with the extracted binary directory:

```powershell
node tool/merchant_acceptance/native.mjs .buildlog/postgresql-17.11/pgsql/bin
```

The runner creates a new random directory under `.buildlog/merchant-native`,
initializes an empty cluster with a random password, binds **127.0.0.1:55439**,
checks the server's data-directory identity and executes unchanged migration
bytes. It stops only its own cluster in `finally`; data/logs remain for diagnosis.
It never adopts an existing server if the port is occupied. Temporary credentials
stay in ignored scratch and are not printed. A passing result records the exact
migration hashes in `docs/data/merchant_ab_native_acceptance.json`.

Race checks hold one transaction open, observe `pg_blocking_pids` for the second
independent connection, then release it and assert committed outcomes. Merely
launching two promises does not count as a contended test.

## Managed local Auth + Storage run

From the repository root:

```powershell
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <printed-run-directory>
node tool/merchant_acceptance/acceptance.mjs <same-run-directory>
node tool/merchant_acceptance/local.mjs stop <same-run-directory>
```

Use the exact generated directory. Each run has a unique `ev-merchant-ab-*`
project/network identity. The CLI configuration lives entirely in ignored
`.buildlog/merchant-acceptance`, independently of the repository migration folder.
Only this runner applies the **Development track 0001–0011 + A/B 0016–0018**;
Production-only 0012–0015 are intentionally excluded. The historical Development
ledger IDs required by unchanged 0010/0011 are synthetic fixture provenance.
A safe eligible category path is activated in this fixture only. Catalog approval
stays disabled. The QR flag is enabled only inside this disposable test database.

The start command requires a local Docker engine, refuses existing matching
containers/volumes and creates a bridge whose default host binding is loopback.
Docker Desktop 29.8.2 on this Windows host did not honor that network default.
A temporary, local socket proxy now explicitly sets **127.0.0.1** in the Docker
create request before either DB/API starts. It accepts only this project's
labeled services and its unexposed Auth/Storage bootstrap jobs, and never opens
a TCP proxy or changes global Docker settings. Container inspection below still
checks the real daemon directly. The proxy closes when startup ends.
The acceptance command additionally verifies the running DB/API containers'
project labels and **127.0.0.1:55432 / 127.0.0.1:55431** bindings, exact local
configuration and an empty app/Auth/Storage/ledger baseline before writing.
If explicit loopback binding fails, the acceptance guard fails closed and startup
stops only this project, retaining its data. Do not weaken the guard.
HTTP transport uses literal-loopback `node:http`, ignores proxy
variables and never follows redirects. Keys and login credentials remain in
memory; CLI key output is suppressed.

Each fixture is single-use. If setup/test fails, inspect its `setup-failure.txt`
or `failure.txt` privately (setup diagnostics may contain local secrets), stop
that same stack preserving data, and prepare a new run. Never use `db reset`,
`stop --no-backup`, `docker system prune` or a remote fallback for this suite.

The managed journey covers catalog lookup → owned listing → price/availability
edit → fresh session → photo intent → foreign upload denial → real upload →
publish → fresh Customer signed-image download → retirement. It also checks
Auth signature rejection, the default-off capability and the full independent-
connection database matrix. Another actual HTTP journey creates a cart/QR,
claims by manual code, completes twice into one purchase, reads Customer evidence
and retries an identical return into one append. Logout then deletes the Auth
session and prevents both completion and reconciliation of an already claimed QR
with the still-signed token; no purchase is created. The capability metadata
read is informational and is not used as the transaction authorization test.
A passing run writes `docs/data/merchant_ab_managed_acceptance.json`, including
service image identities and verified port bindings. **21 managed groups passed
on 2026-10-15. Physical two-device acceptance remains OPEN.**

## Slice C mode

The default commands above preserve the A+B suite. Add `--reviews` to either
acceptance runner to apply additive 0019 in the fresh local fixture and run C:

```powershell
node tool/merchant_acceptance/native.mjs <portable-pgsql-bin> --reviews
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <printed-run-directory>
node tool/merchant_acceptance/acceptance.mjs <same-run-directory> --reviews
node tool/merchant_acceptance/local.mjs stop <same-run-directory>
```

C mode preserves the A+B catalog/Storage and HTTP purchase/return/logout
journeys, substitutes the C database matrix, and adds actual HTTP evaluation,
history, reply, report, moderation, cross-shop reopening, withdrawal and Auth
account-deletion checks. It records 17 native groups and 28 managed groups in
`docs/data/merchant_c_native_acceptance.json` and
`docs/data/merchant_c_managed_acceptance.json`. The managed 28 include those 17;
do not add the totals as distinct coverage. Both reports include final migration
hashes. The capability is enabled only in the synthetic local fixture.

## Evidence handling

The additive `--checkout` mode includes B/C/D/F/H0/E and migrations 0025–0026. It runs
the unchanged-price customer coupon approval, redemption, return allocation and
spent-source offset matrix. Use the same commands above with `--checkout` instead
of `--reviews`, always with a fresh owned fixture. Reports are
`docs/data/merchant_checkout_e_native_acceptance.json` and
`docs/data/merchant_checkout_e_managed_acceptance.json`. The managed report includes
the SQL checkout matrix plus actual HTTP/Auth tests; do not add report totals as
distinct cases. Real product classification, funding, refunds, settlement and
physical-device acceptance remain outside this synthetic proof.
The capacity regression observes the reservation and ledger immediately after
consent and after claim, before completion: net 499.99/500/500.01 TL, zero payment,
replay/reopen, last-slot contention, rollback and expired-package release. Terminal
"no reward" assertions alone cannot prove timely capacity release.

A nonzero exit is not acceptance. The managed runner returns 2 when the local
environment is unavailable and 1 for failures after database connection.
Keep native proof, managed HTTP proof and
device acceptance separate. Do not copy scratch credentials or server logs into
commits. Only the sanitized passing report is a tracked artifact. A failed rerun
does not erase an earlier dated report; always inspect its source hashes/time
and the latest command result. No production migration or app runtime file is
changed by this acceptance task. Native evidence's OPEN Auth/Storage labels mean
that the native runner cannot assess those gates; the separately dated managed
report supplies their actual result.
## G promotion preparation

`--promotion` includes the complete `--statement` chain plus0028. It validates
owned structured previews/drafts, source freshness, concurrent edit/retry,
immutable history, archive/restore, private grants, feature stop and absence of
financial/notification effects. Managed acceptance also exercises actual existing
Storage upload/sign/download/retire and stale-save rejection. No ad purchase,
publication, ranking, targeting, provider send or Production access is exercised.

Use the same fresh-fixture procedure with:

```powershell
node tool/merchant_acceptance/native.mjs <owned-postgresql-17-bin> --promotion
node tool/merchant_acceptance/acceptance.mjs <new-owned-local-run> --promotion
```

Outputs use `merchant_promotion_g_*`. The previous statement contract fixture is
preserved. Final scope/reproduction/rollback details are in
`docs/MERCHANT_PROMOTION_G_HANDOFF.md`.

## I0 shared service notification preparation

`--notifications` includes the complete `--promotion` regression chain, then
explicitly rehearses unchanged `supabase/proposals/0016_engagement_foundation.sql`
and `0029_push_dispatch_i0.sql`. The proposals are not automatic migrations.
Always use a fresh owned local fixture with the same prepare/start/stop procedure.
Reports use `merchant_notification_i0_*` and include both proposal hashes.

The SQL matrix verifies live-session registration, account/role/token changes,
concurrent claims/begin/opt-out, durable uncertainty, safe late-token rejection,
bounded device pages and all private grants. Managed acceptance adds real
Auth/PostgREST registration, logout, RLS and service-only acknowledgement RPCs.
Provider calls use synthetic in-process doubles only; no real send, hosted
database, provider credential or device acceptance is exercised. The old PGlite
foundation test still validates the unchanged0016 proposal separately.

If Docker's default network pools are exhausted, an operator can prepare a
new private bridge after checking host routes and existing subnets. Start accepts
it only when its exact run name/owner label match, it has no containers, and it
uses local bridge/IPv4/loopback bindings. It never prunes another task's networks
or reuses existing fixture data. The private subnet must not overlap host/VPN or
Docker routes; this is a local test environment choice, not a product setting.

```powershell
node --test tool/engagement/push_delivery.test.mjs
node tool/merchant_acceptance/native.mjs <owned-postgresql-17-bin> --notifications
node tool/merchant_acceptance/acceptance.mjs <new-owned-local-run> --notifications
```

## Merchant transaction recovery

`--commerce-recovery` includes the existing checkout/H0/E regression chain and
ten additional real Auth/PostgREST/PostgreSQL groups for B claim recovery,
completion, return replay after exhausted quantities, replacement/live sessions,
concurrent returns, foreign ownership and minimized history. A fresh owned local
fixture is mandatory. Use `node tool/merchant_acceptance/acceptance.mjs <run>
--commerce-recovery` after the normal prepare/start procedure, then stop that
exact run. Output uses `merchant_commerce_recovery_managed_acceptance.json`.
Checkout fixtures now include additive0030 and three projection/privacy groups.
Historical migration bytes remain unchanged. Native PostgreSQL accepts
`--commerce-recovery` for the checkout regression chain plus those three groups.
To reproduce the upgrade from this branch on a fresh owned run, use
`acceptance.mjs <run> --commerce-recovery --privacy-upgrade`. It first rehearses
the exact pre-0030 checkout chain, compares the populated upgrade, then executes
the new recovery/privacy checks. Native `--commerce-recovery` instead installs
0030 before the entire regression chain. Neither path modifies remote databases.
For a populated owned pre-0030 fixture only, `purchase_privacy_upgrade.mjs <run>`
reproduces the old identifiers, applies0030 locally, compares every purchase
payload and fingerprints seven immutable tables. It refuses an already-corrected
or unrelated baseline. The final fresh managed run remains separate evidence.
No remote apply or physical-device/provider evidence is implied. HTTP
tests intentionally ignore acknowledgements; Dart transport fault injection
and widget navigation evidence are recorded separately in the task handoff.

## Merchant campaign and promotion recovery

`--management-recovery` includes the existing G/F and dependent commerce checks,
then rehearses additive0031 on that populated, newly owned local fixture. Eight
campaign/promotion tables are fingerprinted before and after; the new functions
must leave every row unchanged. Five database groups cover exact current revision,
explicit rebase, missing/foreign IDs, live-session/role/shop checks, gates, grants
and zero read side effects. Five additional managed HTTP groups cover actual Auth,
lost acknowledgement replay, archive/restore with fresh revision and fingerprint,
immutable history and actual logout. Dart tests separately cover transport and UI
continuation failures; the HTTP suite does not pretend to simulate device hardware.

For the complete recorded matrix, use these commands with the normal fresh
prepare/start/stop process above. Run the safety tests before starting the stack.

```powershell
node --test tool/merchant_acceptance/safety.test.mjs tool/merchant_acceptance/docker-proxy.test.mjs
node tool/merchant_acceptance/native.mjs <owned-postgresql-17-bin> --management-recovery --notifications --commerce-recovery
node tool/merchant_acceptance/acceptance.mjs <fresh-owned-local-run> --management-recovery --notifications --commerce-recovery
node tool/merchant_acceptance/local.mjs stop <that-exact-owned-local-run>
```

Evidence uses `merchant_management_recovery_{native,managed}_acceptance.json` and
`merchant_management_{native,managed}_upgrade.json`, leaving earlier handoff
evidence intact. Without `--management-recovery`, G fixtures install0031 normally
with the migration chain. `--notifications` rehearses the existing notification
proposals locally only; it never configures or contacts a provider. No remote
deployment, paid operation, actual refund/payout or two-device QR acceptance is
part of these checks.

## J4 pilot launch review preparation

After the approved Development A installation, use the separate new-run flow:
`local.mjs prepare`, `local.mjs start <run>`, `pilot_launch.mjs <run>`, then
`local.mjs stop <run>`. It recreates the exact post-A hosted metadata locally,
including observed body line endings, and exercises the two-function Turkish
notification text repair on populated synthetic data. It never contacts hosted
Auth/DB, sends mail or configures a push provider. Source remains a proposal;
automatic migration discovery and existing fixture defaults are unchanged.

Run `pilot_launch.test.mjs` and `prepare_pilot_launch.test.mjs` with the existing
safety/core/preparation tests while the API port is free. A current passing proof
allows `node tool/merchant_acceptance/prepare_pilot_launch.mjs <new-name>` to emit
an offline E/C/intake review bundle. No A replay or account/catalog write script
is generated. Optional intake input is a plain local file name under
`.buildlog/pilot-intake/`; it never carries private contacts or credentials.
Exact sources, review hashes, local validation and independent remote approval
gates are documented in `docs/MERCHANT_PILOT_LAUNCH_PREPARATION_HANDOFF.md`.

## J6 first-cohort preparation after installed A/C/E

Use `local.mjs prepare`, `local.mjs start <new-run>`,
`pilot_cohort.mjs <same-run> <Flutter-SDK-directory>`, then `local.mjs stop <run>`.
The owned loopback stack mirrors the installed post-C/E schema and tests separate
category/role candidates with real Auth and the existing Flutter repository
journey. Its existing products/accounts are synthetic fixtures, never a suggested
hosted provisioning method. No policy override or new-product materializer exists.

Run `pilot_cohort.test.mjs` and `prepare_pilot_cohort.test.mjs` beside the existing
pilot/safety tests. After current proof passes, `prepare_pilot_cohort.mjs <new-name>`
generates a default no-write review bundle. Optional private input is a plain name
under `.buildlog/pilot-cohort-input`; selected account IDs must never be committed.
Missing facts stay missing. A/C/E are not replayed. Exact B and role-D proposals
require matching observations and separate owner approval before hosted use.
See `docs/MERCHANT_PILOT_COHORT_HANDOFF.md` for source/target guards, reproduction,
the unresolved catalog publication/legacy-price contract and remaining pilot gates.
