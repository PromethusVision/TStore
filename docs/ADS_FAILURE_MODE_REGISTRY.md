# Sponsored Advertising — Failure Mode Registry

**State:** PROPOSED FOR PRODUCT OWNER REVIEW  
**Scope:** Architecture and operations design only; no runtime, schema, alert, or policy implementation.

## 1. Safety Invariants

For every failure below:

- no ad is safer than a wrong, undisclosed, stale, or ineligible ad;
- the independently computed organic result set must remain available and keep its organic order;
- an unverifiable delivery must not become billable;
- customer-facing errors must not expose fraud, policy, competitor, or personal data;
- campaign state, serving state, billing state, and reporting state are separate;
- recovery must be idempotent and auditable.

## 2. Registry

| ID | Failure mode | Detection signal | Safe serving response | Billing/reporting response | Recovery / owner |
|---|---|---|---|---|---|
| ADF-001 | Campaign says active while merchant/shop is inactive | Eligibility snapshot conflicts with campaign state | Suppress candidate; organic fallback | No impression charge; record suppressed reason | Reconcile state; Merchant/Admin |
| ADF-002 | Listing deleted or no longer resolves | Catalog lookup `NOT_FOUND` | Suppress; never render placeholder ad | No charge; historical campaign remains reportable | Auto-pause target; Merchant |
| ADF-003 | Listing becomes out of stock/unavailable | Fresh listing state rejects eligibility | Suppress immediately | No charge; report unavailable suppression | Resume only after fresh eligible state |
| ADF-004 | Price snapshot is stale or conflicts with listing | Version/timestamp mismatch | Suppress price-bearing creative; no silent stale price | No charge for blocked render | Refresh listing snapshot; Catalog |
| ADF-005 | Shop location missing/invalid | Geo eligibility cannot resolve | Suppress location-dependent ad | No charge | Merchant fixes shop data; review |
| ADF-006 | Customer location denied/unavailable | No permitted location context | Use non-location contextual eligibility only if surface contract allows; otherwise no ad | Explain no personalized/local basis without exposing internals | Customer control / product owner policy |
| ADF-007 | Geo service timeout or partial outage | Deadline exceeded/error rate | Fail to organic; never treat unknown as nearby | No charge for unverified impression | Circuit-breaker; Platform |
| ADF-008 | Target taxonomy node renamed or moved | Revision mismatch but stable ID resolves | Re-evaluate eligibility; serve only if meaning/policy still valid | Preserve historical label revision | Automated resolution + audit |
| ADF-009 | Target taxonomy node split/ambiguous | One predecessor has multiple successors | Pause target; no arbitrary broadening | Stop spend; flag merchant review | Manual/deterministic reclassification |
| ADF-010 | Target taxonomy node retired | Node lifecycle inactive | Stop serving | Preserve historical report; no new charge | Merchant selects new approved target |
| ADF-011 | Policy revision blocks product/sector | Current policy snapshot denies candidate | Immediate suppression independent of campaign UI state | Stop future charges; report policy hold safely | Policy/Admin review |
| ADF-012 | Merchant verification expires/revoked | Eligibility evidence no longer valid | Suppress affected campaigns | No charge; restricted report reason | Reverification; Merchant/Admin |
| ADF-013 | Budget exhausted | Authoritative reservation ledger rejects spend | Suppress further paid delivery | Do not exceed cap; reconcile reservations | Next budget window or owner action |
| ADF-014 | Concurrent budget overspend race | Reservation/commit conflict | Only successful reservation may render as billable | Reverse orphan reservation; no double charge | Idempotent ledger reconciliation |
| ADF-015 | Pacing service unavailable | No trustworthy remaining-budget rate | Fail closed for paid delivery or use strictly bounded last-known token | No unreserved charge | Platform; resume after health check |
| ADF-016 | Frequency-cap store unavailable | Cap cannot be verified | Suppress ad for that scope; preserve organic | No charge | Platform; privacy-safe degraded recovery |
| ADF-017 | Candidate retrieval returns irrelevant target | Relevance gate below threshold | Reject sponsored candidate | Record non-billable rejection | Targeting/ranking quality review |
| ADF-018 | Organic ranker unavailable | No independent organic baseline | Do not construct an ad-only discovery page | No delivery charge | Surface error/empty contract; Search |
| ADF-019 | Sponsored ranker unavailable/timeout | Deadline exceeded/invalid response | Render exact organic fallback | No ad event/charge | Circuit-breaker; Ads platform |
| ADF-020 | Sponsored ranker returns duplicate listing | Duplicate stable listing ID in response | Keep at most one eligible representation; prefer organic or defined interleave contract | Deduplicate impression; no duplicate charge | Ranking defect alert |
| ADF-021 | Same merchant exceeds diversity/fairness limit | Post-rank guardrail detects concentration | Remove excess sponsor rows without organic reorder | Charge only rendered valid row | Fairness policy monitoring |
| ADF-022 | Disclosure component missing or clipped | Render contract/accessibility test fails | Do not render sponsored unit | No charge | Client component fail-closed; release blocker |
| ADF-023 | Disclosure lost after scroll/navigation/theme change | UI state audit/accessibility signal | Remove/repair ad unit; never show unlabeled paid placement | Invalidate affected delivery where evidence insufficient | Client bug + incident review |
| ADF-024 | Creative media fails | Image/asset fetch or validation failure | Use approved native text/listing fallback only if disclosure and facts remain valid; else suppress | Charge only if valid impression standard met | Creative/CDN retry |
| ADF-025 | Creative contains unsupported claim | Moderation/policy/evidence mismatch | Reject creative/campaign | No delivery charge | Merchant edits; Policy review |
| ADF-026 | Tracking endpoint unavailable | Delivery visible but event commit unknown | Avoid retries that duplicate UI; buffer only within approved local/privacy contract | Mark `UNVERIFIED`; do not bill until reconciled | Idempotent replay; Platform |
| ADF-027 | Duplicate impression/click events | Idempotency key already seen | No customer-facing change | Count/bill once | Deduplication ledger |
| ADF-028 | Event ordering delayed/out of order | Sequence/timestamp inconsistency | Serving unaffected if current request valid | Reconcile analytics; never fabricate path | Event platform |
| ADF-029 | Bot/click farm/self-click attack | Invalid-traffic rules/anomaly signals | Continue safe customer surface; rate-limit/block hostile source | Exclude or hold billable events | Fraud review; Merchant may dispute |
| ADF-030 | Fraud detector unavailable | Risk score unknown | Fail closed for high-risk billable actions; tightly bound ordinary impressions per owner policy | Hold settlement | Fraud/Finance |
| ADF-031 | Attribution link missing/ambiguous | Multiple or no eligible prior interactions | Do not force attribution | Report organic/unknown; no CPA billing | Measurement policy |
| ADF-032 | Verified-purchase service unavailable | Purchase evidence unresolved | Do not mark verified or reward eligible | Keep attribution pending/non-billable | Independent purchase recovery |
| ADF-033 | Reporting aggregation delayed | Pipeline watermark behind SLO | Serving may continue if billing ledger healthy | Show explicit data-freshness time; no invented zero | Analytics platform |
| ADF-034 | Billing ledger and report disagree | Reconciliation checksum mismatch | Serving may pause at risk threshold | Freeze disputed amount; no hidden adjustment | Finance/Admin reconciliation |
| ADF-035 | Customer withdraws optional ads/privacy choice | Preference revision received | Stop disallowed processing promptly; contextual ads only if permitted | Retain only legally/contractually necessary audit data | Privacy owner |
| ADF-036 | Consent/preference service unavailable | Choice cannot be resolved | Use least-data path or no ad; never assume opt-in | No behavioral event collection | Privacy/Platform |
| ADF-037 | Account/session changes during request | Subject/session version mismatch | Discard stale sponsored response | Do not join events across identities | Client/Identity |
| ADF-038 | Merchant changes campaign during in-flight request | Campaign version mismatch | Validate against latest serving snapshot before render | Bill only committed valid version | Campaign service |
| ADF-039 | Admin review system unavailable | Review-required state cannot be resolved | Keep campaign paused | No delivery charge | Admin/Policy continuity |
| ADF-040 | Clock skew affects schedule/expiry | Trusted server time conflicts with client time | Server time governs; suppress outside verified window | Correct ledger windows; no client-time charge | Platform time synchronization |
| ADF-041 | Currency/price unit mismatch | Campaign budget currency incompatible | Pause delivery | No conversion/charge by guess | Billing/Product Owner |
| ADF-042 | Data leak through explanation/report | Authorization/redaction check fails | Withhold unsafe detail; provide generic status | Log security incident without secret payload | Security/Privacy incident response |
| ADF-043 | Merchant deletes campaign with in-flight events | Tombstone/version conflict | Stop new serving; allow only idempotent finalization of already rendered event | Settle only proven pre-delete delivery | Campaign/Billing reconciliation |
| ADF-044 | Client uses obsolete ad contract version | Unsupported schema/version | Ignore sponsored payload; organic fallback | No charge | Force compatible client/config rollout |
| ADF-045 | Whole advertising subsystem disabled | Kill switch/config state | Exact organic-only product experience | Pause spend and billing; retain audit | Authorized Admin/incident owner |

