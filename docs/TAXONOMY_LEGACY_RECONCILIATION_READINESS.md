# EsnaftaVar Legacy Taxonomy Reconciliation Readiness

**State:** AUDIT COMPLETE — RUNTIME IMPLEMENTATION NOT PERFORMED

## 1. Executive result

The legacy source was independently verified at 651 nodes and every node has one
machine-reviewable reconciliation row. Owner-final targets are separated from
proposal targets, legacy identity limitations are documented, every split is in
the registry, static product impact is bounded, and all rows have a deterministic
future automation lane.

This makes the package ready as input to **post-owner runtime planning**. It does
not make the taxonomy ready for runtime migration: 22 L2 proposals remain
unapproved, 461 rows have no exact successor, deployed UUID/product evidence is
unknown, and no Production authorization exists.

## 2. Legacy source summary

| Measure | Result |
|---|---:|
| Authoritative candidate | `docs/data/esnaftavar_category_taxonomy_v1_final.json` |
| SHA-256 | `182B8719E74EA889F5FC3B257D119C258C8750F8D24883D08AA6AFB88CCD2B08` |
| L1 | 23 |
| L2 | 91 |
| L3 | 505 |
| L4 | 32 |
| Total nodes / reconciliation rows | 651 / 651 |
| Unique legacy locators | 651 |
| Opaque immutable legacy IDs | 0 |
| Runtime import of legacy JSON observed | 0 |

## 3. Reconciliation totals

| Action | Count |
|---|---:|
| KEEP | 20 |
| RENAME | 17 |
| MOVE | 60 |
| RENAME_AND_MOVE | 9 |
| MERGE | 0 |
| SPLIT | 83 |
| RETIRE | 1 |
| ALIAS_ONLY | 0 |
| OUT_OF_PRODUCT_TAXONOMY | 0 |
| UNRESOLVED | 461 |
| **Total** | **651** |

| Target state | Count |
|---|---:|
| CANONICAL_FINAL | 108 |
| PROVISIONAL_PROPOSAL | 542 |
| NO_TARGET_YET | 1 |
| POLICY_REVIEW | 0 |
| OUT_OF_SCOPE | 0 |
| **Total** | **651** |

Policy-sensitive placement is represented separately: 130 rows have one or more
legacy `POLICY_FLAG` values. This prevents a target-state label from being
misread as listing approval.

## 4. Automation readiness

| Lane | Count |
|---|---:|
| AUTO_SAFE | 87 |
| AUTO_AFTER_OWNER_FINAL | 13 |
| MANUAL_REVIEW | 360 |
| POLICY_REVIEW | 130 |
| BLOCKED | 61 |
| **Total** | **651** |

`AUTO_SAFE` is a design classification, not current execution authorization. All
lanes still require stable IDs and a Development dry-run; only the evidence and
review burden differ.

## 5. Split / merge / alias readiness

- MERGE: 0 exact rows; no premature semantic collapse.
- SPLIT: 83 rows, all represented in the split registry.
- Owner-final splits: 16; proposal-dependent splits: 67.
- High-risk splits: 4; assignable legacy leaf splits: 2.
- Future legacy alias/redirect signal: 93 rows.
- Every high-confidence rename/move has alias preservation marked.
- Search synonyms are explicitly separated from identity redirects.

## 6. Product impact readiness

- Exact static products referencing a legacy JSON ID/slug as category identity: 0.
- Exact safe stable-ID mappings: 0, because legacy opaque IDs do not exist and
  deployed UUID binding is unknown.
- Modern Esenler demo: 4 categories, 20 products, 285 listings; 5 products have
  owner-final L2 placement evidence, 15 depend on proposal L2s.
- Historical broad sample: 5 categories, 29 products, 34 related listings; broad
  categories cross canonical domains and all products need eventual leaf review.
- Production and Development product counts/assignments: UNKNOWN; neither
  environment was queried.

## 7. Top 20 reconciliation risks

1. The 22 non-Electronics/non-Computer L2 architectures are proposals, not final.
2. 461 legacy rows lack an exact owner-final successor.
3. 67 splits depend on unapproved proposal targets.
4. The legacy source has no opaque immutable IDs.
5. No static evidence binds deployed category UUIDs to legacy slugs.
6. `telefon-tutucu` is an assignable, cross-L1, use-case-dependent split.
7. `bilgisayar-sogutma` is an assignable leaf with four final successors.
8. `Oyuncak, Hobi & Müzik` splits into two owner-final L1 identities.
9. Coarse Electronics/Computer L2s alter parent filters and deep links.
10. Runtime categories have no visible slug/alias/version/successor model.
11. Product queries filter one exact category UUID, not visible descendants.
12. SQL permits null product category IDs while the Flutter model expects a
    non-null string.
13. 130 nodes carry policy/risk flags independent of taxonomy placement.
14. Live Production product/category impact is unknown by design.
15. Modern demo UUIDs are deterministic fixture IDs, not canonical stable IDs.
16. Historical sample categories mix products across future L1 boundaries.
17. Existing external URLs, saved filters, and merchant imports are unknown.
18. Alias/redirect collision behavior has no runtime implementation yet.
19. `hediyelik-obje` is inactive and could be accidentally reactivated.
20. The zero-merge finding may change after owner-final L3/L4 designs; it must be
    re-audited rather than assumed permanent.

## 8. Recommended future execution sequence

1. Owner-finalize the 22 L2 proposals.
2. Complete necessary owner-final L3/L4 designs and policy boundaries.
3. Freeze canonical opaque stable IDs and lifecycle/edge contracts.
4. Re-run this inventory against final targets and close unresolved rows.
5. Finalize split/merge successor graph and deterministic/manual product rules.
6. Build versioned migration and alias/redirect tooling.
7. Perform an authorized read-only deployed-data profile.
8. Dry-run against Development with product, hierarchy, link, search, and
   analytics reconciliation.
9. Adapt runtime client/query behavior and demo seed under separate scope.
10. Migrate Production only after explicit authorization, rollback readiness, and
    successful post-run reconciliation.

No step in this sequence was executed here.

## 9. Audit document set

- `docs/TAXONOMY_LEGACY_SOURCE_AUDIT.md`
- `docs/TAXONOMY_LEGACY_NODE_RECONCILIATION.csv`
- `docs/TAXONOMY_LEGACY_NODE_RECONCILIATION.md`
- `docs/TAXONOMY_STABLE_ID_MIGRATION_STRATEGY.md`
- `docs/TAXONOMY_LEGACY_ALIAS_REDIRECT_PLAN.md`
- `docs/TAXONOMY_LEGACY_SPLIT_MERGE_REGISTRY.md`
- `docs/TAXONOMY_LEGACY_PRODUCT_IMPACT.md`
- `docs/TAXONOMY_RUNTIME_RECONCILIATION_RISK.md`
- `docs/TAXONOMY_RECONCILIATION_AUTOMATION_PLAN.md`
- `docs/TAXONOMY_LEGACY_RECONCILIATION_READINESS.md`

## 10. Final flags

`LEGACY_TAXONOMY_SOURCE_AUDIT: PASS`

`LEGACY_NODE_RECONCILIATION: PASS`

`STABLE_ID_STRATEGY: PASS`

`SPLIT_MERGE_REGISTRY: PASS`

`PRODUCT_IMPACT_ANALYSIS: PASS`

`RECONCILIATION_AUTOMATION_PLAN: PASS`

`READY_FOR_POST_OWNER_RUNTIME_PLANNING: YES`

`RUNTIME_IMPLEMENTATION_PERFORMED: NO`

`PRODUCTION_TOUCHED: NO`
