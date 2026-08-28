# EsnaftaVar Operations Audit Event Model

**State:** `PROPOSED — ALIGNED WITH OPERATIONS FOUNDATION`

Privileged actions create append-only audit evidence with: audit event ID, trusted
occurred/recorded time, operator subject/capability/session, case/subject reference,
action, result, bounded reason/policy version, evidence references, before/after
change summary, impact, correlation, approval and reversal/supersession lineage.

Candidate events include `operator_accessed_case`, `operator_action_approved`,
`operator_action_rejected`, `operator_subject_restricted`,
`operator_subject_restriction_reversed`, `evidence_attached`,
`policy_decision_recorded` and `audit_export_created`. Names remain candidates.

Rules:

- Corrections append a superseding event; no history deletion or in-place rewrite.
- Before/after fields are allowlisted semantic deltas, not full object payloads.
- Never log passwords, OTP/recovery links, tokens, service keys, raw QR, signed
  URLs, cookies/headers, payment data, identity documents, precise location,
  private chat/review/support text or unrestricted payloads.
- Audit access is least-privilege, itself audited and separate from merchant/
  product analytics.
- Case/evidence retention, legal hold and export require policy/legal decisions.

`AUDIT_RUNTIME_IMPLEMENTED: NO`
