# W52K-BY staged private-preview executor

This package supersedes the BX live orchestration, not the immutable 0013 SQL
payload. It must be used only under a separately authorized live task. BY itself
uses network-disabled local copies of an existing backup and performs no live
Production or Development access.

## Trust and identity inputs

The externally approved SHA-256 of `seal.json` is mandatory. Verification covers
the entrypoint, all transitive runtime dependencies, validators, frozen SQL,
runtime manifest and the data files actually read by those validators. Tests,
this README and the new result documents are outside the runtime seal. Runtime
verification never rebuilds the seal. The authority is main
`ddb0bef7c0d0941c736d708540aafed815903dcd`.

For grant operations, the owner supplies the absolute path of an **existing**
Flutter Windows `shared_preferences.json` outside the repository. The helper
reads only `flutter.sb-mefhfvrgkwciubeajjeb-auth-token`, the cache key derived from
the installed Supabase Flutter SDK and Windows shared-preferences implementation.
It does not search other apps, extract phone credentials, export a session or
persist a new identity file. It reads the current session's user ID, checks the
UUID, issuer, subject, role, audience and expiry, then performs GET `/auth/v1/user`
against the exact Production origin. The server response must identify the same
non-anonymous existing user. A locally decoded JWT alone cannot authorize a grant.
The three resulting gates are `TESTER_UID_RESOLVED`, `TESTER_SESSION_VALID` and
`TESTER_PROJECT_IDENTITY_MATCH`; only their boolean results may be reported.

The real owner's session is **not resolved during BY**. The supported future
handoff requires an existing authenticated desktop cache selected by the owner.
If it is absent, expired or only available on a phone, stop before DB mutation.
The minimum manual action is to sign into the intended **existing** Production
tester account in the approved app with the supported desktop session cache,
then rerun the identity/preflight step. No account creation, password reset,
automatic token refresh, new build or JWT pasted into chat is part of this tool.
Do not claim a phone session has been transferred when it has not.

The external client config must identify project `mefhfvrgkwciubeajjeb`, its exact
HTTPS origin and a publishable key. Never print the key. No service-role key is
accepted for this flow. The DB password comes only from the owner's temporary
process `PGPASSWORD`; never put its literal value in history, scripts or files.
The child transport clears unrelated PG variables and pins DB host, database,
username, TLS `verify-full`, CA hash and PostgreSQL 17 client hash. Password state
is retained only in memory for possible containment reconnect, then cleared.

## Future operation interface

All operations use `node tool/production_preview_bridge/live_v2/cli.mjs OPERATION`.
Required common arguments are `--production-authorized`, `--seal-sha256`,
`--psql`, `--psql-sha256`, `--ca`, and `--ca-sha256`. The authorization flag is an
execution guard, not permission to run a live task without Product Owner approval.

Grant/read operations additionally require `--session-cache` and `--client-config`,
both explicit absolute paths outside the repo. `stage-a` and `deploy-staged` also
require `--backup` and `--backup-metadata`: the existing reviewed backup format,
actual archive bytes and SHA-256 must agree, target identity must match, and the
backup must be at most 15 minutes old. This CLI never creates a live backup.
Use the already reviewed backup workflow in the separately authorized live task.
`--lease-seconds` defaults to 3600 and must be an integer from 1 through 86400.
Short leases can expire before postflight; that safely fails and contains access.
The unchanged 0013 table has an older 30-day database CHECK; BY imposes the stricter
24-hour maximum in both the grant executor and stored-lease post-validation. There
is no client INSERT grant or endpoint that can bypass this operator-only workflow.

| Operation | Effect |
| --- | --- |
| `preflight` | Read-only identity, schema/ledger/data/public-OFF and legacy HTTP checks. |
| `stage-a` | Atomic unchanged bridge payload plus exact 0013 ledger; zero allowlist rows. Independent committed-state default-deny and HTTP checks follow. |
| `validate-a` | Read-only committed Stage A verification. |
| `stage-b` | Repeats Stage A checks; separate atomic insertion of one exact runtime UID with mandatory expiry; verifies tester allowance and other-role denial. |
| `postflight` | Read-only final contract, lease, public-OFF and HTTP verification. |
| `deploy-staged` | Orchestrates preflight, Stage A, independent default-deny checks, Stage B and final verification, with automatic containment on failure. |
| `remove-tester` | Independently removes only the exact runtime UID authorization; repeated use is safe. |
| `rollback-bridge` | Durable UID removal, durable EXECUTE revocation, then bridge-only teardown and ledger reconciliation. |

