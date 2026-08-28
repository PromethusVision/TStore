# Product Deduplication Review

**State:** PROPOSED — NO AUTOMATIC LINK/MERGE THRESHOLD

## Confidence lanes

| Lane | Typical evidence | Operational action |
|---|---|---|
| EXACT | Same validated scoped identifier and compatible identity dimensions | Suggest link; still block on conflict/policy rules |
| HIGH_CONFIDENCE | Multiple strong normalized fields/provenance agree; no identity conflict | Human review or owner-approved future auto-link |
| MANUAL_REVIEW | Partial match, pack/variant ambiguity, conflicting barcode/brand/model, custom item | No auto-link; explain conflicts and alternatives |

No score alone authorizes merge.

## Explainable operator signals

- identifier type/source/validation and issuer scope;
- normalized brand/manufacturer/model/MPN/ISBN;
- pack, measure, variant-defining dimensions;
- category/facet compatibility;
- title/token similarity with collision explanation;
- media hash/similarity as supporting evidence only;
- provenance authority/freshness/conflicts;
- active listings/reviews/purchases/analytics affected;
- policy and lifecycle states.

## Anti-patterns

Do not use name equality, fuzzy title, image similarity, same merchant, same category, or same price as decisive identity. Do not hide conflicting evidence. Do not merge a product and variant, different pack sizes, refurbished versus new where identity differs, or bundle versus single item without the approved catalog rule.

## Outcome

`LINK_EXISTING`, `KEEP_SEPARATE`, `REQUEST_EVIDENCE`, `PROPOSE_MERGE`, or `POLICY_REVIEW`. Every outcome records evidence, rule version, reason, and reviewer. Merge remains a separate impact-reviewed operation.

`DEDUP_AUTO_THRESHOLD_FINALIZED: NO`

`OPAQUE_SCORE_ONLY_DECISION: NO`
