# EsnaftaVar Analytics Owner Decision Deduplication

**State:** `SEMANTIC CLUSTERING — NO DECISION COLLAPSED OUT OF EXISTENCE`

`SAFE_TO_COLLAPSE=NO` means the rows share a review meeting/dependency but require
separate answers because privacy, rights or commercial consequences differ.

| CLUSTER_ID | SOURCE_DECISION_IDS | ROOT_QUESTION | SAFE_TO_COLLAPSE | DISTINCT_SUBQUESTIONS | AFFECTED_SYSTEMS | WHY |
|---|---|---|---|---|---|---|
| CLU-001 | DEC-001, DEC-002, DEC-033 | What is the event/metric governance and pilot scope? | YES | Minimum registry; naming/version rules; approval ownership | Event platform/all | One governance charter can answer scope and change authority without changing product semantics |
| CLU-002 | DEC-005, DEC-009 | What privacy purpose and retention governs product analytics? | NO | Collection/consent versus class-specific lifecycle | Analytics/all producers | Both gate collection but legal basis and retention are independently reviewable |
| CLU-003 | DEC-003, DEC-004, DEC-019, DEC-020 | What identity/time linkage is allowed for sessions, retention and cohorts? | NO | Session; guest-account link; activity anchors/windows; cohort/suppression | Customer/Merchant/Analytics | Same identity dependency but materially different longitudinal and privacy choices |
| CLU-004 | DEC-007, DEC-008 | May sensitive discovery inputs be retained? | NO | Location precision versus raw search sampling | Location/Search | Different data sensitivities and operational purposes must not share one consent toggle |
| CLU-005 | DEC-010, DEC-031, DEC-032 | What pilot observability operating model is adopted? | NO | Processor/reporting; alert ownership/thresholds; formal error budgets | Apps/Backend/Ops | Tool, incident response and SLO policy have separate cost/privacy effects |
| CLU-006 | DEC-011, DEC-012, DEC-034 | What analytics can merchants see or export? | NO | Soft metrics; unique/small cohorts; benchmarking/export | Merchant/Privacy | Aggregates may be safe while customer linkage or cross-merchant comparison is not |
| CLU-007 | DEC-013 | Does the customer need an analytics dashboard? | YES | Standalone | Customer | No equivalent decision elsewhere |
| CLU-008 | DEC-014, DEC-015, DEC-016 | How does the platform define and operate pilot success? | NO | Dashboard scope; north-star; KPI targets | Platform/Pilot/Ops | One review sequence, but evidence definitions and success targets remain distinct |
| CLU-009 | DEC-017, DEC-018 | What is acquisition for each side of the marketplace? | NO | Customer acquisition/attribution versus merchant activation | Customer/Merchant/Ads/Ops | Different identities, evidence and privacy; shared reporting vocabulary only |
| CLU-010 | DEC-006, DEC-021 | What permits and qualifies ad measurement? | NO | Consent/purpose versus qualified visibility | Ads/Customer | Legal permission cannot be collapsed with measurement validity |
| CLU-011 | DEC-022 | Which ad attribution model/window is used? | YES | Standalone | Ads/Purchase | Separate from permission and billing |
| CLU-012 | DEC-023, DEC-035 | How are ads commercialized and reported? | NO | Billable evidence/pricing/dispute versus report access/dimensions | Ads/Billing/Merchant | Reporting can exist without billing; commercial ledger has stronger authority |
| CLU-013 | DEC-024, DEC-025, DEC-036 | What is the future reward product and its reporting? | NO | Earn/unit/caps; lifecycle/funding; visibility | Reward/QR/Ops | Eligibility, economic ledger and reporting carry distinct rights/accounting effects |
| CLU-014 | DEC-026 | What gamification exists and who sees it? | YES | Standalone | Gamification/Customer/Merchant | Must not be inferred from reward rules |
| CLU-015 | DEC-027 | What evidence and consequences define reputation? | YES | Standalone | Reputation/Review/QR/Ops | High-impact fairness decision must remain independent |
| CLU-016 | DEC-028 | How can verified-purchase facts be corrected and downstream rights reversed? | YES | Standalone | QR/Review/Reward/Analytics | Authoritative lifecycle decision |
| CLU-017 | DEC-029, DEC-030 | Which taxonomy dimensions are ready for governed analytics? | NO | Merchant-sector finalization versus Product L2/history reporting | Merchant/Product/Search | Product and merchant taxonomies are deliberately separate |
| CLU-018 | DEC-037 | Which operations reports and operator measures are acceptable? | YES | Standalone | Operations/Trust/Safety | Sensitive case/worker-fairness scope |
| CLU-019 | DEC-038 | Is personalization in V1? | YES | Standalone | Customer/Search/Ads | Distinct profiling purpose; cannot hide under product analytics |

## Coverage

- Raw decisions represented: `38/38`.
- Decisions dropped: `0`.
- Privacy/policy decisions collapsed solely to reduce count: `0`.
- Standalone/deferred decisions remain explicit: DEC-007, DEC-013, DEC-022,
  DEC-026, DEC-027, DEC-028, DEC-037 and DEC-038 are represented by their own
  semantic question even when a surrounding review package exists.

`OWNER_DECISION_DEDUP: PASS`
