# Merchant pilot launch preparation — J4

17 October 2026. **LOCAL PREPARATION PASS. Remote C/E changes NOT AUTHORIZED.**
Base main: `ad42c92d558624d693f0b831a5b4ed8d7a7a5d22` (integrated J3).
Branch: `agent/merchant-pilot-launch-preparation`. Main merge remains Integration
Agent's responsibility. No Production access, hosted write, account creation,
role grant, email send, category activation or catalog provisioning occurred.

## Delivered scope

- A separate, forward-only E proposal corrects six Turkish literals in the two
  existing notification functions. It uses the canonical0006 bodies, retains old
  notifications and all recipients/action metadata, and introduces no push system.
- An atomic review wrapper binds the installed Development schema, exact source,
  distinct review token, advisory/table locks and bounded timeouts. It verifies
  both corrected definitions, preserves function OIDs/owners/ACLs/configuration,
  compares the entire unrelated schema projection, and adds one new ledger record.
- Source code remains under `supabase/proposals/`, outside migration discovery.
  Never execute that bare proposal remotely or replay0006. The reviewed wrapper
  is the only E application candidate and still requires explicit approval.
- A source-bound offline bundle supplies E preflight/candidate/postcheck, the
  existing exact four C callbacks, a privacy-minimized intake template/report,
  anonymous cohort slots and category eligibility inventory. It never emits an A
  replay or account/catalog provisioning SQL. B SQL requires explicit leaf IDs.
- An [intake guide](MERCHANT_PILOT_INTAKE_GUIDE.md) connects real participant/product
  preparation with account ownership, Customer pairing, device/mail and release
  evidence. Unknown facts stay missing; even fully checked self-reported flags
  cannot authorize distribution or remote provisioning.

## Exact E review identity

Target: **EsnaftaVar Development / `tnipyxnvhgelwdpykyez`**.

| Item | Value |
|---|---|
| Plan SHA-256 | `9545ccd2900ca25e01546ff5068e57e4d3e84c23110fb235c65fabf541df5890` |
| Required installed baseline MD5 | `6b26d924c04ad9aa568f15bfcf3279bf` |
| Source | `supabase/proposals/pilot_notification_text_repair_v1.sql` |
| Source LF SHA-256 | `529836466b799df8c59ecbfa688e7f54f8d495c271c20663213be08bff0b3f96` |
| Proposed new ledger entry | `20261017003200 / 0032_pilot_notification_text_repair` |
| Local proved post-schema MD5 | `78f248b24aa67f7befcc7ccdb9ec97bd` |
| Chat function after MD5 | `99dd8841f5092b10634f25109e99f3b3` |
| Purchase function after MD5 | `c1f3e83146c67dc68b74d34dd692e311` |

Expected future user-visible text: “Yeni mesajın var”, “Alışverişin onaylandı”,
“Bir kullanıcı”, “Mağaza” and their two existing body templates in correct UTF-8.
The source changes text only; existing malformed rows are not rewritten.

The token prevents accidental execution; it is not database identity or human
authorization. Before any approved application independently verify the target,
fresh baseline, absence of competing preparation and exact bundle hashes. Insert
the matching transaction-local token after outer BEGIN only after authorization.
The wrapper normalizes the embedded two definitions and ledger SQL to LF on the
server, so a Windows editor cannot silently change their expected hashes.
On failure the whole operation rolls back. After a committed operation, preserve
evidence and propose a forward correction; do not auto-delete history or drop
objects. Replay rejects the changed baseline rather than repairing history.

## Read-only hosted comparison and local mirror

Fresh hosted metadata inspection still matched J3's full post-schema fingerprint.
Twelve of thirteen metadata components matched the initial local post-A fixture;
only the functions component differed. All22 newly installed A functions had the
same settings and effective permissions, with CRLF stored in their bodies. The
other50 functions were unchanged. No remote function was rewritten.

`merchant_pilot_post_a_observation.json` records raw/normalized function hashes
and component hashes only; no credentials, accounts or row contents. Its pinned
LF SHA-256 is `7aa7e8448787987f0ee22511da41b12e055fdc326516d03e5ef91332b058e5a3`.
The local mirror obtains executable definitions from the unchanged, locally
applied migrations, checks normalized hashes, changes only body line endings,
checks the expected raw hashes, then requires the original full hosted MD5.
Unknown executable/permission differences abort. No expected hash is substituted.

The attempted fresh Auth URL-page observation did not complete because the
dashboard SQL overlay could not be dismissed reliably. C therefore deliberately
retains the previous dated observation, rather than claiming a fresh settings
read. No Auth field was edited or saved. Reread C immediately before application.

