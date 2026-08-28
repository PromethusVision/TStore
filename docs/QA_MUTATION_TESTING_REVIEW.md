# Mutation Testing Review

**State:** PROPOSED — CONTRARIAN REVIEW

Mutation testing measures whether assertions detect deliberate code faults, but a full Flutter repository run can be slow, noisy and costly for a pilot.

## Value now

Use manually and narrowly for pure, high-risk deterministic logic such as QR state transitions, eligibility, validation, stable identity, idempotency helpers and pricing boundaries—only when tooling is stable.

## Value later

Scheduled mutation checks may improve mature shared/domain packages after runtime baselines and CI capacity exist.

## Defer

Whole-app widgets, generated code, platform integration and thin adapters produce weak return. Mutation score must not become a vanity gate.

Recommendation: do not make mutation testing a V1 PR requirement. First close physical, signing, contract and migration evidence gaps.

OWNER_DECISION_REQUIRED: none for the pilot unless budget is allocated; engineering may run a bounded experiment later.
