# Test Quarantine Model

**State:** PROPOSED — EXCEPTION ONLY

## Entry criteria

Quarantine is permitted only when a reproducible nondeterministic test blocks unrelated delivery and immediate repair is unsafe. The record requires test ID/path, first failure, root hypothesis, owner, issue, risk, replacement coverage, entry date and review/expiry date.

## Gate behavior

- Quarantined tests still run in a separate visible job where possible.
- Their failures do not silently vanish; PR/release summaries list them.
- A quarantined test protecting a P0 invariant requires equivalent deterministic coverage or blocks release.
- Remote/live environment failures use a distinct `ENVIRONMENT_BLOCKED` state rather than quarantine.

## Exit

Repair root cause, prove repeated first-attempt stability under stress/order variation, remove quarantine metadata and retain regression coverage. Expiry without resolution returns the test to blocking or requires explicit release-owner risk acceptance.

## Limits

No directory-wide, indefinite or ownerless quarantine. Skip annotations alone are not a quarantine registry.

`QUARANTINE_REGISTRY_IMPLEMENTED: NO`

`OWNER_DECISION_REQUIRED: QUARANTINE_EXPIRY_LIMIT`
