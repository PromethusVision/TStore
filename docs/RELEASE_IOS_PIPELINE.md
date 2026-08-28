# iOS Release Pipeline

**State:** CONCEPTUAL — MACOS/XCODE REQUIRED

1. Approve commit, semantic version and unique build number.
2. Run deterministic tests and static bundle/deep-link/permission/entitlement checks.
3. Resolve locked Flutter dependencies on an approved macOS runner.
4. Import authorized distribution identity/profile into an ephemeral keychain.
5. Archive Release with bundle `com.esnaftavar.app`; fail on signing/config warnings.
6. Validate archive, entitlements, Team/profile/certificate and symbols.
7. Export/upload exact candidate to App Store Connect/TestFlight.
8. Record build/artifact identity; run TestFlight install, upgrade, Auth/deep-link, location and QR smoke.
9. Obtain release approval, then use controlled manual/phased release if selected.
10. Remove temporary signing material and preserve only safe manifest/evidence.

TestFlight is the beta distribution/feedback path, not Production certification by itself: https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview.

## Current gate

Windows static inspection can validate project text, bundle and plist structure only. Apple Team/certificate/profile, signed archive and TestFlight acceptance remain external/open.

`IOS_PIPELINE_IMPLEMENTED: NO`

`IOS_SIGNED_ARCHIVE_W22: NO`
