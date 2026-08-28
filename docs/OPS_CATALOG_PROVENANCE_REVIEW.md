# Catalog Provenance Review View

**State:** PROPOSED — CATALOG RUNTIME ABSENT

## Operator questions

- Which source asserted each field, when, and under what authority?
- Which normalized value is currently projected and why?
- Are identifiers scoped/validated and conflicting?
- Is the candidate a product, variant, pack, bundle, custom item, or listing fact?
- Which merchant/listing/media assertions disagree?
- What taxonomy/facet/policy revisions applied?
- What active dependencies would a correction/merge/split affect?

## View components

Canonical product/variant IDs; field-by-field assertions; source class/reference; collected/effective/expiry times; normalization rule/version; confidence and conflicts; barcode/MPN/ISBN scope; media provenance; taxonomy/facet assignment; policy state; predecessor/successor/alias history; active listing/review/purchase/analytics counts; prior decisions and cases.

## Authority

The view explains evidence but does not edit by itself. Operator creates a governed field resolution, candidate decision, merge/split, or reclassification command. Merchant agreement is evidence, not canonical authority.

## Privacy/security

Redact merchant documents, customer information, secret URLs, and irrelevant source payloads. External-source screenshots/claims retain provenance and retrieval time. No opaque “AI confidence” without supporting signals.

## Failure

Conflicting or missing evidence remains visible and can keep activation pending. Do not select newest/highest-volume source automatically.

`PROVENANCE_VIEW_IMPLEMENTED: NO`

`FIELD_LEVEL_EXPLAINABILITY_REQUIRED: YES`
