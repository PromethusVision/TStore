# Privacy Test Model

State: PROPOSED — PRIVACY/OWNER REVIEW REQUIRED

Privacy QA verifies data minimization and purpose boundaries, not legal compliance certification.

## Surfaces

- authentication/profile and support identity verification;
- precise/approximate location and nearby search;
- chat, reviews, media, reports, and operator evidence;
- analytics/event payloads and test/demo traffic;
- logs, crash reports, notifications, clipboard, screenshots, and deep links;
- account export/deletion/correction lifecycle when implemented.

Tests assert role-based visibility, redaction, retention/deletion behavior, account switching, consent/notice state, and absence of PII in URLs or diagnostics. Synthetic identities are used; Production records are not exported into test systems.

OWNER_DECISION_REQUIRED: obtain privacy/legal review for retention, consent, and data-subject policies before finalization.
