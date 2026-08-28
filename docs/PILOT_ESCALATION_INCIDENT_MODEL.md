# EsnaftaVar Esenler Pilot — Escalation and Incident Model

**State:** `PROPOSED RUNBOOK CONTRACT — NOT ACTIVATED`

## Severity

| Severity | Meaning | Default action |
|---|---|---|
| `P0` | Security/privacy breach risk, cross-shop authority, QR duplicate/wrong-shop durable fact, broad outage or unsafe release | Stop affected capability/acquisition, assign incident lead, preserve evidence |
| `P1` | Critical journey materially broken for a cohort, recurring false listing/policy exposure, unstaffed high-risk queue | Contain/narrow, same-window escalation, explicit go/no-go review |
| `P2` | Bounded degradation with safe fallback | Queue, communicate limits, trend and fix |
| `P3` | Cosmetic/question/low-impact improvement | Normal backlog/support response |

## Lifecycle

`detect → classify → appoint owner → contain → communicate → investigate →
recover → validate → close → learn/reopen`

## Decision rights

- Any trained operator may invoke a safe preapproved pause for a P0 symptom.
- Only authorized release/feature owners restore a paused capability after evidence.
- Product Owner decides material scope/promise/commercial changes.
- Legal/privacy/security reviewers decide within their professional remit.
- Support cannot alter authoritative QR/review/catalog history to close a case.

## Communication minimum

State affected feature/cohort, safe workaround, known/unknown facts, next update
time and owner. Do not expose personal data, speculate on blame or declare recovery
before exact-artifact and data-integrity checks.

## Evidence

Environment, release/artifact ID, safe correlation ID, first/last seen, affected
entities/count estimate, logs/events with secrets removed, actions, before/after
state, decision record and validation. Missing telemetry is itself a finding.

`INCIDENT_PROCESS_DRILLED: NO`
