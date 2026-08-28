# Release Versioning Strategy

**State:** PROPOSED — OWNER_DECISION_REQUIRED

## Model

- Customer-visible semantic version `MAJOR.MINOR.PATCH` communicates compatibility/change intent.
- Android `versionCode` and iOS `CFBundleVersion` are unique monotonically increasing build identifiers.
- Customer and future Merchant apps have independent store version/build sequences even when sharing contracts.
- Backend/migration/API/event/policy versions are separate; they are not hidden inside the app version.

## Current fact

`pubspec.yaml` is `1.0.0+1`. WAVE 22 neither changes it nor declares it the next store candidate.

## Rules

- Rebuilding different bytes for store upload receives a new build number.
- Hotfix increments patch and build; release notes identify the fixed risk.
- Pre-release/internal builds use store-supported build metadata without reusing Production build identity.
- Observability, artifact manifest and go/no-go record bind version + build + full commit + environment.
- Minimum-supported-version policy is separate from version numbering.

## Multi-app compatibility

A compatibility manifest records Customer/Merchant build ranges against backend contract revision. Coordinated release does not require identical version numbers.

`OWNER_DECISION_REQUIRED: VERSION_AND_BUILD_ALLOCATION_OWNER`
