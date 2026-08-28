# Release Notes Model

State: PROPOSED — OWNER REVIEW REQUIRED

Release notes are a customer-facing summary of shipped behavior, not the engineering changelog. They must be generated from the exact approved artifact and linked version/build number.

## Required structure

- short value statement in plain Turkish;
- material customer-visible additions and fixes;
- changed permissions, eligibility, or data behavior;
- known limitations and support route;
- separate internal appendix for rollout risks and rollback triggers.

Security fixes should describe customer impact without publishing exploitable detail. Unshipped, disabled, or environment-only work must not appear. Store text, in-app messaging, support scripts, and the immutable release record should share one source draft.

## Gate

Release owner approves customer wording after QA maps every claim to evidence. Marketing approval cannot override an open safety, policy, signing, or exact-artifact gate.

OWNER_DECISION_REQUIRED: choose release-note approver and translation/sign-off workflow.
