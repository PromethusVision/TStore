# Release Hotfix Model

State: PROPOSED — OWNER REVIEW REQUIRED

A hotfix is an exceptional minimal change for a confirmed severe defect in a shipped build. It is not a route around normal QA.

## Flow

1. link incident, affected versions, severity, and containment;
2. branch from the exact shipped source when main is not safely releasable;
3. implement the smallest root fix with a regression test;
4. rerun security, contract, build, signing, exact-artifact, and affected physical gates;
5. issue new build number, artifact hash, notes, and staged rollout;
6. merge the fix back to main and close divergence.

Emergency server containment must remain backward compatible unless an explicit security emergency requires otherwise. Rollback feasibility is assessed before distribution because mobile binaries cannot be recalled instantly.

OWNER_DECISION_REQUIRED: designate hotfix authorization and severity threshold.
