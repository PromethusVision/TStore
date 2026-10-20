# Merchant daily pilot journey — 2026-10-20

Status: **PASS — local implementation and rehearsal; main integration pending**.
Branch: `agent/merchant-pilot-nightly`.
Baseline: `be34fcae6a2f3152ae31f56e6c766d069cd6faf0`.
Authority: canonical §§4.1–4.3 and §4.13; J12 implementation. No FROZEN exception.

## Problem and behavior

The inbox could wait indefinitely when its list/count request did not return;
a thrown read could leave loading active. Reads now have individual 15-second
deadlines with explicit retry. Pagination errors preserve visible rows, a failed
secondary count retains the existing visible-item fallback, and expired results
cannot replace a fresh attempt. No write is cancelled/retried by this deadline.
This is the existing shared notification controller; Customer presentation is
unchanged and its notification regressions are included.

Review also reproduced premature inbox readiness when a live event arrived while
the initial page or count was pending. The pending read could overwrite write
flags and allow another submission. Live revisions are now buffered without
leaving Loading until that read settles; newer content survives the merge. Two
controlled stream regressions prove loading and exactly one permitted write.
This is deterministic client concurrency coverage, not a hosted Realtime test.

After a server-committed profile or product save whose acknowledgement was lost,
explicitly leaving the editor could retain the old shop name or price. Product
routes now refresh owned listings/dashboard on return; shop profile return quietly
revalidates access. The existing unchanged-session draft preservation and changed
shop revision invalidation rules continue to apply. No additional save is sent.
The common product route guard also covers the submissions button.

## Validation

Five intended regressions were reproduced before the runtime fix: thrown inbox
read, unanswered first page/count, stale price and stale profile after uncertain
exit. The profile fixture's save-button selector was corrected before its red
run. All five passed after the fix.

- **Full Flutter: 2,998 PASS / 0 FAIL / 6 existing SKIP**, on the final runtime
  sources. Includes all 13 new regressions (11 inbox + 2 uncertain exits), in
  addition to the initial 193-test adjacent set. The adjacent notification and
  uncertain-exit run passed 146 tests.
- **Analyzer: PASS**, whole project, no issues. Explicit local test also checked.
- **17 new Node guards + 28 existing paired-device guards: PASS.** Changed/added
  sources, missing/partial proof, wrong process nonce, different runtime delta,
  historical SQL/proof tampering, private fields, path escape and overwrite refusal.
- **Current UI: 15 checkpoints + 6 independent DB checks PASS**, on real local
  Auth/REST/Storage. Both uncertain writes consume a successful server response,
  then deliberately lose acknowledgement; fresh UI/Customer reads and one-write
  counters prove recovery without duplicate saves.
- **Current repositories: 18 checkpoints + 6 DB checks PASS**, matching the final
  UI source manifest. This executes the unchanged original repository suite on the
  current client, including ownership, optimistic revision, media, submissions,
  notification isolation and synthetic legacy QR purchase/replay.
- **Customer Development + Merchant Pilot ARM64 debug APK: PASS**, rebuilt from
  committed final sources. The existing
  pair tool also ran 135 compatibility tests and verified package/callback identity,
  signature, version, required permissions, payload markers and artifact bytes.
- **Native Android offline smoke: 9 observed checkpoints PASS** on a new owned
  Android 15 emulator, including cold/warm invalid callbacks and 130% system text.
  This uses a separate x64 Merchant artifact, not a physical-phone acceptance.

Full test log: `.buildlog/nightly-full-tests-delivery.log`. Pair receipt/artifacts:
`.buildlog/pilot-device/nightly-daily-journey-delivery/`. These are **synthetic compilation
rehearsals, not distributable candidates**. Both are version `1.0.0 (5)` with
business flags OFF. Pair source fingerprint:
`9d95c7757b5adf2f818e6bffa69ffff77eeb8a3ef0072404e5b5534ff46029ba`.
The receipt records `5b518dc2061fa24dcb2bd8f826f4a8e3aa21cd2a` and
`uncommitted_sources: false`. Its manifest identifies the actual compiled files;
the final documentation-only checkpoint does not change them. Both APK bytes and
current sources were independently rechecked by `review_pair.mjs`.

## Current screen rehearsal

