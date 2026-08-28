# Operations Priority Model

**State:** PROPOSED — INTERNAL TARGETING, NOT CONTRACTUAL SLA

Priority orders work. Severity describes harm. Urgency describes time sensitivity. They are related but not interchangeable.

## Operational priority

| Priority | Meaning | Typical examples |
|---|---|---|
| P0 | Active or imminent systemic harm requiring immediate containment/leadership awareness | account takeover campaign, leaked privileged credential, widespread QR fraud, undisclosed ads, material privacy breach |
| P1 | Serious customer/merchant/policy harm or broken critical journey with bounded scope | wrongful suspension, regulated listing active, repeated unauthorized QR confirmation, catalog merge corrupting active references |
| P2 | Material but non-urgent case with workaround or limited exposure | incorrect listing/product mapping, isolated review abuse, verification recheck, recurring support defect |
| P3 | Routine request, low-risk correction, information or backlog improvement | status question, typo/evidence clarification, low-impact duplicate report |

## Three-axis assessment

| Axis | Question |
|---|---|
| Product severity | How much customer/merchant/product harm occurs if true? |
| Security severity | Is confidentiality, integrity, authorization, fraud, or privileged access at risk? |
| Support urgency | Is the user blocked, time-limited, or facing irreversible impact? |

A high support urgency does not grant high-risk mutation rights. A low-volume security event may still be P0.

## Inputs

Affected users/merchants, sensitive data, regulated goods, financial/reputation impact, exploitability, spread, reversibility, evidence confidence, active exposure, deadline, vulnerable users, and available containment.

## Safeguards

- Reporter tone, merchant spend, VIP status, or social pressure does not set priority.
- Automation suggests priority with reasons; operator confirms and changes are audited.
- Queue age may raise handling urgency but cannot convert weak evidence into enforcement.
- P0/P1 require explicit incident/escalation ownership.
- False-positive cost is part of action selection, not a reason to ignore credible risk.
- Security SEV and case priority remain separately recorded.

`PRIORITY_MODEL_FINAL: NO`

`CONTRACTUAL_SLA_CREATED: NO`
