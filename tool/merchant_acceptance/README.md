# Merchant A+B local acceptance

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
The acceptance command additionally verifies the running DB/API containers'
project labels and **127.0.0.1:55432 / 127.0.0.1:55431** bindings, exact local
configuration and an empty app/Auth/Storage/ledger baseline before writing.
If the CLI ignores the loopback network option, the acceptance guard fails closed;
do not weaken it. HTTP transport uses literal-loopback `node:http`, ignores proxy
variables and never follows redirects. Keys and login credentials remain in
memory; CLI key output is suppressed.

Each fixture is single-use. If setup/test fails, inspect its `failure.txt`, stop
that same stack preserving data, and prepare a new run. Never use `db reset`,
`stop --no-backup`, `docker system prune` or a remote fallback for this suite.

The managed journey covers catalog lookup → owned listing → price/availability
edit → fresh session → photo intent → foreign upload denial → real upload →
publish → fresh Customer signed-image download → retirement. It also checks
Auth signature rejection, real logout, the default-off capability and the full
independent-connection database matrix. A passing run writes
`docs/data/merchant_ab_managed_acceptance.json`. **The current delivery has not
executed that managed journey successfully because Docker does not start.**

## Evidence handling

A nonzero exit is not acceptance. The managed runner returns 2 when the local
environment is unavailable and 1 for failures after database connection.
Keep native proof, managed HTTP proof and
device acceptance separate. Do not copy scratch credentials or server logs into
commits. Only the sanitized passing report is a tracked artifact. A failed rerun
does not erase an earlier dated report; always inspect its source hashes/time
and the latest command result. No production migration or app runtime file is
changed by this acceptance task.
