# Merchant pilot preparation — J2

Date: 2026-10-17. Source main: `55cee012db9c068e177fad4396ee22c91afcf8d6`.
Branch: `agent/merchant-pilot-preparation`. Main merge belongs to Integration Agent.

**Local preparation and observed-profile rehearsal: PASS. Remote apply: NOT AUTHORIZED.**
This delivery prepares and tests review artifacts; it does not deploy the pilot.
Canonical §4.6 and implementation slice J2 define its scope.

## Delivered

- An offline review-bundle generator with one fixed Development identity. No
  network client, remote credentials, apply flag or deployment executor.
- Exact unchanged catalog-media0016 + operations0017 bodies, wrapped together
  with their two new ledger entries in one transaction. Historical0001–0011
  versions are preserved; no `migration repair`, generic `db push` or old migration
  rewrite. Original source SQL is retained in the new ledger statements.
- Before-write schema fingerprint, explicit review token, cooperative advisory
  lock, bounded table locks/timeouts and postchecks. The token is not an approval
  mechanism or database identity check; a future authorized operator must verify
  both independently. The lock does not prevent every arbitrary external DDL tool.
- Separate category candidates for explicit leaves and required ancestors.
  Every unselected node and all identity/policy/review fields stay unchanged.
  Schema permission cannot authorize category changes. No real selection is made.
- Additive shared Auth callback proposal and a credential-free cohort template.
  Neither changes settings, creates users, grants roles or sends messages.
- A populated-baseline local upgrade rehearsal using actual PostgreSQL, Auth,
  PostgREST, private Storage and the existing Flutter repositories.
- Metadata-only comparison with the authorized Development project. An initially
  rejected generic baseline was replaced by a separately validated local mirror
  of the pinned observed profile, then the entire rehearsal was repeated.

## Reproduce locally

Resolve existing pinned dependencies (`npm ci --ignore-scripts --no-audit --no-fund`
in `tool/merchant_acceptance`; existing Flutter dependencies via offline pub get).
Run socket safety tests **before** starting the stack; they require its API port.

```powershell
node --test tool/merchant_acceptance/safety.test.mjs tool/merchant_acceptance/docker-proxy.test.mjs tool/merchant_acceptance/pilot_contract.test.mjs tool/merchant_acceptance/pilot_preparation.test.mjs tool/merchant_acceptance/prepare_pilot.test.mjs
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <printed-new-owned-run>
node tool/merchant_acceptance/pilot_preparation.mjs <same-run> <Flutter-SDK-directory>
node tool/merchant_acceptance/local.mjs stop <same-run>
node tool/merchant_acceptance/prepare_pilot.mjs new-review-name
```

The runner requires a fresh owned literal-loopback stack. A failed run retains its
data; use a fresh run for another full proof. If address pools are exhausted,
remove only this task's stopped, label-verified empty network; retain all volumes.
Never prune unrelated Docker resources. Diagnostics and transient local credentials
stay ignored; the client fixture is removed in `finally`.

The offline command writes a new `.buildlog/pilot-review/<name>` directory. It
rejects path overrides, existing output, symlink redirection, changed source,
stale source-bound proof and changed target. Each generated file has a SHA-256 in
`bundle.json`. Optional additional arguments are explicit proposed leaf UUIDs;
omitting them emits no category SQL. Even a valid proposal remains unauthorized.

## Validation

- **29/29 Node checks PASS:** existing ownership/loopback/Docker transport and
  core manifest tests plus21 preparation/bundle/profile tests.
- **18/18 managed local groups PASS:** populated migration preservation; missing
  or wrong approval token; ledger, RLS, RPC, table-wide and future-object grant
  drift; competing preparation; late-error full rollback; atomic upgrade; replay;
  unchanged taxonomy; separate category token; stale taxonomy; category rollback;
  exact leaf/ancestry changes; repeat refusal; real role/foreign-owner denial;
  actual Flutter journey; unchanged core/default-OFF state after the journey.
- The Flutter journey has **18 checkpoints**, nested in one managed group, not
  18 additional test cases. It covers actual onboarding/profile, catalog/listing,
  price/availability, Storage media, inbox and matching Customer/legacy QR reads.
- `flutter analyze --no-pub`: PASS, no issues. No app UI, Dart runtime or dependency
  change; no new APK claim and no full Flutter-suite rerun in this delivery.
- Final checks supersede two harness attempts: one drift probe initially removed
  an already-absent privilege; fixed to actually toggle the observed permission.
  One safety run collided with the still-running owned API port; rerun after
  stopping the stack passed. No product regression was hidden by either retry.