## Validation

- **46 Node checks PASS**: existing29 plus14 launch contract/mirror checks and3
  bundle checks. They reject changed source, stale/incomplete evidence, target
  substitution, output escapes, private intake fields and unrelated Auth changes.
- **18 managed local groups PASS** on PostgreSQL/Auth/PostgREST/Storage with the
  matched post-A baseline: source corruption reproduced; wrong/old tokens; drift
  across RLS/function/grants/defaults/ledger; competing writer; late rollback;
  Windows input; unrelated trigger and function-owner mutation; exact upgrade;
  replay; shop/profile/blank-name fallbacks; self-chat; purchase snapshot/fallback;
  real Auth inbox isolation/forgery denial; owner-only mark/delete; unchanged gates.
  Purchase events are synthetic local database fixtures, not physical QR proof.
- **144 targeted Flutter tests PASS**: pilot configuration, real-SDK recovery
  races, account/recovery backends, pilot auth widgets and existing notification
  repository/cubit behavior. No app code or Customer UI changed.
- `flutter analyze --no-pub`: **PASS**, no issues. No APK was built in this package.

Evidence: [managed proof](data/merchant_pilot_launch_acceptance.json),
[post-A observation](data/merchant_pilot_post_a_observation.json), and
[validation summary](data/merchant_pilot_launch_validation.json).

Earlier attempts are not hidden: the first fixture correctly refused the LF/CRLF
fingerprint mismatch. The second reached the owner mutation test, but PostgreSQL
rejected its injected new owner before the candidate guard because that role
lacked schema CREATE. The final test supplies/revokes that permission only inside
the rollback-only fault injection; the actual repair candidate has no GRANT.
The final fresh run passed all18 groups. A Docker address-pool issue was resolved
by removing only this task's label-verified, stopped, empty networks. All fixture
volumes/evidence were retained; no foreign Docker resources were removed.

## Local reproduction and review-bundle generation

Use the existing pinned Node/Flutter dependencies. Run socket tests while the
owned stack is stopped. Each managed proof requires a new empty owned run.

```powershell
node --test tool/merchant_acceptance/safety.test.mjs tool/merchant_acceptance/docker-proxy.test.mjs tool/merchant_acceptance/pilot_contract.test.mjs tool/merchant_acceptance/pilot_preparation.test.mjs tool/merchant_acceptance/prepare_pilot.test.mjs tool/merchant_acceptance/pilot_launch.test.mjs tool/merchant_acceptance/prepare_pilot_launch.test.mjs
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <printed-new-owned-run>
node tool/merchant_acceptance/pilot_launch.mjs <same-run>
node tool/merchant_acceptance/local.mjs stop <same-run>
node tool/merchant_acceptance/prepare_pilot_launch.mjs new-review-name
```

The CLI writes `.buildlog/pilot-launch-review/<name>` once, refuses redirected or
existing output, and verifies the complete current source-bound proof first.
Each artifact has an LF SHA-256 in `bundle.json`. An optional second plain name
loads `.buildlog/pilot-intake/<name>.json`; unknown/private fields are rejected.
These files are proposed review artifacts, never an executable remote command.

Targeted Flutter reproduction:

```powershell
flutter test --no-pub test/unit/merchant/merchant_pilot_config_test.dart test/unit/merchant/merchant_recovery_sdk_race_test.dart test/unit/merchant/merchant_account_recovery_test.dart test/unit/merchant/merchant_recovery_backend_test.dart test/widget/merchant/merchant_pilot_auth_test.dart test/unit/notifications/notification_repository_impl_test.dart test/unit/notifications/notifications_cubit_test.dart
flutter analyze --no-pub
```

## Independent remaining approvals

**C:** Add only the four exact callbacks in the owner packet, preserving every
existing URL and Site URL/SMTP/confirmation setting. Plan identity from the prior
empty-list observation remains `70aa95a39563af8cc4951643e84dc74c886fdd49eabf31b1906a39b4036fcd35`.
Actual fresh settings must be compared before applying; configuration matching
does not prove real mail delivery, PKCE acceptance or physical app callbacks.

**E:** Apply only the exact guarded correction identified above, after approval
and fresh matching preflight. No old notifications or other functions change.

**B/D:** Actual merchants, product leaves and catalog preparation are still
unselected. No global activation, service listing, catalog-decision enablement,
merchant-role grant or account/email provisioning is implied. Production,
provider credentials, real mail/device acceptance, signed distribution and final
Product Owner pilot launch remain separate gates. Local PASS is not pilot-ready.
