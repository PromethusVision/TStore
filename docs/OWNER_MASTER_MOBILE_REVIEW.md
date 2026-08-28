# Owner Master Mobile / PC Review

State: `24 FINAL ROOT CARDS — 0 OPEN / 3 PROVISIONAL / 4 DEFERRED`

Use `OM-Rxx=A/B/C` only for non-final cards when their review phase is active.
`RECOMMENDED` remains an agent
recommendation. Product Owner finalized exactly 24 answers on 2026-08-29. The
second batch added `OM-R01=A`, `OM-R02=A`, `OM-R03=A`, `OM-R09=A`, `OM-R10=A`,
`OM-R11=B`, `OM-R12=A`, `OM-R13=A`, `OM-R14=A`, `OM-R15=A`, `OM-R16=A`,
`OM-R17=A`, `OM-R18=A` and `OM-R31=A`. The third batch added `OM-R06=B` and
`OM-R07=B` as strategy/identity direction only. No other card is selected.

## OM-R01 — Pilot success purpose

DECISION: `FINAL=A`

QUESTION — İlk Esenler pilotunun tek başarı amacı nedir?

RECOMMENDED: A

A: Useful local discovery plus trustworthy merchant/QR operating evidence.

B: User/merchant growth and engagement volume.

C: Immediate revenue validation.

WHY NOW:

- KPI and expansion criteria need one hierarchy.
- Prevents every feature becoming equally “must have.”

BLOCKS: OM-R15, OM-R31

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R01=A`

---

## OM-R02 — Geography and density

DECISION: `FINAL=A` — bounded density-ready cells; not all Esenler at once.

QUESTION — Hangi exact Esenler cells ve hangi minimum usable density ile pilot açılır?

RECOMMENDED: A

A: Bounded launch cells open only after merchant/catalog usability evidence.

B: All Esenler launches together.

C: Scattered merchants launch without cell-level readiness.

WHY NOW:

- Scope drives onboarding, support and acquisition load.
- Local discovery is weak without real nearby density.

BLOCKS: OM-R03, OM-R10, OM-R14, OM-R31

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R02=A`

---

## OM-R03 — Rollout and cohort

DECISION: `FINAL=A` — controlled cohort, then measured staged expansion.

QUESTION — İlk cohort ve distribution sequence nasıl olmalıdır?

RECOMMENDED: A

A: Controlled closed cohort, then measured staged expansion.

B: Broad public/store launch from day one.

C: Indefinite invitation-only research cohort.

WHY NOW:

- Determines release track and support exposure.
- Preserves learning without pretending readiness.

BLOCKS: OM-R04, OM-R14

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R03=A`

---

## OM-R04 — Platform and exact artifact

DECISION: `FINAL=A`

QUESTION — Hangi platform ve exact-artifact evidence ticari pilotu açar?

RECOMMENDED: A

A: Android-only when the signed exact artifact and physical gates pass; iOS later.

B: Android+iOS together, each with signed exact-artifact evidence.

C: Research builds continue without a commercial acceptance gate.

WHY NOW:

- Platform promise changes QA, signing and support scope.
- UI-R15 must certify the artifact that actually ships.

BLOCKS: release scope, UI final acceptance, OM-R31

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R04=A`

---

## OM-R05 — Guest, auth and location

DECISION: `FINAL=A` — KVKK review remains open.

QUESTION — Guest discovery, protected actions, location and device-local history boundary nedir?

RECOMMENDED: A

A: Guest discovery; contextual auth; transient/coarse location; minimal deletable local history.

B: Login-first discovery with no local history.

C: Broad account-linked location and behavioral history.

WHY NOW:

- Resolves UI-R06 AuthGuard without a duplicate owner question.
- Shapes conversion and privacy architecture together.

BLOCKS: Customer access UX, OM-R17 instrumentation

PROFESSIONAL REVIEW: KVKK

ANSWER FORMAT: `OM-R05=A`

---

## OM-R06 — Taxonomy/runtime activation

DECISION: `FINAL=B` — strategy only; no activation, migration or ID generation authorized.

QUESTION — Taxonomy, facets, legacy bridge and demo data runtime'a nasıl taşınmalıdır?

RECOMMENDED: B

A: All taxonomy/facet/legacy/demo changes activate together.

