# EsnaftaVar Ecosystem Master Blueprint

**State:** RECONCILED ARCHITECTURE — RECOMMENDED, NOT OWNER FINAL

## 1. Executive answer

The foundation branches are compatible when four seams remain explicit:

1. identity is stable and labels/taxonomy paths are mutable;
2. authorization is server-side membership/capability, never UI or sector;
3. verified-purchase evidence comes only from atomic merchant-confirmed QR;
4. paid, economic, reputation and analytics systems cannot manufacture organic
   evidence.

The architecture is broad enough for the future but the first Esenler pilot should
remain small: working Customer O2O, truthful catalog/listings, controlled merchant
listing/verifier access, QR/reviews, lean Ops/observability and exact release QA.

## 2. System map

| Layer | Authoritative identity/truth | Primary writer | Pilot state |
|---|---|---|---|
| Auth/Profile | Auth user + customer profile | trusted Auth/customer-scoped path | REQUIRED |
| Merchant | organization + membership + physical shop | authorized merchant/server | MINIMUM SEAM |
| Catalog | canonical Product + optional Variant | platform-governed writer | REQUIRED |
| Commerce offer | Shop Listing, price, availability, merchant SKU | scoped merchant capability | REQUIRED |
| Physical evidence | QR session + verified purchase/items | atomic server transaction | REQUIRED |
| Reviews | customer review keyed to canonical product/evidence | eligible customer/server gate | REQUIRED |
| Ops | case/action/audit evidence | named authorized operator | LEAN REQUIRED |
| Analytics | derived telemetry/metrics | services/clients under registry | MINIMUM REQUIRED |
| Ads | campaign/delivery/attribution | future authorized advertiser/server | POST-PILOT |
| Reward | immutable economic ledger event | future server authority | POST-PILOT |
| Gamification | trusted-event-derived badge/progress | future server/derived | POST-PILOT |
| Reputation | explainable merchant signals | future server/derived | POST-PILOT |

## 3. Global invariants

- Product Taxonomy and Merchant Sector Taxonomy answer different questions.
- Canonical Product, Variant and Shop Listing never collapse; listing owns shop price,
  availability and SKU.
- QR is opaque, short-lived, exact-shop bound and single-winner; it is not payment.
- Only immutable verified purchase evidence unlocks review eligibility.
- One active review exists per customer + canonical product for life; quantity and
  repeat purchase do not multiply review rights.
- Catalog merge/split/correction preserves lineage rather than rewriting history.
- Ratings remain visible and independent from proprietary reputation.
- Ads spend cannot create verified purchase, review, reward, badge, reputation or
  organic rank.
- Analytics/legacy/client events never become authoritative domain evidence.
- Customer precise location and PII are minimized; public projections exclude
  account/private/security fields.
- Existing Customer backend is evolved additively and old clients fail safely.

## 4. Decision-state reconciliation

Owner-final artifacts remain final only in their exact scope. Product Taxonomy V1
is final; proposed facets/runtime migration are not. The Merchant Sector hierarchy
is proposed except explicitly confirmed subtree evidence. Catalog, Merchant App,
Ads, Reward, Ops, Analytics, Backend and QA foundations are architecture proposals
or recommendations, not automatic runtime or product approval. No option in this
wave is selected.

## 5. Contradictions and root fixes

Twenty-four apparent contradictions were reconciled: P0=10, P1=10, P2=3, P3=1.
Twelve reusable root fixes cover all 24: server authorization, identity triad,
evidence firewall, correction lineage, exact release evidence, lean merchant seam,
state provenance, lean Ops, purpose-limited analytics, post-pilot economics, honest
availability language and rights-aware media promotion.

## 6. Pilot architecture

### MUST_HAVE

- named platform/release scope and exact signed artifact evidence;
- stable Customer discovery/search/category/product/shop/location/auth flows;
- truthful active catalog/listings and explicit demo provenance;
- authenticated exact-shop merchant verifier and bounded listing maintenance;
- atomic QR consume/verified purchase/review eligibility;
- ordinary-domain allowlist with unknown/regulated fail closed;
- lean incident/support/correction runbooks and privacy-safe health signals;
- physical target-device and two-device QR acceptance where required.

### SHOULD_HAVE

- listing freshness/unknown semantics;
- manual governed product-candidate escalation;
- critical in-app merchant/customer notifications;
- small question-led pilot scorecard.

### DEFER

Ads, billing/auction, Reward, vouchers, gamification, public composite reputation,
full Merchant App breadth, full multi-branch hierarchy, universal variants,
variable-measure QR, advanced facets, enterprise Ops automation, broad realtime,
event outbox and exhaustive CI permutations.

## 7. Recommended first 15 owner decisions

1. ROOT-01 platform/release evidence.
2. ROOT-04 catalog identity/variant boundary.
3. ROOT-07 merchant organization/staff scope.
4. ROOT-11 QR branch/reissue/measure rule.
5. ROOT-09 policy allowlist/service boundary.
6. ROOT-10 listing truth/merchant communication.
7. ROOT-03 taxonomy/facet/legacy/demo activation.
8. ROOT-05 catalog intake/measure/media.
9. ROOT-06 catalog correction/review history.
10. ROOT-08 Merchant Sector finalization/assignment.
11. ROOT-17 lean Ops/appeal/retention.
12. ROOT-18 analytics KPI/privacy budget.
13. ROOT-12 Merchant App delivery shape.
14. ROOT-13 Ads existence/object/surface.
15. ROOT-15 Reward existence/economics.

ROOT-02, ROOT-14 and ROOT-16 can follow unless an earlier choice makes them urgent.

## 8. Commercialization critical path

Decide release scope → close Customer gates → lock catalog truth → establish
merchant authority → harden QR/review → approve policy allowlist → establish lean
Ops/observability → validate exact artifact physically → controlled pilot → evidence
review. Stop on identity uncertainty, authorization weakness, QR replay/wrong-shop,
ambiguous history or unverifiable artifact.

## 9. Post-pilot sequence

Use pilot evidence to decide full Merchant App expansion. Then consider transparent
merchant signals, Ads shadow mode, Reward economics/ledger and factual badges in
separate gated waves. Levels, challenges and streaks have no default recommendation.

## 10. Stress evidence

| Suite | Scenarios | Result |
|---|---:|---|
| cross-system contracts | 1,000 | 1,000 classified PASS |
| identity/ownership | 500 | 500 classified PASS |
| lifecycle | 500 | 500 classified PASS |
| security/policy | 500 | 500 classified PASS |
| V1/pilot scope | 500 | 260 PASS; 150 deferred; 50 controlled-path; 20 owner gate; 20 evidence-blocked |
| global mixed | 1,000 | 704 PASS; 176 policy review; 100 deferred; 20 root decision |

All 4,000 IDs and non-ID scenario signatures are unique. A classification such as
`POLICY_REVIEW` or `DEFERRED_AS_DESIGNED` is a safe expected outcome, not a hidden
pass or runtime claim.

## 11. Implementation governance

Future implementation uses permanent task branches, single migration ownership,
explicit integration, additive compatibility and separate remote-apply authority.
The first twenty proposed waves are dependency ordered; their presence is not
authorization. Production/Development, database, runtime and Figma were untouched.

`ECOSYSTEM_MASTER_RECONCILIATION: PASS`
`READY_FOR_GLOBAL_PRODUCT_OWNER_REVIEW: YES`
`OWNER_FINALIZATION_PERFORMED: NO`
`RUNTIME_IMPLEMENTATION: NO`
