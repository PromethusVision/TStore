# WAVE 33 — Global Taxonomy Structural Validation

State: **VALIDATED — OWNER FINALIZATION SUPPORT**

Date: 2026-08-29

This audit independently parses the three Wave 32 machine-readable taxonomy trees at their pinned commits. It does not merge a source branch, alter a source tree, make a semantic owner decision, or create production stable IDs.

## 1. Scope and source lineage

| Batch | Pinned commit | Source file | Git blob | SHA-256 | Source rows |
|---|---|---|---|---|---:|
| Batch 01 | `709695961e900db91861a4307f76d24c73267367` | `docs/TAXONOMY_BATCH_01_FINALIZATION_TREE.csv` | `8c695ed7a52bf4a907344173e26e17ae6c522df5` | `f956168393e1d1a05b6984f8422110a6a9db3a5173881136bdecc15331f0a9cf` | 457 |
| Batch 02 | `28c40a3ac026c8712c9de0964de5fde42ba829dc` | `docs/TAXONOMY_BATCH_02_FINALIZATION_TREE.csv` | `623936378735abb0938441f28f1a4dccb518631f` | `37f75c6c453f43a6484ce984a66b1b346e408a19f853f991a1cb148efc165855` | 572 |
| Batch 03 | `3dd6df685c7e6a5ed672188e010992063ea9d720` | `docs/TAXONOMY_BATCH_03_FINALIZATION_TREE.csv` | `d732ef677d3834b67b5bf49d1e945af696cf4f18` | `70cf7cfd41493237f60d1b4a297216350107cbc383faeb857106ac87429d3965` | 459 |

All three files passed strict UTF-8 decoding, have no byte-order mark, and expose the same exact 13-column schema:

`L1,L2,L3,L4,LEAF_YN,NODE_STATE,POLICY_CLASS,PRIMARY_DOMAIN,FACET_NOTES,SYNONYM_NOTES,OWNER_DECISION_REQUIRED,PROFESSIONAL_REVIEW_REQUIRED,SOURCE_NOTES`

The source CSV format materializes L2–L4 rows. L1 count is therefore derived from the distinct canonical L1 values; L1 nodes are not additional source rows. This explains why 22 + 224 + 1,079 + 185 = 1,510 logical depth counts while the source-row manifest contains 224 + 1,079 + 185 = 1,488 rows.

## 2. Recalculated counts

| Scope | Source rows | L1 | L2 | L3 | L4 | Leaf | Max depth |
|---|---:|---:|---:|---:|---:|---:|---:|
| Batch 01 | 457 | 6 | 70 | 340 | 47 | 370 | 4 |
| Batch 02 | 572 | 8 | 77 | 373 | 122 | 451 | 4 |
| Batch 03 | 459 | 8 | 77 | 366 | 16 | 379 | 4 |
| **Global** | **1,488** | **22** | **224** | **1,079** | **185** | **1,200** | **4** |

The independently calculated global counts exactly reconcile with the Wave 33 expected totals. The previously approximate 1,488 source-row expectation is exact for these pinned inputs.

## 3. Validation results

| Contract | Result | Findings |
|---|---|---:|
| Exact CSV schema | PASS | 0 mismatches |
| Strict UTF-8 / Turkish text integrity | PASS | 0 decode failures, malformed Turkish sequences, or non-NFC names |
| Blank or invalid hierarchy names | PASS | 0 |
| Leading/trailing/repeated whitespace | PASS | 0 |
| Punctuation/name normalization | PASS | 0 structural collisions |
| Parent-child consistency | PASS | 0 missing parent paths |
| Orphan L3/L4 nodes | PASS | 0 |
| Maximum depth <= 4 | PASS | maximum 4 |
| L5 absent | PASS | 0 |
| Duplicate full path | PASS | 0 |
| Duplicate sibling | PASS | 0 |
| Normalized duplicate sibling | PASS | 0 |
| Leaf/container contradiction | PASS | 0 |
| Invalid `POLICY_CLASS` enum | PASS | 0 |
| Invalid `NODE_STATE` / boolean state | PASS | 0 |
| Same path with inconsistent policy | PASS | 0 |
| Parent policy weaker than direct child | PASS | 0 |
| Hidden production UUID/stable-ID invention | PASS | 0 |
| Source lineage token/commit/file consistency | PASS | 0 |

