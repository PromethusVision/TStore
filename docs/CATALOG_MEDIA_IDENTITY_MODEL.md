# Catalog Media Identity Model

Status: **OWNER REVIEW DRAFT — NO STORAGE OR UPLOAD CHANGES**
Wave: 16, Work Package 17

Media illustrates an identity but cannot create or override it. Existing active
read paths for product media remain compatible; this design only defines ownership.

## Media layers

| Layer | Purpose | Authority |
| --- | --- | --- |
| Canonical product media | Shared model/form/pack representation usable across shops | Governed catalog; trusted source or reviewed contribution. |
| Variant media | Shows identity-bearing colour, size/form, package or configuration | Governed variant; must be linked to exact variant. |
| Shop listing media | Shows this shop's actual shelf/item/condition/context | Merchant-owned supplemental evidence; visible with shop attribution. |

## Rules

- Merchant upload never overwrites canonical/variant media directly. It creates a
  listing asset and may become a canonical candidate after review and rights checks.
- Shop photo may supplement canonical media when it is current, accurate and safe;
  it overrides display only inside the attributed shop context, never global truth.
- A photo that reveals different model, pack or variant opens an identity conflict;
  the system must not relabel it to fit the chosen product.
- Media carries source, rights/consent status, actor, capture/upload time, content
  hash, product/variant/listing relation, primary/order state and lifecycle.
- Exact duplicate files may share storage/content hashes while their provenance and
  presentation relations remain separate.
- Removal for policy/rights does not retire the product. Historical evidence keeps
  safe metadata without continuing public display.
- Search/dedup uses image similarity only as supporting evidence because stock images
  and copied photos create false merges.

Canonical product-image paths and shop-specific product-image paths remain distinct.
This wave creates no objects, bucket policy, upload flow or path migration.
