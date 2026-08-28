# EsnaftaVar Facet & Search Readiness

**Wave:** 15 / Global Facet, Attribute & Search Architecture  
**Assessment date:** 28 August 2026  
**Overall classification:** `NEEDS_MINOR_REFINEMENT`  
**Owner finalization:** None  
**Runtime implementation:** None

## Source boundary

| Source | HEAD | State consumed |
|---|---|---|
| Canonical main | `f092cf8fe7431f812a017d4cbc9b538775bb41e6` | 24 final L1; Electronics 9 and Computer 11 final L2; two final L3/L4 pilots |
| Batch 01 | `4b500a629e3ca6f388617c49aae16fe32538a378` | 6 L1 / 70 L2 proposals, read-only |
| Batch 02 | `bca5d57c359dc4f767972597551aa6616031b667` | 8 L1 / 77 L2 proposals, read-only |
| Batch 03 | `f1e766eeacbcbc1f1ed69ee18d040321645a6796` | 8 L1 / 77 L2 proposals, read-only |
| Global L2 audit | `7796080e703e4dd3189073b95d196fac82bd93f4` | 224-proposal inventory, collisions/policy/naming and 18 owner roots, read-only |

No source branch was merged or modified.

## Architecture metrics

| Metric | Result |
|---|---:|
| Total facet concepts | **88** |
| Global shared | **18** |
| Domain shared | **30** |
| Leaf-specific/domain facets | **16** |
| Compatibility facets | **10** |
| Policy metadata facets | **10** |
| Derived facets | **4** |
| L1 facet profiles | **24/24** |
| Final L2 represented in vocabulary | **20/20** |
| Proposed L2 represented in vocabulary | **224/224** |
| Controlled search vocabulary | **1,220** expressions |
| Vocabulary coverage | **5 per each 244 L2** |
| Search collision audit | **40** terms |
| Attribute dictionary | **88** rows / unique IDs and keys |
| Synthetic stress scenarios | **240** / 10 per L1 |
| Stress PASS | **216 / 240 = 90.0%** |

Dictionary status split: `34 CANONICAL_CONCEPT_FROM_FINAL_DOMAIN`, `20
PROVISIONAL_CROSS_DOMAIN`, `21 OWNER_REVIEW`, `13 POLICY_REVIEW`. The first status
means the semantic core is evidenced by an owner-final pilot; it does not mean a
global runtime field/schema has been owner-finalized.

## Stress-test results

| Result | Count | Readiness implication |
|---|---:|---|
| `PASS` | 216 | Existing concept/scope architecture describes product without arbitrary free text/category duplication. |
| `MISSING_ATTRIBUTE` | 5 | Add/refine governed concept proposals before runtime profiles. |
| `OVERMODELED` | 4 | Leaf applicability and merchant form must suppress irrelevant/duplicate fields. |
| `AMBIGUOUS_LAYER` | 4 | Product/variant/listing/service owner decision required. |
| `COMPATIBILITY_GAP` | 4 | Target registries/rules need extra version/revision context. |
| `POLICY_GAP` | 7 | Fail closed until policy/legal/evidence owners decide. |

### Missing attribute concepts to refine

1. made-to-measure garment/body measurement and service boundary;
2. maximum safe temperature/use-condition concept for cookware/materials;
3. SPF/UVA claim profile with evidence semantics;
4. instrument tuning/scale system vocabulary;
5. exam/curriculum/version concept for learning materials.

These are stress findings, not approved additions to the 88-concept registry.

### Compatibility refinements

1. usable-interior/device-kit fit profile for equipment bags;
2. chipset/BIOS/firmware support version relation;
3. serial/production-revision target ranges for appliance accessories;
4. chassis/engine/market revision detail for safety-critical vehicle fitment.

## Package readiness

| Work package | Classification | Evidence / next gate |
|---|---|---|
| Global facet registry | `READY_FOR_OWNER_REVIEW` | 88 unique concepts, typed scope and category-confusion risk. |
| Scope architecture | `READY_FOR_OWNER_REVIEW` | 88/88 classified; alias/duplicate rules explicit. |
| 24 L1 profiles | `NEEDS_MINOR_REFINEMENT` | 24/24 coverage; exact leaf requiredness remains future task. |
| Value normalization | `READY_FOR_OWNER_REVIEW` | units/locale/range/enum/free-text/unknown contract complete. |
| Size & measurement | `NEEDS_MINOR_REFINEMENT` | 9 kinds separated; conversion/privacy/tolerance owners open. |
| Compatibility | `NEEDS_MINOR_REFINEMENT` | 6 relations/4 states; 4 stress gaps and evidence owners open. |
| Search synonym architecture | `READY_FOR_OWNER_REVIEW` | 9 term types, precedence and typo/collision rules. |
| Turkish vocabulary | `READY_FOR_OWNER_REVIEW` | 1,220/1,220 target; source proposal state retained. |
| Search collisions | `NEEDS_MINOR_REFINEMENT` | 40 terms; runtime evaluation set/ranking still absent. |
| Merchant onboarding | `READY_FOR_OWNER_REVIEW` | five ownership classes and progressive-input contract. |
| Product/variant/listing | `NEEDS_MINOR_REFINEMENT` | boundary tests complete; 10 owner questions open. |
| Facet governance | `READY_FOR_OWNER_REVIEW` | lifecycle, immutability, alias, analytics/index gates. |
| Anti-pattern guide | `READY_FOR_OWNER_REVIEW` | 20 concrete failure modes and review checklist. |
| Attribute dictionary | `NEEDS_MINOR_REFINEMENT` | 88 unique concepts; 54 provisional/owner/policy rows. |
| Coverage stress test | `NEEDS_MINOR_REFINEMENT` | 90.0% PASS; 24 explicit non-pass findings. |

