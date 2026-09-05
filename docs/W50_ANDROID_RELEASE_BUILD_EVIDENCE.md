# W50 Android release build evidence

Validated source: `a62f7f97860aec9d908eb3b7f4831723c000371e`.
**Android release compilation PASS; current distributable APK/AAB BLOCKED.**
No Production request, remote Development write, key creation/rotation, signing
fallback or store upload was performed.

## Current tools and merged platform truth

| Item | Observed value |
|---|---|
| Flutter / Dart | 3.41.9 / 3.11.5 |
| Android Gradle Plugin / Gradle / Kotlin | 8.9.2 / 8.12 / 2.1.0 |
| JDK used by Flutter | Bundled OpenJDK 21.0.10; Java/Kotlin compilation target 17 |
| NDK | 28.2.13676358 |
| SDK/build tools | Android platform 36 present; doctor reports build-tools 37.0.0; licenses accepted |
| Production identity / label | `com.esnaftavar.app` / `EsnaftaVar` |
| Development identity / label | `com.esnaftavar.app.dev` / `EsnaftaVar Dev` |
| Version | `1.0.0`, code `1`; unchanged owner/store allocation decision |
| min / target / compile SDK | **24 / 36 / 36**; min is resolved from the actual merged manifest, not guessed from Flutter configuration |
| Auth callback | Production `com.esnaftavar.app://login-callback/`; Development `io.supabase.tstore://login-callback/` |
| Android app links | Custom scheme only; no claimed verified HTTPS App Link or `assetlinks.json` deployment |
| MainActivity | Exported launcher/callback, `singleTop`; Flutter default URI-to-route handling explicitly disabled; `app_links` feeds the existing exact URI validator |
| Backup / transfer | `allowBackup=false`; legacy backup plus Android 12+ cloud and device-transfer exclusions cover all nine persistent storage domains |
| Network | Explicit cleartext denial; release is not debuggable in the merged manifest |
| Permissions after merge | INTERNET, ACCESS_NETWORK_STATE, COARSE/FINE_LOCATION, CAMERA and signature-scoped DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION |
| Not requested | No background location, POST_NOTIFICATIONS, media-library or storage permission; Customer notifications are in-app data, not OS push |
| Camera | Customer displays QR and does not request camera. Retained scanner dependency/permission is legacy Merchant footprint; hardware is explicitly optional. Removing that dependency is a later packaging task, not Merchant implementation here |
| Other exported component | AndroidX ProfileInstallReceiver is exported with `android.permission.DUMP`; other merged services/providers and URL launcher/Google API activities are non-exported |