The new runner and screen test use owned loopback Auth/REST/Storage and synthetic
identities only. Historical J7/J9 proofs are not
current UI proof: source changes correctly make their old client binding stale.
The runner verifies the original installation inputs at immutable integration
commit `62e7ba4a4839abc190fd6bf8493c2709a333b861` in a private snapshot, uses the
unchanged exact-schema verifier to construct the database, then exercises today's
client sources separately. No historical hash or acceptance report is rewritten.

The UI covers login/onboarding, profile, catalog selection, exact listing prices,
availability, deactivation/reactivation, photo publish/remove, shared inbox,
logout, denied Customer role, another merchant's own workspace and fresh login.
Availability-off and inactive listings disappear from Customer purchase offers;
owned records remain editable. Tagged central price stays zero, never an offer.

Platform seams are explicit: gallery selection supplies a local PNG; device
preferences use an in-memory platform adapter. The real push cleanup coordinator
still executes. Widget network-image rendering retains Flutter's test binding;
Storage bytes and the Customer signed photo URL are downloaded independently
through a loopback-only HTTP client. No camera, gallery permission, disk durability,
external push, phone image rendering or physical two-device acceptance is claimed.

During harness development, selectors/timing for onboarding, animated routes and
the final fresh-session price were corrected; Customer's existing availability
filter and the missing device-preferences adapter were reflected in the harness.
These unsuccessful attempts produced no PASS proof. Each full attempt used a new
owned empty local stack, preserving previous data. No remote fallback or reset.

## Current offline preparation

The old J9 command correctly rejects current main because the later integrated
session fix changed its bound `merchant_runtime.dart`. It remains unchanged and
fail-closed. The new `prepare_current_pilot.mjs` requires:

1. The exact pinned J9 evidence (32 historical database groups, not rerun or
   relabelled here), with every bound server/preparation/repository source unchanged.
2. Only the exact already integrated runtime-composition hash
   `8e98dd26dfad99b46072547b771dd5f0ef76cdbe40bb70a6f537f3461f0bcafa` as a renewal.
3. Both new current-code records, matching the same **627-source manifest**,
   including every Dart file under `lib`, dependencies and the preparation tools.

Records: [UI acceptance](data/merchant_pilot_ui_acceptance.json) and
[current repositories](data/merchant_pilot_current_repository_acceptance.json).
Any source addition/removal/change, different runtime delta, incomplete record or
historical contract change refuses preparation before producing a review directory.
JSON records are reproducible local evidence, not signed attestations or remote
authority. Integration still reviews and independently verifies the source.

The new entrypoint reuses `installedReviewFiles` and private intake parsing. SQL
is byte-for-byte identical to the existing category/role/publication candidates;
exact schema/data/authority locks, distinct approval tokens, atomic receipt and
replay guards remain. No installer, account creation, connection flag or apply
operation is added. With unknown real participants/products, defaults emit only
incomplete intake plus read-only observation queries.

```text
node tool/merchant_acceptance/verify_pilot_ui.mjs
node tool/merchant_acceptance/prepare_current_pilot.mjs cohort <new-output-name>
node tool/merchant_acceptance/prepare_current_pilot.mjs publication <new-output-name>
```

Optional third argument is the existing private intake name under
`.buildlog/pilot-installed-input/<cohort|publication>/`; original observation and
taxonomy sidecars are still required. No real intake is invented in this package.

Both default paths were executed on the final matching evidence into
`.buildlog/pilot-current-review/nightly-delivery-cohort/` and
`.buildlog/pilot-current-review/nightly-delivery-publication/`. Both report
`INCOMPLETE_NO_MUTATION`, no private identities, no review mutation SQL and no
remote authority. The earlier `nightly-current-*` bundles predate the final
live-event fix and are retained only as historical local output.
Current combined source-manifest digest:
`b11849d344ea23c19cf5a618dc4c39bd128101f99452e42109f86a58248ea6ae`.

To reproduce real-service evidence, prepare/start a **separate new** owned local
stack for each command (ports 55431/55432, loopback only); stop it before starting
the other. Existing populated fixtures are intentionally rejected, never reset.

```text
node tool/merchant_acceptance/pilot_ui.mjs <new-local-run> <flutter-sdk>
node tool/merchant_acceptance/pilot_ui.mjs <another-new-local-run> <flutter-sdk> repositories
node tool/pilot_device/review_pair.mjs nightly-daily-journey-delivery
```

