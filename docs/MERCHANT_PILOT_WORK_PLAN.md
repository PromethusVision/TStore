# Wave 30 Minimum Merchant Pilot Surface Work Plan

**State:** EXECUTION PLAN — 80 SUBSTANTIVE PACKAGES — NO RUNTIME/OWNER FINALIZATION

## Phase 0 — Baseline and source reconciliation

1. Verify clean repository, current `origin/main`, fresh task branch and docs-only scope.
2. Pin Merchant App foundation HEAD and inventory its capabilities.
3. Pin Esenler commercial-pilot foundation HEAD and extract pilot assumptions.
4. Pin Backend foundation and identify authoritative merchant/listing/QR contracts.
5. Pin Operations foundation and extract assisted-operation/audit constraints.
6. Pin QA/Release foundation and extract physical/release gates.
7. Pin Compliance foundation and regulated-domain fail-closed constraints.
8. Pin Catalog and merchant-taxonomy foundations and reconcile product/listing identity.
9. Pin Analytics and unified-review foundations and extract minimum signal/reputation boundaries.
10. Pin customer/QR/review sources and preserve exact-shop verified-purchase contracts.

## Phase 1 — Product contract and model comparison

11. Define what the minimum merchant pilot surface is and is not.
12. Separate pilot learning needs from full Merchant App commercialization scope.
13. Specify Model A: full Merchant App before pilot.
14. Specify Model B: minimum safe merchant pilot slice.
15. Specify Model C: operator-assisted pilot with a tiny verifier surface.
16. Compare safety, usability, development effort and support load.
17. Compare operator burden, scalability and fraud exposure.
18. Compare catalog freshness, QR reliability and commercial-learning quality.
19. Identify capabilities that cannot be deferred under any model.
20. Identify optional dashboard/analytics/staff/ads/reward/reputation capabilities.

## Phase 2 — Identity, authority and onboarding

21. Define merchant authentication minimum and wrong-role handling.
22. Separate auth user, merchant membership, shop ownership and operational authority.
23. Define active-shop selection and exact-shop action binding.
24. Compare single-owner pilot and multi-staff models.
25. Define which staff roles can safely defer.
26. Define merchant-side onboarding minimum steps.
27. Define assisted onboarding evidence and consent boundaries.
28. Define operator-created bootstrap data provenance and handoff.
29. Define merchant verification and regulated-merchant fail-closed gates.
30. Define suspension, ownership change and membership revocation effects.

## Phase 3 — Shop, listing and catalog slice

31. Define minimum shop profile fields and active/verified states.
32. Define listing read contract and exact shop/catalog association.
33. Define minimum listing write operations.
34. Define price, currency and validation requirements.
35. Define availability states and stale-data behavior.
36. Define listing freshness evidence and merchant reaffirmation options.
37. Define canonical product selection/search requirements.
38. Define operator-assisted product association boundaries.
39. Define unknown-product/catalog-intake escalation without ad hoc production identity.
40. Define duplicate candidate, barcode ambiguity and custom-product handling.
41. Separate canonical product data from shop-owned listing fields.
42. Define listing history, audit evidence and correction/reversal needs.

## Phase 4 — QR verifier and verified purchase

43. Define the smallest safe QR verifier surface.
44. Define exact-shop, authenticated merchant authority before confirmation.
45. Define QR payload lookup and customer/basket context minimization.
46. Define confirm/reject/expired/already-used states.
47. Preserve single-use, duplicate/replay and wrong-shop protection.
48. Define double-tap, concurrent confirmation and retry idempotency.
49. Define offline, slow-network and app lifecycle behavior.
50. Define verified-purchase history minimum for merchant support/audit.
51. Define correction/escalation boundary without manual history editing.
52. Define Customer App dependency and two-device physical acceptance.

## Phase 5 — Reviews, notifications, support and operator assistance

53. Define merchant visibility of product reviews and structured evaluations.
54. Define response/report needs without score manipulation.
55. Define reputation/badge dashboard deferral boundary.
56. Define minimum actionable merchant notifications.
57. Define notification fallback when push is unavailable.
58. Define merchant support case categories and escalation evidence.
59. Define what must be self-service.
60. Define what may be operator-assisted temporarily.
61. Define what must never be manual or arbitrary.
62. Define audit trail and operator separation-of-duties compensating controls.

## Phase 6 — Impact, security, QA and release

63. Map exact future Flutter features/modules/files likely to change without editing them.
64. Map backend schema/RLS/RPC/event impact without migrations.
65. Identify Production configuration and data gates.
66. Define Android/device/camera/network assumptions.
67. Threat-model IDOR, cross-shop authority, account takeover and staff abuse.
68. Define fail-closed behavior for regulated domains and unverified merchants.
69. Build unit/widget/contract/integration/concurrency test strategy.
70. Define exact physical two-device acceptance and signed-artifact requirements.
71. Enumerate pilot failure modes and safe degradation.
72. Define minimum analytics and audit signals without dashboard dependency.

## Phase 7 — Scope, decisions and assurance

73. Classify MUST, SHOULD and DEFER capabilities.
74. Build V1 versus post-pilot scope and implementation ordering.
75. Define future parallel-agent execution plan and integration gates.
76. Create raw owner decisions, semantic dedup/root decisions and fast cards.
77. Perform contrarian review and minimum-surface simplification.
78. Generate and validate at least 3,200 unique synthetic stress scenarios.
79. Build master blueprint, readiness assessment and exact document manifest.
80. Run cross-document, scope, count, secret/PII, diff and final self-review.

## Checkpoints

Checkpoint after planning/sources, product/authority/listing, QR/support/security, impact/QA/decisions,
stress matrices and final assurance. No source branch is merged and no runtime state is touched.

`WORK_PACKAGES: 80`
`OWNER_FINALIZATION: NO`
`RUNTIME_IMPLEMENTATION: NO`
