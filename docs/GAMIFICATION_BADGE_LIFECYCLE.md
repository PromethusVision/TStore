# Badge Lifecycle

Status: **PROPOSED CONCEPT — NO DB ENUM**
Wave: 18 / Workstream AB

| State | Meaning | Customer/merchant display |
|---|---|---|
| EARNED | Criteria first satisfied; processing/policy may still complete | Not necessarily public |
| ACTIVE | Current rule/evidence permits display/use | Explainable and scope-labeled |
| REVOKED | Fraud, invalid evidence or eligibility loss invalidates active badge | Removed with safe reason/appeal; history retained |
| RETIRED | Program/badge definition no longer issues | Historical display policy TBD |
| SUPERSEDED | New version/replacement exists | Link old to successor; no duplicate achievement |

## Transitions

- Source event and badge rule versions determine EARNED.
- ACTIVE requires privacy/display permission and current policy state where relevant.
- Revocation appends an event; it does not erase the original award.
- Retire/supersede cannot silently convert economic reward or review evidence.
- Re-earning after revocation needs explicit rule and cannot replay old evidence.

## Boundaries

Badge state is not customer/merchant role, authorization, review eligibility, rating or ad eligibility. Exact states/transitions remain owner/backend design decisions.
