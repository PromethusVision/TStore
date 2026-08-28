# Taxonomy Owner Decision Semantic Deduplication

## Status

**SEMANTIC CLUSTERING — NO OWNER FINALIZATION / NO SOURCE REWRITE**

All 248 source decisions are assigned exactly once. A `NO` cluster still has a common root question, but its materially different legal/structural sub-questions must remain visible and cannot be answered by one blanket choice.

## Cluster summary

| Cluster | Root family | Source decisions | Safe to collapse | P0 | P1 | P2 |
|---|---|---:|:---:|---:|---:|---:|
| CLUSTER-01 | Medical intended-use rule | 17 | NO | 11 | 2 | 4 |
| CLUSTER-02 | Baby/life-stage ownership rule | 10 | YES | 8 | 1 | 1 |
| CLUSTER-03 | Technical sport product ownership | 8 | YES | 3 | 5 | 0 |
| CLUSTER-04 | Generic versus domain-specific carrying product | 13 | YES | 10 | 1 | 2 |
| CLUSTER-05 | Fixed installation versus movable product | 13 | YES | 10 | 3 | 0 |
| CLUSTER-06 | Manual versus powered household product | 5 | YES | 5 | 0 | 0 |
| CLUSTER-07 | Generic versus fitment/device-specific electronics | 15 | YES | 8 | 7 | 0 |
| CLUSTER-08 | PPE and certified protection ownership | 13 | YES | 10 | 0 | 3 |
| CLUSTER-09 | Gift purpose and personalization no-duplication rule | 14 | YES | 2 | 9 | 3 |
| CLUSTER-10 | Product versus service boundary | 14 | YES | 4 | 9 | 1 |
| CLUSTER-11 | Weapon-like and hazardous recreation posture | 8 | NO | 3 | 0 | 5 |
| CLUSTER-12 | Live and biological product scope | 4 | NO | 1 | 1 | 2 |
| CLUSTER-13 | Facet or controlled category exception | 16 | YES | 10 | 5 | 1 |
| CLUSTER-14 | Published content, supply and kit principal-product rule | 11 | YES | 1 | 9 | 1 |
| CLUSTER-15 | Pet nutrition and veterinary-health rule | 9 | NO | 5 | 2 | 2 |
| CLUSTER-16 | Precious/high-value and protected-material provenance | 4 | NO | 3 | 0 | 1 |
| CLUSTER-17 | Same-L1 primary-intent rule for future L3/L4 | 10 | YES | 2 | 7 | 1 |
| CLUSTER-18 | Exact L2 structure and naming acceptance | 64 | NO | 46 | 13 | 5 |
| **TOTAL** | **18 root families** | **248** | — | **142** | **74** | **32** |

## Cluster detail

### CLUSTER-01 — Medical intended-use rule

- **CLUSTER_ID:** `CLUSTER-01`
- **SOURCE_DECISION_IDS:** B01:B01-FOOD-P0-03, B01:B01-COSMETICS-P0-06, B03:PET-03, B03:HLTH-02, B03:HLTH-05, GLOBAL:ROOT-01, COL:COL-B-002, COL:COL-B-003, COL:COL-C-001, COL:COL-F-003, COL:COL-F-004, COL:COL-F-010, COL:COL-F-011, FAIL:FAIL-005, FAIL:FAIL-006, FAIL:FAIL-007, STRESS_ROOT:SR-01
- **COMMON ROOT QUESTION:** When does a food, cosmetic, optic, sport, pet or consumer device move to Sağlık & Medikal or a controlled medical scope?
- **DISTINCT SUB-QUESTIONS:** Human medicines/exclusion; supplements and medical nutrition; medical-device eligibility; dermocosmetic/biosidal status; prescription optics.
- **SAFE TO COLLAPSE:** NO
- **WHY:** Taxonomy posture can share a root, but the listed product/legal families require separate evidence or domain approval; none may disappear behind the cluster.

### CLUSTER-02 — Baby/life-stage ownership rule

