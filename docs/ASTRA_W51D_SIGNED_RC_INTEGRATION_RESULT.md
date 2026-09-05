# ASTRA W51D — Signed RC Evidence Integration

Date: 2026-09-05 UTC. **Integration PASS; exact APK/AAB preserved; final-main
rebuild REQUIRED under the task's explicit lineage rule.** No Production access,
store upload, device/ADB operation or new artifact generation occurred in W51D.

## Git and the two lineage comparisons

| Evidence | Result |
|---|---|
| Expected/fetched starting main | `813f16f54d27b6a25a07cb708fc78244a5e4c791` |
| Required source HEAD | `a18c6813c45136f863b2dbf7057748486b661b90` |
| Source branch | `origin/astra-release/w51c-signed-rc-candidate` |
| Exact merge-base | `813f16f54d27b6a25a07cb708fc78244a5e4c791` |
| Main commits after merge-base | **0** |
| Artifact build source | `633f5c91de85c080417557ea51bee344a4a03907` |
| Integration branch | `integration/w51d-signed-rc-evidence` |
| No-ff merge/checkpoint | `ce99a033647b64eb1256ab75676499e2d294c629`, pushed to integration branch |
| Source delta against starting main | **2 files: pubspec.yaml and the W51C result document** |
| Build-to-source-HEAD delta | **W51C result document only** |
| Conflict / extra Integration executable changes | **NONE / 0** |

All three source commits were reviewed, including their added-text secret scan:

1. `cc7ffc980ee9b4cbb6cda48d039dae85416e8dc6`: initial incomplete-input evidence.
2. `633f5c91de85c080417557ea51bee344a4a03907`: Production sample-asset scoping.
3. `a18c6813c45136f863b2dbf7057748486b661b90`: exact signed artifact evidence.

Source is fresh and descends directly from starting main. The known binary-affecting
change is **pubspec.yaml**, absent from starting main but included in build source
633f5c9. It adds default flavor development and excludes 20 unused sample images
from explicit Production packaging, preserving three approved Home fallback images.
Dependencies, lockfile, version, Dart runtime, Android signing/configuration,
manifest, actual asset files, tests and backend do not change.

**The comparisons must not be conflated:**

- Starting main → W51C-R source: **binary-affecting delta YES**, pubspec.yaml.
- Artifact build 633f5c9 → source HEAD / integrated tracked inputs:
  **binary-affecting delta NO**; all non-document tracked files match build source.

The user explicitly requires a rebuild when W51C-R introduces binary-affecting
source/configuration not already in main. That condition is true even though the
provided artifacts already contain 633f5c9's asset fix. Therefore **REBUILD_REQUIRED
AFTER_INTEGRATION YES** and **READY_FOR_DEVICE_INSTALL_LAUNCH_GATE NO** apply to the
final-main candidate. The existing files remain valid evidence for their exact
633f5c9 lineage; W51D does not relabel them as a final-main RC or invoke the
docs-only physical-smoke exception. No rebuild is performed by this integration.

`BINARY_AFFECTING_DELTA_AFTER_BUILD: NO` means exactly the second comparison;
it does not override the explicitly required first-comparison policy. This report
records both so the NO flag cannot be mistaken for permission to skip rebuilding.

The verified Codex `0716/TStore_CLEAN` worktree shares Git metadata with the
canonical CLEAN repository. Both source files remain exact. Integration adds or
updates five Markdown files: this report, PROJECT_STATE, PARALLEL_WORK_MAP,
PRODUCT_BACKLOG and ASTRA_CALIBRATION_LOG; **7 changed paths total** from main.
The evidence commit is the commit containing this report. Final remote commit IDs,
normal branch/main push and clean-tree verification are recorded in TASK_RESULT.

## Authoritative files: unchanged

