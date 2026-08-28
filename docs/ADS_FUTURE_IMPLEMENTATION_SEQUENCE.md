# Sponsored Advertising — Future Implementation Sequence

**State:** PROPOSED SEQUENCE AFTER OWNER REVIEW
**Scope:** Analysis only. This is not authorization to implement schema, payments, environment configuration, or Production advertising.

## 1. Sequencing Principle

Advertising sits downstream of catalog truth, merchant identity, organic discovery, policy, finance, privacy, and operations. Building the campaign UI or ranking service first would encode unresolved business choices and create pressure to serve unsafe inventory.

Every phase below has an explicit exit gate. A failed gate stops advertising work while the organic product continues.

## 2. Phase 0 — Decide Whether to Build

### Work

- Product owner reviews the contrarian and business-model comparisons.
- Validate whether initial commercial release needs ads, subscription, both, or neither.
- Gather merchant willingness-to-pay and customer trust evidence.
- Estimate eligible local demand/supply and operational cost.

### Exit gate

- explicit owner decision to proceed with a defined pilot objective;
- stop criteria and success evidence recorded;
- no assumption that roadmap presence implies implementation.

If not approved, archive the foundation for future review and make no ad runtime.

## 3. Phase 1 — Close Root Owner Decisions

### Work

- decide sponsored object, surfaces, locality, policy cohorts, density/rank interaction, pricing basis, auction/no-auction, and data-use boundary;
- close P1 operating and P2 wording/retention/SLO decisions;
- record decisions in canonical product governance rather than leaving them only in proposal docs.

### Exit gate

- all P0 decisions closed coherently;
- dependent P1/P2 decisions have named owners and deadlines;
- V1 and deferred scope frozen for the pilot.

## 4. Phase 2 — Freeze Upstream Identity and Organic Contracts

### Work

- finalize canonical product/variant/shop-listing/shop identities and lifecycle/version fields;
- define listing price, stock, availability, freshness, and deletion semantics;
- establish owner-final taxonomy stable IDs and revision/split/merge handling for permitted targets;
- verify merchant/shop identity and primary/secondary sector contract;
- specify independent organic search/category ranking inputs and deterministic fallback.

### Exit gate

- an exact active listing is resolvable without name/slug/path identity;
- nonexistent/inactive/stale objects fail closed;
- ad removal cannot change organic result membership/order;
- no proposal-only taxonomy identity is frozen into runtime.

## 5. Phase 3 — Establish Policy, Privacy, Finance, and Operations Authority

### Work

- owner/legal review product/merchant eligibility matrices and sector-specific evidence;
- define restricted/excluded products, claims, documents, expiry, moderation, appeal, and incident process;
- approve contextual/location data basis, notices, controls, child/vulnerable-user protections, retention, and access;
- decide price/billing basis, merchant terms, tax/accounting, invoices, credits/refunds, disputes, and charge evidence;
- assign policy, fraud, finance, support, privacy, security, and kill-switch owners.

### Exit gate

- narrow written launch allowlist exists;
- every sensitive cohort has a fail-closed rule;
- financial and privacy control owners accept the contract;
- operations can stop serving and freeze settlement safely.

## 6. Phase 4 — Design Runtime Contracts and Threat Model

### Work

- convert approved design into versioned API/domain contracts for campaign, targeting, eligibility, budget, serving, creative, events, and reporting;
- define authorization/RLS boundaries and admin separation;
- define idempotency, concurrency, reservation/commit/reversal, tombstones, and audit events;
- perform security/privacy threat modeling and abuse-case review;
- define performance budgets, circuit breakers, organic fallback, observability, and data lifecycle.

### Exit gate

- architecture/security/privacy/finance reviews pass;
- no service-role or privileged decision is delegated to merchant/customer clients;
- all failure modes have safe response and operational ownership;
- schema/API proposal can be reviewed without Production writes.

## 7. Phase 5 — Build Merchant and Admin Foundations in Development

### Work

- complete merchant catalog/listing quality and analytics prerequisites;
- build campaign creation/edit/preview/pause/end flow behind a disabled feature flag;
- build policy review, evidence, rejection/appeal, and kill-switch tools;
- implement the budget ledger in test/shadow mode with zero real payment movement;
- make all state changes auditable and authorized.

### Exit gate

- unauthorized merchant/admin transitions are rejected;
- concurrent edits/budget operations remain idempotent and fail closed;
- inactive/deleted/stale listing and policy changes pause serving automatically;
- no Production data/config has been touched.

## 8. Phase 6 — Implement Eligibility and Shadow Ranking in Development

### Work

- retrieve campaign candidates by contextual intent and permitted coarse locality;
- apply merchant, shop, listing, policy, evidence, schedule, budget, frequency, and fairness gates;
- compute organic results independently;
- compute sponsored ordering without rendering or billing it to customers;
- record privacy-minimized shadow evidence.

### Exit gate

