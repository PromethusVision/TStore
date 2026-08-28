# Regulated Policy Evidence Model

**State:** PROPOSED, FAIL-CLOSED, NOT LEGAL ADVICE

## Evidence dimensions

| Dimension | Questions |
|---|---|
| ISSUER/AUTHORITY | Is the source authoritative for this exact assertion? |
| HOLDER | Does evidence belong to the merchant/entity/shop/product? |
| SCOPE | Which activity, premises, product class, claim, channel, or jurisdiction? |
| VALIDITY | Effective, expiry, suspension, revocation, current status |
| AUTHENTICITY | Verifiable reference/signature/registry and tamper indicators |
| COMPLETENESS | Required fields/pages without collecting irrelevant PII |
| POLICY_FIT | Which ruleset version and capability consumes it? |
| REUSE | May still-valid evidence safely support another scoped assertion? |

## Status

`SUBMITTED`, `UNVERIFIED`, `VERIFIED_SCOPED`, `CONFLICTING`, `EXPIRED`, `REVOKED`, `INSUFFICIENT`, `LEGAL_REVIEW`. A document upload is not verification.

## Handling

Use protected evidence reference, integrity hash where appropriate, redacted operator view, access/exports audit, exact retention/renewal, and issuer verification method. Avoid copying national IDs, signatures, addresses, health data, or third-party details into notes.

## Decision boundary

Evidence supports a specific assertion; it does not authorize all merchant inventory or change Product Taxonomy. Unknown authority/scope/validity fails closed for sensitive capability. Operator cannot interpret ambiguous law or create a one-off exception.

## Change

Policy/authority revocation triggers impact review and scoped recheck, not silent mass punishment. Historical evidence/decision remains reconstructable.

`REGULATED_EVIDENCE_RULES_FINAL: NO`

`UPLOAD_EQUALS_APPROVAL: NO`