B: Stable-ID staged migration with rollback and dependency-aware demo retirement.

C: Current runtime taxonomy remains frozen indefinitely.

WHY NOW:

- Final and proposed taxonomy states must not mix.
- This can be scheduled without blocking current pilot code.

BLOCKS: future taxonomy/catalog runtime rollout

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R06=B`

---

## OM-R07 — Catalog identity

DECISION: `FINAL=B` — domain-gated Variant; no schema/runtime implementation authorized.

QUESTION — Product, Variant, Listing and identifier identities nasıl ayrılmalıdır?

RECOMMENDED: B

A: Product and Listing only; no explicit Variant.

B: Product + domain-gated Variant + separate Listing + evidence-based identifiers.

C: Universal Variant in every domain with broad automatic barcode linkage.

WHY NOW:

- Listing price/availability and canonical identity must not drift.
- QR, review and correction evidence depend on stable meaning.

BLOCKS: OM-R08, OM-R12, OM-R13, OM-R26

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R07=B`

---

## OM-R08 — Catalog intake and publication

QUESTION — Merchant candidate, variable-measure and media ne zaman customer-visible olabilir?

RECOMMENDED: B

A: Merchant submissions become public canonical content directly.

B: Governed candidate review, gated measure contract and reviewed media promotion.

C: Merchant catalog contributions stay closed.

WHY NOW:

- Prevents catalog pollution and unsupported product claims.
- Keeps simple merchant submission possible without blind publication.

BLOCKS: candidate/catalog implementation, OM-R12

PROFESSIONAL REVIEW: REGULATORY

ANSWER FORMAT: `OM-R08=B`

---

## OM-R09 — Merchant authority and cohort

DECISION: `FINAL=A`

QUESTION — Pilot merchant organization, authority and cohort shape nedir?

RECOMMENDED: A

A: Ordinary single-owner shops with an organization seam; staff/branch automation waits for evidence.

B: Multi-staff shops with fixed presets from day one.

C: Full enterprise multi-branch hierarchy before pilot.

WHY NOW:

- Authority scope determines every merchant write and QR permission.
- Single-owner shops can validate the pilot with less security surface.

BLOCKS: OM-R11, OM-R12, OM-R13

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R09=A`

---

## OM-R10 — Policy allowlist and verification

DECISION: `FINAL=A` — lawyer/regulatory review remains open.

QUESTION — Hangi merchant sectors, verification evidence and policy classes pilotta açıktır?

RECOMMENDED: A

A: Ordinary allowlist; unknown and regulated capabilities fail closed.

B: Bounded regulated cohort only after specialist approval.

C: Broad sectors/products open by default.

WHY NOW:

- Onboarding and catalog cannot safely proceed without a perimeter.
- Taxonomy placement is not regulatory authorization.

BLOCKS: OM-R09, OM-R11, OM-R12

PROFESSIONAL REVIEW: LAWYER / REGULATORY

ANSWER FORMAT: `OM-R10=A`

---

## OM-R11 — Minimum Merchant App

DECISION: `FINAL=B` — minimum safe slice only; full Merchant App not approved.

QUESTION — İlk pilot için hangi merchant-side operating surface gerekir?

RECOMMENDED: B

A: Full Merchant App before pilot.

B: Minimum safe Merchant App for authority, listing truth and QR; assisted bootstrap is time-boxed.

C: Tiny verifier with mostly operator-assisted merchant operations.

WHY NOW:

- It is the main merchant implementation scope decision.
- Model B preserves real merchant learning without dashboard overbuild.

BLOCKS: Merchant pilot implementation

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R11=B`

---

## OM-R12 — Listing truth and freshness

DECISION: `FINAL=A` — exact enum/schema is not selected.

QUESTION — Price, availability and freshness truth kim tarafından ve hangi states ile korunur?

RECOMMENDED: A

A: Merchant self-service core; explicit AVAILABLE/OUT/UNKNOWN/TEMP states and risk-tier freshness.

B: Operator-only listing truth.

C: Best-effort price/stock with no explicit stale/unknown state.

WHY NOW:

- Customer trust depends on current local facts.
- Operator-only updates do not scale and distort pilot learning.

BLOCKS: live listing contract, OM-R31

PROFESSIONAL REVIEW: LAWYER for customer-facing claims

ANSWER FORMAT: `OM-R12=A`

