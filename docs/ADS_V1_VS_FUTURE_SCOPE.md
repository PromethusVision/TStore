# Sponsored Advertising — V1 vs Future Scope

**State:** PROPOSED FOR PRODUCT OWNER REVIEW  
**Scope:** Deliberate scope minimization; no roadmap item is owner-final or implemented.

## 1. V1 Challenge

A contextual, location-based sponsored-listing pilot is technically simpler than an auction or behavioral ad system, but it is not inherently small. Even this version needs catalog identity, merchant tooling, policy review, visible disclosure, independent organic ranking, budget integrity, invalid-traffic handling, reporting, privacy controls, operational ownership, and an incident kill switch.

The safest V1 may therefore be **no advertising at launch**, or a narrowly controlled Development/manual pilot after owner decisions. This document classifies capabilities if the owner elects to proceed.

## 2. MUST_HAVE Before Any Customer-Facing Pilot

| Capability | Minimum proposed contract |
|---|---|
| Owner decisions | Sponsored object, surfaces, policy allowlist, business/pricing basis, locality, density, disclosure, billing/dispute, and data-use choices approved. |
| Sponsored object integrity | Exact active `SHOP_LISTING` with immutable campaign reference and current shop/listing/price/stock/availability checks. |
| Merchant eligibility | Active merchant/shop; required verification; no policy, fraud, or suspension hold. |
| Product eligibility | Narrow owner-approved product allowlist with exact evidence; unknown/restricted items fail closed. |
| Contextual relevance | Query/category intent match above a hard threshold; spend cannot buy relevance. |
| Location eligibility | Coarse, permission-aware local context and real distance; no false “nearest” or hidden radius broadening. |
| Independent organic ranking | Organic result set/order computed without ad spend and preserved on no-ad/failure paths. |
| Limited interleave | Owner-approved density; no duplicate listing; merchant diversity; no ad-only discovery result. |
| Persistent disclosure | Visible textual `Sponsorlu` label throughout render/scroll/navigation/accessibility states. |
| Simple campaign state | Draft/review/scheduled/active/paused/ended/rejected states with versioning and audit. |
| Fail-closed budget | Simple total/daily cap, reservation/commit/reversal, no overspend, explicit under-delivery treatment. |
| Non-auction pricing | Owner-approved flat daily/fixed promotion candidate; no inferred or hidden dynamic price. |
| Frequency control | Privacy-minimized cap at surface/object/merchant scope with safe outage behavior. |
| Measurement integrity | Idempotent request/eligible/render/impression/interaction events; no fabricated attribution. |
| Invalid traffic | Self-click/bot/duplicate handling, held/disputed amounts, merchant appeal path. |
| Privacy and customer control | Contextual/minimum-data default, location control, ad/report control, no sensitive/child behavioral profiling. |
| Merchant transparency | Budget/spend/delivery/freshness/policy status and clear explanation that ads do not buy organic rank or trust. |
| Operations | Policy/admin review queue, observability, billing reconciliation, support/dispute flow, kill switch, incident ownership. |
| Development validation | Automated contract tests plus controlled manual accessibility, failure, slow-network, concurrency, and trust acceptance. |

If any MUST_HAVE item is absent, the product should remain organic-only.

## 3. SHOULD_HAVE for a Controlled V1

| Capability | Value | Can launch without it? |
|---|---|---|
| Search as the first/only surface | Strong explicit intent and explainability | Yes, if owner chooses another single validated surface; multiple surfaces increase risk. |
| Category sponsorship after search | Adds discovery volume with coarser intent | Yes; defer until search quality is proven. |
| “Why am I seeing this?” detail | Improves trust and review | A concise disclosure is mandatory; richer explanation can follow if disclosure already meets the approved standard. |
| Merchant preview | Reduces disclosure/creative errors | Possible to begin with admin-assisted setup; risky at scale. |
| Near-real-time reporting freshness | Reduces merchant confusion | Daily/explicitly delayed reporting may be acceptable for a manual pilot. |
| Automated campaign policy review | Operational scale | Manual review may be safer at very low volume. |
| New-merchant exploration quota | Reduces incumbent lock-in | Can start with manually balanced rotation if measured. |
| Aggregate attributed verified-purchase reporting | Shows offline outcome without CPA | Not required for initial delivery/billing validation. |
| Customer ad-topic controls | Additional agency | Report/hide controls and privacy choices remain required; advanced topic controls can follow. |
| Automated credit workflow | Dispute efficiency | Manual reconciliation is acceptable only at very low volume with a clear SLA. |

