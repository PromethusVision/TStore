# Merchant App State Requirements

Status: **PROPOSED — IMPLEMENTATION-AGNOSTIC**
Wave: 17 / WP68

## Universal states

- `INITIAL/LOADING`: skeleton/progress without fake data.
- `CONTENT`: authoritative projection plus freshness.
- `EMPTY`: valid zero result with next action.
- `STALE/OFFLINE`: cached read, clearly non-authoritative for writes.
- `VALIDATION_ERROR`: field/action correction.
- `PERMISSION/POLICY_BLOCKED`: safe reason and allowed path.
- `CONFLICT`: current revision and intentional retry.
- `TEMPORARY_ERROR`: bounded retry.
- `UNKNOWN_OUTCOME`: reconcile before new mutation.
- `SUCCESS`: based on authoritative result.

## Domain requirements

- QR keeps `VALIDATING`, `AWAITING_CONFIRMATION`, `CONFIRMING` and terminal states distinct.
- Listing editor preserves draft but refreshes authorization/revision before submit.
- Analytics distinguishes zero, delayed, unavailable, partial and privacy-suppressed.
- Onboarding resumes server stage and never skips policy gate.
- Shop switch clears old scoped state.

Double submit/tap is prevented in UX and safe through backend idempotency. Error dismissal cannot convert failure into success.
