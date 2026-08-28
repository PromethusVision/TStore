# Taxonomy Owner Decision Auto-Resolution Map

## Status

**HYPOTHETICAL RECOMMENDED-OPTION IMPACT — NOT OWNER APPROVED / NOT CANONICAL**

This map answers what would become deterministic if the product owner selected each agent-recommended option. It does not mutate any proposal. “Resolved” means the root rule supplies a placement/decision answer; policy eligibility and exact L2 editorial ballots can remain open.

## Counting contract

- `RAW_DECISIONS_RESOLVED` counts the non-collision/non-failure source questions recorded in the matching semantic cluster.
- For the six `SAFE TO COLLAPSE: NO` clusters, only the shared root protocol is auto-closed; distinct sub-questions remain explicitly retained.
- Every collision and failure ID has one root owner in this map and is counted once.
- The 88 directly mapped `AMBIGUOUS` edge cases have one **primary** root owner here. Twenty-three secondary root references are recorded as dependencies, not counted again.
- `EDGE-0158`, `EDGE-0159` and `EDGE-0161` remain product-specific/manual; the minimum-root artifact did not directly assign them.
- `TOTAL IMPACT SCORE` is an auditable coverage score: raw source questions + collision IDs + failure IDs + primary ambiguity IDs. It is not a claim that policy or editorial work disappears.
- Policy entries mean “high-level posture clarified”; **zero** item-level policy allowlists are treated as legally resolved.

## Auto-resolution matrix

