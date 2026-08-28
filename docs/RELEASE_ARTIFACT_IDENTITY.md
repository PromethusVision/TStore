# Release Artifact Identity

**State:** PROPOSED MANIFEST

Each candidate manifest should record:

| Field | Requirement |
|---|---|
| Product/application | Customer App or future Merchant App; never inferred from filename |
| Version | semantic customer-visible version |
| Build | monotonically unique per store/platform policy |
| Commit | full immutable Git SHA and clean/dirty state |
| Environment | Production/Development plus config contract revision; no values |
| Package/bundle | expected canonical identifier |
| Flavor/entrypoint | exact build target |
| Signing | public certificate/team/profile identity or fingerprint; no private material |
| Artifact | type, filename, byte size and SHA-256 |
| Toolchain | Flutter/Dart/Gradle/JDK/Xcode and lockfile hash |
| Backend | minimum/maximum compatible API/migration contract |
| Features | release-visible flag/policy version set |
| Evidence | test suite, install/upgrade/smoke and approval references |

Manifest and artifact are immutable siblings. Rename/copy does not change identity; rebuild creates a new hash and candidate record even from the same commit.

Observability uses app/build/commit/environment to separate failures by exact release. Unknown build metadata is retained as unknown rather than guessed.

`OWNER_DECISION_REQUIRED: CANONICAL_MANIFEST_FORMAT_AND_STORAGE`
