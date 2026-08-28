# Merchant App Catalog Exception Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**  
Wave: 17 / WP26

## Merchant-visible states

| State | Meaning | Safe action |
|---|---|---|
| CANDIDATE_PENDING | Review not complete | View status; avoid duplicate resubmit |
| POSSIBLE_DUPLICATE | Existing identity may match | Compare safe facts, select or request review |
| NEEDS_CORRECTION | Required/invalid data | Edit named safe fields |
| POLICY_REVIEW | Policy evidence/decision needed | Supply allowed evidence or contact support |
| POLICY_BLOCKED | Cannot proceed under current rule | No client bypass |
| IDENTIFIER_CONFLICT | Barcode/identifier maps ambiguously | Governed review |
| REVISION_CONFLICT | Record changed since edit began | Refresh, compare, resubmit intentionally |
| SYSTEM_TEMPORARY | Retryable service issue | Preserve draft, idempotent retry |

## Queue principles

- Customer publication and merchant draft status are separate.
- Merchant sees reason class and next step, not private reviewer notes or other merchant data.
- Every resolution records actor, provenance, policy/version and result.
- Similar exceptions can be grouped for operations, but each candidate retains exact outcome.
- No “approve anyway” client action.

## Operational gap

Reviewer ownership, SLA, appeal flow and candidate activation authority remain `OWNER_DECISION_REQUIRED` and are commercialization dependencies.

