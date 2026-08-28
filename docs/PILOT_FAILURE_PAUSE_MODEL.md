# EsnaftaVar Esenler Pilot — Failure, Pause and Rollback Model

**State:** `PROPOSED CONTROL MODEL — NOT ACTIVATED`

## Failure signals

| Class | Example | Response |
|---|---|---|
| Product-value failure | Users cannot complete discovery despite healthy app | Narrow supply/search hypothesis; do not add incentives |
| Supply failure | Thin/stale/misleading catalog or inactive merchants | Stop acquisition into affected cell/domain |
| Authority/security failure | Cross-shop/role access, credential/token exposure | P0 containment and capability pause |
| QR integrity failure | Duplicate/wrong-shop durable purchase or unreconcilable commit | Pause QR globally or by smallest safe scope |
| Release failure | Wrong environment/artifact, crash/startup regression | Stop rollout/rollback under release plan |
| Operations failure | Unowned P0/P1, case age/backlog beyond capacity | Cap growth, add coverage or narrow features |
| Trust/policy failure | Prohibited item, false claim, unexplained customer harm | Suppress affected content and escalate |
| Economics failure | Manual/support cost grows faster than learning/value | Simplify model or pause expansion |

## Pause levels

`LISTING → SHOP → DOMAIN → CELL → QR → ACQUISITION CHANNEL → RELEASE COHORT →
ENTIRE PILOT`. Use the smallest safe containment unless evidence is uncertain or
cross-cutting.

## Failed-pilot indicators

Repeated inability to maintain useful local density; merchants will not maintain
truth or continue under an explicit offer; customers do not repeat useful discovery
without incentives; QR/support cost dominates the learning; critical defects recur
after corrective cycles; or the team cannot operate safely within declared staffing.
These trigger review, not automatic blame or expansion.

## Pivot triggers

- concentrate geography/domains further;
- switch broad launch to invite/merchant-led cohort;
- run discovery-only before QR;
- replace self-service with bounded assistance or vice versa;
- change merchant offer after evidence and explicit owner decision;
- remove a non-core feature/channel that adds operational noise.

## Resume evidence

Root cause bounded, authoritative data reconciled, affected artifact/config fixed,
targeted regression plus physical acceptance passed, monitoring active, merchant/
customer communication ready, and authorized owner approves restoration. A quiet
dashboard alone is not recovery evidence.

`PAUSE_CONTROLS_TESTED: NO`
