# Customer App Android Release Audit

Status: STATIC PASS; STORE OPERATIONS REMAIN MANUAL

## Verified configuration

- Namespace/application ID: `com.esnaftavar.app`.
- Production flavor label/scheme: EsnaftaVar / `com.esnaftavar.app`.
- Development flavor: `.dev` application suffix, EsnaftaVar Dev label, Development callback scheme.
- Compile/target SDK: 36; Java/Kotlin target: 17; min SDK follows the current Flutter SDK contract.
- Version source: `pubspec.yaml` (`1.0.0+1` at this baseline).
- Auth intent filter: browsable exact scheme plus `login-callback` host, `singleTop` activity.
- Permissions: internet, coarse/fine location, camera only.
- Release signing reads ignored `android/key.properties`, rejects missing/placeholders/nonexistent store, and never falls back to the debug key.
- Release build type does not enable an undocumented minify/ProGuard behavior.
- Architecture tests cover identity, callback, signing, and absence of legacy demo identifiers in runtime platform files.

## External gates

- The canonical keystore exists outside Git per prior signed-device evidence; passwords/private material were not inspected or logged.
- Version code/name must be deliberately selected for the store candidate.
- AAB generation, Play Console upload, listing/content/privacy declarations, device-catalog review, and second secure keystore backup are manual release tasks.

`ANDROID_STATIC_READINESS: PASS`
`ANDROID_SIGNING_FAIL_CLOSED: PASS`
`PLAY_CONSOLE_READY: BLOCKED_BY_MANUAL_WORK`
