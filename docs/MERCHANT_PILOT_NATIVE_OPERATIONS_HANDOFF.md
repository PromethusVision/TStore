# Merchant native Android operations — 2026-10-20

Status: **local acceptance PASS; Integration review pending; pilot opening OPEN**.
Branch: `agent/merchant-pilot-operational-recovery`.
Baseline: `0c1ad8d5d5615e34e590e86656abc4e593394925` (integrated J12).
Canonical authority: §§4.1–4.5, §4.16 / J13. No FROZEN exception.

## Result and purpose

J12 verified actual services through Flutter widget/repository tests, and separately
observed an offline native bootstrap. This package connects the unchanged real
Android Merchant application to owned loopback Auth, REST, Storage and PostgreSQL.
It closes a specific evidence gap: actual Android preferences/session persistence,
process recreation, gallery selection and network image rendering.

The application needed **no runtime correction** for these observed scenarios.
No Customer layout, Dart runtime, dependency, Android configuration, migration or
feature default changes. New code is local acceptance tooling. The shared Auth,
notification and catalog foundations remain unchanged.

## Completed scope

| Unit | Result | Evidence |
|---|---|---|
| Native fixture and isolated device tools | PASS | Exact J8 raw schema; generated synthetic identities; exact named AVD; offline checks before actions |
| Android operations and recovery | PASS | 11 checkpoints below; real installed app, UIAutomator and inspected screenshots |
| Independent server/Customer checks | PASS | Seven snapshots: original price, unsaved draft, photo, unavailable, inactive, reactivated, final |
| Reproducible handoff and regression | PASS | Guard tests, full Flutter/analyzer, source/APK binding and explicit remaining gates |

All four units completed. No UI design/Figma work was required.

1. Native login and owned shop creation.
2. Process termination/relaunch restores the session, shop and `123.45` listing.
3. Service-notification preference survives process restart; marketing stays OFF.
4. Removing ADB reverse breaks the only API connection. Background/resume hides
   the stale workspace behind the access failure screen. Restoring the connection
   and explicit retry recovers the same account without an extra login.
5. A `234.56` price draft survives background/resume while DB/Customer still read
   `123.45`. Only the subsequent Save changes the listing.
6. Android's real system photo picker selects the repository logo as synthetic
   gallery material. The app uploads and publishes it, and renders it natively.
7. Photo remains visible after process restart. A separately authenticated Customer
   signs/downloads the exact **437,090 bytes**, SHA-256
   `a87dc38bcd50dd2650c71257e664c744ad28982f8eddd452f50029c6fe25fb30`.
8. Unavailable and inactive states each remove the offer and media from Customer
   reads. Reactivation restores the same listing at `234.56`, without duplicates.
9. Logout survives process restart. A Customer-role login is denied the workspace.
10. Another merchant sees an empty owned product list and its own default
    preferences, not the first merchant's saved preference.
11. The original merchant returns to its existing listing, saved preference and
    own inbox. The foreign shop and foreign notification remain untouched.

The seven server observations each preserve the exact installed schema, zero
central-price sentinel, `listing_only_v1` marker, decisions OFF, one listing and
zero verified purchases. They are local observations, not hosted data checks.

## Validation and artifact

- Full Flutter: **2,998 PASS / 0 FAIL / 6 existing SKIP** (2m20s test runner).
  Log: `.buildlog/native-package-full-tests.log`.
- **51 Node tests PASS / 0 FAIL**: six new native guards plus 45 existing
  UI/current-preparation/paired-device guards. Wrong device, online network despite airplane
  flag, ambiguous UI selectors, real-account input, shell syntax and incomplete
  observations are rejected.
- Analyzer: **PASS, no issues**, `.buildlog/native-package-analyze.log`.
- Native Android build: PASS, `merchantDevelopment`, `android-x64`,
  `lib/main_merchant_development.dart`, debug `1.0.0 (5)`.
