# Merchant Verification Lifecycle

**State:** PROPOSED FOR OWNER REVIEW

## States

| State | Meaning |
|---|---|
| NOT_STARTED | No verification request |
| DRAFT | Merchant is assembling required evidence |
| SUBMITTED | Immutable submission version received |
| TRIAGED | Identity/shop/sector scope and evidence requirements resolved |
| IN_REVIEW | Authorized reviewer evaluating current policy/evidence |
| NEEDS_INFORMATION | Specific missing/conflicting item requested |
| ESCALATED | Regulated, fraud, security, or legal/owner input required |
| VERIFIED_SCOPED | Exact assertions/capabilities approved within scope |
| REJECTED | Evidence/rules do not support approval |
| EXPIRED | Time-based validity ended |
| SUSPENDED | Risk/incident temporarily blocks reliance |
| REVOKED | Evidence/authorization invalidated or decision superseded |
| WITHDRAWN | Merchant withdrew request |

## Transition rules

- Merchant may create/submit/withdraw its own request but cannot set approval states.
- Each resubmission is a version; previous evidence/decisions remain in history.
- `NEEDS_INFORMATION` specifies exact evidence and safe reason.
- `VERIFIED_SCOPED` records assertion scope, policy version, effective/expiry, reviewer, and limitations.
- Expiry/revocation immediately removes dependent capabilities server-side in a future implementation.
- Appeal creates a linked reconsideration; it does not overwrite the original.
- Policy change can trigger recheck, scoped suspension, or grandfathering only if owner-approved.
- Account/shop suspension and verification status are separate but may affect each other.

## Dependency effects

Shop visibility, merchant catalog writes, QR confirmation, sensitive listings, ads, and badges consume current verification state but cannot derive it client-side. A dependent feature must fail closed when required verification is expired, revoked, ambiguous, or unavailable.

`VERIFICATION_LIFECYCLE_FINAL: NO`

`HISTORY_PRESERVED: YES`
