# Merchant Pilot Owner Decisions

State: `OWNER_DECISION_REQUIRED — NO OPTION SELECTED`

## Raw decision inventory

| ID | Priority | Question | Options | Recommendation (non-final) |
|---|---|---|---|---|
| MPD-01 | P0 | Pilot operating model? | A Full App / B Minimum safe / C Assisted verifier | B; C only time-boxed bootstrap |
| MPD-02 | P0 | Initial cohort shape? | single-owner ordinary shops / broader shops | Single-owner ordinary cohort |
| MPD-03 | P0 | Must merchant self-service listing truth? | price+availability+freshness / operator-only | Self-service core |
| MPD-04 | P0 | QR launch scope? | all cohort / staged subset / defer | Staged subset after gates |
| MPD-05 | P0 | Regulated domains? | exclude / specialist allowlist / broad allow | Fail-closed ordinary allowlist |
| MPD-06 | P0 | Production release authority? | owner/integration human gate / automated | Explicit human gate |
| MPD-07 | P1 | Single-owner duration? | entire pilot / until threshold / immediate staff | Until measured multi-user need |
| MPD-08 | P1 | Assisted onboarding limit? | all cohort / first batch/time-box / none | First batch/time-box |
| MPD-09 | P1 | Shop profile edits? | self-service / request change / assisted | Low-risk self-service, verified fields reviewed |
| MPD-10 | P1 | Freshness policy? | fixed interval / category-risk interval / manual-only | Small risk-tier policy, baseline needed |
| MPD-11 | P1 | Availability model? | boolean / AVAILABLE-OUT-UNKNOWN-TEMP | Explicit states |
| MPD-12 | P1 | Candidate intake? | merchant submit / operator only / defer | Simple submit + review |
| MPD-13 | P1 | QR history depth? | last transactions / full export / none | Limited recent PII-minimized view |
| MPD-14 | P1 | Review capability? | read+report / read-only / defer | Read + simple report |
| MPD-15 | P1 | Critical notifications? | in-app only / push+in-app / support relay | In-app authority + push convenience |
| MPD-16 | P1 | Android-only merchant pilot? | Android only / Android+iOS | Android-only option merits owner choice |
| MPD-17 | P1 | Merchant verification evidence set? | minimal ordinary / broad documents | Minimal risk-proportionate evidence |
| MPD-18 | P1 | Support coverage/pause rule? | named hours+pause / best effort | Named coverage and pause path |
| MPD-19 | P1 | One operator combines roles? | yes+audit / strict separation | Pilot combination + compensating audit |
| MPD-20 | P2 | Multi-staff trigger? | merchant count / support evidence / date | Evidence trigger, not date |
| MPD-21 | P2 | Multi-branch trigger? | cohort need / prebuild | Real cohort need |
| MPD-22 | P2 | Analytics surface? | action summary / dashboard / none | Action summary only |
| MPD-23 | P1 | App packaging path? | dedicated app / second entry point / customer routes | Dedicated direction; engineering spike decides path |
| MPD-24 | P0 | Pilot stop conditions? | predefined trust/ops stops / ad hoc | Predefined P0/P1 and support-capacity stops |

## Semantic deduplication

| Root | Raw decisions | Root question |
|---|---|---|
| MPR-01 | 01, 08 | Hangi operating model ve assisted sınır? |
| MPR-02 | 02, 07, 20, 21 | Hangi merchant/shop organizasyonları cohort'a alınır? |
| MPR-03 | 03, 09, 10, 11 | Merchant hangi listing/profile truth'u self-service sürdürür? |
| MPR-04 | 12 | Catalog candidate akışı pilotta açılır mı? |
| MPR-05 | 04, 13 | QR kapsamı ve merchant history görünürlüğü? |
| MPR-06 | 05, 17 | Verification ve regulated allowlist sınırı? |
| MPR-07 | 14 | Review/evaluation görünürlüğü ve report? |
| MPR-08 | 15, 18 | Critical notifications ve support coverage? |
| MPR-09 | 16, 23 | Merchant App platform/paketleme stratejisi? |
| MPR-10 | 19 | Pilot separation-of-duties düzeyi? |
| MPR-11 | 22 | Merchant analytics minimumu? |
| MPR-12 | 06, 24 | Production authority ve stop/governance? |

Counts: 24 raw; 12 root; P0 raw 7; P1 raw 13; P2 raw 4. Hiçbir seçenek owner adına seçilmemiştir.

