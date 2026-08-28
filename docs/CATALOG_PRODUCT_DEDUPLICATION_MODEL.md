# Product Deduplication Model

Status: **OWNER REVIEW DRAFT — CONCEPTUAL, NO ML IMPLEMENTATION**
Wave: 16, Work Package 8

Deduplication proposes a relationship between catalog records; it does not
mutate identity by itself. False merge is generally more damaging than a
temporary duplicate because it can combine incompatible listings, reviews and
verified-purchase history. Automatic decisions therefore require positive
evidence and absence of material conflict.

## Evidence signals

| Signal | Strength when trustworthy | Conflict behavior |
| --- | --- | --- |
| Verified GTIN/ISBN | Very high for its sellable trade item | Incompatible brand/model/pack blocks auto-merge and opens identifier investigation. |
| Manufacturer + MPN/model | High within manufacturer namespace | Different generation/suffix/form factor blocks merge. |
| Responsible brand/manufacturer | Medium-high | Conflicting responsible party lowers confidence unless rebrand/private-label provenance explains it. |
| Normalized title | Medium supporting signal | Never exact proof; generic titles collide. |
| Primary taxonomy leaf | Plausibility signal | Different leaves may be misclassification; same leaf is not sameness proof. |
| Identity-bearing attributes | High in combination | Pack, capacity, edition, size or formulation conflict decides variant/different product. |
| Images | Medium supporting signal | Shared stock image, copied merchant photo or packaging refresh is not proof. |
| Pack/measure | High | `2 × 500 ml` is not the same physical pack as `1 L`. |
| Compatibility | High for intrinsic part identity | Broad keyword compatibility is weak. |
| Provenance/history | Confidence modifier | Low-authority assertions cannot override verified evidence. |

## Pipeline

1. **Normalize:** preserve raw values; derive deterministic comparison forms for
   identifiers, names, units and manufacturer codes.
2. **Candidate generation:** retrieve by exact identifier, manufacturer+model,
   high-overlap identity facts and taxonomy-compatible title. Avoid all-to-all
   merchant input matching.
3. **Hard-conflict gate:** reject automatic merge on incompatible pack, model,
   edition, formulation, intrinsic fitment or reliable identifier assignment.
4. **Relationship classification:** distinguish same product, different variant,
   different product and bundle relation before assigning match confidence.
5. **Decision policy:** auto-link only allowlisted exact/high combinations;
   possible/unknown cases enter review; negative decisions retain evidence.
6. **Audit:** store candidate inputs, ruleset version, evidence, conflicts,
   confidence, decision actor and any later reversal.

## Confidence classes

| Confidence | Meaning | Permitted action |
| --- | --- | --- |
| `EXACT_MATCH` | Independently trustworthy identity evidence agrees and no hard conflict exists. | Auto-reuse existing identity; merge remains auditable/reversible. |
| `HIGH_CONFIDENCE` | Multiple strong facts agree but exact authoritative coverage is incomplete. | Strong suggestion; auto-link only owner-approved low-risk rules. |
| `POSSIBLE_MATCH` | Some agreement with missing or weak evidence. | Show suggestion; require merchant/admin confirmation. |
| `NOT_MATCH` | Material identity conflict or clearly different relationship. | Keep separate; retain negative-pair evidence. |
| `MANUAL_REVIEW` | Identifier conflict, unknown composition, or merge/split impact is material. | No automatic identity mutation. |

## Safe decision examples

- Same verified GTIN, brand/model/pack agree: `SAME_PRODUCT`, exact candidate.
- Same model, different storage/size/colour: `SAME_PRODUCT_DIFFERENT_VARIANT`.
- Same normalized title, different pack or formulation: not an exact match.
- Same photo and generic title from two merchants: possible only.
- One record is a set containing the other: `BUNDLE_RELATION`, never merge.
- No barcode but maker/model/material/measure agree: high confidence is possible.

Thresholds and auto-merge allowlists remain owner decisions. The stress artifacts
test classification coverage; they are not trained-model performance claims.
