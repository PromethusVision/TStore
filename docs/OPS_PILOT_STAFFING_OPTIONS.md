# Pilot Operations Staffing Options

**State:** OPTIONS — NO HIRING OR OUTSOURCING DECISION

| Model | Strengths | Risks | Suitable condition |
|---|---|---|---|
| Owner-operated | direct product learning, lowest cash cost | bottleneck, conflict, no coverage/independence, decision fatigue | very small controlled pilot only |
| One support/operator | dedicated queue continuity | single point, limited specialization, escalation still needed | low volume with narrow allowlist |
| Outsourced partial | variable capacity/channel coverage | training, data access/vendor privacy, quality consistency | routine intake/support after controls |
| Automated queues | scalable routing/dedup | false confidence, opaque errors, cannot replace high-risk judgment | after labeled real cases and QA |
| Hybrid lean | owner policy + one operator + specialist escalation | coordination overhead | recommended candidate for controlled pilot |

## Minimum functions, not necessarily people

Incident lead, support/triage, merchant verification, catalog/moderation, policy/privacy/security escalation, and audit/QA. One person may wear multiple hats, but high-risk actions record conflict and use compensating review.

## Decision inputs

Projected case volume/mix, operating hours, feature/sector allowlist, response targets, expected evidence/appeals, languages/channels, access/security training, incident reserve, vendor cost/data processing, and Product Owner availability.

## Lean recommendation

For a tiny pilot: narrow features/sectors, owner retains root policy, one trained operator handles support/ordinary queues, and named external/on-call specialist routes cover legal/privacy/security. Do not claim 24/7 coverage. If critical capability has no owner, keep that feature/scope disabled.

`PILOT_STAFFING_SELECTED: NO`

`PRODUCT_OWNER_HANDLES_EVERY_CASE: NOT_RECOMMENDED`
