# EsnaftaVar Esenler Pilot — Product Owner Decision Inventory

**State:** `RAW BUSINESS/PRODUCT DECISIONS — NONE SELECTED`

Technical invariants such as exact-shop authorization, QR idempotency, secret
handling and artifact identity are not presented as optional owner choices.

| ID | Question | Affected areas | Cost effect | Merchant effect | Customer effect | Technical effect | Pilot effect | Priority |
|---|---|---|---|---|---|---|---|---|
| `PD-001` | What single outcome defines pilot success? | Scope, KPI, go/no-go | Prevents scattered spend | Clarifies value promise | Clarifies expected value | Focuses acceptance | Governs all tradeoffs | P0 |
| `PD-002` | Which exact Esenler launch cell(s) are in scope? | Geography, support, acquisition | Travel/coverage burden | Eligibility and density | Local relevance | Geo/config/content | Contains risk | P0 |
| `PD-003` | Invite-only, closed-track or broad public first cohort? | Release, acquisition, support | Volume/campaign load | Customer flow exposure | Access and selection bias | Track/cohort handling | Learning safety | P0 |
| `PD-004` | Which launch-size band is acceptable? | Merchant/customer scope | Staffing/onboarding | Opportunity and burden | Choice breadth | Scale/load | Controls complexity | P0 |
| `PD-005` | What evidence makes a cell/domain “usable”? | Density, KPI, marketing | Field/measurement effort | Required peer density | Honest coverage | Status projection | Prevents empty launch | P0 |
| `PD-006` | Which ordinary product domains launch first? | Catalog, merchant, search | Moderation burden | Merchant eligibility | Assortment breadth | Allowlist/config | Sets pilot promise | P0 |
| `PD-007` | How may proposed Merchant Sector taxonomy be used before finalization? | Onboarding, analytics, policy | Review/manual mapping | Sector selection | Shop discovery labels | Provisional identity rules | Avoids false canon | P0 |
| `PD-008` | What merchant participation offer is tested? | Acquisition, retention, terms | Direct/revenue tradeoff | Willingness to join | Indirect supply effect | Offer state/reporting | Commercial learning | P0 |
| `PD-009` | Is “three months free” retained, revised or removed? | Offer, messaging, retention | Delays revenue evidence | Expectations/exit | Supply continuity | Entitlement/date logic later | May distort continuation | P0 |
| `PD-010` | Which merchant acquisition channels may be used first? | Field, referrals, partners, inbound | Channel/time cost | Reach and trust | Supply mix | Source attribution | Density speed/quality | P1 |
| `PD-011` | Self-service, assisted or hybrid merchant onboarding? | Onboarding, staffing | Operator vs tooling cost | Friction/control | Catalog quality | Surface/workflow | Launch speed | P0 |
| `PD-012` | What merchant/shop verification evidence is proportionate? | Verification, privacy, policy | Review burden | Access friction | Trust | Evidence lifecycle | Safety gate | P0 |
| `PD-013` | Must full Merchant App precede pilot? | Merchant runtime, timeline | Build vs manual ops | UX and capability | Indirect supply truth | Delivery surface | Critical-path choice | P0 |
| `PD-014` | What assisted listing/candidate cap applies per merchant? | Catalog/bootstrap/staffing | Direct operator minutes | Assortment depth | Choice | Queue controls | Prevents overload | P1 |
| `PD-015` | What freshness promise/window applies by domain? | Listing truth, messaging | Reminder/review cost | Maintenance cadence | Stock confidence | State/display rules | Trust/operability | P0 |
| `PD-016` | Is QR enabled day one, staged or limited-cohort? | QR, reviews, support | Training/incident load | Checkout-counter work | Verified evidence timing | Feature flag/cohort | Learning sequence | P0 |
| `PD-017` | Which merchant verifier surface/path is acceptable? | Merchant App/minimum path | Build/manual support | Device/flow | QR reliability | Auth/capability path | Readiness blocker | P0 |
| `PD-018` | Is first discovery guest-visible? | Customer funnel/privacy | Acquisition efficiency | Demand reach | Friction/value preview | Guest/auth state | Conversion learning | P0 |
| `PD-019` | Which actions require registration? | Customer journey, privacy | Support/funnel | Customer lead quality | Friction/control | Authorization UX | Measures value fairly | P0 |
| `PD-020` | When/how is location permission requested? | Nearby, privacy, UX | Research/support | Local demand quality | Trust and access | Fallback/state | First-use success | P0 |
| `PD-021` | Android-only, Android-first or dual-platform pilot? | Release, acquisition, support | QA/store/device cost | Device compatibility | Inclusion/exclusion | Platform lanes | Timeline/reach | P0 |
| `PD-022` | Internal/closed/open/store distribution sequence? | Release/cohort | Store/ops effort | Install support | Discoverability | Track/version | Rollout safety | P0 |
| `PD-023` | What is the first customer acquisition channel mix? | Marketing, merchants, community | Spend/time | Merchant promotion asks | Reach/trust | Attribution | Demand quality | P0 |
| `PD-024` | Is any paid Meta/local experiment authorized in pilot? | Marketing/privacy/compliance | Hard budget | Possible traffic | Paid exposure | Source tagging | Can distort learning | P1 |
| `PD-025` | What support channels/hours are promised? | Support, terms, incident | Coverage cost | Help availability | Expectation/recovery | Contact surfaces | Trust/capacity | P0 |
| `PD-026` | Which staffing option funds the first cell? | Ops, support, verification | Direct staffing | Onboarding speed | Response capacity | Access/roles | Feasibility | P0 |
| `PD-027` | Who may pause features/acquisition and who restores them? | Incident/governance | On-call burden | Business continuity | Safety | Kill-switch authority | Prevents delay | P0 |
| `PD-028` | What minimum monitoring/tooling is funded? | Health, support, privacy | SaaS/operator cost | Merchant incident visibility | Reliability | Telemetry/vendors | Evidence quality | P0 |
| `PD-029` | Which KPI set and reporting cadence govern pilot? | Analytics, reviews | Measurement effort | Value reporting | Honest interpretation | Event/metric needs | Go/no-go | P0 |
| `PD-030` | What baseline/window precedes numeric KPI targets? | KPI/governance | Time before scaling | Fair evaluation | Honest claims | Metric versioning | Avoids arbitrary targets | P1 |
| `PD-031` | How are customer and merchant retention defined? | Cohorts, commercial model | Analysis effort | Continuation semantics | Useful repeat behavior | Identity/privacy | Validates durability | P0 |
| `PD-032` | Which post-pilot commercial model(s) are tested? | Subscription/free/other | Revenue/cost tradeoff | Willingness to pay | Supply continuity | Billing later | Commercial readiness | P0 |
| `PD-033` | When, if ever, may sponsored ads enter? | Ads, ranking, policy | XL prerequisites | Visibility/business model | Trust/disclosure | New engine | Focus risk | P1 |
| `PD-034` | When, if ever, may rewards/gamification enter? | Reward, retention, finance | XL liability/support | Funding/participation | Incentive effects | Ledger/UX | Distortion risk | P1 |
| `PD-035` | When, if ever, may public merchant reputation enter? | Trust/fairness/appeal | Review/support cost | Reputation impact | Choice signal | Projection/history | Premature scoring risk | P1 |
| `PD-036` | Which customer/merchant feedback methods are approved? | Research, support, privacy | Interview/incentive cost | Voice and burden | Consent/voice | Capture/retention | Learning quality | P1 |
| `PD-037` | Which customer/merchant pilot terms and non-promises apply? | Legal, support, offer | Review cost | Commitment clarity | Rights/expectations | Copy/versioning | Trust gate | P0 |
| `PD-038` | Which privacy purposes/retention/vendors are approved? | Analytics, support, location | Compliance/tool cost | Evidence handling | Data trust | Logging/retention | Launch gate | P0 |
| `PD-039` | Who approves regulated/policy-sensitive domain expansion? | Allowlist, operations | Specialist cost | Eligibility | Safety/trust | Policy state | Fail-closed gate | P0 |
| `PD-040` | Which business/operational pause thresholds apply? | Support, supply, acquisition | Opportunity vs risk | Availability | Safe recovery | Feature/cohort control | Failure handling | P0 |
| `PD-041` | What proves readiness to expand within Esenler? | Density, KPI, staffing | Growth cost | More merchants | Wider reach | Scale evidence | Prevents premature growth | P0 |
| `PD-042` | What proves readiness for a second district? | Expansion strategy | Replication cost | New market | New geography | Multi-region support | Post-pilot gate | P1 |
| `PD-043` | Is Android reach bias acceptable for the first cohort? | Research, fairness, release | Avoids iOS cost now | Device coverage | Exclusion | Platform support | Changes validity | P0 |
| `PD-044` | What launch window/cadence and freeze period are acceptable? | Operations/release | Staffing window | Merchant timing | Support availability | Release freeze | Controls risk | P1 |
| `PD-045` | Which dimension may expand first: cell, merchants, domains, cohort or channel? | Experiment design | Incremental cost | Supply opportunity | Demand reach | Config/measurement | Preserves causality | P1 |

`RAW_OWNER_DECISIONS: 45`

`OWNER_OPTIONS_SELECTED: 0`
