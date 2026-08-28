# Backend Provenance Contract

**State:** PROPOSED — CATALOG-FIRST, CROSS-DOMAIN

Provenance records why the platform believes a fact, who/what asserted it, when it
was observed, the evidence class, confidence/verification and governing rule
version. It is distinct from the current value and from audit of who changed it.

## Catalog assertions

Canonical product identity, barcode, brand, variant dimensions, taxonomy, media
and policy claims may have several sources. Latest writer does not automatically
win. Conflicts create explicit review/resolution while retaining prior assertions.

## Listing assertions

Price, availability, SKU and local media identify merchant/shop source and
freshness. Merchant authority proves permission to assert, not objective truth.

## Rules

- external IDs include provider/type namespace;
- evidence documents are referenced with restricted access, not copied broadly;
- confidence labels do not bypass policy;
- correction/supersession is explicit;
- customer-visible explanation uses safe reason/source classes;
- analytics and ads cannot promote their observations into catalog truth.

Evidence taxonomy and auto-resolution thresholds are
`OWNER_DECISION_REQUIRED`.