| Root ID | Option | Raw decisions resolved | Collisions resolved | Failures resolved | Ambiguities resolved (primary allocation) | Policy items resolved | Dependent roots unlocked | Total impact score |
|---|:---:|---|---|---|---|---|---|---:|
| ROOT-01 | A | 1 root protocol / 7 source questions; 6 sub-questions retained (`CLUSTER-01`) | COL-B-002, COL-B-003, COL-C-001, COL-F-003, COL-F-004, COL-F-010, COL-F-011 | FAIL-005, FAIL-006, FAIL-007 | EDGE-0011, EDGE-0014, EDGE-0023, EDGE-0024 (4) | 0 final; posture clarified for POL-011, POL-017, POL-018, POL-019, POL-020, POL-027 | ROOT-02, ROOT-08, ROOT-12, ROOT-15, ROOT-17, ROOT-18 | 21 |
| ROOT-02 | A | All 6 source questions in `CLUSTER-02` | COL-B-001, COL-C-006, COL-F-002, COL-G-003 | — | EDGE-0001, EDGE-0002, EDGE-0003, EDGE-0021, EDGE-0037 (5) | 0 final; posture clarified for POL-008, POL-009, POL-016 | ROOT-13, ROOT-17, ROOT-18 | 15 |
| ROOT-03 | A | All 3 source questions in `CLUSTER-03` | COL-B-004, COL-C-002, COL-C-003, COL-C-004, COL-C-005 | — | 0 primary; related PPE/sport edges are counted once under ROOT-08 | 0 final; POL-010 remains evidence-gated | ROOT-08, ROOT-13, ROOT-17, ROOT-18 | 8 |
| ROOT-04 | A | All 9 source questions in `CLUSTER-04` | COL-C-007, COL-C-008 | FAIL-003, FAIL-004 | EDGE-0038, EDGE-0039, EDGE-0040, EDGE-0041, EDGE-0042, EDGE-0044, EDGE-0045, EDGE-0046, EDGE-0048 (9) | 0 final; weapon-carrying POL-025 stays blocked | ROOT-17, ROOT-18 | 22 |
| ROOT-05 | A | All 5 source questions in `CLUSTER-05` | COL-B-009, COL-C-011, COL-C-012, COL-C-013, COL-F-006 | FAIL-008, FAIL-009, FAIL-018 | 0 primary; combined movable/fixed edge set is counted once under ROOT-06/ROOT-07 | 0 final; posture clarified for POL-012, POL-021, POL-024 | ROOT-06, ROOT-07, ROOT-17, ROOT-18 | 13 |
| ROOT-06 | A | All 2 source questions in `CLUSTER-06` | COL-B-008, COL-C-009, COL-C-010 | — | EDGE-0053, EDGE-0054, EDGE-0055, EDGE-0056, EDGE-0057, EDGE-0061 (6) | 0 final; POL-012 remains product-evidence-gated | ROOT-07, ROOT-17, ROOT-18 | 11 |
| ROOT-07 | A | All 5 source questions in `CLUSTER-07` | COL-B-010, COL-C-014, COL-C-015, COL-C-016, COL-C-017, COL-C-022, COL-F-007, COL-G-009 | FAIL-002, FAIL-019 | EDGE-0062, EDGE-0063, EDGE-0064, EDGE-0066, EDGE-0070, EDGE-0074, EDGE-0075, EDGE-0076, EDGE-0077, EDGE-0078, EDGE-0079, EDGE-0080, EDGE-0081, EDGE-0082, EDGE-0083, EDGE-0084, EDGE-0085, EDGE-0098, EDGE-0099, EDGE-0100, EDGE-0104, EDGE-0105, EDGE-0106, EDGE-0107, EDGE-0108, EDGE-0109, EDGE-0136, EDGE-0138, EDGE-0139, EDGE-0140, EDGE-0143, EDGE-0144, EDGE-0145 (33) | 0 final; posture clarified for POL-012, POL-013, POL-024 | ROOT-04, ROOT-17, ROOT-18 | 48 |
| ROOT-08 | A | All 8 source questions in `CLUSTER-08` | COL-B-005, COL-C-021, COL-F-005 | FAIL-001, FAIL-020 | EDGE-0025, EDGE-0026, EDGE-0027, EDGE-0028, EDGE-0029, EDGE-0030, EDGE-0031, EDGE-0032, EDGE-0033, EDGE-0034, EDGE-0036, EDGE-0113, EDGE-0114, EDGE-0115, EDGE-0117, EDGE-0119, EDGE-0120 (17) | 0 final; posture clarified for POL-010, POL-019 | ROOT-17, ROOT-18 | 30 |
| ROOT-09 | A | All 7 source questions in `CLUSTER-09` | COL-D-004, COL-D-005, COL-E-004 | FAIL-013, FAIL-014, FAIL-015, FAIL-016 | EDGE-0147, EDGE-0155, EDGE-0156 (3) | 0 final; POL-022 provenance remains separate | ROOT-17, ROOT-18 | 17 |
| ROOT-10 | A | All 6 source questions in `CLUSTER-10` | COL-E-001, COL-E-002, COL-E-003, COL-E-005 | FAIL-021, FAIL-022, FAIL-023, FAIL-024 | 0 primary; service-leakage cases are not part of the 91 `AMBIGUOUS` rows | 0 final; POL-003 remains separate | ROOT-09, ROOT-17, ROOT-18 | 14 |
| ROOT-11 | A | 1 root protocol / 4 source questions; 3 regulated-family sub-questions retained (`CLUSTER-11`) | COL-F-001, COL-F-008, COL-F-012 | FAIL-011 | 0 primary; restricted cases remain policy-blocked rather than re-labelled clear | 0 final; posture clarified for POL-006, POL-007, POL-025, POL-030, POL-031, POL-032 | ROOT-12, ROOT-16, ROOT-17, ROOT-18 | 8 |
| ROOT-12 | A | 1 root protocol / 4 source questions; 3 live/biological sub-questions retained (`CLUSTER-12`) | — | — | 0 primary; scope remains explicit allowlist/fulfilment work | 0 final; posture clarified for POL-015, POL-028, POL-029 | ROOT-17, ROOT-18 | 4 |
| ROOT-13 | A | All 8 source questions in `CLUSTER-13` | COL-C-018, COL-C-019, COL-C-020, COL-D-001, COL-D-002, COL-D-003 | FAIL-028, FAIL-029 | EDGE-0086, EDGE-0087, EDGE-0090, EDGE-0092, EDGE-0093, EDGE-0094, EDGE-0095 (7) | 0 final; child-safety POL-007 remains separate | ROOT-14, ROOT-17, ROOT-18 | 23 |
| ROOT-14 | A | All 8 source questions in `CLUSTER-14` | COL-G-006, COL-G-007, COL-G-008 | — | 0 directly mapped; three cases listed below stay explicit/manual | 0 final; POL-003 and POL-007 remain separate | ROOT-17, ROOT-18 | 11 |
| ROOT-15 | A | 1 root protocol / 4 source questions; 3 species/regulated-product sub-questions retained (`CLUSTER-15`) | COL-B-011, COL-F-009 | FAIL-025, FAIL-026, FAIL-027 | EDGE-0123, EDGE-0125, EDGE-0130, EDGE-0132 (4) | 0 final; posture clarified for POL-026, POL-028 | ROOT-17, ROOT-18 | 13 |
| ROOT-16 | A | 1 root protocol / 3 source questions; 2 precious/protected-material sub-questions retained (`CLUSTER-16`) | COL-B-012 | — | 0 primary; provenance remains an eligibility gate | 0 final; posture clarified for POL-022, POL-023 | ROOT-17, ROOT-18 | 4 |
| ROOT-17 | A | All 3 source questions in `CLUSTER-17` | COL-B-006, COL-B-007, COL-D-006, COL-G-001, COL-G-002, COL-G-004, COL-G-005 | — | 0 primary; future-L3/L4 rules are not current edge relabelling | 0; no policy group | ROOT-18 | 10 |
| ROOT-18 | A | 1 review protocol / 48 source questions; 47 domain/editorial questions retained (`CLUSTER-18`) | — | FAIL-010, FAIL-012, FAIL-017, FAIL-030, FAIL-031, FAIL-032, FAIL-033, FAIL-034, FAIL-035, FAIL-036, FAIL-037, FAIL-038, FAIL-039, FAIL-040, FAIL-041, FAIL-042 | 0; exact L2 review cannot auto-resolve product placement | 0; no policy group | — | 64 |