Directory:
`C:\Users\Mustafa\EsnaftavarReleases\w51c-r\1.0.0+1-633f5c9\`

| Artifact | Exact file name | Bytes | SHA-256 |
|---|---|---:|---|
| APK | `EsnaftaVar-1.0.0+1-w51cr-633f5c9-production.apk` | 89,348,517 | `3f13d97d5549c5f033addd5e1f8a1b26c5cbe6faf3c77f589460b246cf9899e1` |
| AAB | `EsnaftaVar-1.0.0+1-w51cr-633f5c9-production.aab` | 68,793,338 | `f81e6c91346a26246bc4ebfe05cb9accc2004cf5f9723792a0019b95cc7275d1` |

Both hashes match the user's authoritative values before and after validation.
Paths, sizes and write timestamps also remain unchanged: APK
`2026-09-05T20:32:03.0863625Z`, AAB `2026-09-05T20:32:03.4684787Z`.
The files were only read; no copying, renaming, resigning, repacking or overwriting.

Both certificates match the supplied existing upload identity:

```text
3B83D98AB8D32E0F3B9930FA837636E0E9E13219784FFCA39CEF8CAE82A6669B
```

Android apksigner verifies the APK with **one RSA-4096 signer, v2 signature PASS**.
AAPT reads package **com.esnaftavar.app**, versionName **1.0.0**, versionCode **1**,
minSdk 24 / targetSdk 36 and all three ABIs. AAB jarsigner reports **jar verified**;
keytool independently reads the same public certificate, valid until
2054-01-03. These read-only checks do not open a keystore or external config.

A second local Java verification reads every non-META-INF AAB payload entry
through verifying JarFile: **548 signed entries, zero unsigned payload entries,
zero duplicate names, one pinned signer per entry**. Parsing the actual AAB
protobuf manifest through the existing local AAPT classes confirms the same
package/version; debuggable is not enabled. APK and AAB both contain arm64-v8a,
armeabi-v7a and x86_64 `libapp.so` entries.

Jarsigner warnings are retained: the upload certificate is self-signed and not a
trusted public PKIX chain, no timestamp is present, and JAR stream-based reading
reports a signing-view discrepancy with JarFile. The independent complete
JarFile verification above establishes payload signatures; it does not erase the
stream warning or prove Play Store acceptance. W51D did not repair/repack the
authoritative AAB. A subsequent rebuilt artifact needs its own signature and
package validation before any device/store gate.

Independent ZIP inspection confirms **all 20 excluded samples absent in both
artifacts** and **all three approved promo-banner images byte-exact to repository
artwork**. No binary configuration/client-key strings were printed. Source-reported
secret-value scanning and Production input validation remain attributed to
[the W51C-R result](RELEASE_W51C_SIGNED_RC_CANDIDATE_RESULT.md); W51D did not reopen
the external signing or Production JSON files to repeat those secret-value checks.

## Tests and repository safety

| Gate | Integration result |
|---|---|
| Targeted asset/UI and release/config/callback matrix | **139 PASS / 0 FAIL / 0 SKIP**, 15 files, runner 17.751 s |
| `flutter analyze --no-pub` | **No issues found**, 30.8 s |
| One final `flutter test --no-pub --reporter json` | **2065 PASS / 0 FAIL / 6 unchanged conditional skips**, runner 83.716 s |
| Test-file coverage / preservation | **175/175 run**, all 175 existing test files unchanged |
| Golden preservation | **245/245 existing PNGs unchanged**, none regenerated |
| Source preservation | Both source files exact; no non-document delta after build source |
| Net source added-text scan | **267 lines, 0 findings** |
| Source history added-text scan, all three commits | **408 lines, 0 findings** |

The six live conditional skips were compared by name with W51B: two Development
Auth/RLS/lifecycle, two Development Realtime, two Production anonymous-client tests.
No opt-in was enabled or test/skip/assertion changed. Targeted counts overlap the
full suite and are not added to it. Integration documentation is the only change
after the final Flutter gate.

Diff scans cover private-key blocks, credential tokens including Supabase
publishable/server forms, credential assignments, email and Turkish phone forms;
final integration documentation is scanned again before publication. Tracked-path
checks find no actual key.properties, Production JSON, keystore, private signing
bundle, APK/AAB or .env. No password, real client key or service-role secret was
added in source history or the integration delta. This is local source review and
pattern scanning, not an assertion that every possible secret format is detectable.

No unexpected runtime, backend/RPC/RLS/migration or platform change was introduced.
The only reviewed shared binary input is pubspec.yaml, owned by W51C-R; Integration
adds no further edit. All source and staged aggregate whitespace checks pass before
publication. Ignored `.buildlog/w51d-*` retains local redacted scan outputs,
test JSON and read-only artifact evidence; raw logs/helpers are not committed.

## Metrics, handoff and calibration

Six Integration gates: Git freshness/exact delta, artifact hashes/signatures/
identity, Flutter/analyzer, secret/PII/backend safety, lineage/coordination evidence,
and normal Git publication. The source checkpoint is already pushed; final
publication and clean-tree acceptance are confirmed by delivered TASK_RESULT.

Observable start **20:48:29 UTC**; local verification/checkpoint boundary
**20:57:01 UTC = 8m32s**, including tool waits but excluding remaining documentation
and final publication. TASK_RESULT reports the later end boundary. No arbitrary
duration threshold or normalized model-speed claim is used.

W51C-R worker remains **GREEN / SAME_SIZE** as source-reported for its completed
13/13 local artifact scope. W51D is **YELLOW / SAME_SIZE**: integration and artifact
checks pass without critical regression, scope drift, substantive owner correction
or collision, but the explicit final-main rebuild requirement remains. Integration
UI/runtime changes **0**; Figma **NOT_REQUIRED / 0 calls**; AGENTS.md/protocol unchanged.

Next recommended package is one separately authorized **final-main signed RC
rebuild and exact artifact verification**, preserving the files above. It must
record final-main source SHA, output hashes, package/version/ABIs and signer before
device install/launch readiness can be reconsidered. No permission to build, access
Production, install on a device or publish to a store is inferred from this recommendation.

Production remote proof, physical QR, install/launch, Merchant, legal/privacy,
support and store acceptance remain OPEN. Customer Final UI is COMPLETE and local
tests PASS; final-main RC/commercial launch readiness is not established here.

```text
W51D_SIGNED_RC_INTEGRATION: PASS
SIGNED_APK_HASH_PRESERVED: PASS
SIGNED_AAB_HASH_PRESERVED: PASS
SIGNING_CERT_MATCH: PASS
BINARY_AFFECTING_SOURCE_DELTA_VS_STARTING_MAIN: YES
BINARY_AFFECTING_DELTA_AFTER_BUILD: NO
REBUILD_REQUIRED_AFTER_INTEGRATION: YES
SECRETS_COMMITTED: NO
PRODUCTION_ACCESSED: NO
STORE_UPLOAD_PERFORMED: NO
DEVICE_INSTALL_PERFORMED: NO
READY_FOR_DEVICE_INSTALL_LAUNCH_GATE: NO
```
