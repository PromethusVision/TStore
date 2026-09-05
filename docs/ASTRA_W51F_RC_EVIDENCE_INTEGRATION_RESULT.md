# ASTRA W51F — Final-Main Signed RC Evidence Integration

Date: 2026-09-06 Türkiye / 2026-09-05 UTC. **Evidence integration PASS.
Binary-affecting delta NO; rebuild required NO. Exact frozen APK ready for the
separately authorized device install/launch gate; that gate has not been run.**

## Git and source equivalence

| Field | Verified value |
|---|---|
| Expected/fetched starting main | `6a1cf14639124bf709c6a988b9e8290ac7757c60` |
| Artifact SOURCE_MAIN_COMMIT | `6a1cf14639124bf709c6a988b9e8290ac7757c60` |
| Build main Git tree | `738dd23b18b5a44560c7ef6094d133c38586df4b`, independently resolved |
| Source HEAD | `0500c3030f8f64283cd79d784290d57c00279e1b` |
| Source branch | `origin/astra-release/w51e-final-main-signed-rc` |
| Merge-base | Exact starting/build main above |
| Main commits after merge-base | **0** |
| Source commits/delta | **1 commit, 1 added Markdown evidence file, 227 lines** |
| Integration branch | `integration/w51f-final-main-signed-rc-evidence` |
| No-ff merge/checkpoint | `1ea0f5edfd064eba0304e8e0d6dc35b466b1edd3`, pushed to integration branch |
| Conflicts | **NONE** |

The only source change is `docs/RELEASE_W51E_FINAL_MAIN_SIGNED_RC_RESULT.md`.
It records the clean exact-main build, unchanged tracked/external inputs through
build/freeze and the authoritative new artifact identities. The source commit and
all added text were reviewed. No Dart, Android/Gradle, pubspec, asset, dependency,
environment/runtime configuration or signing behavior changed after the build.

The verified `0716/TStore_CLEAN` worktree shares Git metadata with the canonical
CLEAN repository; the protected old TStore was not used. A complete Git comparison
outside docs is empty against build main, before and after integration. All 175
test files and 245 test PNGs are unchanged. The source evidence file remains exact.
W51F adds/updates five Markdown paths: this report, PROJECT_STATE, PARALLEL_WORK_MAP,
PRODUCT_BACKLOG and ASTRA_CALIBRATION_LOG; **6 documentation paths total** from main.

W51D's explicit final-main rebuild requirement is satisfied by W51E's new build
from 6a1cf14. W51F introduces no new binary input and therefore requires no rebuild.
The frozen artifacts remain source-equivalent to the delivered main's executable
inputs. Their actual build source remains **6a1cf14**; the later documentation
merge/evidence commit must not be misreported as their build commit.

The evidence commit is the commit containing this report. Final remote HEAD,
normal branch/main publication and clean-tree verification are reported in delivered
TASK_RESULT after the last freshness check. This report does not invent its own SHA.

## Frozen artifacts and independent verification

