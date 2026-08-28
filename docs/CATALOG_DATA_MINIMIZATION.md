# Catalog Data Minimization

Status: **OWNER REVIEW DRAFT**
Wave: 16, Work Package 47

V1 should require only data needed to identify a physical product safely, connect a
shop offer, support discovery and preserve trusted purchase/review history.

## Minimum V1 fields by layer

| Layer | Required core | Optional/evidence-driven |
| --- | --- | --- |
| Product | opaque ID, canonical name, physical product type, stable primary leaf, lifecycle, brand/maker/unbranded state, provenance/revision | manufacturer/model, pack/measure, description, canonical media, identifier assertions |
| Variant | opaque/default variant ID, product ID, lifecycle; explicit dimensions only when choices exist | GTIN/MPN, variant media, aliases |
| Listing | ID, shop, product/variant, current price/currency, availability/stock-knowledge state, observed time, lifecycle | stock quantity, merchant SKU, local description/media, sell minimum/increment |
| Candidate/assertion | source, actor type, value, time, confidence/validation, evidence reference | last verified/effective interval when needed |
| Verified item | immutable transaction/item, customer ownership at transaction layer, product, optional variant, listing/shop and commercial snapshot | lot/merchant SKU only when authoritatively captured and needed |

## Do not require for every product

Global barcode, brand, manufacturer legal details, model number, 100 generic facets,
compatibility graph, full dimensions, batch/expiry, multiple media, long SEO text,
serial number, advertising fields, gamification fields or complete price history.

## Privacy and retention

- Catalog identity is non-personal where possible. Store merchant/admin actor reference
  in restricted audit rather than public product projection.
- Evidence uses hashes/references and minimum excerpts; no credentials, private keys,
  unrelated EXIF/location or customer PII.
- Analytics events store IDs and necessary snapshots, not full records.
- Retain predecessor/verified evidence required for integrity; expire transient search
  candidates and rejected raw uploads under an owner-approved retention policy.

Optional absence is explicit (`UNKNOWN`, `UNBRANDED`, `NOT_APPLICABLE`) and must not be
filled with invented defaults merely to satisfy completeness scores.
