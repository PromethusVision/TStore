# Wave 33 — Global Taxonomy Candidate Inventory

**State:** SEMANTIC AUDIT INPUT — NO OWNER FINALIZATION

## 1. Source register

| Source | Exact HEAD | Input | Merge |
|---|---|---|:---:|
| Batch 01 | `709695961e900db91861a4307f76d24c73267367` | 6 candidate L1 | NO |
| Batch 02 | `28c40a3ac026c8712c9de0964de5fde42ba829dc` | 8 candidate L1 | NO |
| Batch 03 | `3dd6df685c7e6a5ed672188e010992063ea9d720` | 8 candidate L1 | NO |
| Current main | `d54239c6de8b4637bd093ea1e849d19093bdce7a` | 24 final L1, owner roots and two anchor domains | N/A |

All three source CSVs were read through Git objects. Source branches and source-tree files were not modified or merged.

## 2. All-24 L1 inventory

`POLICY-SENSITIVE` and `PROFESSIONAL-REVIEW` are terminal-leaf counts for candidate domains. Anchor domains do not yet expose one unified policy-tagged full tree, so they are reported qualitatively rather than assigned invented counts.

| # | L1 | State | L2 | L3 | L4 | Leaf | Policy-sensitive | Professional-review | Structural blocker |
|---:|---|---|---:|---:|---:|---:|---:|---:|---|
| 1 | Gıda & İçecek | CANDIDATE_FOR_OWNER_FINALIZATION | 14 | 67 | 6 | 71 | 19 | 19 | NO |
| 2 | Giyim & Moda | CANDIDATE_FOR_OWNER_FINALIZATION | 10 | 43 | 0 | 43 | 0 | 5 | NO |
| 3 | Ayakkabı | CANDIDATE_FOR_OWNER_FINALIZATION | 8 | 38 | 5 | 41 | 4 | 15 | NO |
| 4 | Çanta & Aksesuar | CANDIDATE_FOR_OWNER_FINALIZATION | 10 | 45 | 0 | 45 | 0 | 8 | NO |
| 5 | Elektronik | OWNER_FINAL | 9 | 9* | 7* | 14* | Present; exact full-tree count TBD | YES — electrical, battery/spare-part and device safety | NO for final anchor; sibling L3/L4 not in this audit |
| 6 | Bilgisayar & Tablet | OWNER_FINAL | 11 | 9* | 7* | 14* | Present; exact full-tree count TBD | YES — electrical, component and compatibility evidence | NO for final anchor; sibling L3/L4 not in this audit |
| 7 | Beyaz Eşya & Ev Aletleri | CANDIDATE_FOR_OWNER_FINALIZATION | 10 | 51 | 23 | 66 | 11 | 66 | NO |
| 8 | Ev & Yaşam | CANDIDATE_FOR_OWNER_FINALIZATION | 10 | 49 | 24 | 64 | 7 | 14 | NO |
| 9 | Züccaciye & Mutfak | CANDIDATE_FOR_OWNER_FINALIZATION | 11 | 51 | 5 | 54 | 49 | 50 | NO |
| 10 | Yapı, Hırdavat & Tesisat | CANDIDATE_FOR_OWNER_FINALIZATION | 14 | 78 | 2 | 79 | 57 | 58 | NO |
| 11 | Otomotiv & Motosiklet | CANDIDATE_FOR_OWNER_FINALIZATION | 11 | 61 | 14 | 71 | 58 | 58 | NO |
| 12 | Kozmetik & Kişisel Bakım | CANDIDATE_FOR_OWNER_FINALIZATION | 11 | 52 | 10 | 59 | 55 | 58 | NO |
| 13 | Anne & Bebek | CANDIDATE_FOR_OWNER_FINALIZATION | 9 | 42 | 17 | 53 | 49 | 53 | NO |
| 14 | Oyuncak & Hobi | CANDIDATE_FOR_OWNER_FINALIZATION | 11 | 50 | 8 | 55 | 44 | 55 | NO |
| 15 | Müzik & Enstrüman | CANDIDATE_FOR_OWNER_FINALIZATION | 10 | 52 | 31 | 72 | 2 | 72 | NO |
| 16 | Spor & Outdoor | CANDIDATE_FOR_OWNER_FINALIZATION | 10 | 55 | 34 | 77 | 39 | 77 | NO |
| 17 | Kitap | CANDIDATE_FOR_OWNER_FINALIZATION | 10 | 50 | 0 | 50 | 7 | 7 | NO |
| 18 | Kırtasiye & Ofis | CANDIDATE_FOR_OWNER_FINALIZATION | 11 | 59 | 2 | 60 | 23 | 23 | NO |
| 19 | Evcil Hayvan Ürünleri | CANDIDATE_FOR_OWNER_FINALIZATION | 7 | 43 | 0 | 43 | 31 | 31 | NO |
| 20 | Gözlük & Optik | CANDIDATE_FOR_OWNER_FINALIZATION | 7 | 21 | 0 | 22 | 20 | 20 | NO |
| 21 | Saat & Takı | CANDIDATE_FOR_OWNER_FINALIZATION | 11 | 35 | 0 | 36 | 31 | 31 | NO |
| 22 | Sağlık & Medikal | CANDIDATE_FOR_OWNER_FINALIZATION | 9 | 44 | 0 | 44 | 44 | 44 | NO — policy gate remains closed |
| 23 | Çiçek & Bahçe | CANDIDATE_FOR_OWNER_FINALIZATION | 11 | 53 | 0 | 53 | 40 | 40 | NO |
| 24 | Hediyelik & Parti | CANDIDATE_FOR_OWNER_FINALIZATION | 9 | 40 | 4 | 42 | 23 | 37 | NO |

