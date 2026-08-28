# Contrarian Catalog Architecture Review

Status: **INDEPENDENT CHALLENGE — NOT OWNER FINAL**
Wave: 16, Work Package 40

## Main challenge

The full model can become an enterprise master-data platform before EsnaftaVar proves
its core value: discovering a nearby shop that has the physical item. Field-level
provenance, variant graphs, reversible splits, temporal aliases and policy layers are
correct long-term ideas, but implementing all simultaneously could delay merchant
onboarding and make correction harder rather than safer.

## Objections and responses

| Challenge | Valid concern | Architecture response / simplification |
| --- | --- | --- |
| Variants everywhere | Small shops may have one item and no structured choices | Permit implicit default variant; introduce explicit variants only when independently listed. |
| Barcode dependency | Handmade/open goods lack GTIN; bad scans exist | Barcode is optional evidence, never primary internal identity. |
| Merchant contribution is unsafe | Incentive favors fast duplicate creation and promotional text | Existing-first flow, non-discoverable candidate state, listing authority only. |
| Handmade goods fit poorly | Global dedup may erase maker uniqueness | Maker/form/material/measure and one-off identity patterns; no generic-title merge. |
| Variable measure is over-modeled | Full batch/inventory system is not launch-critical | V1 only needs sell unit/minimum/increment and purchase snapshot; defer batch engine. |
| Review identity conflicts | Product merge can violate one-review uniqueness | Disable automatic impact merges until explicit collision policy; retain history. |
| Grouped search may hide useful shops | User may want a specific local merchant | Default product group, with shop-specific queries/seller expansion preserving listing results. |
| Over-normalization | Many tables/relations could burden operations | Conceptual layers need not map 1:1 to tables; use minimal schema after owner decisions. |
| Provenance overhead | Field-level assertions are costly | V1 can store source/evidence for identity-critical fields and full record audit; expand selectively. |

## Simpler viable V1

1. Stable canonical product ID, optional stable variant ID and shop listing ID.
2. Listing owns shop, price, availability/stock state, SKU and shop media.
3. Minimum product identity: name, physical type, leaf, brand/maker state, pack/measure,
   optional model/identifier and provenance.
4. Exact validated identifier suggestions but no unattended product merge.
5. Candidate queue and immutable merge/split lineage; manual P0 corrections.
6. Search groups listings under product; Cart V2/QR stores listing plus product/variant
   snapshots; current review rule remains.
7. Normal products and explicitly approved policy scope only.

This simpler path preserves every irreversible boundary while deferring automation,
complete provenance infrastructure, full batch inventory and sophisticated bundles.
The architecture is viable if treated as contracts and gates, not a mandate to build
every conceptual entity for V1.
