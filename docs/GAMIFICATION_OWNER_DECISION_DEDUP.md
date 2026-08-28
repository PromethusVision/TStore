# Gamification Owner Decision Dedup
**State:** SEMANTIC DEDUP — NO OWNER FINALIZATION
All 40 raw decisions are represented exactly once across 16 root clusters. `SAFE_TO_COLLAPSE: NO` means the cluster is useful for review ordering but retains materially distinct subquestions.
## GC-01
- **SOURCE_DECISION_IDS:** GD-01, GD-17, GD-27
- **ROOT_QUESTION:** What launches in the commercial pilot, and in which sequence?
- **SAFE_TO_COLLAPSE:** YES
- **DISTINCT_SUBQUESTIONS:** Reward, customer badge and merchant reputation timing remain independent subquestions.
- **AFFECTED_SYSTEMS:** All
- **WHY:** Combines release sequencing without forcing all systems to share timing.
## GC-02
- **SOURCE_DECISION_IDS:** GD-02, GD-03, GD-04, GD-05
- **ROOT_QUESTION:** What authoritative purchase evidence and granularity may earn reward?
- **SAFE_TO_COLLAPSE:** NO
- **DISTINCT_SUBQUESTIONS:** Repeat, quantity and monetary trust require explicit subanswers.
- **AFFECTED_SYSTEMS:** REWARD
- **WHY:** One evidence root; materially different economic multipliers remain visible.
## GC-03
- **SOURCE_DECISION_IDS:** GD-06, GD-07
- **ROOT_QUESTION:** What reward unit, calculation and threshold form the customer progress model?
- **SAFE_TO_COLLAPSE:** YES
- **DISTINCT_SUBQUESTIONS:** Unit and threshold are dependent choices.
- **AFFECTED_SYSTEMS:** REWARD
- **WHY:** A unit cannot be simulated coherently without its calculation behavior.
## GC-04
- **SOURCE_DECISION_IDS:** GD-08
- **ROOT_QUESTION:** Where is value earned/redeemed, including cross-merchant transfer?
- **SAFE_TO_COLLAPSE:** YES
- **DISTINCT_SUBQUESTIONS:** None.
- **AFFECTED_SYSTEMS:** REWARD
- **WHY:** Standalone P0 scope/liability question.
## GC-05
- **SOURCE_DECISION_IDS:** GD-09
- **ROOT_QUESTION:** Who funds and owes reward value?
- **SAFE_TO_COLLAPSE:** YES
- **DISTINCT_SUBQUESTIONS:** None.
- **AFFECTED_SYSTEMS:** REWARD
- **WHY:** Standalone economic root.
## GC-06
- **SOURCE_DECISION_IDS:** GD-10, GD-11, GD-12
- **ROOT_QUESTION:** How is value redeemed, expired and corrected?
- **SAFE_TO_COLLAPSE:** NO
- **DISTINCT_SUBQUESTIONS:** Redemption, expiry and negative/reversal rules must each remain explicit.
- **AFFECTED_SYSTEMS:** REWARD
- **WHY:** Shared customer liability lifecycle but distinct consequences.
## GC-07
- **SOURCE_DECISION_IDS:** GD-13, GD-14
- **ROOT_QUESTION:** What may merchants configure and what platform policy always overrides?
- **SAFE_TO_COLLAPSE:** NO
- **DISTINCT_SUBQUESTIONS:** Merchant controls and regulated-domain exclusions remain distinct.
- **AFFECTED_SYSTEMS:** REWARD; CROSS_SYSTEM
- **WHY:** Both govern eligibility but legal exclusions cannot be collapsed into configuration.
## GC-08
- **SOURCE_DECISION_IDS:** GD-15, GD-40
- **ROOT_QUESTION:** How are identity lifecycle and platform governance operated?
- **SAFE_TO_COLLAPSE:** NO
- **DISTINCT_SUBQUESTIONS:** Customer lifecycle and operational ownership remain explicit.
- **AFFECTED_SYSTEMS:** CROSS_SYSTEM
- **WHY:** Both require retained audit and accountable privileged actions.
## GC-09
- **SOURCE_DECISION_IDS:** GD-16, GD-26, GD-37
- **ROOT_QUESTION:** What notification, naming and surface communication is used?
- **SAFE_TO_COLLAPSE:** NO
- **DISTINCT_SUBQUESTIONS:** Reward, customer badge and merchant signal copy need separate UX validation.
- **AFFECTED_SYSTEMS:** All
- **WHY:** Low-risk presentation cluster, not one universal copy decision.
## GC-10
- **SOURCE_DECISION_IDS:** GD-18, GD-19, GD-23, GD-24, GD-25
- **ROOT_QUESTION:** Which customer badges exist, from which evidence, with what privacy/lifecycle?
- **SAFE_TO_COLLAPSE:** NO
- **DISTINCT_SUBQUESTIONS:** Family, evidence, public display, soft events and revocation remain explicit.
- **AFFECTED_SYSTEMS:** CUSTOMER_GAMIFICATION
- **WHY:** One product model with inseparable trust dependencies.
## GC-11
- **SOURCE_DECISION_IDS:** GD-20, GD-21, GD-22
- **ROOT_QUESTION:** Are levels, challenges or streaks necessary?
- **SAFE_TO_COLLAPSE:** NO
- **DISTINCT_SUBQUESTIONS:** Each mechanic can be independently included/excluded.
- **AFFECTED_SYSTEMS:** CUSTOMER_GAMIFICATION
- **WHY:** Shared engagement strategy; dark-pattern risk differs.
## GC-12
- **SOURCE_DECISION_IDS:** GD-28, GD-29, GD-30, GD-33
- **ROOT_QUESTION:** What is the merchant reputation scope, signal model and freshness?
- **SAFE_TO_COLLAPSE:** NO
- **DISTINCT_SUBQUESTIONS:** Shop/org scope, signals, composite/factual display and decay remain explicit.
- **AFFECTED_SYSTEMS:** MERCHANT_REPUTATION
- **WHY:** Defines core reputation architecture.
## GC-13
- **SOURCE_DECISION_IDS:** GD-31, GD-32
- **ROOT_QUESTION:** Which merchant badges exist while preserving new-merchant fairness?
- **SAFE_TO_COLLAPSE:** NO
- **DISTINCT_SUBQUESTIONS:** Badge families and cold-start presentation remain explicit.
- **AFFECTED_SYSTEMS:** MERCHANT_REPUTATION
- **WHY:** Badge thresholds affect cold start.
## GC-14
- **SOURCE_DECISION_IDS:** GD-34, GD-35
- **ROOT_QUESTION:** Are product/category or service-specific reputation signals justified?
- **SAFE_TO_COLLAPSE:** NO
- **DISTINCT_SUBQUESTIONS:** Product/category and service contracts need distinct evidence.
- **AFFECTED_SYSTEMS:** MERCHANT_REPUTATION
- **WHY:** Both are deferred specialization.
## GC-15
- **SOURCE_DECISION_IDS:** GD-36, GD-38
- **ROOT_QUESTION:** How do merchant disputes coexist with independent visible customer ratings?
- **SAFE_TO_COLLAPSE:** YES
- **DISTINCT_SUBQUESTIONS:** Dispute may correct system evidence, never legitimate rating.
- **AFFECTED_SYSTEMS:** MERCHANT_REPUTATION; CROSS_SYSTEM
- **WHY:** One integrity boundary.
## GC-16
- **SOURCE_DECISION_IDS:** GD-39
- **ROOT_QUESTION:** Are advertising money/events excluded from reward and reputation evidence?
- **SAFE_TO_COLLAPSE:** YES
- **DISTINCT_SUBQUESTIONS:** None.
- **AFFECTED_SYSTEMS:** CROSS_SYSTEM
- **WHY:** Standalone non-negotiable separation recommendation.
## Coverage proof
The ordered source list across GC-01–GC-16 contains GD-01 through GD-40 once each; no decision is dropped, duplicated or silently finalized.
