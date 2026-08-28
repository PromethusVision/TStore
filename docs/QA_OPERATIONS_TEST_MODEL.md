# Operations Platform Test Model

**State:** PROPOSED — OPERATIONS RUNTIME NOT IMPLEMENTED

| Boundary | Required proof |
|---|---|
| Authorization | UI visibility grants nothing; server rechecks operator, capability, case and subject scope |
| Case | valid lifecycle transitions, assignment, severity and linked-case preservation |
| Evidence | provenance/integrity/access state, minimization and no secret payload |
| Moderation | policy version, proportional reason, no rating/reputation manipulation |
| High-risk action | preview, exact target, re-auth, reason/evidence and required second review |
| Audit | append-only actor/action/before/after/case/evidence; denied attempts and reversals recorded |
| Appeals | independent reviewer where required; uphold/overturn/remand/supersede history |
| Operator error | wrong subject, bulk scope, stale policy and failed audit are blocked/reversible |
| Privacy | purpose-bound fields, export binding, internal/public note separation |

## Adversarial actor matrix

Support, moderator, merchant verifier, catalog reviewer, policy reviewer and break-glass principals each receive positive and negative capabilities. Cross-role and cross-case access is denied. One-person pilot combinations retain individual attribution and retrospective quality review.

## Existing design evidence

Wave 19 supplies 4,400 synthetic cases and 32 failure modes, but no server/UI implementation. Future tests should reuse those scenario classes without treating generated CSV expectations as runtime PASS.

`OPS_TEST_RUNTIME: NOT_IMPLEMENTED`
