# EsnaftaVar Catalog Event Model

**State:** `PROPOSED — NO RUNTIME`

Catalog identity separates canonical product, variant and shop listing. Events use
opaque stable IDs and retain source/revision lineage.

| Area | Candidate events | Authority rule |
|---|---|---|
| Candidate | `catalog_candidate_submitted`, `catalog_candidate_accepted`, `catalog_candidate_rejected` | Trusted workflow; submission does not become canonical automatically |
| Product | `canonical_product_created`, `canonical_product_updated`, `canonical_product_retired` | Governed catalog authority |
| Variant | `variant_created`, `variant_updated`, `variant_retired` | Governed catalog authority; identity-defining changes reviewed |
| Listing | `listing_created`, `listing_updated`, `listing_retired` | Merchant/server authority within shop capability |
| Correction | `catalog_entities_merged`, `catalog_entity_split` | Governed operation with predecessor/successor graph |
| Price | `listing_price_changed` | Server authoritative listing revision; not payment/revenue |
| Availability | `listing_availability_changed` | Server authoritative listing revision |

Rename or hierarchy move keeps identity when semantics are unchanged. Merge keeps
all predecessor IDs and a successor mapping; split never assigns historical facts
to an arbitrary child. Verified-purchase events retain event-time product/variant/
listing snapshots and can also be projected through current lineage explicitly.

Duplicate candidates and retries cannot create duplicate canonical entities or
listing revisions. Corrections are append-only, effective-dated and auditable; no
historical event is rewritten in place.

`CATALOG_EVENT_RUNTIME: NOT_IMPLEMENTED`
