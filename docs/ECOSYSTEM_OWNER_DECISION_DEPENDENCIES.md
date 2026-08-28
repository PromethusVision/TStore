# Ecosystem Owner Decision Dependency Graph

**State:** RECOMMENDED REVIEW ORDER — NO DECISION SELECTED

| Root | Direct raw decisions | Unlocks | Depends on | First-15 rank |
|---|---:|---|---|---:|
| ROOT-01 Pilot/release | 4 | artifact scope, physical gates, CI/release evidence | none | 1 |
| ROOT-04 Catalog identity | 3 | listings, search, QR snapshots, reviews, Ads object | taxonomy final evidence | 2 |
| ROOT-07 Merchant topology/staff | 3 | shop authorization, verifier, listing writes, Merchant App | none | 3 |
| ROOT-11 QR evidence | 2 | merchant verification, review, physical acceptance | ROOT-04, ROOT-07 | 4 |
| ROOT-09 Policy/services | 2 | merchant/product activation, Ops queues, Ads/Reward allowlists | merchant/product identity | 5 |
| ROOT-10 Listing/communication | 3 | customer truth, Merchant minimum UX, dashboards | ROOT-07, ROOT-09 | 6 |
| ROOT-03 Taxonomy/facet/legacy/demo | 4 | runtime navigation/search/migration/demo retirement | ROOT-04 | 7 |
| ROOT-05 Catalog intake/measure/media | 3 | candidate workflow, variable measure, Storage moderation | ROOT-04, ROOT-09 | 8 |
| ROOT-06 Corrections/reviews | 2 | merge/split implementation and historical rights | ROOT-04, QR invariant | 9 |
| ROOT-08 Merchant Sector | 3 | onboarding vocabulary, secondary sectors, branch assignments | ROOT-07, ROOT-09 | 10 |
| ROOT-17 Lean Ops | 3 | cases, appeals, regulated review, incident response | ROOT-09 | 11 |
| ROOT-18 Analytics/privacy | 2 | pilot KPI, dashboards, monitoring retention | ROOT-01, ROOT-09 | 12 |
| ROOT-12 Merchant App delivery | 1 | full app sequencing/platform workload | ROOT-07, ROOT-10, ROOT-11 | 13 |
| ROOT-13 Ads existence/object | 2 | whether any Ads work continues | ROOT-04, ROOT-09, ROOT-10, ROOT-17 | 14 |
| ROOT-15 Reward existence/economics | 4 | whether Reward ledger/economics work continues | QR invariant, ROOT-09, ROOT-17 | 15 |
| ROOT-02 Customer local privacy | 2 | Nearby/login and device retention UX | ROOT-18 privacy posture | later independent |
| ROOT-14 Ads economics/privacy | 3 | billing, targeting, attribution, disputes | ROOT-13 must permit Ads | conditional |
| ROOT-16 Gamification/reputation | 2 | badge/signal/display runtime | verified evidence volume, ROOT-15 where related | post-pilot |

## Highest-leverage chain

`ROOT-04 + ROOT-07 + ROOT-09` establish what is sold, who may operate, and what may
activate. `ROOT-11` then secures physical evidence. `ROOT-01` establishes what can
ship. These five roots unblock most pilot implementation without deciding Ads,
Reward or gamification.