## 4. DEFER

- CPC or CPA billing as a launch dependency;
- first-price, second-price, generalized second-price, or real-time auction;
- automated bid optimization or value prediction;
- behavioral profiles, interest cohorts, lookalikes, third-party data, or cross-app/site retargeting;
- sensitive-category, child-directed, or vulnerability-based targeting;
- seller-comparison sponsorship unless separately owner-approved after trust testing;
- Nearby sponsorship until locality and “nearest” comprehension tests pass;
- Home feed personalization and broad awareness campaigns;
- merchant/canonical-product/taxonomy node as a sponsored object;
- banner/display advertising and arbitrary merchant-uploaded creative templates;
- “watch/click ad for reward” gamification;
- paid badges, reputation, review, organic-rank, or verified-purchase benefits;
- service/booking/quotation ads until a real sponsored-object and outcome contract exists;
- cross-device identity graphs and precise-location history;
- automatic budget scaling, credit lines, and complex invoicing;
- external ad-network demand or data sharing;
- self-service regulated-domain advertising before policy operations are proven.

## 5. Smallest Coherent Pilot Candidate

If the owner chooses ads rather than subscription-only launch:

1. Development first; no Production traffic or money.
2. A small, owner-approved set of low-risk merchants and product types.
3. Exact active `SHOP_LISTING` only.
4. Search surface only, contextual exact/strong intent plus coarse local eligibility.
5. At most one sponsored unit within an owner-approved initial window; density never inferred as final here.
6. Always-visible `Sponsorlu` label and merchant/shop identity.
7. Non-auction flat pilot budget with hard total cap, paced rotation, and no charge/credit for under-delivery.
8. Manual policy approval and support-assisted campaign creation if merchant foundations are incomplete.
9. Impression/interaction shadow measurement before any money moves.
10. Explicit go/no-go review using trust, relevance, invalid-traffic, under-delivery, merchant fairness, and operational-load evidence.

This pilot remains a candidate, not an authorization.

## 6. V1 Exit Criteria

Before expanding surface, pricing, targeting, or self-service scope:

- zero undisclosed sponsored renders in acceptance evidence;
- no nonexistent/inactive/stale listing served;
- organic fallback/order contract passes failure tests;
- budget never exceeds hard cap in concurrency tests;
- billing/reporting event reconciliation is explainable;
- policy review and appeal SLAs are operational;
- merchant/customer comprehension tests meet owner-defined thresholds;
- invalid-traffic false-positive and false-negative evidence is reviewed;
- privacy/data-retention controls are verified;
- owner explicitly approves the next expansion.

## 7. Open Owner Decisions

1. Is any advertising needed for V1, or should launch use subscription/organic discovery first?
2. If ads proceed, is Search the only pilot surface?
3. Is seller comparison excluded from V1?
4. What exact listing density and locality limits are acceptable?
5. Which low-risk product/merchant cohort is eligible for the pilot?
6. Is the proposed non-auction flat budget model acceptable?
7. What evidence is required before moving from shadow measurement to real billing?

## 8. Recommendation

Do not implement a broad “simple ads” feature. Either launch without ads or conduct a narrow, manually controlled, non-auction sponsored-listing pilot after every MUST_HAVE contract and root owner decision is closed. Defer behavioral targeting, auctions, CPA, rewards, seller comparison, and multi-surface expansion.