## 3. Severity Model

| Severity | Meaning | Example response |
|---|---|---|
| SEV-0 | Security/privacy exposure or systemic financial integrity risk | Kill switch, incident response, settlement hold |
| SEV-1 | Broad undisclosed/ineligible ads, overspend, or organic outage | Immediate paid-serving disablement and owner escalation |
| SEV-2 | Surface/campaign cohort impaired with safe organic fallback | Suppress cohort, alert, repair under SLO |
| SEV-3 | Reporting delay or isolated non-billable defect | Mark freshness/partial status and reconcile |

Severity does not change the fundamental rule: uncertain ad eligibility or disclosure fails closed; organic discovery remains independent.

## 4. Required Observability

Metrics should separate:

- eligible candidates retrieved;
- candidates rejected by each hard gate;
- organic-fallback rate and reason;
- disclosure render validation failures;
- budget reservation/commit/reversal counts;
- deduplicated and invalid traffic;
- reporting watermark age;
- taxonomy/policy revision mismatches;
- customer-control resolution failures;
- campaign auto-pause and recovery transitions.

Alerts and dashboards must use aggregate identifiers and role-scoped access. They must not copy creative secrets, customer queries, precise location trails, session tokens, or raw personal data into operational messages.

## 5. Recovery Contract

1. Detect and assign an immutable incident/failure reference.
2. Contain affected sponsored serving without changing organic order.
3. Freeze or reverse unverified billing effects.
4. Preserve minimal audit evidence.
5. Correct authoritative state, then reconcile derived reports.
6. Resume only after current eligibility, disclosure, budget, and policy checks pass.
7. Notify merchants/customers only to the extent required and useful, without exposing attack or competitor details.

## 6. Open Owner Decisions

1. Which SEV levels automatically activate the global paid-serving kill switch?
2. May bounded last-known pacing tokens be used during a short pacing outage, or must all paid delivery stop?
3. What evidence qualifies an impression as billable when tracking acknowledgement is delayed?
4. What are the merchant credit/refund rules for reporting or delivery disputes?
5. What retention and access model applies to security, billing, and policy incident evidence?

