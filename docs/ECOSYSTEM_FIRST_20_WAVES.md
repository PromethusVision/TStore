# Ecosystem First 20 Future Waves

**State:** RECOMMENDED ROADMAP — NO RUNTIME AUTHORIZED

| Wave | Goal | Dependencies | Owner gate | Integration evidence | Size |
|---:|---|---|---|---|---|
| 1 | Select pilot platform/release bar | ROOT-01 | YES | signed artifact matrix | S |
| 2 | Close remaining Customer physical gates | 1 | NO | device smoke | M |
| 3 | Lock catalog Product/Variant/Listing pilot contract | ROOT-04 | YES | identity tests | M |
| 4 | Activate only required taxonomy/catalog delta | 3, ROOT-03 | YES | migration dry run/rollback | L |
| 5 | Add minimal merchant organization/membership seam | ROOT-07 | YES | RLS isolation | L |
| 6 | Deliver controlled merchant listing path | 3,5, ROOT-12 | YES | cross-shop denial | L |
| 7 | Deliver verifier capability and revocation | 5 | NO | role/capability matrix | M |
| 8 | Harden QR exact-shop consume transaction | 7, ROOT-11 | YES | replay/concurrency suite | L |
| 9 | Revalidate verified-purchase/review invariants | 8 | NO | physical two-device + SQL/RLS | L |
| 10 | Establish ordinary-domain pilot allowlist | ROOT-09 | YES | fail-closed policy tests | M |
| 11 | Establish lean Ops evidence/runbooks | ROOT-17 | YES | incident/reversal exercise | M |
| 12 | Establish minimum event/health registry | ROOT-18 | YES | event authority/privacy audit | M |
| 13 | Run end-to-end Esenler release candidate | 1–12 | YES | exact artifact acceptance | XL |
| 14 | Conduct controlled commercial pilot | 13 | YES | monitoring/stop criteria | XL |
| 15 | Reconcile pilot evidence and catalog corrections | 14 | YES | owner learning review | M |
| 16 | Decide/full-build Merchant App expansion | 15, ROOT-12 | YES | merchant journey acceptance | L |
| 17 | Evaluate transparent reputation signals | 15, ROOT-16 | YES | fairness/explainability | M |
| 18 | Evaluate Ads shadow experiment | 15, ROOT-13/14 | YES | organic separation/no billing | L |
| 19 | Decide Reward economics before implementation | 15, ROOT-15 | YES | liability/fraud contract | M |
| 20 | Evaluate factual badges; defer levels/streaks | 15, ROOT-16 | YES | trusted evidence/trust test | M |

## Ordering invariant

Wave numbers communicate dependencies, not authorization. Waves 16–20 may be
reordered or omitted based on pilot evidence. Ads, Reward and badges are not pilot
prerequisites and no row selects an owner option.

`FIRST_20_WAVES: READY_FOR_OWNER_REVIEW`