`*` Elektronik counts describe the owner-final `Telefon & Aksesuarları` subtree (`9/7/14`); the other eight final L2 siblings have no owner-final full L3/L4 tree in this Wave 33 input. Bilgisayar counts likewise describe the owner-final `Bilgisayar Bileşenleri` subtree (`9/7/14`); the other ten final L2 siblings are not silently treated as completed L3/L4 trees.

## 3. Independently verified candidate totals

| Metric | Expected | Actual | Result |
|---|---:|---:|:---:|
| Candidate L1 | 22 | 22 | PASS |
| L2 | 224 | 224 | PASS |
| L3 | 1,079 | 1,079 | PASS |
| L4 | 185 | 185 | PASS |
| Assignable leaf | 1,200 | 1,200 | PASS |
| Machine rows | approximately 1,488 | 1,488 | PASS |

Batch detail:

| Batch | L1 | L2 | L3 | L4 | Leaf | Rows |
|---|---:|---:|---:|---:|---:|---:|
| 01 | 6 | 70 | 340 | 47 | 370 | 457 |
| 02 | 8 | 77 | 373 | 122 | 451 | 572 |
| 03 | 8 | 77 | 366 | 16 | 379 | 459 |

## 4. Candidate policy inventory

Across 1,200 candidate leaves:

- `NORMAL`: 587
- `REGULATED`: 442
- `LEGAL_REVIEW_REQUIRED`: 171
- policy-sensitive (`REGULATED` + `LEGAL_REVIEW_REQUIRED`): 613
- `PROFESSIONAL_REVIEW_REQUIRED=YES`: 841

Policy labels are candidate routing metadata, not sale permission. Cross-batch severity consistency is assessed separately in the policy semantic audit.

## 5. Anchor compatibility

- The exact Elektronik nine-L2 list and Bilgisayar & Tablet eleven-L2 list are not redesigned.
- Telefon & Aksesuarları and Bilgisayar Bileşenleri exact owner-final L3/L4 paths are not copied into or modified by the 22-domain candidate CSV.
- Cross-domain recommendations defer to the final anchor rules for generic/device-specific charging, smart home, camera/toy drone, console/PC gaming, vehicle electronics, smartwatch/classic watch, toner/paper, Arduino/ESP and SBC.
- Generic multi-device stylus, enterprise server and similar anchor TBDs remain TBD; this audit does not close them.

`CANDIDATE_L1_RECONCILED: 22/22`
`CANDIDATE_L2_RECONCILED: 224/224`
`OWNER_FINALIZATION_PERFORMED: NO`
`RUNTIME_IMPLEMENTATION: NO`