- **CLUSTER_ID:** `CLUSTER-02`
- **SOURCE_DECISION_IDS:** B01:B01-FOOD-P0-02, B02:BAG-01, B02:MOTHER-01, B02:MOTHER-03, B02:TOY-01, GLOBAL:ROOT-02, COL:COL-B-001, COL:COL-C-006, COL:COL-F-002, COL:COL-G-003
- **COMMON ROOT QUESTION:** When does explicit baby/pregnancy life-stage purpose override ordinary food, cosmetic, clothing, shoe, bag or toy form?
- **DISTINCT SUB-QUESTIONS:** Baby food owner; formula launch eligibility; baby-specific care/safety; age-only shoes/toys; diaper-bag integration.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-03 — Technical sport product ownership

- **CLUSTER_ID:** `CLUSTER-03`
- **SOURCE_DECISION_IDS:** B01:B01-CLOTHING-P1-05, B02:SHOE-01, GLOBAL:ROOT-03, COL:COL-B-004, COL:COL-C-002, COL:COL-C-003, COL:COL-C-004, COL:COL-C-005
- **COMMON ROOT QUESTION:** Should apparel/footwear keep product-form ownership when used for sport, and what threshold creates a specialist Sports product?
- **DISTINCT SUB-QUESTIONS:** Apparel/footwear form; technical sport equipment threshold; swim/ski eyewear; sports bra/internal leaf.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-04 — Generic versus domain-specific carrying product

- **CLUSTER_ID:** `CLUSTER-04`
- **SOURCE_DECISION_IDS:** B02:BAG-02, B02:BAG-03, B02:BAG-04, B03:STAT-04, GLOBAL:ROOT-04, COL:COL-C-007, COL:COL-C-008, FAIL:FAIL-003, FAIL:FAIL-004, STRESS_ROOT:SR-02, STRESS_ROOT:SR-04, STRESS_ROOT:SR-05, STRESS_ROOT:SR-10
- **COMMON ROOT QUESTION:** When does a bag/case stay in Çanta & Aksesuar, and when does integration make it part of Mother/Baby, Music, Sports or another device domain?
- **DISTINCT SUB-QUESTIONS:** Generic bag; instrument/camera/laptop case; hydration/bicycle bag; integrated carrier modules.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-05 — Fixed installation versus movable product

- **CLUSTER_ID:** `CLUSTER-05`
- **SOURCE_DECISION_IDS:** B01:B01-HOME-P0-06, B01:B01-HARDWARE-P1-05, B02:HOME-01, B03:FLWR-04, GLOBAL:ROOT-05, COL:COL-B-009, COL:COL-C-011, COL:COL-C-012, COL:COL-C-013, COL:COL-F-006, FAIL:FAIL-008, FAIL:FAIL-009, FAIL:FAIL-018
- **COMMON ROOT QUESTION:** Should fixed/plumbed/building-integrated products route to Hardware while movable room/garden products stay in Home or Flowers/Garden?
- **DISTINCT SUB-QUESTIONS:** Plumbed bathroom goods; fixed lighting; garden irrigation/furniture; installer-only gas/HVAC; custom cabinetry.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-06 — Manual versus powered household product

- **CLUSTER_ID:** `CLUSTER-06`
- **SOURCE_DECISION_IDS:** B01:B01-KITCHEN-P0-02, GLOBAL:ROOT-06, COL:COL-B-008, COL:COL-C-009, COL:COL-C-010
- **COMMON ROOT QUESTION:** Should powered appliance identity override kitchen/home/cosmetics usage context?
- **DISTINCT SUB-QUESTIONS:** Manual versus electric kitchen tools; powered cleaning; appliance accessories; electric personal-care devices.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-07 — Generic versus fitment/device-specific electronics

