# Operations Case Lifecycle

**State:** PROPOSED FOR OWNER REVIEW

## States

| State | Meaning | Allowed next states |
|---|---|---|
| NEW | Intake accepted; not yet classified | TRIAGED, CLOSED as duplicate/invalid intake |
| TRIAGED | Subject, category, severity, queue, and immediate containment assessed | IN_REVIEW, ESCALATED, WAITING_EXTERNAL, CLOSED |
| IN_REVIEW | Authorized operator evaluates evidence/rules | WAITING_EXTERNAL, RESOLVED, REJECTED, ESCALATED |
| WAITING_EXTERNAL | Awaiting merchant/customer/authority/vendor evidence; no unsafe default approval | IN_REVIEW, ESCALATED, CLOSED after policy timeout |
| RESOLVED | Report substantiated and decision/actions recorded | CLOSED, REOPENED, ESCALATED |
| REJECTED | Report not substantiated/allowed under current evidence | CLOSED, REOPENED, ESCALATED |
| ESCALATED | Higher capability, security, policy, legal, or owner input required | IN_REVIEW, WAITING_EXTERNAL, RESOLVED, REJECTED |
| REOPENED | New evidence, appeal, recurrence, or faulty decision requires review | TRIAGED, IN_REVIEW, ESCALATED |
| CLOSED | Workflow complete; immutable history retained | REOPENED only with reason/new evidence |

## Rules

- Case status is not enforcement status. A merchant may remain temporarily restricted while a case is waiting.
- Every transition has actor/system source, timestamp, reason, prior/new state, and policy version.
- `WAITING_EXTERNAL` must have a requested item and follow-up target; it cannot hide queue age.
- `RESOLVED` and `REJECTED` require evidence disposition and customer/merchant communication class.
- Duplicate cases link to the surviving case; they are not silently deleted.
- Reopening preserves prior decisions and adds a superseding review.
- P0 incident containment may occur before full triage, but must create/link a case promptly.
- Automation may route or suggest; material enforcement remains governed by capability and evidence.

## Terminal semantics

`CLOSED` means no current workflow action, not “history erased” or “subject innocent/guilty forever.” Policy change, appeal, recurrence, or newly reliable evidence can reopen or create a linked case.

`CASE_LIFECYCLE_FINAL: NO`

`SILENT_HISTORY_REWRITE: PROHIBITED`
