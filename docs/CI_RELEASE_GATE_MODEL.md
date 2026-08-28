# CI Release Gate Model

State: PROPOSED — OWNER REVIEW REQUIRED

Release gates operate on an immutable candidate after feature freeze.

## Required chain

- main/RC quality evidence and no unresolved P0/P1;
- exact environment/version/build provenance;
- protected signing with external secrets and approval;
- artifact hash/signature/attestation;
- exact-artifact clean/upgrade and critical smoke;
- Development live and physical gates where required;
- migration/compatibility/rollback and monitoring readiness;
- store metadata, privacy/policy/support, go/no-go approval;
- staged distribution with pause signals.

Signing and distribution jobs must not be reachable from untrusted PRs. Production release is never automatic solely because tests passed.

OWNER_DECISION_REQUIRED: select protected release trigger, approvers, and store credential custody.