The local runner needs Git history for immutable installation commit `62e7ba4a`.
Docker default address pools were exhausted on this machine; task-labelled empty
networks used distinct explicit private subnets. Only this task's stacks are
stopped; all eleven task-owned empty networks were removed after checking their
exact labels and empty container lists. Test volumes and prior projects/networks
were retained. No global Docker cleanup was used.

## Native Android offline follow-through

The installed SDK contained Android 15's Google Play x86_64 image and usable WHPX.
A new Pixel 5 AVD was created under `.buildlog/android-offline/`, using private
`ANDROID_USER_HOME`/`ANDROID_AVD_HOME`, a hidden headless process and disabled
cameras/audio. Before installing either app, airplane mode, disabled Wi-Fi/data,
no active default network and an empty current-network list were verified. No
real account or credential was entered. Network isolation was rechecked at exit.

The ARM64 phone APK installed but could not load Flutter on this x64 emulator
(`EM_AARCH64 instead of EM_X86_64`). This was an environment mismatch, retained
as a failed attempt, not concealed or labelled a phone runtime failure. A separate
Merchant APK was built with `--target-platform android-x64` from the same committed
sources and byte-equivalent synthetic configuration. No application/Gradle change
or new dependency was needed. The original ARM64 pair remained byte-identical.

Observed through Android's package resolver, UIAutomator, actual screenshots and
the final running process log:

- Cold launch reaches the real login screen; blank fields show local validation.
- Invalid recovery text is rejected; background/resume retains the draft.
- Both installed callback schemes resolve to exactly their own application.
- Token-free `?error=access_denied` callbacks are rejected in warm and cold starts,
  without exposing a private workspace or password-update form.
- Normal cold relaunch remains usable at system font scale 1.3; screenshots were
  visually inspected. The final x64 process had no critical Flutter/runtime log
  errors. Earlier ARM64 loader errors are explicitly outside that log assertion.

The Customer app was installed for resolver checks only; its native runtime was
not exercised. This does not certify real login, mail, hardware, external push,
disk persistence of an authenticated session or physical two-device QR. The owner
previously accepted the real Merchant mail/reset path; this run does not repeat it.

[Android offline evidence](data/merchant_pilot_android_offline_acceptance.json)
binds the source, signature, separate APK and nine observed checkpoint files.
Screenshots/XML remain under `.buildlog/android-offline/`; their hashes are in the
record. This is an observed local smoke record, not a signed/automated field
certificate. The exact named emulator was stopped afterward; its data/evidence
were retained and no user's phone or existing AVD was modified.

## Delivery checkpoints

- `1030ac0c415806b634fe3e4b5fc2be5d1875a834`: runtime fixes and 13 regressions.
- `5b518dc2061fa24dcb2bd8f826f4a8e3aa21cd2a`: current screen/repository evidence,
  preparation entrypoint and contracts. Both checkpoints pushed to the task branch.
- Final documentation-only checkpoint closes Android/evidence reporting. Use the
  task branch's final HEAD for integration, not either intermediate checkpoint.

The final scope is 19 files. Secret/private-email scan and diff checks passed;
there are no historical migration, dependency or centralized coordination edits.

## Boundaries

Production access/writes: **NONE**. Hosted Development access/writes: **NONE**.
Local fixture migrations are not remote migration application. No real account,
catalog publication, provider setup, new dependency or economic activation.
The owner temporarily lifted hosted approval limits for this task; none of the
selected work currently requires a hosted mutation. Permanent policy remains.
Only Integration Agent merges/pushes main. Physical two-device QR, actual merchant
cohort, device gallery/permissions and pilot opening remain separate OPEN gates.

Shared review areas: notification controller, canonical/slices and the new local
preparation entrypoint. No dependency, historical migration, frozen Customer layout,
Auth foundation, signing policy or central coordination document changed. The
shared inbox behavior is covered by the full Customer/Flutter suite.

Integration must verify this task branch's exact source, current proof freshness,
full Flutter/analyzer and Android compatibility against then-current main. No
hosted SQL, account provisioning, APK distribution or automatic main merge is part
of this delivery. This package improves local pilot readiness; it is not a claim
that real merchants can be admitted without the remaining field/product gates.
