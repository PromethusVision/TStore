# Merchant App Root Fix Opportunities

Status: **PROPOSED — OWNER/BACKEND REVIEW REQUIRED**
Wave: 17 / WP103

| Root fix | Failure classes reduced | Proposal |
|---|---|---|
| RF-01 Membership+capability+shop decision function | F-01, F-02, F-14, F-18 | One server-side authorization contract used by RLS/RPC/services |
| RF-02 Atomic idempotent mutation envelope | F-03, F-09, F-13, F-16 | Request ID, revision, certainty and reconcile endpoint |
| RF-03 QR one-time shop-bound consume | F-03–05 | Transactional token consume and immutable evidence |
| RF-04 Catalog layer protection | F-06, F-07, F-09 | Canonical/variant/listing field allowlists and exception queue |
| RF-05 Policy eligibility evaluator | F-08, F-17 | Versioned fail-closed merchant/shop/product/media decisions |
| RF-06 Projection privacy classes | F-02, F-10, F-17 | Customer-visible, merchant-private, platform-restricted DTOs |
| RF-07 Explicit state/metric vocabulary | F-11, F-15, F-19 | Governed enums/reason classes and semantic tests |
| RF-08 Immutable evidence boundary | F-03, F-12, F-20 | Merchant cannot rewrite QR/review/reputation truth |
| RF-09 Scope-keyed client state | F-01, F-02, F-14, F-18 | Account/org/shop keys and purge/reload on transition |
| RF-10 Future-engine adapter boundary | F-15, F-20 | Ads/reward/gamification consume references, never core ownership |

Prioritize RF-01–05 before feature UI parallelization; they remove the widest P0 failure set.