- **CLUSTER_ID:** `CLUSTER-07`
- **SOURCE_DECISION_IDS:** B01:B01-HARDWARE-P0-04, B03:AUTO-02, B03:AUTO-04, GLOBAL:ROOT-07, COL:COL-B-010, COL:COL-C-014, COL:COL-C-015, COL:COL-C-016, COL:COL-C-017, COL:COL-C-022, COL:COL-F-007, COL:COL-G-009, FAIL:FAIL-002, FAIL:FAIL-019, STRESS_ROOT:SR-08
- **COMMON ROOT QUESTION:** When should electronics/accessories follow Automotive, Hardware, Computer or a specific device family instead of owner-final generic Electronics?
- **DISTINCT SUB-QUESTIONS:** Vehicle fitment; generic charger/GPS; tool-platform accessories; EV infrastructure; PC/pro-audio workflow; watch batteries.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-08 — PPE and certified protection ownership

- **CLUSTER_ID:** `CLUSTER-08`
- **SOURCE_DECISION_IDS:** B01:B01-CLOTHING-P0-06, B01:B01-HARDWARE-P0-02, B02:SHOE-03, B02:SPORT-04, B03:HLTH-03, GLOBAL:ROOT-08, COL:COL-B-005, COL:COL-C-021, COL:COL-F-005, FAIL:FAIL-001, FAIL:FAIL-020, STRESS_ROOT:SR-03, STRESS_ROOT:SR-09
- **COMMON ROOT QUESTION:** Should certified protective function override clothing, footwear or eyewear form?
- **DISTINCT SUB-QUESTIONS:** Certified occupational PPE; safety footwear; sport protection; medical PPE; corrective versus protective eyewear.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-09 — Gift purpose and personalization no-duplication rule

- **CLUSTER_ID:** `CLUSTER-09`
- **SOURCE_DECISION_IDS:** B02:GIFT-01, B02:GIFT-02, B02:GIFT-03, B02:GIFT-04, B03:WATCH-04, GLOBAL:ROOT-09, COL:COL-D-004, COL:COL-D-005, COL:COL-E-004, FAIL:FAIL-013, FAIL:FAIL-014, FAIL:FAIL-015, FAIL:FAIL-016, STRESS_ROOT:SR-11
- **COMMON ROOT QUESTION:** Can gift purpose or personalization ever change the primary product owner?
- **DISTINCT SUB-QUESTIONS:** Gift occasion; intrinsic keepsake; personalization capability; multi-product bundle primary line item; party tableware.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-10 — Product versus service boundary

- **CLUSTER_ID:** `CLUSTER-10`
- **SOURCE_DECISION_IDS:** B01:B01-FOOD-P1-05, B01:B01-HOME-P1-04, B03:OPT-02, B03:FLWR-05, GLOBAL:ROOT-10, COL:COL-E-001, COL:COL-E-002, COL:COL-E-003, COL:COL-E-005, FAIL:FAIL-021, FAIL:FAIL-022, FAIL:FAIL-023, FAIL:FAIL-024, STRESS_ROOT:SR-12
- **COMMON ROOT QUESTION:** How should physical products bundled with preparation, installation, repair, personalization, subscription or delivery be classified?
- **DISTINCT SUB-QUESTIONS:** Packaged food versus restaurant; product versus installation/repair; flower subscription/delivery; physical versus digital goods.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-11 — Weapon-like and hazardous recreation posture

- **CLUSTER_ID:** `CLUSTER-11`
- **SOURCE_DECISION_IDS:** B01:B01-FOOD-P0-04, B02:TOY-03, B02:SPORT-02, GLOBAL:ROOT-11, COL:COL-F-001, COL:COL-F-008, COL:COL-F-012, FAIL:FAIL-011
- **COMMON ROOT QUESTION:** What is the V1 posture for alcohol, airsoft/paintball, hunting/weapon-like goods, fireworks, pressurized party gas and excluded weapons/explosives?
- **DISTINCT SUB-QUESTIONS:** Alcohol; weapon-like recreation; firearms/ammunition; pyrotechnics and pressured gas; hazardous automotive chemicals.
- **SAFE TO COLLAPSE:** NO
- **WHY:** Taxonomy posture can share a root, but the listed product/legal families require separate evidence or domain approval; none may disappear behind the cluster.

### CLUSTER-12 — Live and biological product scope