- static 500-case ranking and 200-case campaign scenarios become executable contract tests;
- no nonexistent/ineligible listing reaches output;
- relevance/locality and diversity thresholds behave deterministically;
- every failure produces exact organic fallback;
- budget concurrency never exceeds hard cap.

## 9. Phase 7 — Customer Rendering Behind Development Flags

### Work

- implement one approved surface first, preferably Search if the owner selected it;
- render native authoritative listing data with persistent textual `Sponsorlu`;
- implement accessibility, reason/report/hide controls, real distance, slow-network, session change, and navigation lifecycle behavior;
- do not add deferred surfaces or seller comparison opportunistically.

### Exit gate

- automated render/navigation/accessibility/failure tests pass;
- no theme, scroll, refresh, or navigation state loses disclosure;
- duplicate listing/double impression is prevented;
- 150 trust cases are translated into targeted acceptance evidence;
- real moderated customer comprehension meets owner-set thresholds.

## 10. Phase 8 — Measurement, Fraud, and Reporting in Shadow Mode

### Work

- implement idempotent request/candidate/render/impression/interaction events;
- separate billable, invalid, attributed, and verified-purchase states;
- reconcile duplicates, late/out-of-order events, outages, and report watermarks;
- test self-click, bots, collusion, multi-account/device ambiguity, and merchant disputes;
- provide merchant/admin reports with explicit freshness and invalid/held status.

### Exit gate

- event and ledger reconciliation has no unexplained material mismatch;
- invalid-traffic controls have reviewed false-positive/negative evidence;
- raw personal/location/query data stays within approved minimization/retention;
- verified purchase remains independently authoritative and non-billable unless separately approved.

## 11. Phase 9 — Development Manual Acceptance and Incident Drills

### Work

- run slow/degraded/offline, stale catalog, policy change, budget race, kill switch, privacy-choice, reporting delay, and rollback drills;
- test representative low-risk and blocked regulated cohorts;
- exercise support, appeal, credit/refund, security, and privacy procedures;
- validate no-regression organic experience with advertising globally disabled.

### Exit gate

- release checklist signed by Product, Policy, Privacy, Security, Finance, Support, Merchant, Customer, and Operations owners;
- all P0/P1 launch decisions and critical gaps closed;
- Development evidence is preserved without real secrets or customer PII in source;
- an explicit go/no-go review approves a tiny pilot.

## 12. Phase 10 — Optional Real-Money Development/Sandbox Acceptance

Only if a compliant payment sandbox and owner-approved terms exist:

- test budget funding/reservation/commit/reversal/credit/refund and invoices with isolated fixtures;
- never use Production merchants, customer data, credentials, or funds;
- reconcile finance and campaign reports independently.

### Exit gate

- end-to-end sandbox ledger reconciles;
- no secret is committed/logged;
- refund/dispute and failed-payment states pass;
- signed finance/security acceptance exists.

## 13. Phase 11 — Production Pilot Preparation

This phase requires a new explicit Production authorization.

### Work after authorization only

- prepare reviewed migrations/config/feature flags/monitoring/rollback;
- define exact merchant/customer cohort, geography, product allowlist, budget ceiling, time window, and stop thresholds;
- require manual campaign/policy approval;
- start with shadow/no-charge observation if feasible;
- verify disclosure and organic fallback on real supported clients before paid scale.

### Exit gate

- separate integration/release review passes;
- backups/rollback/kill switch and on-call owners are proven;
- no unresolved policy, privacy, security, billing, or trust blocker;
- owner explicitly authorizes the exact Production change.

## 14. Phase 12 — Evidence-Gated Expansion

Only after the pilot:

- review customer trust, relevance, organic impact, merchant incrementality, fairness/concentration, under-delivery, fraud, disputes, privacy, and operating cost;
- expand one dimension at a time: cohort, geography, surface, targeting, pricing, or self-service;
- rerun threat/policy/trust acceptance for each expansion;
- keep auctions, behavioral targeting, CPA, rewards, seller comparison, and external demand behind separate owner gates.

## 15. Forbidden Shortcuts

- campaign UI before object/policy/billing contracts;
- mutable name/slug/path as advertising identity;
- client-authoritative eligibility, billing, or admin actions;
- using spend to bypass relevance, locality, policy, freshness, fairness, or disclosure;
- serving stale/nonexistent listing to satisfy delivery;
- charging unverified events;
- treating merchant sector as product permission;
- treating verified purchase as automatic CPA or reward;
- changing Production during Development acceptance;
- broadening V1 because a deferred component is technically easy to add.

## 16. Recommended Next Action

Run a product-owner decision workshop using `ADS_OWNER_ROOT_DECISIONS.md`, `ADS_CONTRARIAN_REVIEW.md`, and `ADS_BUSINESS_MODEL_COMPARISON.md`. Do not begin schema or runtime work until Phase 0–3 exit gates are closed.

`FUTURE_IMPLEMENTATION_AUTHORIZED: NO`

`NEXT_GATE: PRODUCT_OWNER_DECISIONS`

`PRODUCTION_CHANGE_AUTHORIZED: NO`
