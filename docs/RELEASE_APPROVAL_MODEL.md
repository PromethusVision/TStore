# Release Approval Model

State: PROPOSED — OWNER REVIEW REQUIRED

Release approval is an explicit, auditable decision for one candidate.

## Lean pilot

The Product Owner may hold final commercial authority, but technical preparation supplies independent evidence for QA, security/backend, operations/policy, and store/signing. Where one person combines roles, record the conflict and require a second review for credentials, destructive migration, policy-sensitive launch, or unresolved P1 acceptance.

## Record

- artifact identity and target environment;
- evidence bundle and open risks;
- approver identities, roles, decision time, and rationale;
- rollout, monitoring, pause, rollback, and communication owners;
- rejected/superseded candidate history.

Approval expires when code, dependencies, config, migration, signing, or artifact changes.

OWNER_DECISION_REQUIRED: name the accountable Production release approver and minimum separation-of-duties controls.
