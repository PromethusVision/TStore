# Defect Registry Model

**State:** PROPOSED — NO ISSUE-TRACKER INTEGRATION

## Conceptual fields

`DEFECT_ID`, title, domain, severity, priority, status, environment, affected/fixed versions, reporter, owner, reproduction certainty, evidence links, customer/merchant impact, security/privacy/policy flags, root cause, workaround, regression test, release gate, accepted-risk link, duplicate/parent, created/updated/resolved times.

## Lifecycle

NEW → TRIAGED → CONFIRMED → IN_PROGRESS → FIXED_PENDING_VERIFICATION → VERIFIED → CLOSED, with DUPLICATE, NOT_REPRODUCED, EXPECTED_BEHAVIOR and ACCEPTED_RISK as reasoned terminal/holding outcomes.

Reopening preserves history. A duplicate retains its reporter/evidence and points to the root defect. Closure requires verification against the correct artifact/environment; a code commit alone is not verification.

OWNER_DECISION_REQUIRED: select future registry tooling only when team workflow warrants it.