`Supabase Flutter 2.12.0` uses SharedPreferences for session/PKCE persistence.
That is why backup exclusions are needed. The URI handler change follows
[Flutter's plugin deep-link guidance](https://docs.flutter.dev/ui/navigation/deep-linking).
Cloud and transfer policies follow
[Android backup configuration](https://developer.android.com/identity/data/autobackup).
These are source/configuration proofs; OS backup/restore behavior on actual
devices remains part of the later device acceptance.

## Release packaging attempts

Existing local input: the checked-in **synthetic compile contract only**.
No `android/key.properties` exists in this worktree or the canonical CLEAN
checkout. No approved namespaced Production release manifest was supplied or
found at the conventional local tool paths. The canonical ignored `.env` has
legacy generic field names; it was not repurposed as approved Production config.
Values were not printed. Historical external keystore existence does not supply
credentials or authorize searching/decrypting a password store.

Commands from repository root:

```powershell
flutter build apk --release --flavor production -t lib/main_production.dart --dart-define-from-file=tool/production_compile_contract.json --no-pub
flutter build appbundle --release --flavor production -t lib/main_production.dart --dart-define-from-file=tool/production_compile_contract.json --no-pub
```

Both stop at the existing missing-signing guard. These are packaging attempts
using a non-deployable fixture, not signed candidate builds. The fixture remains
rejected by release-mode preflight. No debug key or synthetic signing material
was used to bypass the guard.

| W50 distributable | Filename | ID/version/size/hash/signature |
|---|---|---|
| APK | Not created | NOT_AVAILABLE |
| AAB | Not created | NOT_AVAILABLE |

Old `build/app/outputs/flutter-apk/app-production-release.apk` (122,739,377 bytes,
2026-08-23 16:04:03 UTC) and `build/app/outputs/bundle/productionRelease/app-production-release.aab`
(99,337,105 bytes, 2026-08-23 16:04:29 UTC) predate W50. They are preserved,
excluded from current release evidence and must not be distributed as W50.

## Strongest safe local build

Production AOT, Kotlin/Java sources, Android resources, merged manifest/native
libraries and Android Lint passed using the synthetic fixture. The existing
packaging guard remains intact. The final Gradle run succeeded in **1m06s**,
480 actionable tasks (19 executed, 461 up-to-date).

Reproducible PowerShell sequence from `android/`, using the existing JDK selected
by Flutter (set `JAVA_HOME` to that JDK locally without committing its path):

```powershell
$w50Config = Get-Content ../tool/production_compile_contract.json -Raw | ConvertFrom-Json
$w50Defines = ($w50Config.PSObject.Properties | ForEach-Object {
    [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($_.Name + '=' + [string]$_.Value))
}) -join ','
.\gradlew.bat :app:compileFlutterBuildProductionRelease :app:processProductionReleaseManifest :app:compileProductionReleaseSources :app:processProductionReleaseResources :app:mergeProductionReleaseNativeLibs :app:lintProductionRelease '-Ptarget=lib/main_production.dart' "-Pdart-defines=$w50Defines" '-Ptarget-platform=android-arm,android-arm64,android-x64' --console=plain --warning-mode all
```

Fresh AOT outputs are under
`build/app/intermediates/merged_native_libs/productionRelease/mergeProductionReleaseNativeLibs/out/lib/`.
They are **compile evidence, not installable or signed packages**:

| ABI / file | Bytes | SHA-256 |
|---|---:|---|
| `arm64-v8a/libapp.so` | 8,258,480 | `3eb9d9f2d59b7bfe774cacff59be45f03821e8ee2124a99dbe21c26b2d10f209` |
| `armeabi-v7a/libapp.so` | 9,077,340 | `7a8ac57a0f1ea9d049bfe19ca5a825aac1c1a01a780ab97870f005ba4bcbc09c` |
| `x86_64/libapp.so` | 8,520,624 | `f3c6204ea2cd37ddea0943f1ec399f12a22d377de028a5694a8bc5574cc2c5b6` |

All **12 merged 64-bit native libraries** have load-segment alignment of at least
16KB and congruent offsets. There are 22 merged native files in total. ARM64 AOT
was cross-checked with the installed NDK `llvm-readelf`; its load alignment is
64KB. The three SDK-generated AOT files lack GNU_RELRO; ARM64 has no dynamic
relocations. This is recorded as toolchain/security follow-up, not changed by
hand. No APK ZIP alignment or 16KB device runtime PASS is claimed without a
fresh package/device. See [Android page-size verification](https://developer.android.com/guide/practices/page-sizes).

## Android Lint and dependency findings

Final Android Lint: **0 errors / 16 warnings**. Four real API-level resource
errors were fixed with v28/v29 qualifiers, preserving appearance on supported
versions. Jetifier could not transform Byte Buddy's Java 24 multi-release classes
in a plugin's test dependency. All current plugins build with AndroidX directly;
disabling obsolete Jetifier restored the complete Lint path without upgrading
packages or excluding dependency test models. Native dependency unit tests were
not separately executed by this Lint command.

One precisely matched `NotificationPermission` false positive is excluded in
`android/app/lint.xml`: only the message naming Geolocator's unused
`BackgroundNotification` class. Customer uses `getCurrentPosition` with ordinary
`LocationSettings`, no foreground notification configuration and no position
stream. New architecture assertions guard these facts. The permission check is
not globally disabled and no unnecessary notification permission was added.
Introducing background tracking or OS push requires revisiting that exception.

Remaining warnings are resource maintenance only: 10 duplicate splash icons,
2 duplicate configuration images, 1 densityless bitmap, 2 obsolete v21 folders,
1 unused legacy launcher icon. No lint baseline or global error suppression was
added. Plugin Groovy DSL deprecations remain maintenance before a future Gradle
upgrade; no major upgrade was attempted.

`flutter pub outdated --json` completed without changing dependencies. Its
reported package entries show **0 affected advisories, 0 retracted current
versions, 0 discontinued packages**. Available updates include both patch/minor
and major releases; none is a demonstrated remaining release blocker. This is
the package service's report, not an independent security certification.

## Attempts retained and final proof boundary

- First APK attempt: missing signing, expected external blocker.
- Initial AAB after flavor guard: false rejection because Flutter adds incidental
  other-variant tasks. Fixed by checking requested artifact tasks. Final AAB
  reaches the correct missing-signing guard. Both deliberate wrong flavor/target
  pairs are rejected by real Gradle dry runs; aggregate packaging requires a flavor.
- Initial full Android Lint: Jetifier failure; then four resource errors and the
  identified unused dependency notification warning. Corrections above pass.
- Final Android compilation/Lint uses the same runtime/test tree as the final
  Flutter gate. Later documentation does not alter the built source.

Local logs: `.buildlog/w50-apk-attempt.log`, `w50-aab-final-attempt.log`,
`w50-mismatched-production.log`, `w50-mismatched-development.log`,
`w50-android-delivery.log`, `w50-android-evidence.json`, `w50-outdated.json`.
No Android device is connected and no configured emulator exists. An installed
SDK system image is not a running/authorized acceptance device. Install/launch
is **MANUAL_PHYSICAL_GATE**; no old APK was installed as substitute proof.
