# Regulated Merchant Review

**State:** PROPOSED, FAIL-CLOSED, NOT LEGAL ADVICE

## Trigger

Route to regulated review when merchant activity, shop, product, service, claim, document, or policy mapping is `VERIFICATION_MAY_BE_REQUIRED`, `LEGAL_REVIEW_REQUIRED`, conflicting, expired, or unsupported. Examples include optics, medical, precious goods, plant-protection scope, pet/live-animal ambiguity, ingestibles/claims, high-risk construction/installation, vehicle safety, and body-contact services.

## Review steps

1. Resolve exact merchant, shop, declared activity, and requested capability.
2. Resolve current policy version and jurisdiction/scope.
3. Request only the minimum defined evidence.
4. Verify issuer/source, holder, scope, effective/expiry/revocation status.
5. Separately evaluate exact product/listing/service/claim.
6. Record `ALLOW_SCOPED`, `RESTRICT`, `REQUEST_EVIDENCE`, `LEGAL_ESCALATION`, or `REJECT_UNSUPPORTED`.
7. Apply only approved capability/scope; set recheck trigger.
8. Communicate safe reason/remediation and appeal.
9. Audit evidence, decision, reviewer, policy version, and impact.

## Fail-closed rules

- missing, illegible, inconsistent, expired, revoked, or out-of-scope evidence does not approve;
- an approved shop does not approve every product;
- taxonomy placement does not authorize sale/advertising;
- “natural”, “professional”, “medical”, “authorized”, or similar merchant text is not evidence;
- operator cannot create a one-off policy exception;
- legal uncertainty escalates; it is not interpreted as permission.

## Proportionality

Fail-closed approval does not always require full-account suspension. Restrict the affected capability/product/sector while ordinary eligible activity remains available when safely separable.

Authoritative rules must be rechecked at implementation and launch. The source merchant policy audit is a proposal, not a legal determination.

`REGULATED_UNKNOWN_DEFAULT: DENY_APPROVAL`

`LEGAL_FINALIZATION_PERFORMED: NO`
