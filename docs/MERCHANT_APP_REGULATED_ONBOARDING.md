# Merchant App Regulated Onboarding

Status: **PROPOSED — POLICY/LEGAL REVIEW REQUIRED**
Wave: 17 / WP10

## Fail-closed rule

A merchant, sector, product or claim that requires unresolved legal/policy evidence cannot become customer-visible merely because a form was completed. Client metadata, merchant assertion or sector choice is not approval.

## Risk classes

| Class | Example signal | Default behavior |
|---|---|---|
| STANDARD | No known policy signal | Normal onboarding gates |
| REVIEW_REQUIRED | Taxonomy policy signal or uncertain business model | Draft/pending; publication blocked |
| REGULATED | License, professional authorization or restricted-goods signal | Evidence and authorized review required |
| EXCLUDED | Prohibited/unsupported activity | Reject with reason class and appeal/support path |
| UNKNOWN | `Other`, ambiguous or conflicting data | Fail closed; classification review |

Examples are classification signals, not legal conclusions. Exact sector/product allowlists require owner and legal review.

## Minimum evidence handling

- Collect only evidence necessary for the applicable rule; no broad identity/document harvesting.
- Store access-limited references, review status, reviewer, policy version and timestamp.
- Never expose private documents to customers or ordinary staff.
- Expiry/revocation triggers re-review and, when required, publication suspension.
- Avoid showing sensitive rejection detail that enables bypass; provide safe merchant guidance.

## Separation of concerns

- Merchant sector classification does not approve product listings.
- Merchant approval does not approve every regulated product.
- Product taxonomy category is not a license.
- Role assignment cannot override policy status.

## Open decisions

- `REG-01 P0`: Launch sector/product allowlist and exclusions.
- `REG-02 P0`: Evidence types, retention and authorized reviewer.
- `REG-03 P0`: Appeal/re-review policy and SLA.
- `REG-04 P1`: Customer-visible disclosure labels.
