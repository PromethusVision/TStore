# Operations Escalation Model

**State:** PROPOSED FOR OWNER REVIEW

## Escalation routes

| Trigger | Destination |
|---|---|
| Missing capability/complex case | senior qualified operator/queue lead |
| Regulated/legal ambiguity | Policy Reviewer + designated legal/policy owner |
| Account/privilege/security threat | security incident lead |
| Personal-data exposure/request conflict | privacy/security/legal owner |
| Catalog merge/split broad impact | Catalog Reviewer + second reviewer/Product Owner gate |
| Merchant permanent restriction | policy/owner high-risk review |
| Billing/credit dispute when ads exist | finance + ads operations |
| Systemic outage/integrity failure | platform incident response |
| Root product rule/TBD | Product Owner decision inventory |

## Escalation envelope

Case/incident, current severity/priority, subject, safe summary, attempted actions, exact decision needed, evidence/conflicts, policy version, current containment, time/external deadline, and least-privilege recipient.

## Rules

Escalation does not transfer unnecessary PII or grant broad access. The receiver accepts ownership explicitly. Source operator retains visibility appropriate to support communication. Emergency escalation can precede complete evidence, but labels unknowns.

Do not escalate routine technical decisions to Product Owner, or allow commercial pressure to bypass queue. If no qualified owner exists, sensitive approval remains fail-closed and the gap is recorded as a blocker.

`ESCALATION_CONTACTS_FINALIZED: NO`

`UNKNOWN_POLICY_DEFAULT: FAIL_CLOSED`
