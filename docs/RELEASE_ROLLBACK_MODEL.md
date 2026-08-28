# Release Rollback Model

State: PROPOSED — OWNER REVIEW REQUIRED

Rollback is a coordinated recovery choice, not simply redeploying an old APK. Installed mobile clients may remain active and database migrations may be irreversible.

## Recovery levers

- stop or pause store rollout;
- disable a risky capability through an approved server kill switch;
- restore a backward-compatible backend version;
- publish a corrected higher-version client;
- roll back data only from a tested, authorized recovery plan.

Every release records client compatibility range, migration reversibility, feature-switch dependencies, data restoration point, and communication plan. Old binaries must never be re-signed with a misleading version.

A destructive database rollback and Production action require explicit authorization. Current documentation does not claim that these mechanisms exist.

OWNER_DECISION_REQUIRED: select rollback authority and required recovery-time targets after operational baselines exist.