No package requires wholesale redesign: non-pass findings are bounded owner, profile,
compatibility and policy refinements. Therefore overall state is
`NEEDS_MINOR_REFINEMENT`, not `NEEDS_MAJOR_REWORK`.

## Owner decisions

### Inherited taxonomy gates (unchanged)

The previous global L2 audit's `18` root decisions remain open for the 22 proposal
domains. This work neither resolves them nor changes `PROPOSED FOR OWNER REVIEW`.

### Facet/search decision groups

1. approve/revise the 88 semantic concepts and six scope classes;
2. approve L1/leaf applicability, requiredness and variant-candidate profiles;
3. choose measurement conversion/tolerance/privacy authorities;
4. choose compatibility target sources, evidence hierarchy and customer visibility;
5. decide product/variant/listing/custom-service boundaries;
6. decide merchant required-field budgets, canonical correction and publish gates;
7. decide policy evidence/eligibility for the seven stress-test policy gaps;
8. approve vocabulary types, ambiguous-query grouping and typo strategy;
9. assign governance owners, lifecycle and change authority;
10. approve stable runtime identities/schema/index/release plan in a separate task.

These are `10` grouped review gates, not final decisions. Together with the inherited
18 taxonomy roots, the owner queue has `28` headline gates; dependencies should be
reviewed in grouped order rather than as dozens of independent micro-decisions.

## Runtime blockers

- Owner review/finalization of the 22 proposed L2 domains and relevant root decisions.
- Owner approval/refinement of registry/dictionary/profile semantics.
- Resolution of 5 missing-attribute, 4 compatibility and 7 policy gaps.
- Exact leaf-level requiredness/variant source-of-truth profiles.
- Stable opaque runtime identities, versioning and schema/API/index design.
- Policy/legal/merchant authorization and evidence workflows.
- Source-data mapping, migration/backfill, quality thresholds and rollback plan.
- Search relevance/collision/typo evaluation against real non-sensitive query data.
- Merchant/customer UI design and usability testing.

## Safety and consistency review

- 24/24 L1 profiles: PASS.
- 224 proposed + 20 final L2 represented in search vocabulary: PASS.
- Vocabulary minimum 5 meaningful expressions per L2: PASS (`1,220`).
- Duplicate facet concept IDs: 0.
- Duplicate attribute technical-key proposals: 0.
- Duplicate term/scenario IDs: 0.
- Category/facet/search/policy/compatibility/listing separation: PASS.
- Proposed categories owner-finalized: NO.
- Production schema/runtime/DB/migration: NO.
- Flutter/Figma/Supabase/Production/Development changes: NO.
- Source proposal/canonical/coordination documents modified: NO.

## Documents

1. `TAXONOMY_GLOBAL_FACET_REGISTRY.md`
2. `TAXONOMY_FACET_SCOPE_ARCHITECTURE.md`
3. `TAXONOMY_L1_FACET_PROFILES.md`
4. `TAXONOMY_FACET_VALUE_NORMALIZATION.md`
5. `TAXONOMY_SIZE_MEASUREMENT_MODEL.md`
6. `TAXONOMY_GLOBAL_COMPATIBILITY_MODEL.md`
7. `TAXONOMY_SEARCH_SYNONYM_ARCHITECTURE.md`
8. `TAXONOMY_GLOBAL_SEARCH_VOCABULARY.csv`
9. `TAXONOMY_SEARCH_TERM_COLLISION_AUDIT.md`
10. `TAXONOMY_MERCHANT_ATTRIBUTE_ONBOARDING.md`
11. `TAXONOMY_PRODUCT_VARIANT_LISTING_ATTRIBUTE_MODEL.md`
12. `TAXONOMY_FACET_GOVERNANCE.md`
13. `TAXONOMY_FACET_ANTI_PATTERN_GUIDE.md`
14. `TAXONOMY_PROVISIONAL_ATTRIBUTE_DICTIONARY.csv`
15. `TAXONOMY_ATTRIBUTE_COVERAGE_STRESS_TEST.csv`
16. `TAXONOMY_FACET_SEARCH_READINESS.md`

`GLOBAL_FACET_ARCHITECTURE: PASS`

`L1_FACET_PROFILES: 24/24`

`FACET_NORMALIZATION_MODEL: PASS`

`COMPATIBILITY_MODEL: PASS`

`SEARCH_SYNONYM_ARCHITECTURE: PASS`

`MERCHANT_ATTRIBUTE_ONBOARDING_MODEL: PASS`

`PRODUCT_VARIANT_LISTING_BOUNDARY: PASS`

`ATTRIBUTE_DICTIONARY: PASS`

`ATTRIBUTE_COVERAGE_STRESS_TEST: PASS`

`READY_FOR_FACET_OWNER_REVIEW: YES`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`
