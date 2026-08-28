# Catalog Candidate Review

**State:** PROPOSED — CATALOG SOURCE REMAINS OWNER-REVIEW DRAFT

## Candidate outcomes

| Outcome | Use |
|---|---|
| APPROVE_NEW | Evidence supports a genuinely new canonical product/variant |
| MERGE_EXISTING | Candidate is the same identity as an existing product; preserve assertion provenance |
| REQUEST_CORRECTION | Required identity fields/evidence are missing or conflicting |
| REJECT | Spam, fabricated/non-product, unsupported, or clearly invalid candidate |
| POLICY_REVIEW | Exact product/claim/merchant scope is sensitive or uncertain |

## Review view

Show candidate assertion version, merchant/shop source, normalized identity fields, brand/manufacturer/model/pack/variant dimensions, barcode/MPN/ISBN evidence, media provenance, proposed taxonomy/facets, similar products with explainable signals, conflict fields, policy flags, and impact if linked.

Do not show unnecessary merchant/customer PII or a single opaque similarity score.

## Rules

- Merchant proposes; it cannot approve canonical truth.
- Barcode equality is evidence, not unconditional identity.
- Missing evidence fails closed for activation, not necessarily permanent rejection.
- Category/facet placement does not grant product policy permission.
- Approval creates immutable identity/provenance events.
- Merge and split use their dedicated high-risk operations.
- One-off/custom products follow the future owner-approved catalog model.
- Operator cannot edit a field merely to make a candidate match.
- Active listing linkage occurs only after the canonical decision and current listing eligibility.

## Conflict handling

Conflicting authoritative sources remain explicit. Resolve per field authority and revision; do not overwrite all fields from the newest submitter. Candidate status and merchant listing status are separate.

`CATALOG_CANDIDATE_REVIEW_FINAL: NO`

`MERCHANT_SELF_APPROVAL: NO`
