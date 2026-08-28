# EsnaftaVar Analytics Product Owner Decision Inventory

**State:** `RAW INVENTORY — NO OPTION SELECTED, NO FINAL DECISION`

Technical implementation details are excluded unless they change product meaning,
privacy, commercialization, customer/merchant visibility or pilot scope.

| DECISION_ID | QUESTION | AFFECTED_SYSTEMS | AFFECTED_EVENTS | AFFECTED_METRICS | PRIVACY_IMPACT | PILOT_IMPACT | IMPLEMENTATION_IMPACT | POLICY_OR_LEGAL_REVIEW_REQUIRED | PRIORITY |
|---|---|---|---|---|---|---|---|---|---|
| DEC-001 | Which candidate event families are in the pilot minimum registry? | Customer/Merchant/QR/Catalog/Review/Search | All pilot producers | All pilot metrics | More collection increases surface | Instrumentation scope/cost | Producer registry and kill switches | YES | P0 |
| DEC-002 | Approve/revise the event naming and semantic-version governance? | Event platform/all producers | All | All | Low directly | Prevents inconsistent pilot data | Registry/change workflow | NO | P2 |
| DEC-003 | Does V1 use no session or an ephemeral analytics session? | Customer/Ads/Search | Soft navigation/measurement | Funnels/unique sessions | Pseudonymous linkage | Determines funnel feasibility | Session lifecycle/rotation | YES | P0 |
| DEC-004 | May guest activity ever be linked to an authenticated customer? | Customer/Auth/Ads | Guest and post-login events | Retention/acquisition/funnel | High longitudinal linkage | Not needed for minimum pilot | Identity join/deletion controls | YES | P0 |
| DEC-005 | What consent/purpose model permits Product Analytics? | Customer/Merchant | Views/search/directions/wishlist/cart | Discovery/intent KPIs | Core personal-data question | Can block soft KPI collection | Consent/config/ingestion gates | YES | P0 |
| DEC-006 | What separate consent/purpose model permits Ad Measurement? | Ads/Customer | Impression/open/attribution candidates | Ad reporting/acquisition | Cross-purpose tracking risk | Ads reporting may remain disabled | Separate pipeline/consent | YES | P0 |
| DEC-007 | Is any coarse customer location retained for analytics; at what precision? | Location/Search/Discovery | Coarse context/directions | Area coverage | Location sensitivity/re-identification | Optional for pilot | Coarsening/suppression/expiry | YES | P0 |
| DEC-008 | Is raw unmatched search query sampling allowed? | Search/Privacy | Search submission | Zero-result/vocabulary quality | Queries may be sensitive | Affects search research only | Redaction/restricted sample workflow | YES | P0 |
| DEC-009 | What retention applies to domain/audit/security/product/ad/optional classes? | All | All retained events | Historical windows | Direct data-lifecycle impact | Must precede Production collection | TTL/legal hold/deletion/backups | YES | P0 |
| DEC-010 | Which crash/error monitoring processor and reporting posture is acceptable? | Customer/Merchant/Platform | Crash/nonfatal/UI telemetry | Crash-free/health | SDK processor/breadcrumb/identity risk | Critical pilot visibility | Tool/config/symbol/privacy work | YES | P1 |
| DEC-011 | Which soft merchant metrics are visible at launch? | Merchant dashboard | Product/shop view/directions/wishlist/cart | Merchant interest panel | Aggregate access/small cohorts | Merchant value proposition | Projection/API/dashboard | YES | P0 |
| DEC-012 | Are unique-customer or low-volume breakdowns ever shown to merchants? | Merchant dashboard/Privacy | Customer-linked facts | Unique/retention/breakdowns | High re-identification risk | Not required for pilot | Identity counts/suppression | YES | P0 |
| DEC-013 | Does customer app need any analytics dashboard? | Customer app | Customer history/analytics | Customer-visible insights | Tracking expectations | Low pilot need | New product surface | YES | P1 |
| DEC-014 | What is the minimum platform-owner pilot dashboard? | Platform/Operations | Business and health signals | Pilot scorecard | Access and aggregation | High operations value | Dashboard/access/export | YES | P0 |
| DEC-015 | Which north-star option guides EsnaftaVar? | Platform/Customer/Merchant | Outcome/supply/intent events | North-star/guardrails | Depends on selected identity | Commercialization-critical | Metric governance/dashboard | NO | P0 |
| DEC-016 | Which Esenler KPI set and targets define pilot success? | Pilot/all systems | Selected pilot events | Pilot scorecard/targets | Depends on KPI choices | Go/no-go criteria | Baseline/target/dashboard | YES | P0 |
| DEC-017 | What constitutes an acquired customer and which attribution is allowed? | Acquisition/Ads/Customer | Campaign/install/discovery/purchase | CAC/acquisition | Cross-app/account linkage | Marketing evaluation | Spend import/attribution/privacy | YES | P0 |
| DEC-018 | What constitutes an activated/acquired merchant? | Acquisition/Merchant/Ops | Lead/verification/catalog/QR/purchase | Merchant CAC/activation | Merchant contact/case access | Merchant growth evaluation | CRM/entity/funnel mapping | YES | P0 |
| DEC-019 | Which activity anchors/windows define customer and merchant retention? | Customer/Merchant | Discovery/directions/purchase/catalog activity | Retention | Longitudinal identity | Not minimum until volume | Cohort/window projections | YES | P1 |
| DEC-020 | Which minimal cohorts are permitted and what minimum size applies? | Analytics/Privacy | Acquisition/activity events | Cohort/retention | Re-identification risk | Limits pilot drilldown | Suppression/cohort service | YES | P1 |
| DEC-021 | What makes an ad impression qualified? | Ads/Customer | Impression events | Qualified impression/open rates | Measurement/consent | Ads reporting integrity | Visibility rule/version | YES | P0 |
| DEC-022 | Which attribution model/window/status is used? | Ads/Customer/Purchase | Ad interactions and outcomes | Attribution candidates | Identity linkage | Ads value narrative | Join/recompute/model version | YES | P0 |
| DEC-023 | Is any event billable and under which pricing/dispute evidence? | Ads/Billing/Ops | Qualified measurement/billing facts | Spend/billing | Commercial records/access | Monetization-critical | Authoritative ledger/reconciliation | YES | P0 |
| DEC-024 | Which authoritative behaviors may earn reward and in what unit/caps? | Reward/QR/Customer | Purchase and future eligible facts | Awards/balance | Customer economic profiling | Reward launch blocked | Ledger/rules/idempotency | YES | P0 |
| DEC-025 | What are reward reversal/expiry/redemption/funding/accounting rules? | Reward/Ops/Merchant | Ledger lifecycle | Liability/balance | Financial/account data | Reward launch blocked | Ledger/accounting/workflows | YES | P0 |
| DEC-026 | What gamification exists, which signals count and who can see it? | Gamification/Customer/Merchant | Progress/grant events | Progress/badges | Behavioral profiling/social visibility | Optional/deferred | Rules/projection/UI/abuse | YES | P1 |
| DEC-027 | Which evidence affects reputation, with what weights/consequences/appeal? | Reputation/Review/QR/Ops | Source signals/projections | Reputation | High-impact profiling/fairness | Trust model could affect launch | Versioned scoring/explanation/appeal | YES | P0 |
| DEC-028 | Are verified purchases ever corrected/cancelled and how do rights/metrics reverse? | QR/Review/Reward/Analytics | Purchase correction/reversal | Purchase/review/reward metrics | Customer/merchant rights | Integrity-critical | Domain lifecycle/recompute | YES | P0 |
| DEC-029 | Finalize proposed 67 merchant-sector leaves and assignment policy? | Merchant taxonomy/Analytics | Sector assignment/history | Sector/merchant KPIs | Policy-sensitive sectors | Required for stable sector reporting | Stable IDs/mapping/versioning | YES | P1 |
| DEC-030 | Finalize remaining Product L2 taxonomy and event-time/current reporting policy? | Product taxonomy/Search/Analytics | Taxonomy change/product events | Category metrics | Sensitive-domain filtering | L1 pilot possible; detailed reporting limited | Stable IDs/lineage/projections | YES | P1 |
| DEC-031 | Which P0/P1 alert ownership, response windows and baseline thresholds apply? | Observability/Ops | Health/security/data-quality | Reliability scorecards | On-call access to evidence | Required before controlled pilot | Alerts/runbooks/escalation | YES | P1 |
| DEC-032 | Adopt formal error budgets for pilot or defer until baseline? | Engineering/Product/Ops | Health signals | SLO/budget | Low | Process overhead vs discipline | SLO tooling/release policy | NO | P2 |
| DEC-033 | Who can approve/version/deprecate events and metrics? | Platform/Data/Product/Privacy | All governed types | All | Prevents purpose creep | Needed for trustworthy pilot | Registry ownership/review process | YES | P0 |
| DEC-034 | Are cross-merchant comparisons and exports allowed; at what granularity? | Merchant/Platform/Privacy | Aggregate merchant/shop facts | Benchmark/export | Competitive and re-identification risk | Not required for minimum | Access/suppression/audit/export | YES | P1 |
| DEC-035 | Which ad report dimensions/exports are visible to merchants and platform owners? | Ads/Merchant/Platform | Ad measurement | Ad reports | Campaign/customer privacy | Ads launch dependency | Access/report/export | YES | P1 |
| DEC-036 | Which reward reports are visible and how is economic value presented? | Reward/Customer/Merchant/Platform | Future ledger events | Balance/award/liability | Financial/personal data | Reward launch dependency | Role-specific reporting | YES | P1 |
| DEC-037 | Which operations reports and operator performance measures are acceptable? | Operations/Trust/Safety | Case/audit/security | Queue/SLA/reversal | Sensitive cases/operator fairness | Pilot operations | Restricted reporting/access | YES | P1 |
| DEC-038 | Is personalized analytics/recommendation in V1 or explicitly deferred? | Customer/Search/Ads | Profile/personalization events | Personalized engagement | High profiling/consent | Not required for pilot | Profile store/decisioning | YES | P0 |

`RAW_OWNER_DECISION_COUNT: 38`

`OWNER_FINALIZATION_PERFORMED: NO`
