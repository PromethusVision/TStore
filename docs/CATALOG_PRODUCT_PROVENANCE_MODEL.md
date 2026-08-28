# Product Provenance Model

Status: **OWNER REVIEW DRAFT — CONCEPTUAL**
Wave: 16, Work Package 15

Catalog data is a set of sourced assertions, not a record whose latest writer is
automatically correct. Provenance must support both record creation history and
field-level authority because one product can combine trustworthy values from
different sources.

## Source classes

| Source type | Typical scope | Default authority |
| --- | --- | --- |
| `SYSTEM_CURATED_SEED` | Controlled launch/demo/reference record | Medium-high for declared scope; not external truth by default. |
| `MERCHANT_SUBMISSION` | Product candidate or correction from a shop | Medium for observable facts, high only for its listing. |
| `TRUSTED_CATALOG_SOURCE` | Contracted/verified master data | High within covered fields and effective interval. |
| `ADMIN_CORRECTION` | Reviewed resolution with evidence | High, but evidence and reason remain mandatory. |
| `IMPORT` | Batch transport from known origin | Inherits source authority; “import” alone conveys none. |
| `LEGACY_MIGRATION` | Historical record carried forward | Compatibility provenance; confidence must be re-evaluated. |
| `MANUFACTURER_EVIDENCE` | Packaging/specification/responsible-party assertion | Highest for manufacturer-owned facts when current and authentic. |

## Assertion envelope

Each governed value conceptually carries:

- `VALUE` plus normalized comparison form;
- `SOURCE` identity and source class;
- `CONFIDENCE` and validation status;
- `CREATED_AT`, effective interval and `LAST_VERIFIED_AT`;
- `ACTOR_TYPE` and actor reference where permitted;
- evidence reference/hash, ruleset version and superseded assertion link.

Record-level provenance answers how the candidate entered the catalog. Field-level
provenance answers why the displayed brand, model, pack, taxonomy, identifier or
media is trusted. A record-level “trusted import” must not launder an unsupported
field.

## Rules

- Keep conflicting assertions; select a resolved projection separately.
- Source priority is field- and domain-specific, not one global ladder.
- Merchant submissions are authoritative for their own price, availability, SKU
  and shop media, but only evidence for canonical fields.
- Majority agreement increases confidence only when sources are independent.
- Stale evidence decays in confidence; it is not silently deleted.
- Merge/split, policy and taxonomy decisions link to the exact assertions used.
- Provenance may contain actor identifiers but not unnecessary personal data or
  raw secrets; retention follows audit necessity and access control.
