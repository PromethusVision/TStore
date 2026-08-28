# Dependency Security Model

State: PROPOSED — OWNER REVIEW REQUIRED

Dependency review is risk-based and must not trigger blind mass upgrades.

## Inventory and review

- lockfile-resolved direct/transitive package, SDK, Gradle/CocoaPods, and build-tool versions;
- official advisory/provenance, maintenance health, license, permissions, and platform impact;
- reachable vulnerable behavior versus package presence;
- pinned/reproducible resolution and approved registries;
- release artifact software bill of materials when tooling matures.

Critical reachable findings block release unless contained and explicitly accepted. Updates land in small groups with changelog review, contract/regression/build tests, and rollback path. Major framework or broad dependency change needs owner authorization.

CI action dependencies are covered separately and should be pinned to immutable revisions.

OWNER_DECISION_REQUIRED: select advisory/SBOM tooling and risk-acceptance authority.
