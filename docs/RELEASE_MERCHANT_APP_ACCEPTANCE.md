# Merchant App Release Acceptance

State: FUTURE PROPOSAL — OWNER REVIEW REQUIRED

No Merchant App runtime is certified by this document. Its release must have an independent signed artifact and acceptance evidence.

## Future gates

- merchant identity/onboarding/verification and regulated-sector review;
- shop ownership, staff roles, least privilege, and user switch;
- canonical catalog candidate, listing, price, availability, media, and moderation;
- QR scan/confirmation, replay/wrong-shop/concurrency, and audit;
- review visibility without rating manipulation;
- future ads/analytics eligibility without privilege leakage;
- offline/lifecycle/device/accessibility/localization;
- cross-version backend compatibility with Customer App.

One customer credential must never become merchant through client mutation. Shared backend releases need a compatibility matrix across both currently supported apps.

OWNER_DECISION_REQUIRED: choose Merchant App platforms, V1 scope, signing owners, and pilot acceptance cohort after runtime exists.
