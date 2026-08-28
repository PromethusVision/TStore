# Platform Incident Classification

**State:** PROPOSED — INTERNAL SEVERITY, NOT PUBLIC SLA

## Severity

| SEV | Definition | Examples | Response posture |
|---|---|---|---|
| SEV-0 | Confirmed/credible active systemic threat to safety, privileged control, sensitive data, or broad integrity | service-role/private key compromise, destructive unauthorized Production access, broad PII breach | immediate containment, incident lead, kill switch, owner/security/privacy escalation |
| SEV-1 | Critical customer/merchant journey or security integrity broadly impaired | widespread Auth/QR failure, cross-tenant authorization defect, mass fraudulent verification | rapid containment, dedicated owner, frequent updates |
| SEV-2 | Material bounded degradation or policy harm with safe workaround/fallback | one feature/sector/shop cohort affected, catalog writes failing, ad disclosure issue with ads disabled | scoped disablement/repair and tracked review |
| SEV-3 | Minor degradation, isolated error, reporting delay, routine defect | low-volume transient errors, stale dashboard, noncritical support issue | normal queue and trend monitoring |

## Assessment dimensions

Confidentiality, integrity, availability, safety/policy, financial/reputation, number/sensitivity of subjects, active exploitability, blast radius, reversibility, detection confidence, and workaround. Severity can rise or fall with evidence; every change is timestamped/reasoned.

## Distinctions

Incident SEV is not case priority, support urgency, bug priority, or contractual SLA. A single-account takeover can be SEV-2/1 by sensitivity while being P0 operational priority. A noisy complaint is not automatically high SEV.

## Rules

Prefer temporary over-classification during credible active harm, then correct transparently. Do not suppress severity for vanity metrics. Privacy notification/legal thresholds are determined separately by responsible review.

`INCIDENT_SEVERITY_FINAL: NO`

`SEV_ZERO_AUTOMATIC_PRODUCTION_MUTATION: NO`