- **CLUSTER_ID:** `CLUSTER-12`
- **SOURCE_DECISION_IDS:** B03:PET-05, B03:FLWR-02, B03:FLWR-03, GLOBAL:ROOT-12
- **COMMON ROOT QUESTION:** What live plant/seed/animal/aquatic product families are in V1, and which traceability/fulfilment controls are mandatory?
- **DISTINCT SUB-QUESTIONS:** Live plants/seeds; aquatic plants/live animals; fertilizers versus pesticides; fulfilment and traceability.
- **SAFE TO COLLAPSE:** NO
- **WHY:** Taxonomy posture can share a root, but the listed product/legal families require separate evidence or domain approval; none may disappear behind the cluster.

### CLUSTER-13 — Facet or controlled category exception

- **CLUSTER_ID:** `CLUSTER-13`
- **SOURCE_DECISION_IDS:** B01:B01-CLOTHING-P0-02, B02:TOY-02, B02:TOY-04, B02:TOY-05, B02:MUSIC-01, GLOBAL:ROOT-13, COL:COL-C-018, COL:COL-C-019, COL:COL-C-020, COL:COL-D-001, COL:COL-D-002, COL:COL-D-003, FAIL:FAIL-028, FAIL:FAIL-029, STRESS_ROOT:SR-07, STRESS_ROOT:SR-14
- **COMMON ROOT QUESTION:** What evidence permits a cross-cutting attribute/audience/collection to remain an L2 instead of a facet or browse projection?
- **DISTINCT SUB-QUESTIONS:** Style/gender/age facets; traditional-instrument registry; toy-grade capability; collection versus structural node.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-14 — Published content, supply and kit principal-product rule

- **CLUSTER_ID:** `CLUSTER-14`
- **SOURCE_DECISION_IDS:** B03:BOOK-02, B03:BOOK-03, B03:BOOK-04, B03:BOOK-05, B03:STAT-02, B03:STAT-03, B03:STAT-05, GLOBAL:ROOT-14, COL:COL-G-006, COL:COL-G-007, COL:COL-G-008
- **COMMON ROOT QUESTION:** How should books/workbooks, blank stationery, art supplies, educational kits and puzzles choose one owner?
- **DISTINCT SUB-QUESTIONS:** Published book/workbook; blank stationery; art supply versus complete kit; physical versus digital publication.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-15 — Pet nutrition and veterinary-health rule

- **CLUSTER_ID:** `CLUSTER-15`
- **SOURCE_DECISION_IDS:** B03:PET-01, B03:PET-02, B03:PET-04, GLOBAL:ROOT-15, COL:COL-B-011, COL:COL-F-009, FAIL:FAIL-025, FAIL:FAIL-026, FAIL:FAIL-027
- **COMMON ROOT QUESTION:** How should pet food, pet supplements, hygiene and veterinary medical products be separated from human Food/Health/Cosmetics?
- **DISTINCT SUB-QUESTIONS:** Species-first architecture; shared pet products; pet food; supplements/veterinary goods; connected pet devices.
- **SAFE TO COLLAPSE:** NO
- **WHY:** Taxonomy posture can share a root, but the listed product/legal families require separate evidence or domain approval; none may disappear behind the cluster.

### CLUSTER-16 — Precious/high-value and protected-material provenance

- **CLUSTER_ID:** `CLUSTER-16`
- **SOURCE_DECISION_IDS:** B02:MUSIC-04, B03:WATCH-03, GLOBAL:ROOT-16, COL:COL-B-012
- **COMMON ROOT QUESTION:** Can ordinary product-form taxonomy remain stable while precious/high-value/protected-material eligibility is handled separately?
- **DISTINCT SUB-QUESTIONS:** Finished jewelry; investment gold/loose stones; protected biological material; authenticity/provenance.
- **SAFE TO COLLAPSE:** NO
- **WHY:** Taxonomy posture can share a root, but the listed product/legal families require separate evidence or domain approval; none may disappear behind the cluster.

### CLUSTER-17 — Same-L1 primary-intent rule for future L3/L4