---

## OM-R13 — QR rollout and evidence

DECISION: `FINAL=A` — gated subset; physical/two-device evidence remains open.

QUESTION — QR hangi cohort'ta, hangi exact-shop authority ve history görünürlüğüyle açılır?

RECOMMENDED: A

A: Gated merchant subset; exact issued shop; replay-safe; limited PII-minimized merchant history.

B: Every merchant on day one with the same authority contract.

C: QR and verified review evidence defer.

WHY NOW:

- QR is the verified-purchase and review evidence boundary.
- Physical training and two-device acceptance are real gates.

BLOCKS: OM-R25, OM-R26, verified-review pilot

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R13=A`

---

## OM-R14 — Operations and support

DECISION: `FINAL=A` — lawyer review of user-facing process remains open.

QUESTION — Pilot support, staffing, operator authority and pause controls nasıl çalışır?

RECOMMENDED: A

A: Named lean coverage; one-person combination allowed with evidence/audit and explicit pause authority.

B: Best-effort Product Owner operations with ad-hoc decisions.

C: Full enterprise role separation before pilot.

WHY NOW:

- A controlled pilot still needs a reachable recovery path.
- Manual database edits cannot become routine operations.

BLOCKS: incident handling, OM-R31

PROFESSIONAL REVIEW: LAWYER for user-facing process

ANSWER FORMAT: `OM-R14=A`

---

## OM-R15 — KPI, monitoring and privacy

DECISION: `FINAL=A` — KVKK review and exact thresholds remain open.

QUESTION — Hangi minimum KPI, baseline and monitoring evidence piloti yönetir?

RECOMMENDED: A

A: Question-led health/discovery/listing/QR metrics; baseline before numeric targets.

B: Broad dashboard and many targets before pilot.

C: Anecdotal feedback without consistent metrics.

WHY NOW:

- Pilot success and expansion need falsifiable evidence.
- Minimum metrics reduce privacy and tooling burden.

BLOCKS: OM-R31 go/continue/expand evidence

PROFESSIONAL REVIEW: KVKK

ANSWER FORMAT: `OM-R15=A`

---

## OM-R16 — Merchant pilot offer

DECISION: `FINAL=A` — no future price is approved; accounting/tax review remains open.

QUESTION — Merchant'a hangi bounded commercial pilot offer sunulur?

RECOMMENDED: A

A: Explicit no-charge pilot term with end state and no silent paid conversion.

B: Fixed “three months free” promise before post-pilot economics are proven.

C: Paid participation from entry.

WHY NOW:

- Offer expectations affect recruitment and retention evidence.
- Avoids accidentally promising an unreviewed future price.

BLOCKS: merchant acquisition and terms copy

PROFESSIONAL REVIEW: ACCOUNTANT before billing/tax claims

ANSWER FORMAT: `OM-R16=A`

---

## OM-R17 — Acquisition and feedback

DECISION: `FINAL=A` — KVKK review remains open.

QUESTION — İlk customer/merchant acquisition mix ve feedback yöntemi nedir?

RECOMMENDED: A

A: Merchant/community-led local acquisition plus opt-in interviews/in-app feedback.

B: Paid local/Meta acquisition leads the first cohort.

C: Broad untargeted acquisition with informal feedback only.

WHY NOW:

- Channel choice changes cohort bias and cost.
- Feedback must measure learning without becoming support or surveillance.

BLOCKS: channel operations, OM-R15 attribution scope

PROFESSIONAL REVIEW: KVKK for research and paid-channel data

ANSWER FORMAT: `OM-R17=A`

---

## OM-R18 — Terms, privacy and account lifecycle

DECISION: `FINAL=A` — lawyer/KVKK review remains a commercial-launch gate.

QUESTION — Hangi professionally reviewed terms, privacy, deletion and factual platform disclosures launch before pilot?

RECOMMENDED: A, subject to professional review

A: Minimum lawyer/KVKK-reviewed customer and merchant surfaces ship before launch.

B: Incomplete interim notices ship while review continues.

C: Pilot launches without reachable terms/privacy/deletion/support surfaces.

WHY NOW:

- Product Owner should not finalize professional wording alone.
- These surfaces are a real commercial launch dependency.

BLOCKS: commercial release, OM-R04, OM-R05, OM-R14

PROFESSIONAL REVIEW: LAWYER / KVKK — REVIEW FIRST

ANSWER FORMAT: `OM-R18=A`

---

## OM-R19 — UI palette

DECISION: `FINAL=A`

QUESTION — Customer UI semantic palette rollerinde primary ve accent hangisidir?

RECOMMENDED: A

A: Teal/green primary; terracotta warm accent.

B: Terracotta primary; teal accent.

C: New palette exploration; rollout waits.

WHY NOW:

- Token roles affect every component and acceptance frame.
- Resolves the Wave 14/Wave 27 role inconsistency.

BLOCKS: OM-R20, OM-R21, OM-R22, OM-R23, OM-R24

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R19=A`

