# Customer App iOS Release Audit

Status: BLOCKED FOR ARCHIVE/SUBMISSION; STATIC CONTRACT PARTIAL PASS

## Verified static contract

- Bundle ID: `com.esnaftavar.app`; test bundle uses its `.RunnerTests` child.
- Production callback scheme: `com.esnaftavar.app`; Debug callback scheme: Development scheme.
- `Info.plist` declares URL handling plus camera and when-in-use location descriptions.
- Deployment target in the Xcode project: iOS 12.0.
- Version/build values derive from Flutter build settings.
- Release project settings expect Apple Distribution/manual signing, and `Release.xcconfig` optionally includes an ignored signing file.
- The example signing file contains placeholders only.

## Blocking evidence

- No tracked `ios/Podfile` exists at this baseline. With Flutter plugins in use, a reproducible CocoaPods dependency contract cannot be proven until generated/reviewed on macOS.
- No real Apple team, provisioning profile, certificate/keychain, archive, TestFlight install, or physical iOS callback evidence is available in this Windows worktree.
- iOS landscape orientations are enabled; whether Customer V1 should be portrait-only is an owner/release decision, not changed here.

Do not label iOS as release-ready from static plist/Xcode evidence alone.

`IOS_STATIC_CONTRACT: PARTIAL_PASS`  
`IOS_SIGNING_ARCHIVE: BLOCKED`  
`PRODUCTION_CONFIG_REQUIRED: YES`
