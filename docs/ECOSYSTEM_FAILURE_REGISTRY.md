# Ecosystem Stress Failure Registry

**State:** DESIGN FINDINGS — NO RUNTIME FAILURE CLAIM

Stress scenarios test whether a contract has an explicit safe answer. `OPEN` means an
owner or future implementation gate remains; it does not mean a live system failed.

| Failure ID | Priority | Systems | Failure mode | Safe disposition | Status |
|---|---:|---|---|---|---|
| ECO-F001 | P0 | Auth/Merchant | profile role used as shop authorization | membership + capability + RLS | RESOLVED_BY_CONTRACT |
| ECO-F002 | P0 | Merchant/Policy | sector label treated as licence | separate policy evidence | RESOLVED_BY_CONTRACT |
| ECO-F003 | P0 | Catalog | Product/Variant/Listing collapsed | stable separate identities | ROOT-04 OPEN |
| ECO-F004 | P0 | QR/Analytics | telemetry creates purchase evidence | atomic QR transaction only | RESOLVED_BY_CONTRACT |
| ECO-F005 | P0 | Catalog/Review | merge/split rewrites review history | immutable lineage/correction | ROOT-06 OPEN |
| ECO-F006 | P0 | Ads/Analytics | attribution represented as sale/revenue | soft intent labels only | RESOLVED_BY_CONTRACT |
| ECO-F007 | P0 | Reward/Review | quantity/repeat adds review rights | independent eligibility evaluator | RESOLVED_BY_CONTRACT |
| ECO-F008 | P0 | Ads/Reputation | paid spend creates organic trust | hard evidence firewall | RESOLVED_BY_CONTRACT |
| ECO-F009 | P0 | Ops/RLS | admin interface bypasses authority | server capability + case + audit | ROOT-17 OPEN |
| ECO-F010 | P0 | QA/Release | green automation implies release acceptance | exact artifact/manual gates | ROOT-01 OPEN |
| ECO-F011 | P1 | Catalog/QR | variable measure activated without snapshot rule | defer until ROOT-05/11 | OPEN |
| ECO-F012 | P1 | Merchant/Pilot | full Merchant App blocks pilot verifier | controlled operating path | ROOT-12 OPEN |
| ECO-F013 | P1 | Merchant | enterprise branch hierarchy imposed on pilot | one-shop seam | ROOT-07 OPEN |
| ECO-F014 | P1 | Taxonomy/Runtime | final taxonomy implies final migration/facets | staged activation | ROOT-03 OPEN |
| ECO-F015 | P1 | Merchant Taxonomy | one final subtree finalizes proposal | preserve per-node state | ROOT-08 OPEN |
| ECO-F016 | P1 | Ops/Pilot | enterprise case automation delays launch | lean manual Ops | ROOT-17 OPEN |
| ECO-F017 | P1 | Analytics/Privacy | broad collection without decision question | minimum registry/privacy budget | ROOT-18 OPEN |
| ECO-F018 | P1 | Ads/Pilot | complete design interpreted as launch need | organic-only pilot | ROOT-13 OPEN |
| ECO-F019 | P1 | Reward/Reputation | design interpreted as economic readiness | defer to post-pilot | ROOT-15/16 OPEN |
| ECO-F020 | P1 | Merchant/Analytics | stale availability/intent called stock/sales | honest freshness/metric language | ROOT-10 OPEN |
| ECO-F021 | P2 | Merchant/Shop | shop and branch identity used ambiguously | physical branch semantics | ROOT-07 OPEN |
| ECO-F022 | P2 | Realtime/QA | broad realtime/CI added without risk value | risk-justified minimum | ROOT-01 OPEN |
| ECO-F023 | P2 | Catalog/Media/Ads | listing media promoted without rights | authority + reviewed promotion | ROOT-05 OPEN |
| ECO-F024 | P3 | Notifications/Analytics | late delivery changes domain truth | eventual derived delivery only | RESOLVED_BY_CONTRACT |

Counts: P0=10; P1=10; P2=3; P3=1; total=24. No case permits an
unclassified security/evidence fallback.
