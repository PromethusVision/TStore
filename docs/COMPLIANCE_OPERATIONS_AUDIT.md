# Operations, Moderation, Suspension and Appeal Compliance Audit

**State:** PROPOSED DUE-PROCESS FOUNDATION — NO ENFORCEMENT POLICY FINALIZED

Admin UI is not security. All privileged decisions are server-authoritative,
case/evidence/policy based, least-privilege and auditable.

## Case minimum

`CASE_ID`, subject, category, severity, reporter/protected identity, assignee,
status, evidence references, policy version, decision, reason, before/after impact,
communication, appeal link and history. Free text does not replace structured reason
and evidence.

## Decision controls

| Action | Minimum control | Extra control candidate |
|---|---|---|
| View customer/merchant PII | case/purpose/capability and access log | masked field default |
| View raw merchant document | regulated-review case | re-authentication and limited export |
| Reject regulated capability | evidence/policy/reason and safe remediation | specialist reviewer |
| Suspend merchant/account | exact scope/impact/reason and appeal | second review for permanent/high-impact |
| Remove review/listing/media | content/version/rule/evidence | independent appeal for material impact |
| Correct verified purchase | append-only status, impact preview | two-person or delayed compensating review |
| Merge/split catalog product | lineage/impact/rollback plan | specialist catalog review |
| Change policy status | version/effective date/impact scan | policy owner + professional sign-off |
| Bulk enforcement | dry-run/exact target/count/abort/reversal | two-person approval; avoid in pilot |

## Proportionality and fail-closed

Unresolved evidence blocks the affected capability/listing/ad rather than automatically
destroying the whole merchant account when ordinary activity is safely separable.
Urgent containment can be immediate for credible ongoing harm, but receives prompt
review. An operator cannot invent a one-off legal exception.

## Suspension and reason

A reason must be meaningful enough to understand the affected capability, rule class,
effective time, evidence/remediation category and appeal route. It must not disclose
reporter identity, fraud thresholds, security detection details or another person's
PII. Permanent restriction is an owner/policy decision after lawyer review; it is
not an automatic P0 response.

## Appeal

`SUBMITTED → ELIGIBILITY_CHECK → IN_REVIEW → WAITING_EVIDENCE/ESCALATED →
UPHELD/MODIFIED/OVERTURNED → CLOSED`.

The appeal links to, but never overwrites, the original decision. New material evidence
can reopen. Where staffing permits, high-impact appeals use a different qualified
reviewer. A one-person pilot records role conflict, uses a checklist/evidence/policy
snapshot and queues later sample review. Appeal does not automatically lift a safety
containment or extend punishment.

## Operator PII access

- default list/search uses opaque IDs and masked summaries;
- exact e-mail/location/chat/document appears only for a named case purpose;
- reporter identity is compartmentalized;
- no password, OTP, recovery link, token, raw QR secret or payment credential;
- export/download/print is separately authorized and logged;
- internal notes never appear in customer/merchant responses;
- revoked/offboarded operator access stops immediately and is reviewed;
- support screenshots/training use synthetic or redacted data only.

## Policy versioning

Every decision records the applied ruleset. A new policy triggers an impact scan of
active merchants, listings, ads, rewards, reviews and affected cases; it does not
silently rewrite past facts. Emergency rules expire or receive formal review.

## Privacy/security incidents

Potential personal-data breach, account takeover, operator misuse or broad export is
routed to the security/breach model, not processed as ordinary support. Preservation,
access and legal hold stay exact and time-reviewed.

`OPERATIONS_DUE_PROCESS_FINALIZED: NO`
