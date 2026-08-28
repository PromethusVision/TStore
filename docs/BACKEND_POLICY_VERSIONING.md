# Backend Policy Versioning

**State:** PROPOSED

Every decision whose meaning may change over time references a stable policy/rule
identifier and immutable version. This includes legal consent, catalog approval,
availability/price freshness, QR confirmation, review eligibility, moderation,
ads, reward, reputation, operations and retention.

## Semantics

- draft, approved/effective and retired versions are distinct;
- effective intervals are explicit and use trusted time;
- one decision records the version evaluated at that moment;
- new versions do not silently reinterpret historical facts;
- a migration/backfill states whether it preserves, re-evaluates or supersedes;
- rollback activates a new/restored effective version with audit, not history edit;
- clients send supported contract version but cannot choose a weaker policy;
- unsupported versions fail with bounded upgrade/error behavior.

Policy version is not the same as schema migration, app release or event version,
though references may link them. Who approves each policy family and which changes
re-evaluate active entities are `OWNER_DECISION_REQUIRED`.
