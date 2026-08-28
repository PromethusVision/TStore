# Backend Product Candidate Contract

**State:** PROPOSED — CANDIDATE IS NOT CUSTOMER-ACTIVE PRODUCT

A candidate captures a merchant/import/operator assertion that may become a new
canonical product, variant, link to an existing product or rejection.

## Minimum contract

- immutable candidate ID, source/provenance and submitted evidence;
- merchant/shop/listing context without granting catalog authority;
- normalized identity hints and possible matches;
- lifecycle and revision;
- reviewer/decision, reason, policy version and successor IDs;
- idempotency for repeated submission.

Candidate outcomes are `MATCH_EXISTING`, `CREATE_CANONICAL`, `REQUEST_EVIDENCE`,
`REJECT`, or equivalent; exact names are not finalized. Approval is atomic with
the resulting reference. A candidate cannot appear as active canonical content
merely because a client marked it approved.

Auto-approval thresholds and merchant-private visibility are
`OWNER_DECISION_REQUIRED`.