---

## OM-R20 — UI mode scope

DECISION: `FINAL=A`

QUESTION — Pilot consistent light mode ile, dark mode olmadan çıkabilir mi?

RECOMMENDED: A

A: Explicit light-only pilot; dark mode becomes a later quality wave.

B: Light and dark both complete before pilot.

C: Current mixed legacy dark behavior remains.

WHY NOW:

- Theme mode doubles visual and physical acceptance scope.
- A consistent limited mode is safer than an inconsistent broad claim.

BLOCKS: OM-R21 final theme acceptance

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R20=A`

---

## OM-R21 — Critical screen direction

DECISION: `FINAL=A`

QUESTION — Home, listing, product and seller screens hangi visual direction ile ilerler?

RECOMMENDED: A

A: Current direction is accepted after every bounded C1 correction is verified.

B: Specified areas receive a bounded revision before implementation.

C: Critical Customer screens are redesigned.

WHY NOW:

- It unlocks the largest Customer UI implementation group.
- Avoids re-litigating component details before screen direction.

BLOCKS: OM-R22, OM-R23, OM-R24, UI fallback/content details

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R21=A`

---

## OM-R22 — Shop Details CTA

DECISION: `FINAL=A`

QUESTION — Shop Details ekranında en güçlü CTA hangisidir?

RECOMMENDED: A

A: Directions/physical visit primary; products are core content; chat secondary.

B: Shop products are primary and visit intent is secondary.

C: Chat is primary.

WHY NOW:

- The product promise is local physical discovery, not online checkout.
- CTA hierarchy materially changes customer expectation.

BLOCKS: Shop Details implementation

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R22=A`

---

## OM-R23 — Cart V2 meaning

DECISION: `FINAL=A`

QUESTION — Cart V2 müşteriye hangi product meaning ile sunulur?

RECOMMENDED: A

A: Single-shop physical-shopping preparation with estimated total and QR education.

B: Generic basket without strong local-shopping explanation.

C: Checkout-like progression.

WHY NOW:

- Checkout-like language contradicts the no-payment platform role.
- Cart and QR education must tell one story.

BLOCKS: Cart V2 and QR education implementation

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R23=A`

---

## OM-R24 — Card density

DECISION: `FINAL=A`

QUESTION — 390 px Customer ekranında product/category cards ne kadar yoğun olmalıdır?

RECOMMENDED: A

A: Balanced two-line content with merchant count and availability context.

B: Compact price-first cards.

C: Wide editorial cards with fewer items per viewport.

WHY NOW:

- Long Turkish content and local availability both need space.
- It affects every discovery/list grid.