Evidence:

- `data/merchant_pilot_preparation_acceptance.json`: dated services, source and
  migration hashes,18 groups,18 client checkpoints and local-only plans.
- `data/merchant_pilot_preparation_baseline.json`: local metadata/taxonomy snapshot;
  no accounts, user rows, object contents or credentials. It is not hosted proof.
- `data/merchant_pilot_remote_observation.json`: independently read hosted hashes,
  comparison and limitations. Raw database function hashes retain CRLF differences.
- `data/merchant_pilot_hosted_profile.json`: pinned public schema/function metadata,
  no user data. The local mirror refuses remote connections and validates every
  executable definition against unchanged migration output before copying it:
  only reviewed newline differences, the six existing text defects and the exact
  hash-pinned managed RLS function are accepted. Unknown code differences abort.

No historical migration or automatic migration discovery is changed. The sole
existing runner change is an opt-in `baselineOnly` mode requiring `coreOnly`;
all existing defaults remain. Shared touchpoints are canonical/slices documentation
and `tool/merchant_acceptance/fixture.mjs`. Central coordination documents, app
routing, providers, dependencies, Customer UI and notification architecture stay fixed.

## Hosted findings, mirror and authorization gate

Target: `tnipyxnvhgelwdpykyez`, EsnaftaVar Development, previously resumed with
explicit owner permission. This task performed only read-only SQL and prior Auth
settings inspection. No remote migration, account, email, Auth save or data write.

- Eleven historical ledger entries,29 public tables with RLS, staged taxonomy and
  missing A/operations prerequisites agree with the earlier audit. Eight captured
  metadata components match; all1,563 selected taxonomy records match exactly.
- Five components differ: grants, function metadata, table-wide privileges,
  postgres/public future-object defaults and managed public event triggers.
- The hosted baseline has810 fewer column-privilege records, all `service_role`;
  none of the differing column grants are hosted-only. Do not widen remote grants
  to imitate local infrastructure. This count is not a complete security audit.
- Of49 application function definitions,47 match after newline normalization.
  The two notification bodies differ only in **six Turkish string literals**;
  exact body comparison confirmed this after replacing those literals locally.
  Examples: `Yeni mesajÄ±n var` and `AlÄ±ÅŸveriÅŸin onaylandÄ±`.
  The repository0006 source already has correct Turkish text. Replaying0006 is
  not a repair strategy; it would affect unrelated historical objects.
- The hosted provider also has `rls_auto_enable()` / `ensure_rls`; the local stack
  lacks that managed addition. Do not delete it to make fingerprints match.
- Products count observed by aggregate only: **0**. Categories active/assignable:
  **0**. A schema-only install will not supply usable merchant catalog contents.
- Shared Auth: Site URL localhost, no redirects, custom SMTP off and Confirm email
  off. These observations are not permission to change shared Customer settings.

The original generic candidate was rejected correctly. The final runner now
reproduces the observed50 functions, effective client/table privileges, narrower
service-role grants, postgres/public defaults and managed RLS trigger **locally**.
It asserts equality of the complete captured schema projection and its raw
database-side fingerprint before creating any synthetic fixture data. The final
18-group rehearsal and actual repositories pass on this matched profile.

The final candidate therefore matches the captured hosted baseline, including the
two existing text defects; it does not silently repair them. Fresh read-only
preflight and explicit approval are still mandatory immediately before remote
execution. Do not substitute a new hash or use the older generic bundle. Exact
current review artifacts are generated by `prepare_pilot.mjs` from passing proof.

Notification text repair remains a separate forward-only proposal/rehearsal gate,
preserving owners, ACLs, triggers and existing notification rows. A schema install
does not close that gate or make the pilot ready for participants. Auth callbacks
have an independent scope in the [owner packet](MERCHANT_PILOT_APPROVAL_PACKET.md).
Physical two-device QR, real mail/push, signed distribution and final feature
selection remain open. Remote behavioral acceptance has not been executed.

## Transaction and rollout limits

Local evidence proves a late failure rolls back both migrations, their ledger
records and bucket creation. After a successful future commit, preserve evidence
and stop rollout if acceptance fails; prepare a reviewed forward correction.
Do not automatically drop tables, delete users/media or undo an activated category
after real usage. Authorization must name the exact project and reviewed artifacts.

This package needs no manual visual acceptance because it changes no app UI.
The later release gate requires real devices, recovery-email/callback acceptance
and owner acceptance of the exact selected features and signed builds.
