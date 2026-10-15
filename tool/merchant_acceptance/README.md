# Merchant local acceptance — A+B and optional C

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

The additive `--checkout` mode includes B/C/D/F/H0/E and migration 0025. It runs
the unchanged-price customer coupon approval, redemption, return allocation and
spent-source offset matrix. Use the same commands above with `--checkout` instead
of `--reviews`, always with a fresh owned fixture. Reports are
`docs/data/merchant_checkout_e_native_acceptance.json` and
`docs/data/merchant_checkout_e_managed_acceptance.json`. The managed report includes
the SQL checkout matrix plus actual HTTP/Auth tests; do not add report totals as
distinct cases. Real product classification, funding, refunds, settlement and
physical-device acceptance remain outside this synthetic proof.

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
