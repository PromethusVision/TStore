# Release Build Contract

**State:** PROPOSED — NO ARTIFACT BUILT IN WAVE 22

## Inputs

Exact commit, clean worktree, locked dependencies, Flutter/Dart/Java/Xcode versions, app flavor/entrypoint, production environment schema, version/build number, signing identity reference and feature/policy configuration.

## Outputs

Android production AAB (and APK only for controlled testing/distribution need), iOS archive/IPA through authorized Apple flow, optional synthetic web compile contract, symbols/source maps, manifest, SHA-256 hashes and build log with values redacted.

## Current platform constraints

- Android production identity is `com.esnaftavar.app`; release packaging fails closed without valid untracked `key.properties`/keystore and must never use debug signing.
- iOS bundle is `com.esnaftavar.app`; release signing config is optional for static compile, but signed archive requires external Team/certificate/profile.
- Development flavor and callback/config never enter Production artifact.
- Synthetic production web config proves compilation only and is non-deployable.

## Gate

Build succeeds with no suppressed errors, artifact identity matches manifest, hashes are recorded, secrets are absent from output, and the exact artifact—not a rebuild—enters smoke/install/upgrade tests.

`SIGNED_ARTIFACT_CREATED_W22: NO`
