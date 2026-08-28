# Product Review Identity Impact

Status: **OWNER REVIEW DRAFT — CURRENT REVIEW POLICY PRESERVED**
Wave: 16, Work Package 11

Canonical rule remains: one active review per customer plus canonical product,
and eligibility comes only from server-authoritative verified physical QR
purchase evidence. Variant, listing, quantity or repeat purchase does not create
additional review entitlement.

## Catalog correction effects

| Change | Review behavior |
| --- | --- |
| Display rename/taxonomy move | Product ID and review remain unchanged. |
| Duplicate merge | Reviews project to survivor; same-customer collision cannot be silently combined or discarded. Verified-only aggregates are recomputed. |
| Wrong merge split | Move only reviews whose immutable purchase/product/variant snapshot proves a child; ambiguous reviews remain historical and out of child aggregates pending review. |
| New variant distinction | Existing product review remains at canonical product level; optional variant context may be displayed but cannot create a second active review. |
| Pack-size separation | If pack is proven to be a different product/variant, future evidence follows corrected identity; historical review reassignment needs snapshot proof. |
| Duplicate records | Do not double-count aggregates; preserve both source records until controlled merge. |

## Required safeguards

- Review row ID, author, content, timestamps and evidence link are immutable across
  catalog corrections except through an auditable mapping process.
- `is_verified_purchase` is derived from valid evidence, never copied merely
  because another record merged.
- A customer who reviewed both duplicates presents a uniqueness collision. V1 may
  keep one visible canonical review and quarantine the other, but the final choice
  is P0 owner policy and no content is lost.
- Product split must never guess a variant from review text or current listing.
- Search/product pages use derived eligible aggregates; legacy preserved reviews
  keep their existing unverified semantics.

This document does not change RPCs, review tables, UI or current eligibility.
