# Wave 28 Unified Review and Merchant Badge Work Plan

**State:** COMPLETE — 100/100 WORK PACKAGES — NO OWNER FINALIZATION — NO RUNTIME

This plan contains 100 substantive work packages. The existing owner-final product-review rights
are constraints, not hypotheses. New shop evaluation, reputation and badge decisions remain
proposed for review.

## Phase 0 — Scope and evidence

1. Verify repository, clean worktree, current `origin/main` and isolated task branch.
2. Pin every required read-only source branch HEAD without merging it.
3. Extract current product-review, QR and verified-purchase invariants.
4. Extract catalog product identity, merge/split and evidence-snapshot constraints.
5. Extract merchant organization/shop/branch identity constraints.
6. Extract reward, reputation, badge and new-merchant fairness hypotheses.
7. Extract operations, moderation, fraud and appeal constraints.
8. Extract analytics event authority, idempotency and privacy boundaries.
9. Extract advertising/reward/reputation separation constraints.
10. Build a research registry for statistical, survey and ranking methods with limitations.

## Phase 1 — Unified evaluation contract

11. Define the single customer-visible `Alışveriş Değerlendirmesi` contract.
12. Preserve one product free-text review system and prohibit a second seller free-text review.
13. Separate product-review and shop-evaluation logical identities behind one UX flow.
14. Define verified-purchase evidence binding for both logical outputs.
15. Define product review identity as customer plus canonical product.
16. Compare shop-evaluation identities: purchase, customer-shop lifetime and rolling customer-shop.
17. Model repeated purchase of the same product at the same shop.
18. Model repeat purchase of the same product at another shop.
19. Model multiple products in one verified basket without vote multiplication.
20. Model quantity and basket-value neutrality.
21. Model partially completed/skipped evaluation sections.
22. Model negative product feedback with positive shop experience.
23. Model positive product feedback with negative shop experience.
24. Define edit, delete, recreate and revision semantics for both logical outputs.
25. Define immutable evidence and mutable authored-content boundaries.

## Phase 2 — Merchant feed and identity projection

26. Define merchant/shop review feed as a projection, not a second review record.
27. Bind product free text to an immutable origin purchase/shop evidence choice.
28. Compare cross-shop attribution options when multiple evidence records predate first review.
29. Define feed behavior after product-review edit or content moderation.
30. Define feed behavior after review deletion and recreate.
31. Define verified-label and structured-signal presentation without aggregate confusion.
32. Define product rename, taxonomy move and variant-context behavior.
33. Define product duplicate merge and customer-review collision behavior.
34. Define product split and ambiguous historical evidence behavior.
35. Define shop rename, relocation, temporary closure and permanent closure behavior.
36. Define shop merge, branch transfer and organization merge/split behavior.
37. Compare shop-first, organization-first and layered reputation scopes.
38. Define multi-branch feed filtering and organization roll-up explanations.
39. Define merchant ownership-change evidence continuity and non-portable claims.
40. Define historical feed lineage and current-versus-at-event labels.

## Phase 3 — Structured evaluation research

41. Research friendliness as a customer-answerable dimension.
42. Research attention/helpfulness and distinguish it from friendliness.
43. Research product knowledge/accurate information and claim ambiguity.
44. Research overall shop experience as a summary item.
45. Evaluate speed/transaction ease as a later candidate.
46. Exclude product quality and “as described” from merchant interpersonal aggregation.
47. Compare three-question, four-question and adaptive/optional forms.
48. Analyze survey fatigue, completion friction and order effects.
49. Compare five-point, three-point, binary and labeled-anchor scales.
50. Define `SKIPPED`, `NOT_APPLICABLE` and missing-at-random limitations.
51. Define Turkish neutral labels and accessibility requirements conceptually.
52. Define dimension versioning and question-text change rules.
53. Define minimum respondent explanation and consent/privacy boundary.

## Phase 4 — Aggregation and confidence

54. Specify Model A: simple mean plus minimum sample.
55. Specify Model B: Bayesian-adjusted ordinal score plus minimum sample.
56. Specify Model C: confidence/lower-bound score with binary-transform limitation.
57. Specify Model D: hybrid dimension eligibility and confidence gates.
58. Compare interpretability, cold start, fraud resistance and operational cost.
59. Define unique-customer/effective-contribution denominator.
60. Compare per-purchase, lifetime and rolling customer-shop contribution caps.
61. Define no quantity, basket value, frequency or ad/reward weighting.
62. Compare raw count, effective sample, unique customer and confidence thresholds.
63. Define no-imputation rule for skipped dimensions.
64. Define aggregate recomputation after edit, delete, moderation and evidence correction.
65. Define score version, policy version, window and freshness metadata.
66. Compare lifetime, rolling-window, dual-window and exponential-decay options.
67. Challenge whether recency should affect pilot scoring at all.
68. Define stale/insufficient-evidence behavior without punitive zero ratings.
69. Define new-merchant organic fairness and badge withholding.
70. Define merchant comparison guardrails and no false precision.

## Phase 5 — Badge graph and lifecycle

71. Define factual, dimension, derived, composite and meta badge classes.
72. Design candidate primary badge families and prohibited implications.
73. Define badge criterion, evidence scope, sample, confidence, time and policy envelope.
74. Define a versioned acyclic badge dependency graph.
75. Define prerequisite set semantics: all, any-N and weighted family coverage.
76. Define confidence propagation without multiplying certainty.
77. Define shop, organization and branch badge scope.
78. Define region/neighborhood identity and effective-time binding.
79. Define relocation and neighborhood-change behavior.
80. Compare five `Mahallenin Yıldızı` models: specified set, any-N, balanced, percentile, hybrid.
81. Stress small-neighborhood denominators and percentile distortion.
82. Define badge lifecycle: EARN, ACTIVE, AT_RISK, SUSPENDED, REVOKED, RETIRED.
83. Define retention, expiry/staleness, revocation and re-earning.
84. Define closure, ownership transfer and org restructuring effects.
85. Define customer-facing and merchant-facing explainability.

## Phase 6 — Integrity, moderation and system boundaries

86. Model QR collusion, staff abuse, merchant self-rating and multi-account rings.
87. Model customer over-weighting, repeat-frequency dominance and coordinated brigading.
88. Define hold/suspend/recompute behavior without erasing immutable history.
89. Separate free-text moderation from structured-score evidence validity.
90. Define merchant dispute and customer/merchant appeal boundaries.
91. Define privacy-minimized public feed and restricted evidence access.
92. Define event identity, idempotency, corrections and projection rebuild.
93. Define analytics as observation, never rating authority.
94. Prove advertising spend cannot influence score, badge or visibility of negative feedback.
95. Prove reward participation cannot influence reputation evidence.

## Phase 7 — Decisions, pilot and assurance

96. Create raw owner decisions, semantic dedup, root decisions and fast decision cards.
97. Perform contrarian review and algorithm simplification review.
98. Define phased pilot: collection, private analytics, factual badges, composite/meta badges.
99. Generate and reconcile at least 4,300 unique synthetic stress scenarios.
100. Build implementation sequence, master blueprint, readiness, manifest and final self-review.

## Checkpoint strategy

Checkpoint after: plan/source baseline; unified contract/feed; dimensions/research; aggregation and
confidence; badges/lifecycle; fraud/moderation/boundaries; owner/pilot pack; stress matrices; final
blueprint and consistency review. Every checkpoint runs scope, diff and secret/PII checks before push.

`WORK_PACKAGES: 100`
`WORK_PACKAGES_COMPLETED: 100`
`OWNER_FINALIZATION: NO`
`RUNTIME_IMPLEMENTATION: NO`