BLOCKS: product/category card implementation

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R24=A`

---

## OM-R25 — Unified evaluation form

QUESTION — Tek “Alışveriş Değerlendirmesi” akışı hangi launch phase ve structured question set ile başlar?

RECOMMENDED: A

A: Collection-only; three labeled dimensions, 1–5, independent skip/N/A.

B: Four questions including an overall shop-experience item.

C: One overall merchant-experience question only.

WHY NOW:

- Preserves one product free-text review and avoids survey fatigue.
- Collection can launch before public reputation if privacy is cleared.

BLOCKS: OM-R26

PROFESSIONAL REVIEW: KVKK before collection

ANSWER FORMAT: `OM-R25=A`

---

## OM-R26 — Evaluation contribution and feed

QUESTION — Structured shop evaluation contribution ve merchant feed projection kimliği nasıl çalışır?

RECOMMENDED: A

A: Per-purchase raw evidence; capped customer+shop contribution; cross-shop allowed; immutable review-origin projection.

B: One lifetime customer+shop evaluation; later purchases cannot refresh it.

C: Every purchase contributes equally without customer cap.

WHY NOW:

- Same product at Shop A and Shop B must not create a second product review.
- Merchant feed must not invent a second free-text seller review.

BLOCKS: OM-R27 public reputation

PROFESSIONAL REVIEW: KVKK

ANSWER FORMAT: `OM-R26=A`

---

## OM-R27 — Public reputation and badge timing

QUESTION — Shop/organization reputation and primary badges ne zaman public olmalıdır?

RECOMMENDED: A

A: No public pilot score/badge; collect data and run private fairness analysis first.

B: A small set of factual shop-level primary badges launches in pilot.

C: Public star, primary and composite badges launch together.

WHY NOW:

- Small samples can unfairly label new merchants.
- Public claims need appeal/correction and privacy readiness.

BLOCKS: OM-R28

PROFESSIONAL REVIEW: LAWYER / KVKK

ANSWER FORMAT: `OM-R27=A`

---

## OM-R28 — Reputation algorithm and meta badges

QUESTION — Hangi scoring/confidence/composite model ve Mahallenin Yıldızı kuralı kullanılmalıdır?

RECOMMENDED: A

A: Defer formula/threshold; calibrate representative data, then compare hybrid absolute quality + local standing.

B: Bayesian-adjusted score plus hybrid gates is selected before pilot data.

C: Simple average plus minimum sample is selected now.

WHY NOW:

- The architecture is ready, but numeric choice without data creates false precision.
- Neighborhood-relative ranking is unstable with small merchant counts.

BLOCKS: composite/meta badge implementation only

PROFESSIONAL REVIEW: LAWYER / KVKK / TECHNICAL ARCHITECT

ANSWER FORMAT: `OM-R28=A`

---

## OM-R29 — Ads timing and contract

QUESTION — Ads ne zaman ve hangi object, disclosure, targeting and economic contract ile açılır?

RECOMMENDED: A

A: Organic-only pilot; Ads remains a post-pilot shadow design.

B: Narrow disclosed contextual listing experiment after organic baseline.

C: Broad sponsored surfaces, targeting and billing in pilot.

WHY NOW:

- Organic behavior is needed before paid ranking can be interpreted.
- Enabling Ads introduces professional, operational and billing dependencies.

BLOCKS: Ads children only if enabled

PROFESSIONAL REVIEW: LAWYER / KVKK

ANSWER FORMAT: `OM-R29=A`

---

## OM-R30 — Reward timing and economics

QUESTION — Reward ne zaman ve hangi funding, expiry and value-transfer contract ile açılır?

RECOMMENDED: A

A: Economic rewards are disabled for pilot.

B: Merchant-local, non-transferable bounded reward experiment after review.

C: Cross-merchant reward value launches.

WHY NOW:

- Funding/liability/accounting are not yet established.
- Reward participation must never become reputation evidence.

BLOCKS: Reward children only if enabled

PROFESSIONAL REVIEW: LAWYER / ACCOUNTANT

ANSWER FORMAT: `OM-R30=A`

---

## OM-R31 — Pause and expansion

DECISION: `FINAL=A` — exact numeric thresholds are not selected.

QUESTION — Piloti hangi evidence durdurur ve hangi evidence bir sonraki dimension'a genişletir?

RECOMMENDED: A

A: Predefined trust/ops stops; expand one dimension after evidence and support capacity.

B: Product Owner expands or pauses case by case without predefined rules.

C: Calendar-based expansion regardless of evidence.

WHY NOW:

- Prevents unsafe growth and retrospective success criteria.
- One-dimension expansion preserves causal learning.

BLOCKS: launch go/continue/expand governance

PROFESSIONAL REVIEW: NONE

ANSWER FORMAT: `OM-R31=A`

---

## Review response template

The owner may answer only the current session, for example:

`OM-R01=A, OM-R02=A, OM-R03=A`

Non-final cards retain their explicit `PROVISIONAL` or `DEFERRED` state;
recommendations are never auto-applied.

`ROOT_CARDS: 31`

`OWNER_FINAL_OPTIONS: 24`

`OWNER_OPEN_ROOTS: 0`

`OWNER_PROVISIONAL_ROOTS: 3`

`OWNER_DEFERRED_ROOTS: 4`