- APK: **105,323,156 bytes**, SHA-256
  `bd853b81160189ff088d85c5530f78d8364be63f43bb187fe8a02077d06d4012`.
  Package `com.esnaftavar.app.merchant.dev`; debug certificate
  `2e938b2733f51283c2c300974ec2aee9409d1799ec423eab1a51512e26e17a95`.
- Existing 782-file runtime/build source fingerprint:
  `9d95c7757b5adf2f818e6bffa69ffff77eeb8a3ef0072404e5b5534ff46029ba`.
  It matches J12's runtime sources; historical UI/current preparation remains fresh.
- Actual APK inspection checks package/version/ABI/debug mode, backup and cleartext
  defaults, signature, local endpoint/anonymous key in the executable payload and
  absence of the local server key or synthetic account credentials.
- Final running process log: no critical Flutter exception, overflow or fatal
  runtime error. Local Realtime service is absent; no Realtime/provider acceptance
  is inferred from native inbox reads.

This APK is a disposable local emulator artifact, **not a phone distribution**.
It is not the hosted `merchantPilot` flavor. Customer compatibility was checked
through actual local HTTP/media reads and the full Flutter suite; a new paired
Customer APK was not needed because the runtime/build sources are unchanged.

[Sanitized evidence](data/merchant_pilot_native_operations_acceptance.json) binds
source/tool hashes, the artifact, 11 screen/XML hashes and seven server observations.
Raw screenshots/XML and the copied APK remain in the task's ignored fixture
directory. Hashes establish drift detection, not a signed human/device attestation.

## Reproduction

Use installed Node, Flutter, Docker Desktop, Android SDK build tools35 and Android
35 Google Play x86_64 system image, plus the existing Java runtime. No dependency
upgrade, SDK download, shared emulator or hosted credential is required.

1. Run `node tool/merchant_acceptance/local.mjs prepare`; use its fresh run directory.
   Start it with `local.mjs start <run>`. If Docker's default pools are exhausted,
   first create a distinct empty task-labelled network with an unused private
   subnet, exact `<project>-network` name and loopback binding. Never prune others.
2. `node tool/merchant_acceptance/native_fixture.mjs <run>` creates the exact
   installed-profile fixture using unchanged historical source contracts, existing
   category/role/publication wrappers and four `example.invalid` accounts.
3. `native_prepare_android.ps1 -RunDirectory <run> -AndroidSdk <sdk> -JavaHome <jbr>`
   creates a fresh private AVD. Wait for boot, then run
   `node tool/merchant_acceptance/native_device.mjs <run> <sdk> isolate`.
   Every later device action checks the exact named AVD and network isolation.
4. Build:
   `flutter build apk --debug --no-pub --target-platform android-x64 --flavor merchantDevelopment --target lib/main_merchant_development.dart --dart-define-from-file <run>/native/build.json`.
   Verify the package, then install **only** on the exact task AVD `emulator-5582`.
   Connect the owned API with `native_device.mjs <run> <sdk> connect`, then `launch`.
5. `screen` reads/redacts the current UI; `tap <exact-label>`, `input <visible-index>
   <synthetic-text>`, `tab <0..4>`, `scroll up|down`, `back`, `home`, `restart` and
   `login merchant|other|customer` perform the observed steps. `photo-fixture`
   supplies the known logo through the actual Android picker. No picker mock,
   test-only Flutter entrypoint, auto-granted media permission or direct app-state
   injection is used. Select the known fixture thumbnail, not a captured screenshot.
6. `capture <unused-name>` retains each observed checkpoint; see `native_evidence.mjs`
   for required names/labels. `native_observe.mjs <run> <unused-name>` performs
   independent local DB/Customer reads. The seven expected state names are also
   defined in that evidence verifier. Outputs cannot be overwritten.
