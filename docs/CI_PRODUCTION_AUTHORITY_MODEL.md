# CI Production Authority Model

**State:** PROPOSED — OWNER REVIEW REQUIRED

CI may prepare evidence and a release candidate; it is never the business authority that decides to change Production.

## Authority split

| Action | Automation | Required authority |
|---|---|---|
| Analyze, deterministic tests, static migration validation | Fully automated | Engineering gate policy |
| Build unsigned/compile artifacts | Fully automated in isolated CI | Engineering gate policy |
| Build signed release candidate | Automated only in protected environment | Human release approval and signing custody |
| Development migration/live acceptance | Automated after explicit gate | Authorized Development operator |
| Production database migration | Never unattended default | Named human migration authority, verified backup and exact artifact |
| Store submission/promotion | Protected automation may execute | Named app-release authority |
| Rollback/pause/kill switch | Tooling may execute bounded action | Named incident/release authority |
| Destructive recovery or emergency privilege | No implicit automation | Explicit high-risk authorization and audit |

## Non-negotiable controls

- exact environment, commit, artifact hash and actor are recorded;
- approvals expire when code, configuration, migration or artifact changes;
- untrusted PRs cannot reach Production credentials or protected jobs;
- emergency access is scoped, time-bounded, audited and reviewed afterward;
- test success never self-authorizes migration, store rollout or rollback.

OWNER_DECISION_REQUIRED: name Production migration, app-release, rollback and emergency authorities, including one-person-pilot compensating review.
