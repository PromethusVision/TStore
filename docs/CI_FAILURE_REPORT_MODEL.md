# CI Failure Report Model

State: PROPOSED — OWNER REVIEW REQUIRED

A failure report should tell a contributor what failed, why it matters, and how to reproduce—without exposing secrets or massive logs.

## Minimum report

- job/test/contract name and first actionable failure;
- commit, environment, tool versions, shard, and retry count;
- safe command or documented local reproduction;
- relevant sanitized log excerpt and artifact link;
- owner/domain and whether the gate is required;
- classification: product defect, test defect, infrastructure, flaky suspected, or policy gate.

Later duplicate failures may be grouped by fingerprint. Reruns remain visible and never replace the first result. A green rerun after red is flaky evidence until root cause is resolved.

OWNER_DECISION_REQUIRED: select notification destinations and failure ownership rules.
