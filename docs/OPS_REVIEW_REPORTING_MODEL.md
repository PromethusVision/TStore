# Review Reporting Model

**State:** PROPOSED — VERIFIED REVIEW CONTRACT PRESERVED

## Reporter and reasons

Customers and merchants may report a review through structured reasons such as spam, harassment, threat, personal data, irrelevant content, prohibited content, conflict of interest, coercion/retaliation, or suspected authenticity abuse. “I disagree with the rating” is not a removal reason.

## Intake

- exact review ID/version and product/merchant context;
- authenticated reporter where required, with protected identity;
- structured reason plus minimal optional explanation/evidence;
- duplicate/rate-abuse signals;
- customer/merchant conflict and retaliation risk;
- current verified-purchase/review status from authoritative server state.

## Workflow

Accept report → acknowledge without outcome promise → deduplicate/link → triage severity → moderator review → allow/limit/remove/escalate → safe notification → appeal → audit. Multiple reports increase evidence volume, not automatic guilt.

## Boundaries

Merchant cannot edit/delete customer review or discover reporter identity. Operator cannot adjust star rating, mark a review verified, or remove criticism merely to satisfy a merchant. Verified-purchase eligibility remains immutable server evidence; content moderation is a separate state.

False/mass reporting is itself an abuse signal. Reporter sanctions require proportionate independent evidence, not one rejected report.

## Privacy

Redact personal data and avoid exposing private case notes. Public removal reasons should be categorical, not reveal reporter/security signals.

`REVIEW_DISAGREEMENT_REMOVAL: PROHIBITED`

`REVIEW_REPORTING_MODEL_FINAL: NO`
