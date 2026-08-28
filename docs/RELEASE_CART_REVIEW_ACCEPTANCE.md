# Cart and Review Release Acceptance

State: PROPOSED — OWNER REVIEW REQUIRED

## Cart

- listing identity, price/availability refresh, quantity limits, and seller separation;
- duplicate taps, stale product/listing, offline retry, session switch, and empty/error states;
- no cart state from one account visible to another.

## Review

- only canonical eligible verified purchase can authorize a review;
- one active review invariant and idempotent submission;
- merchant/customer role boundaries and cross-shop rejection;
- report/moderation behavior does not remove ratings for mere disagreement;
- correction preserves verified purchase and audit evidence.

Client tests do not replace backend RLS/RPC and concurrency tests. Exact artifact smoke uses synthetic Development history; Production smoke avoids artificial ratings and commerce history.

OWNER_DECISION_REQUIRED: confirm V1 cart persistence expectations and review correction authority.
