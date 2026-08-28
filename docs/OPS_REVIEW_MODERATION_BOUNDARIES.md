# Review Moderation Boundaries

**State:** PROPOSED — CANONICAL VERIFIED REVIEW CONTRACT PRESERVED

## Independent dimensions

- `ELIGIBILITY`: server-authoritative verified purchase for the exact product.
- `VERIFICATION_BADGE`: derived from durable purchase evidence.
- `CONTENT_STATE`: visible, limited, removed, restored, under review.
- `RATING_VALUE`: customer-authored value; not operator-adjustable.
- `AGGREGATION`: includes only records allowed by current canonical rules.

Moderation may change content state; it cannot fabricate eligibility, verification, authorship, transaction, or rating.

## Allow versus act

Critical but relevant negative reviews remain visible. Remove/limit only under owner-approved content rules such as unlawful/unsafe content, harassment/threat, personal data, spam, irrelevant content, manipulation, or authenticity abuse. Merchant disagreement, commercial pressure, advertising spend, reputation impact, or low rating are not grounds.

## Operator actions

`NO_ACTION`, `REDACT_MINIMAL_PII` where policy permits, `LIMIT_CONTENT`, `REMOVE_CONTENT`, `ESCALATE_POLICY/SECURITY`, `RESTORE`. Every action binds review version, evidence, reason, policy version, scope, appeal, and audit. Text redaction must not change rating or meaning deceptively.

## History

Preserve original content under restricted evidence access where justified; public removal does not hard-delete evidence. Restoration/supersession is a new event. Verified purchase snapshots remain immutable.

## Conflicts

Merchant retaliation/coercion, review rings, mass reports, or account takeover create linked abuse/security cases. Operator cannot manually increase/decrease merchant aggregate; projections recalculate from governed review states.

`OPERATOR_RATING_EDIT: PROHIBITED`

`VERIFIED_REVIEW_CONTRACT_CHANGED: NO`