7. `native_evidence.mjs record <run> <sdk> <java-exe>` validates the files, exact
   unchanged baseline and actual APK before creating the record. `verify` checks
   source/shape freshness only; it does not rerun Android or attest physical use.
   A fresh independent run should keep its own evidence instead of overwriting
   this delivery's dated record.
8. Stop the exact AVD using `native_device.mjs <run> <sdk> stop`, then stop only the
   owned stack using `local.mjs stop <run>`. Remove the synthetic `fixture.json`
   and `build.json` from that exact ignored native directory. Retain DB volumes
   and observations; remove only the task's empty labelled network if desired.

The supplied AVD creation script reflects the commands exercised in this task;
existing-device adoption and directory reuse fail closed. Actions are intentionally
observed, not a blind timed tap sequence. Screens/OS language differences require
fresh selectors and review. No action accepts a physical-device serial or endpoint.

## Failures retained and corrected during preparation

- Android network teardown was asynchronous: checking immediately after toggling
  airplane mode still found an active network. The helper now waits boundedly
  for the full offline state; no app was installed/used before isolation passed.
- The first independent Customer observation used the HTTP helper's default POST
  instead of GET and was rejected. The observer now specifies GET explicitly.
  No PASS record was produced for the rejected attempt.
- Initial screenshots stored on shared storage appeared in the photo picker and
  the first selected image was a synthetic screen capture. It was retired through
  the app; the known logo was selected and byte-verified. Captures now use Android
  shell-private temporary storage. The earlier local observation is retained.
- Kotlin emitted the existing Windows cross-drive incremental-cache warning and
  completed successfully through its fallback. No build configuration was changed.
- The first combined Node run passed 48 tests but three existing junction tests
  could not create their temporary directory links under the restricted Windows
  sandbox (`EPERM`). The unchanged 51-test set then passed with the required local
  permission. No test was weakened or skipped. Log: `.buildlog/native-node-tests.log`.
- New tool hashes normalize LF for portable Git checkout validation; runtime APK
  fingerprint retains the existing exact-byte build contract.

The task-owned emulator and five local services were stopped after acceptance.
The synthetic login/build input files were removed; local DB volumes, screenshots,
APK and logs were retained. No other AVD, phone, container, volume or network was
modified. The preliminary aggregate record remains private historical output.

## Remaining pilot gates

Production and hosted Development access/writes: **NONE**. Remote migration apply:
**NO**. Real email/provider operation: **NONE**. No main merge or main push.

Real merchants and products are still unspecified. This work cannot replace
selected category/account/catalog approval, a compatible approved phone build,
physical two-device QR/camera acceptance and the owner's pilot-opening decision.
Hosted Merchant recovery remains the separately recorded prior owner acceptance.
Android emulator gallery/disk evidence does not certify all manufacturers or
physical hardware. No deferred financial/Ads/trust capability is activated.

Recommended next package: a **bounded real-cohort field session**, once at least
one actual merchant and its initial physical products are selected. Existing
current preparation can generate exact review candidates; obtain the applicable
hosted-write approval before executing them. More generic local preparation must
not be presented as opening the pilot.

Integration: review these tools/docs/evidence and unchanged runtime, run Node
guards and freshness checks, inspect full Flutter/analyzer logs. Merge Git only;
do not replay fixture SQL remotely or distribute the local APK. Shared files are
canonical/slices only. Central coordination documents remain Integration-owned.

Calibration: **GREEN** for the four scoped local units; 4/4 complete, no critical
runtime regression, no FROZEN change, no owner correction, no shared-code collision.
Exact whole-turn start/elapsed is `NOT_OBSERVABLE`; no minimum duration is claimed.
The observed native preparation/acceptance window began by 10:52 UTC, and the
source-bound acceptance record supplies its end timestamp. Follow-on package size:
`SAME_SIZE`, four coordinated field units (selected intake, authorized provisioning,
compatible phone artifacts, physical acceptance), dependent on actual participant
facts and applicable approvals. This is a recommendation, not authorization.
