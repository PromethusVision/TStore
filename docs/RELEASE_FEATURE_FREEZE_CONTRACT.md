# Release Feature Freeze Contract

State: PROPOSED — OWNER REVIEW REQUIRED

Feature freeze means the release candidate accepts no new product behavior. It does not mean the product is commercialization-ready; signing, physical acceptance, policy, store, and Production gates remain independent.

## Allowed during freeze

- blocker fixes with a reproducible failure and targeted regression test;
- documentation or release metadata corrections that do not alter runtime behavior;
- security fixes through an explicit risk review;
- removal or fail-closed disabling of unsafe behavior.

## Not allowed

New features, broad refactors, dependency churn, taxonomy rollout, opportunistic UI redesign, and unreviewed backend contract changes. Every exception records owner, rationale, affected tests, artifact replacement, and renewed go/no-go review.

Freeze begins from a named commit and environment contract. Any runtime change invalidates prior artifact hashes and affected acceptance evidence.

OWNER_DECISION_REQUIRED: select the freeze entry authority and minimum stabilization window.
