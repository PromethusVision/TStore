# Merchant App Failure Registry

Status: **DESIGN STRESS CONSOLIDATION — NO RUNTIME EXECUTION**
Wave: 17 / WP102

Generated scenario matrices found no contradiction against the proposed fail-closed contracts; every row is marked `DESIGN_CONTRACT_PASS`. The following 20 failure classes are release failures if an implementation produces them.

| ID | Priority | Failure class | Required detection/result |
|---|---|---|---|
| F-01 | P0 | Role/self-escalation succeeds | Server denial and unchanged membership |
| F-02 | P0 | Cross-shop read/write leaks | Deny existence/private data |
| F-03 | P0 | QR creates duplicate transaction | Atomic uniqueness; exactly one |
| F-04 | P0 | Expired/wrong-shop QR accepted | Server-time/shop-bound rejection |
| F-05 | P0 | Offline QR shown successful | No offline confirmation |
| F-06 | P0 | Canonical facts mutated through listing | Reject protected fields |
| F-07 | P0 | Duplicate/ambiguous product auto-merged | Review/exception, no blind link |
| F-08 | P0 | Regulated/unknown state publishes | Fail closed |
| F-09 | P0 | Stale price/listing overwrites | Revision conflict |
| F-10 | P0 | Customer identity exposed to merchant | Minimized projection/suppression |
| F-11 | P1 | Unknown availability shown in stock | Explicit semantic state |
| F-12 | P1 | Review altered/hidden by merchant | Reporting only; immutable evidence |
| F-13 | P1 | Mutation timeout causes duplicate retry | Idempotency + reconciliation |
| F-14 | P1 | Branch switch carries draft/mutation | Scoped state isolation |
| F-15 | P1 | Analytics intent labeled sales | Metric glossary/semantic test |
| F-16 | P1 | Bulk operation silently partial | Preview and per-row/atomic result |
| F-17 | P1 | Media path/rights crosses shop | Authorization and moderation |
| F-18 | P2 | Notification deep link trusts stale scope | Re-resolve state and authorization |
| F-19 | P2 | Dashboard shows delayed as zero | Delayed/unavailable/partial states |
| F-20 | P2 | Future paid/reward UI changes organic truth | Strict engine separation |

Counts: P0 = 10, P1 = 7, P2 = 3.

These are acceptance criteria, not claims about existing runtime because no Merchant App runtime exists.