Policy values observed across all 1,488 source rows are `NORMAL` (695), `REGULATED` (552), and `LEGAL_REVIEW_REQUIRED` (241). No value outside the permitted enum was found. Zero `AGE_RESTRICTED` and zero `EXCLUDED` rows are count observations, not a semantic policy judgment.

## 4. Structural issue register

There are **0 errors** and **1 warning**.

| Issue | Severity | Finding | Treatment |
|---|---|---|---|
| `W33-ISSUE-0001` | WARNING | `Fren Parçaları` occurs under both `Spor & Outdoor > Bisiklet > Bisiklet Parçaları` and `Otomotiv & Motosiklet > Motosiklet Yedek Parçaları`. | Do not mechanically merge or rename. The full paths are unique and structurally valid; retain as a semantic cross-domain owner-review item. |

This warning does not represent a duplicate path or sibling collision. The two product-family labels have different parents and may be legitimate contextual homonyms. Wave 33 makes no semantic owner decision.

## 5. Batch 02 rename validation

### İş & Profesyonel Ayakkabılar

- Exact L2 container count: 1
- Descendant count: 3
- Descendants resolving through the exact new parent path: 3/3
- References to the prior `İş & Güvenlik Ayakkabıları` parent: 0
- Result: PASS

### Balıkçılık

- Exact L2 container count: 1
- Descendant count: 6
- Descendants resolving through the exact new parent path: 6/6
- References to the prior `Balıkçılık & Avcılık` parent: 0
- Result: PASS

No descendant retains an old parent reference for either proposed Batch 02 rename.

## 6. Global manifest contract

`TAXONOMY_W33_GLOBAL_NODE_MANIFEST.csv` contains exactly one row for each of the 1,488 materialized source rows. Ordering is deterministic: Batch 01, Batch 02, Batch 03, then original source-row order.

The identifiers `AUDIT-000001` through `AUDIT-001488` are temporary audit locators only. They are continuous and unique, and every materialized L3/L4 parent reference resolves to another audit row. They are explicitly marked `TEMPORARY_AUDIT_ID_NOT_PRODUCTION_STABLE_ID` and must never be migrated, persisted, or interpreted as canonical production stable IDs. Materialized L2 rows have no `PARENT_AUDIT_ID` because L1 is derived rather than represented as a source row.

## 7. Recommended correction and owner support

No mechanical source correction is required. The only registered warning should remain a semantic owner-review item so that contextual homonyms are not changed by an automated structural validator.

The three pinned sources are structurally ready to support bulk owner finalization. This statement confirms structural integrity only; it does not finalize taxonomy semantics, policy eligibility, source proposals, or runtime activation.

## 8. Safety and limitations

- Source branches were read by pinned commit and were not merged.
- Source CSV trees were not edited.
- No runtime, Flutter, Figma, database, migration, Supabase, Production, or Development change was made.
- No production stable ID was generated.
- The validator checks structural and lexical contracts. Cross-domain semantic ownership remains outside its authority.

## 9. Final flags

`GLOBAL_STRUCTURAL_VALIDATION: PASS`

`SOURCE_BATCHES: 3/3`

`L1_COUNT_RECONCILED: PASS`

`L2_COUNT_RECONCILED: PASS`

`L3_COUNT_RECONCILED: PASS`

`L4_COUNT_RECONCILED: PASS`

`LEAF_COUNT_RECONCILED: PASS`

`MAX_DEPTH_CONTRACT: PASS`

`DUPLICATE_PATHS: 0`

`ORPHAN_NODES: 0`

`READY_FOR_OWNER_FINALIZATION_SUPPORT: YES`

`RUNTIME_IMPLEMENTATION: NO`
