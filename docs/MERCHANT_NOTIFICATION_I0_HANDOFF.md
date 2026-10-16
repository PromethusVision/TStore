# Merchant I0 — shared service notification preparation

Status: **PASS — local I0 preparation delivered; full I/provider gates remain OPEN.**
Baseline: `bfebb2f136466cc9623c5e0b6205f0eb5e862076`.
Branch: `agent/merchant-notification-i0`.

## Scope and audit

The existing inbox, NotificationRepository/NotificationsCubit, PushCoordinator,
mobile provider/device/preferences ports and SupabasePushBackend are reused.
Both Customer and Merchant runtime/UI remain unchanged. Screen inventory: no new
screen; the existing inbox and local preference screens retain their current
pending-provider behavior.

The missing part was a real durable server store. The old mock dispatcher also
combined provider success and database acknowledgement in one catch block,
disabled devices by installation alone, and allowed uncapped general marketing.
I0 supplies a concrete PostgreSQL store and a service-only dispatcher, with no
automatic runner, endpoint, SDK, dependency, credentials or real sends.

Historical engagement proposal0016 stays byte/content-identical. New
`supabase/proposals/0029_push_dispatch_i0.sql` is a **separate local proposal**,
not an automatic migration. It requires0016 plus the integrated live Auth
contract. Do not confuse engagement proposal0016 with catalog migration0016.

## Contracts

- Default-OFF server gate. Only order/chat or explicitly service-labelled system
  notifications may proceed. All promotion/marketing/campaign-associated rows
  fail closed, even with opt-in. No G/O10 quota or targeting policy is invented.
- Live Auth session and profile role for registration/preferences/disable.
  Preferences remain own-row reads; stale sessions and changed roles read none.
  No client token/delivery access. A late disable from an old live session cannot
  revoke the same installation's newer session binding.
- Device revision changes for owner, session, token, platform or enabled state.
  Old registrations lacking a session are ineligible until registered again.
- Candidate pages contain at most100 installation IDs and a continuation cursor,
  not tokens. Every claim and begin revalidates the authoritative state.
- Existing unique (notification, installation, role) key prevents duplicate sends.
  Claim is planned; begin commits unknown before exposing the target token.
  Concurrent begin returns a target once. No transaction spans provider I/O.
- Read-committed isolation is explicit in the pool adapter and enforced by SQL.
  First opt-out and dispatch serialize even when no preference row existed.
- Provider response contract: explicit `outcome: accepted` means submission
  accepted; `outcome: rejected` means definitive rejection; other results,
  exceptions and timeouts are unknown. Only a definitive rejected
  `token_unregistered` can disable the exact attempted device revision.
- Provider-call timeout defaults15s, bounded1–60000ms. Abort is a best-effort
  cancellation signal, not proof of rejection. Late results do not resend or
  rewrite the durable unknown record.
- Successful provider submission and successful DB acknowledgement are separate.
  A lost finish acknowledgement reports uncertainty. Replays never resend
  existing keys, including failed/cancelled/planned keys.
- Trusted reconciliation may call finish only with independently obtained
  provider evidence; terminal results cannot conflict or revert. The opaque
  delivery ID is supplied to the future provider adapter for correlation.
  A restarted worker can recover the minimized receipt by exact
  notification/installation/role key without knowing the lost claim ID.
  I0 does not implement an operator override, evidence-source binding, queue
  scanner, retry scheduler or expiry/release policy.
- Lock-screen copy is generic. Data carries existing notification/user/role and
  opaque delivery ID. No notification body, token or raw provider error is stored
  in delivery receipts or committed evidence.
- Revocation committed before begin cancels. After begin, an in-flight external
  send cannot be recalled; authenticated lookup and generic copy remain necessary.

The old draft's direct service-role table grants are replaced with five narrow
dispatch/read RPC grants. There is no service-role config activation grant.
Legacy pending/sent/failed records remain intact and non-retryable. This is
tightening of an undeployed preparation contract, not a live privilege change.

## Validation and reproduction

Completed application checks: 2572 Flutter tests PASS, 0 failures, 6 existing skips;
analyzer PASS; 29 dispatcher/adapter unit tests PASS; 6 local harness safety tests
PASS; unchanged0016 PGlite contract 28 PASS. Native final source:152 groups PASS,
including27 I0 groups. Managed final source:161 groups PASS, including the same27
SQL groups and4 actual Auth/PostgREST groups. Both final runs use the exact
delivered SQL bytes.

Sanitized reports: `docs/data/merchant_notification_i0_native_acceptance.json`,
`merchant_notification_i0_managed_acceptance.json` and final source fingerprint
`merchant_notification_i0_validation.json`. Raw logs/credentials stay in ignored
owned scratch. SQL manifest hashes refer to the exact bytes executed; historical
Git contents are separately checked unchanged from baseline.

```powershell
node --test tool/engagement/push_delivery.test.mjs
npm --prefix tool/merchant_acceptance test
node tool/engagement/schema.test.mjs <existing-pglite-package-directory>
node tool/merchant_acceptance/native.mjs <portable-postgresql-17-bin> --notifications
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <printed-owned-run-directory>
node tool/merchant_acceptance/acceptance.mjs <same-run-directory> --notifications
node tool/merchant_acceptance/local.mjs stop <same-run-directory>
flutter analyze --no-pub
flutter test --no-pub --concurrency=2
```

Native proof uses real PostgreSQL/locks/crypto with synthetic Auth schema.
Managed proof uses actual local Auth/PostgREST/Storage and includes the SQL
matrix; the two group counts must not be added as unique coverage. Full C/D/F,
H0/E/checkout/H1/G regressions execute before I0. Only synthetic in-process
providers are used. Neither report is physical-device or external-provider proof.

The acceptance harness also permits a precreated network only after exact owner,
name, empty-container and local loopback bridge checks. This avoids pruning
other tasks when default address pools are exhausted. No existing data is resumed.

Local environment recovery: Docker was stopped after its startup error. Its
broken temporary IPC directory was renamed, without deleting any contents, to
`C:\Users\Mustafa\AppData\Local\Docker\run.i0-recovery-20261017`.
Images/volumes/disks/settings were untouched. A new task-only private test network
used a subnet checked against host and Docker routes; cleanup removes only that
empty, labelled task network after stopping the fixture. The backup is retained.

## Integration and remaining gates

Integration Agent reviews/merges this task branch; this agent does not merge main.
Shared conflict areas: canonical/slices, existing dispatcher, local acceptance
harness. No Flutter source, routing, bootstrap, dependencies, lockfiles, historical
migrations or historical proposal0016 changed. No new app build is required to
validate a server/proposal-only change; the unchanged apps' full tests/analyzer run.

Remote deployment must explicitly review both proposals and exact schema state,
then separately approve credentials, provider binding, mobile permission/config,
consent reconciliation, transport deployment and sends. Production access/write
and migration apply are **NONE**. Full I, marketing G/O10, H1 settlement and
physical QR/provider J remain OPEN.

For a later authorized rollout, stop the worker and disable the gate to prevent
new begin calls; keep delivery evidence and unknown claims. Do not drop/recreate
delivery keys, remove uncertainty or blindly retry. An already-begun provider call
cannot be cancelled by the gate. No rollback or rollout command was run remotely.
