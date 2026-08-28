# EsnaftaVar Analytics Owner Option Simulation

**State:** `SIMULATION — ALL OPTIONS UNSELECTED, NO FINAL STATE`

Every materially distinct option from the 20 root decisions is simulated below.
`RECOMMENDED_NOT_SELECTED` is architectural guidance, never owner approval.

| ROOT / OPTION | RESULTING EVENT MODEL | RESULTING METRIC MODEL | PRIVACY / POLICY EFFECT | PILOT EFFECT | IMPLEMENTATION EFFECT | TRADEOFF | OWNER STATUS |
|---|---|---|---|---|---|---|---|
| ROOT-01 A — Broad registry | Most candidate events emit from launch | Broad discovery/funnel inventory | Largest purpose/retention surface | More questions answerable, more noise | Many producers/consumers | History breadth versus quality/cost | UNSELECTED |
| ROOT-01 B — Minimum question-led | Only approved operational/outcome/soft events emit | Small versioned scorecard | Data minimization and explicit ownership | Sufficient for pilot | Registry, owners, kill switches | Less historical data for future questions | RECOMMENDED_NOT_SELECTED |
| ROOT-01 C — Operational-only | Domain/audit/security/health only | No soft product KPIs | Lowest analytics privacy scope | Product learning limited | Smallest instrumentation | Safety versus discovery insight | UNSELECTED |
| ROOT-02 A — Product analytics off | No optional product events | Authoritative/health metrics only | Simplest policy | Soft KPI unavailable | Disable optional producers | Low insight | UNSELECTED |
| ROOT-02 B — Gated minimal | Approved views/search/directions with class retention | Aggregate soft metrics + authoritative outcomes | Purpose/consent/TTL required | Balanced pilot evidence | Consent/config/access/deletion | Governance overhead | RECOMMENDED_NOT_SELECTED |
| ROOT-02 C — Broad default | Extensive engagement collection | Rich funnels/retention | Highest purpose-creep risk | Fast analysis | Broad pipeline and controls | Coverage versus privacy/cost | UNSELECTED |
| ROOT-03 A — No sessions | Independent events/explicit correlation only | Counts, no session funnels | Lowest linkage | Basic pilot works | Simplest identity | No abandonment/unique sessions | UNSELECTED |
| ROOT-03 B — Ephemeral, no guest merge | Rotating session for approved events | Bounded session funnels/cohorts | Moderate pseudonymous linkage | Adds journey quality | Rotation/suppression/deletion | Cross-session analysis limited | RECOMMENDED_NOT_SELECTED |
| ROOT-03 C — Account longitudinal | Guest/account/device histories join | Retention/full funnels | Highest profiling/legal burden | Richest acquisition/retention | Identity graph and rights handling | Insight versus surveillance risk | UNSELECTED |
| ROOT-04 A — Retain neither | Controlled IDs/classes only | Aggregate search/location quality | Lowest sensitive-data risk | Enough for minimum | Normalization/coarse result bands | Unknown-query diagnosis slower | RECOMMENDED_NOT_SELECTED |
| ROOT-04 B — Coarse location only | Approved coarse cell attached to bounded events | Area coverage metrics | Precision/suppression/consent needed | Geographic pilot analysis | Coarsening and minimum cohorts | Area insight versus re-identification | UNSELECTED |
| ROOT-04 C — Restricted raw-query sample | Sampled unmatched queries in restricted stream | Vocabulary/error research | Sensitive text/legal review | Improves search research | Redaction/sample/access/rapid expiry | Quality insight versus leakage | UNSELECTED |
| ROOT-04 D — Both | Coarse location and query sample coexist | Detailed local search analytics | Combined sensitivity highest | Rich local diagnostics | Two restricted pipelines | Broad insight versus disproportionate risk | UNSELECTED |
| ROOT-05 A — Provider logs only | Backend/provider logs, app errors local | Minimal backend health | Low new processor surface | App crash blind spots | Runbooks/manual review | Cheap but incomplete | UNSELECTED |
| ROOT-05 B — Logs + crash tool + critical alerts | Privacy-safe app/backend/QR signals | Critical health scorecard | Processor/redaction/access review | Strong pilot readiness | SDK proof, symbols, alerts/runbooks | Moderate setup | RECOMMENDED_NOT_SELECTED |
| ROOT-05 C — Full tracing/error budgets | Logs/metrics/traces across services | SLO/budget reporting | More telemetry/processor exposure | Deep diagnosis, heavy process | Collector/tracing/SLO operations | Power versus pilot overengineering | UNSELECTED |
| ROOT-06 A — Operational/authoritative only | Merchant receives listing/QR/purchase/review facts | No soft interest metrics | Lowest customer privacy risk | Less merchant insight | Simple projections | Safety versus value | UNSELECTED |
| ROOT-06 B — Aggregate soft metrics | Quality-filtered views/directions join shop aggregates | Interest + authoritative panels | Suppression/no customer identity | Stronger merchant value | Aggregates/access/freshness | Useful but directional | RECOMMENDED_NOT_SELECTED |
| ROOT-06 C — Customer-linked/benchmark exports | Longitudinal/customer/cross-merchant joins | Unique/retention/benchmarks | High re-identification/competitive risk | Rich but risky | Identity, suppression, export audit | Insight versus trust/policy | UNSELECTED |
| ROOT-07 A — No customer dashboard | No new analytics surface | None customer-visible | Lowest tracking expectation | No loss to core journey | No work | Missed future insight feature | UNSELECTED |
| ROOT-07 B — Contextual facts only | Purchase/review/privacy status remain domain projections | No behavioral score | Purpose stays transactional | Clear customer value | Existing-context UI only | Less engagement novelty | RECOMMENDED_NOT_SELECTED |
| ROOT-07 C — Behavioral dashboard | Customer activity/profile events feed personal view | Personal trends/scores | Profiling/consent risk | New feature not pilot-critical | New UI/profile/rights | Novelty versus complexity | UNSELECTED |
| ROOT-08 A — One vanity KPI | Narrow event source dominates | Download/view/single count | Depends on metric | Simple but misleading | Simple dashboard | Communicability versus gaming | UNSELECTED |
| ROOT-08 B — Balanced verified-purchase scorecard | Outcome/supply/health/privacy events stay distinct | Verified purchase + active supply + guardrails | Minimized aggregates | Credible go/no-go after baseline | Versioned scorecard/owners | More numbers | RECOMMENDED_NOT_SELECTED |
| ROOT-08 C — Composite index | Many inputs normalized into one score | Weighted index | Hidden weighting/purpose risk | Easy headline, opaque diagnosis | Weight/version model | Simplicity versus transparency | UNSELECTED |
| ROOT-09 A — Top-of-funnel acquisition | Campaign click/signup/lead events | Cheap acquisition counts/CPL | Attribution/contact rules | Inflated activation story | Marketing/CRM import | Early signal versus vanity | UNSELECTED |
| ROOT-09 B — First value/activation | Customer local value and merchant readiness events | Activated customer/merchant acquisition | Bounded identity/provenance | More meaningful pilot | Milestone joins/dedup | Later conversion point | RECOMMENDED_NOT_SELECTED |
| ROOT-09 C — Retained value | Longitudinal repeated outcomes | Retained CAC/LTV-like models | Highest linkage/accounting need | Requires time/volume | Cohorts/spend/identity | Quality versus delay/privacy | UNSELECTED |
| ROOT-10 A — No ad measurement | Ads emit no customer measurement | No ad performance report | Lowest ad privacy | Ads evaluation blocked | No pipeline | Safety versus commercialization | UNSELECTED |
| ROOT-10 B — Separate gated qualified measurement | Dedicated consented ad events with rule version | Qualified impressions/opens | Clear separate purpose | Honest pilot reporting | Separate pipeline/visibility rule | Slower setup | RECOMMENDED_NOT_SELECTED |
| ROOT-10 C — Reuse broad analytics | Product events double as ad events | Blended reports | Purpose confusion | Fast but untrustworthy | Easy joins, hard governance | Convenience versus correctness | UNSELECTED |
| ROOT-11 A — No attribution | Interaction/outcome events remain unlinked | Independent counts | Lowest linkage | No outcome association | None | Limited ads insight | UNSELECTED |
| ROOT-11 B — Explicit correlation | Outcome carries explicit sponsored context | Attribution candidates only | Bounded context | Sparse but defensible | Correlation/model/invalidation | Precision versus coverage | RECOMMENDED_NOT_SELECTED |
| ROOT-11 C — Session/account window | Pseudonymous/account interactions joined by window | First/last-touch reports | Higher consent/linkage | Broader coverage | Identity/session/window engine | Coverage versus bias/privacy | UNSELECTED |
| ROOT-11 D — Experiment/lift | Assignment/exposure cohorts analyzed | Aggregate incremental estimate | Experiment policy/sample | Needs scale/design | Experiment service/statistics | Stronger causal evidence versus cost | UNSELECTED |
| ROOT-12 A — Reporting only | Measurement events and candidates only | Non-financial ad reports | Lower commercial/data burden | Enables learning, no billing | Role-based reports | Monetization deferred | RECOMMENDED_NOT_SELECTED |
| ROOT-12 B — Qualified-event billing | Authoritative billing fact consumes qualified event | Billable units/spend | Contract/dispute/access required | Monetization possible | Ledger/pricing/reconciliation | Simple unit may incentivize gaming | UNSELECTED |
| ROOT-12 C — Outcome billing | Purchase candidate/outcome feeds billing | Outcome-priced reports | Causal/fairness/privacy risk | Commercially attractive but unsupported | Attribution + financial ledger | Strong claim beyond current proof | UNSELECTED |
| ROOT-13 A — No reward | No reward events/ledger | No reward reports | Lowest financial/profile impact | Core pilot unaffected | None | No incentive feature | RECOMMENDED_NOT_SELECTED |
| ROOT-13 B — Non-economic recognition | Authoritative/soft rules grant non-monetary recognition | Progress/grants only | Behavioral profiling remains | Optional engagement | Rules/dedup/reversal/UI | Lower financial risk, still gameable | UNSELECTED |
| ROOT-13 C — Economic ledger | Server-authoritative award/reversal/redemption ledger | Balance/liability/reports | Financial/personal/legal impact | Major product/commercial scope | Ledger, funding, accounting, abuse | Value versus complexity/risk | UNSELECTED |
| ROOT-14 A — None | No progress/grant events | No gamification metrics | Lowest profiling | No pilot dependency | None | No engagement mechanic | UNSELECTED |
| ROOT-14 B — Private non-economic | Versioned private progress/grants | Aggregate/private progress | Consent/abuse manageable | Optional later | Rules/idempotency/reversal/UI | Modest value/complexity | RECOMMENDED_NOT_SELECTED |
| ROOT-14 C — Public competitive | Rankings/streaks/social progress events | Leaderboards/competition | Social/fairness/small-cohort risk | Distracts pilot | Ranking/moderation/anti-abuse | Engagement versus harm/gaming | UNSELECTED |
| ROOT-15 A — No score | Reviews/purchases remain separate facts | Review/purchase summaries only | Lowest profiling | Trust still visible | Existing projections | No unified reputation | UNSELECTED |
| ROOT-15 B — Explainable evidence summary | Governed evidence classes roll up transparently | Versioned summary/distribution | Fairness/explanation/appeal manageable | Useful trust layer | Evidence allowlist/lineage | Less ranking automation | RECOMMENDED_NOT_SELECTED |
| ROOT-15 C — Consequential weighted score | Many signals calculate one score and actions | Score/rank/enforcement metrics | High-impact profiling/due process | Could affect merchant access | Model/threshold/appeal/audit | Automation versus fairness/gaming | UNSELECTED |
| ROOT-16 A — Immutable/no correction | Only creation event exists | Permanent count/rights | Cannot remedy real error | Simple but risky | Minimal | Integrity versus remedy | UNSELECTED |
| ROOT-16 B — Status correction | Append correction/status fact; preserve creation | Net/gross/status metrics | Rights rules required | Handles mistakes | Lifecycle/recompute | Moderate complexity | RECOMMENDED_NOT_SELECTED |
| ROOT-16 C — Reversal ledger/compensation | Append reversal plus downstream compensations | Fully restated purchase/reward/review | Strong audit/rights policy | Most robust at scale | Cross-domain saga/ledger | Correctness versus complexity | UNSELECTED |
| ROOT-17 A — Treat proposals as final | Sector assignments emit canonical IDs immediately | Detailed sector KPIs | Misstates owner/policy state | Fast granularity | Premature migration | Speed versus governance | UNSELECTED |
| ROOT-17 B — Proposal-labelled internal | Events retain proposed IDs/state/version | Internal proposal metrics only | Clear caveat/access | Supports research | State/version/unresolved handling | Limited external use | RECOMMENDED_NOT_SELECTED |
| ROOT-17 C — Wait for finalization | No proposal-dimensioned metric | Family/none until final | Lowest taxonomy risk | Less sector insight | Delay mapping/runtime | Integrity versus delay | UNSELECTED |
| ROOT-18 A — Treat L2 proposals canonical | Detailed product events use proposal IDs | Fine-grained category KPIs | Misstates 22-domain state | Fast but unsafe | Premature migration/index | Granularity versus correctness | UNSELECTED |
| ROOT-18 B — Final L1 + labelled proposals | Canonical 24-L1 plus explicit proposal details | Canonical L1/provisional detail views | Clear state/policy | Coherent pilot | Lineage/state filters | Less final detail | RECOMMENDED_NOT_SELECTED |
| ROOT-18 C — Wait for all L2 final | Product taxonomy metrics limited/blocked | No detailed category KPIs | Lowest taxonomy ambiguity | Delays useful L1 metrics | No interim mapping | Purity versus pilot learning | UNSELECTED |
| ROOT-19 A — Queue counts only | Case lifecycle emits minimal counts | Backlog/age only | Low operator profiling | Basic operations | Simple aggregates | Limited quality insight | UNSELECTED |
| ROOT-19 B — Quality-balanced restricted | Case/audit outcomes include quality/reversal/timeliness | Aggregate balanced operations report | Restricted access/fairness | Supports safe operations | Policy versions/suppression/audit | More governance | RECOMMENDED_NOT_SELECTED |
| ROOT-19 C — Individual speed ranking | Operator events feed individual productivity | Speed/throughput ranking | Worker fairness and gaming risk | Unsafe incentives | Individual identity dashboards | Efficiency appearance versus quality | UNSELECTED |
| ROOT-20 A — Explicitly deferred | No personalization profile/events | Non-personalized discovery metrics | Lowest profiling | Core pilot unaffected | None | No personalized experience | RECOMMENDED_NOT_SELECTED |
| ROOT-20 B — On-device minimal | Local preferences influence UI; central aggregate only | Limited non-identifying quality | Lower central profiling | Some relevance benefit | Client rules/reset | Cross-device consistency limited | UNSELECTED |
| ROOT-20 C — Server profile | Longitudinal profile/prediction events | Personalized engagement/experiments | Highest consent/deletion/bias risk | Large new scope | Profile store/models/explanations | Relevance versus privacy/complexity | UNSELECTED |

## Simulation coverage

- Root decisions simulated: `20/20`.
- Material options simulated: `62`.
- Owner-selected options: `0`.
- FINAL states: `0`.

`OWNER_OPTION_SIMULATION: PASS`