## Primary ambiguity reconciliation

| Metric | Count |
|---|---:|
| `AMBIGUOUS` rows in stress source | 91 |
| Directly mapped by the minimum-root artifact | 88 |
| Secondary cross-root references | 23 |
| Primary assignments in this map | 88 |
| Unmapped/manual | 3 |
| Counted more than once in totals | 0 |

The three retained cases are:

- `EDGE-0158` — child activity/colouring book;
- `EDGE-0159` — artist sketchbook;
- `EDGE-0161` — DIY jewelry starter kit.

ROOT-14 provides a strong future decision rule for these cases, but the prior minimum-root artifact did not claim them as direct mappings. This pack therefore keeps them explicit instead of retroactively inflating the auto-resolution estimate.

## Naming effect

- Naming issues auto-resolved by a root choice alone: **0/40**.
- Root choices can clarify the scope behind names, but all `NAM-001`–`NAM-040` remain explicit owner/editorial findings under ROOT-18.
- Examples of scope clarification without automatic rename include PPE (`NAM-023`, `NAM-036`), hazardous hunting scope (`NAM-002`), gift intent (`NAM-004`), species-first pet structure (`NAM-005`, `NAM-006`, `NAM-022`) and product/service wording (`NAM-024`, `NAM-038`, `NAM-040`).

## Future L3/L4 boundaries stabilized by recommended options

| Root family | Stable future boundary gained |
|---|---|
| ROOT-01 / ROOT-02 / ROOT-15 | Intended-use, life-stage and species facts stop competing as duplicate primary leaves. |
| ROOT-03 / ROOT-08 | Ordinary wearable form, technical sport function and certified protection receive a precedence order. |
| ROOT-04 / ROOT-07 | Generic carrying/accessory identity is separated from intrinsic fitment or device-domain integration. |
| ROOT-05 / ROOT-06 | Fixed infrastructure, movable product, manual utensil and powered appliance receive deterministic prompts. |
| ROOT-09 / ROOT-10 | Gift/personalization/service signals stop creating duplicate physical-product branches. |
| ROOT-13 / ROOT-14 / ROOT-17 | Facet exceptions, principal product and same-L1 leaf precedence gain explicit tests. |

## Totals

| Evidence layer | Unique items | Represented once in impact score |
|---|---:|:---:|
| Non-COL/non-FAIL source questions | 140 | YES |
| Collision IDs | 66 | YES |
| Failure IDs | 42 | YES |
| Directly mapped ambiguity IDs | 88 | YES |
| **TOTAL IMPACT SCORE** | **336** | **YES** |

- Safe-collapse roots: **12**.
- Roots retaining distinct sub-questions: **6**.
- Downstream root gates with at least one prerequisite: **13**.
- Item-level policy allowlists auto-finalized: **0**.
- Owner finalization performed: **NO**.

`AUTO_RESOLUTION_MAP: PASS`

`AMBIGUITIES_PRIMARY_MAPPED: 88/91`

`DOUBLE_COUNTED_AUTO_RESOLUTION_TOTALS: 0`

`OWNER_FINALIZATION: NOT_PERFORMED`
