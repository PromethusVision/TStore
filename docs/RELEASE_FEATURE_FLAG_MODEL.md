# Release Feature Flag Model

State: PROPOSED — OWNER REVIEW REQUIRED

Feature flags separate deployment from controlled enablement. They are not authorization, taxonomy truth, or a substitute for tested defaults.

## Minimum contract

- stable key, purpose, owner, environments, and default;
- targeted audience only from non-sensitive, server-authoritative rules;
- created/changed time, reason, approver, expiry review;
- client fallback when configuration is missing or stale;
- exposure event separated from business outcome;
- removal plan after rollout.

Security-sensitive enforcement remains server-side. Production defaults fail closed for write paths such as QR, ads, rewards, and catalog mutation. Flags must not embed secrets or identify individual customers unnecessarily.

Kill switches have incident semantics and are modeled separately. Experimentation requires privacy and analytics review.

OWNER_DECISION_REQUIRED: select a minimal provider/storage approach before implementation; no vendor is chosen here.