- **CLUSTER_ID:** `CLUSTER-17`
- **SOURCE_DECISION_IDS:** B01:B01-FOOD-P1-06, B02:MUSIC-03, GLOBAL:ROOT-17, COL:COL-B-006, COL:COL-B-007, COL:COL-D-006, COL:COL-G-001, COL:COL-G-002, COL:COL-G-004, COL:COL-G-005
- **COMMON ROOT QUESTION:** When adjacent L2s within one L1 both plausibly fit, should physical form, use intent or packaging control the future leaf?
- **DISTINCT SUB-QUESTIONS:** Adjacent same-L1 intent; packaging versus use; play versus collection; MIDI instrument/controller; future leaf precedence.
- **SAFE TO COLLAPSE:** YES
- **WHY:** The source questions apply the same precedence principle to different products; one guarded root answer can resolve them while preserving listed exceptions.

### CLUSTER-18 — Exact L2 structure and naming acceptance

- **CLUSTER_ID:** `CLUSTER-18`
- **SOURCE_DECISION_IDS:** B01:B01-FOOD-P0-01, B01:B01-CLOTHING-P0-01, B01:B01-CLOTHING-P1-03, B01:B01-CLOTHING-P0-04, B01:B01-HOME-P0-01, B01:B01-HOME-P0-02, B01:B01-HOME-P0-03, B01:B01-HOME-P1-05, B01:B01-KITCHEN-P0-01, B01:B01-KITCHEN-P0-03, B01:B01-KITCHEN-P0-04, B01:B01-KITCHEN-P0-05, B01:B01-KITCHEN-P1-06, B01:B01-HARDWARE-P0-01, B01:B01-HARDWARE-P0-03, B01:B01-HARDWARE-P0-06, B01:B01-HARDWARE-P0-07, B01:B01-COSMETICS-P0-01, B01:B01-COSMETICS-P0-02, B01:B01-COSMETICS-P0-03, B01:B01-COSMETICS-P0-04, B01:B01-COSMETICS-P1-05, B01:B01-COSMETICS-P2-07, B02:SHOE-02, B02:HOME-02, B02:HOME-03, B02:MOTHER-02, B02:MUSIC-02, B02:SPORT-01, B02:SPORT-03, B03:AUTO-01, B03:AUTO-03, B03:AUTO-05, B03:BOOK-01, B03:STAT-01, B03:OPT-01, B03:OPT-03, B03:OPT-04, B03:OPT-05, B03:WATCH-01, B03:WATCH-02, B03:WATCH-05, B03:HLTH-01, B03:HLTH-04, B03:FLWR-01, GLOBAL:ROOT-18, FAIL:FAIL-010, FAIL:FAIL-012, FAIL:FAIL-017, FAIL:FAIL-030, FAIL:FAIL-031, FAIL:FAIL-032, FAIL:FAIL-033, FAIL:FAIL-034, FAIL:FAIL-035, FAIL:FAIL-036, FAIL:FAIL-037, FAIL:FAIL-038, FAIL:FAIL-039, FAIL:FAIL-040, FAIL:FAIL-041, FAIL:FAIL-042, STRESS_ROOT:SR-06, STRESS_ROOT:SR-13
- **COMMON ROOT QUESTION:** After root boundaries are answered, which of the 22 exact L2 lists/names require owner edits before canonical lock?
- **DISTINCT SUB-QUESTIONS:** Twenty-two exact L2 structures; 40 naming findings; over/under-granularity; domain-specific order and wording choices.
- **SAFE TO COLLAPSE:** NO
- **WHY:** Taxonomy posture can share a root, but the listed product/legal families require separate evidence or domain approval; none may disappear behind the cluster.

## Reconciliation

- Source decisions represented: 248/248.
- Unique source IDs represented: 248/248.
- Semantic clusters: 18.
- Safe to collapse: 12.
- Must preserve distinct sub-questions: 6.
- Standalone/deferred disposition: determined in the minimum-root and workload packages; no source decision is dropped here.

`OWNER_DECISION_DEDUPLICATION: PASS`

`SOURCE_DECISIONS_ACCOUNTED: 248/248`
