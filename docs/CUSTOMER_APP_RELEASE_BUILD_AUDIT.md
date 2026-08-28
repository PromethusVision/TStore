# Customer App Release Build Audit

Status: **AUDIT PASS — COMMERCIAL RELEASE STILL CONDITIONAL**
Wave: **16 — Customer App Commercialization Closeout**

## Identity and entrypoints

| Item | Result | Evidence |
|---|---|---|
| Production entrypoint | PASS | `lib/main_production.dart` uses the strict Production environment contract |
| Development fallback | PASS | Missing/invalid Production values fail closed |
| Android application id | PASS | `com.esnaftavar.app` in release configuration |
| Android callback | PASS | `com.esnaftavar.app://login-callback/` product flavor contract |
| iOS bundle/callback static contract | PASS | Canonical identifier/scheme contract tests |
| Version | PASS_STATIC | `1.0.0+1`; store/version decision still belongs to release owner |
| Icon tree shaking | PASS | Standard web release build tree-shook Iconsax, Cupertino and Material fonts |

## Signing safety

`android/key.properties` is absent in this worktree and correctly ignored. The
Gradle release task is fail-closed: APK/AAB packaging throws rather than falling
back to the debug key when canonical signing input is unavailable. No keystore,
password, alias value or signing property was read, moved, changed or logged.

Previous signed Android artifacts and external signing material were not
overwritten. A new signed APK/AAB was therefore **SKIPPED** in Work Package 80.
This is a safe build-environment decision, not a compile defect.

## Safe compile performed

The tracked synthetic config was accepted only in contract mode:

```text
Production config preflight: PASS (COMPILE_CONTRACT_ONLY)
Deployment authorization: NO
Configuration values were not logged.
```

Then a standard release compilation ran without `--no-tree-shake-icons`:

```text
flutter build web --release -t lib/main_production.dart \
  --dart-define-from-file=tool/production_compile_contract.json \
  --output=build/wave16-web
```

Result: **PASS**, 41.1 seconds. This output is synthetic, non-deployable and was
not connected to Production. A distinct ignored directory was used to preserve
existing build artifacts.

## Platform readiness

- Android code/signing contract: **PASS_STATIC**; final signed candidate,
  device install and Play/internal-track checks remain manual.
- iOS code/identity contract: **PASS_STATIC**; archive/signing/TestFlight and
  physical callback remain blocked by the Apple release environment.
- Web compile contract: **PASS_COMPILE_ONLY**; no owner-approved HTTPS origin or
  real release config was used, so this is not a web deployment approval.

No Production/Development remote access, secret interaction, signing-material
change or preserved-artifact overwrite occurred.
