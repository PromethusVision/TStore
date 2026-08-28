# Release Signing Safety

**State:** REQUIRED — NO SIGNING MATERIAL ACCESSED

## Android

- Production release packaging remains fail-closed when `android/key.properties`, required values or keystore are absent.
- No debug-signing fallback, placeholder credential or committed `.jks/.keystore`.
- Upload key/password enter only a protected local/CI runtime and are never echoed, cached or uploaded as generic artifacts.
- Verify package, version and public signing certificate fingerprint on the exact APK/AAB evidence path.
- Separate upload key from Play app-signing key where the owner adopts Play App Signing.

## iOS

- Team, distribution certificate and provisioning profile are external protected inputs.
- Static/unsigned compile is labelled accordingly; only an authorized Xcode archive/export is signed evidence.
- Validate bundle, entitlements, profile, certificate identity and TestFlight processed build.
- P12/profile/password material is neither committed nor retained in ordinary artifacts.

## CI

Signing jobs run only from trusted protected release refs/environment with least permissions and approval. Fork PRs receive no secrets. Temporary keychain/keystore copies are removed after the job and never stored in caches.

Official Android guidance distinguishes the private app-signing key and upload key: https://developer.android.com/studio/publish/app-signing.

`SIGNING_PERFORMED_W22: NO`