Do not reconstruct the sequence with ad hoc SQL. Prefer `deploy-staged` for the
authorized future execution, so errors between the stages are contained within
one process. The separately callable stages exist for explicit operator control.
Every mutation verifies the runtime seal again and uses the same advisory lock.
A failed deployment exits nonzero even when containment and rollback succeed.
Only an explicitly requested, healthy `rollback-bridge` operation may report
`ROLLED_BACK` with a successful process exit.

The cache is read once into memory; the real UID/token are neither command-line
arguments nor results. The token is sent only in the HTTPS header to the exact
Production host; redirects are rejected. Preview REST operations are allowlisted
GETs. A new RPC absent from the HTTP schema cache retries at most five times;
404 never counts as proof of denial during deployment. SQL role checks include
a distinct, unlisted UUID without inserting a live Auth user. Local rehearsals
also exercise HTTP using two independently signed synthetic existing-user sessions.

## Independent containment and recovery

For `remove-tester` / `rollback-bridge`, the same explicitly selected cache can
supply the exact subject even after token expiry, **for revocation only**. If that
cache is unavailable, `--recovery-stdin` accepts a single in-memory JSON object
with exactly `project_ref` and `user_id`, provided privately by the authorized
operator. This recovery input cannot authorize Stage A/B and must never be saved
in repository files or pasted into chat. It is not a wildcard or a second tester.

Rollback does not run a broad healthy-baseline prerequisite. It first commits
removal of the subject's row, then separately commits revocation of all known
bridge EXECUTE grants, including unexpected grants. It reconnects after a failed
SQL transaction. These durable containment commits survive a later teardown
failure. Exact object ownership, signatures and namespace boundaries still guard
destructive teardown; no `DROP ... CASCADE` or unrelated repairs are allowed.

An intact bridge footprint permits reconciliation of a missing or malformed 0013
ledger record. Ambiguous provenance or a structural dependency stops teardown
after exposure has been revoked. The result is `EMERGENCY_CONTAINMENT`; retain the
fresh backup and escalate for a separately reviewed recovery. A connectivity or
database-authority failure that prevents revocation is `CONTAINMENT_FAILED`, never
a false claim of closed access. Arbitrary loss of database access cannot be made
recoverable by this executor.

If schema/RLS, products/listings or the public flag drift, the observed core state
is preserved exactly while removing the bridge where safe. The result is
`ROLLED_BACK_CORE_DRIFT`, which is not a healthy Production state. Public activation
is checked OFF before write, after A, after B and in final validation. If it turns
ON, containment does **not** set it OFF. Core repair requires a separate task.

## Offline validation

`package.test.mjs` checks identity, expiry, seal tampering and HTTP cache behavior
without live network access. `rehearse.mjs` uses only `local-harness.mjs` and the
existing guarded local restore tools. The only allowed Docker endpoint is the
local Desktop named pipe; containers have `--network none`, no published ports,
the pinned PostgreSQL 17.6 image and one read-only hash-pinned backup mount.

The newest available archive predates 0012. Each fresh restore includes all 958
TOC entries and 69 data sections, then reconstructs unchanged reviewed 0012
locally. A checkpoint of that state is cloned between fault cases; failed copies
are not manually repaired. Synthetic Auth rows and tokens exist only inside the
isolated rehearsal and are removed before the final archive-data comparison.
The mock Auth endpoint validates signatures against a local throwaway signer;
it is explicitly not evidence of a live Production Auth response.

Run rehearsal with `W52KB_DOCKER`, `W52KB_CONTAINER` (`w52kb-byone` or
`w52kb-bytwo`), `W52KB_DUMP`, `W52KBY_PROOF_DIR` (outside repo), and the approved
`W52KBY_SEAL_SHA256`. No Production transport is used. The result documents retain
only sanitized counts, assertions, hashes and outcomes, never session data,
personal paths, raw backup data or account identifiers.