Directory:
`C:\Users\Mustafa\EsnaftavarReleases\w51e\1.0.0+1-main-6a1cf14\`

| Artifact | Exact filename | Bytes | SHA-256 |
|---|---|---:|---|
| APK | `EsnaftaVar-1.0.0+1-w51e-main-6a1cf14-production.apk` | 89,348,517 | `c5d8835832c4d7c050e7da85b4074813a5a99f15ecdd01c00a715693adde037b` |
| AAB | `EsnaftaVar-1.0.0+1-w51e-main-6a1cf14-production.aab` | 68,793,334 | `b785374a879dd35641c22114777a8e053565b2b28d6a766489268bf782d7eacb` |

Both files match the user-supplied frozen hashes. They remain read-only; their
paths, sizes and write timestamps are preserved (APK `2026-09-05T21:29:05.9951105Z`,
AAB `2026-09-05T21:29:06.0919823Z`). They were only read: no build, copy, rename,
re-sign, repack, overwrite or attribute change occurred in W51F. Hashes are checked
again before and after final Git publication.

Both artifact certificates match exactly:

```text
3B83D98AB8D32E0F3B9930FA837636E0E9E13219784FFCA39CEF8CAE82A6669B
```

- APK: Android apksigner verifies one RSA-4096 signer and v2 signature; AAPT reads
  **com.esnaftavar.app**, **versionName 1.0.0**, **versionCode 1** and all three ABIs.
- AAB: jarsigner reports **jar verified**; keytool independently reads the same
  certificate. A verifying JarFile pass reads **548 signed payload entries**, with
  **0 unsigned payload / 0 duplicate names**, one pinned signer per entry.
- The actual AAB protobuf manifest independently confirms **com.esnaftavar.app /
  1.0.0 / 1** and debuggable not enabled. Both files contain arm64-v8a, armeabi-v7a
  and x86_64 AOT libraries.
- All 20 excluded sample assets are absent from both files; all three approved
  Home promo images match repository artwork byte-for-byte.

Existing AAB warnings remain disclosed: self-signed upload certificate, missing
public PKIX trust chain, no timestamp and JarFile/JarInputStream signing-view
differences. Complete payload verification passes; warnings are not silently
removed and do not establish store acceptance. No AAB repair/repack was performed.

The read-only artifact checks use existing local Android/JDK tools. No keystore,
key.properties or Production JSON was opened. Source-reported external-input and
exact-secret-value scans are attributed to
[W51E's result](RELEASE_W51E_FINAL_MAIN_SIGNED_RC_RESULT.md), rather than presented
as repeated by W51F. No client-key/password value was extracted or printed.

## Validation and safety

| Gate | W51F result |
|---|---|
| `flutter analyze --no-pub` | **No issues found**, 13.2 s |
| Full Flutter rerun | **NOT_REQUIRED / NOT_RUN — evidence/docs only** |
| Existing full-suite evidence on identical build inputs | W51E **2065 PASS / 0 FAIL / 6 existing conditional skips**, 175/175 files |
| Source added-text secret/PII scan | **227 lines / 0 findings** |
| Final documentation scan / aggregate `git diff --check` | Required and passed before final publication |
| Non-document Git diff against artifact build main | **Empty** |
| Frozen APK/AAB and signer/identity | **PASS**, independently verified |

The user explicitly permits skipping a full rerun when source is truly docs-only.
Both the source and integration deltas satisfy that condition; no runtime, build
input, test or assertion changed. W51E's full run on the identical inputs is
reported as **21:19:58.763–21:21:17.176 UTC, 78.421 s**. It is preserved as source
evidence, not falsely counted as a new W51F test execution. No live test opt-in,
test weakening, new skip, golden regeneration or Android build occurs here.

Pattern scans cover private-key blocks, credential tokens including Supabase
publishable/server forms, credential assignments, email and Turkish phone forms.
Tracked-path checks find no actual key.properties, Production JSON, keystore,
private signing bundle, .env or APK/AAB. No password, actual publishable-key value,
service-role secret or private PII was added. Exact file/diff review accompanies
the scan; no universal secret-detection claim is made. Raw logs and local read-only
helpers remain ignored under `.buildlog/w51f-*` (the already existing artifact
reader is reused); they are not committed.

Backend/RPC/RLS/migrations, UI/runtime/configuration and shared components remain
unchanged. Source/main publication uses normal non-forced Git pushes. Production
access, remote Development writes, store upload, device/ADB use and Figma access
are all **0**. AGENTS.md and Astra execution protocol are unchanged.

## Handoff, metrics and calibration

Six Integration gates cover freshness/docs-only scope, frozen artifact identity,
runtime invariance/analyzer, secret/PII safety, coordination evidence and final
normal publication. Source merge checkpoint is already pushed; final remote/clean
acceptance is reported in delivered TASK_RESULT. No owner decision, shared collision
or in-scope blocker remains. Observable start **21:38:02 UTC**; TASK_RESULT supplies
the later end boundary including checks, waits, documentation and publication.

W51E worker reports **12 local phases**, **GREEN / SAME_SIZE**, and an observed
**21:10:35–21:29:06.134 UTC = 18m31.134s** through freeze, excluding final report/Git
delivery. W51F is **GREEN / SAME_SIZE** for completing its evidence-only integration
without binary change, regression, scope drift or substantive owner correction.
This is an integration acceptance record, not an additional UI implementation or
normalized model benchmark. No arbitrary time threshold determines success.

**READY_FOR_DEVICE_INSTALL_LAUNCH_GATE YES** means the exact frozen APK above is
the candidate for a separately authorized controlled device task. Do not rebuild
it before that gate; a different hash is a different candidate requiring new
evidence. The actual install/launch gate remains **OPEN / NOT_PERFORMED**.
Physical two-device QR follows device smoke; Production remote proof, Merchant,
legal/privacy, support and store gates remain OPEN. No commercial launch approval
or remote/device authority is inferred from local readiness.

Next recommended package: one coherent controlled install/launch smoke using the
frozen APK identity, under separate explicit device authority. Preserve the APK/AAB
and their source lineage throughout; do not replace them with the older W51C-R pair.

```text
W51F_RC_EVIDENCE_INTEGRATION: PASS
W51E_EVIDENCE_MAIN: PASS
FROZEN_APK_HASH_PRESERVED: PASS
FROZEN_AAB_HASH_PRESERVED: PASS
SIGNING_CERT_MATCH: PASS
BINARY_AFFECTING_DELTA: NO
REBUILD_REQUIRED: NO
SECRETS_COMMITTED: NO
PRODUCTION_ACCESSED: NO
DEVICE_INSTALL_PERFORMED: NO
STORE_UPLOAD_PERFORMED: NO
READY_FOR_DEVICE_INSTALL_LAUNCH_GATE: YES
```
