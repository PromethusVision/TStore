# Release Risk Register Model

**State:** PROPOSED — EMPTY UNTIL CANDIDATE REVIEW

## Fields

`RISK_ID`, candidate version/build/hash, category, description, trigger, evidence, probability band, impact/severity, affected journeys/platforms, mitigation, detection signal, containment/rollback, owner, decision state, approver, expiry and linked defect/test.

## Categories

Artifact/signing, Android/iOS/store, backend compatibility, migration/data, auth/deep link, QR/review/cart, location/device/network, security/privacy/policy, observability/support and operational capacity.

Register review occurs at freeze entry, go/no-go, each staged expansion and incident/postmortem. Resolved entries retain history. Duplicates roll into a root risk without losing references.

OWNER_DECISION_REQUIRED: approve candidate risk acceptance authority and escalation bands.
