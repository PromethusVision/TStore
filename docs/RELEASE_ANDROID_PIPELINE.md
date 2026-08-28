# Android Release Pipeline

**State:** CONCEPTUAL — NO BUILD/UPLOAD

## Fail-closed sequence

1. Select approved commit; verify clean tree, lockfile and version/build uniqueness.
2. Run deterministic PR/full regression, security and production-config preflight.
3. Use protected production flavor/entrypoint and secure untracked signing inputs.
4. Build signed AAB; optionally signed APK for controlled physical acceptance.
5. Fail on any build command error or warning classified as gate.
6. Verify package `com.esnaftavar.app`, version, signer and artifact SHA-256.
7. Store manifest/symbols/logs without secrets.
8. Upload exact AAB to internal track; perform exact-artifact clean/upgrade smoke.
9. Promote the same release through approved track/rollout gates.

## Current repository audit

Gradle signing is fail-closed and does not use debug fallback. However current `android/fastlane/Fastfile` appends `|| echo` to clean/build commands, so failures can be masked, and uses `--no-tree-shake-icons`. It is **not** an acceptable release authority until a future implementation task makes commands fail closed and validates the standard build.

## Store principle

Google Play requires signed artifacts and new Play apps use AAB/Play App Signing flows. Internal testing should precede closed/production promotion: https://support.google.com/googleplay/android-developer/answer/9845334.

`ANDROID_PIPELINE_IMPLEMENTED: NO`

`CURRENT_FASTFILE_RELEASE_GATE: FAIL`
