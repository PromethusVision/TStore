# Ecosystem Architecture Simplification Review

**State:** RECOMMENDED — OWNER DECISIONS REMAIN OPEN

## Simplification rules

1. Reuse the working Customer backend contract; evolve additively.
2. Keep future identities as seams without activating empty enterprise workflows.
3. Prefer explicit manual pilot operations over fragile premature automation.
4. Build a server transaction/RPC only where authority, concurrency or atomicity
   demands it; ordinary reads remain ordinary reads.
5. Keep Ads, Reward, Gamification and Reputation stores and evidence separate.
6. Expose unknown/stale state honestly instead of inventing precision.

## Proposed reductions

| Area | Broad foundation | Simplified pilot form | Preserved seam |
|---|---|---|---|
| Merchant identity | organization + membership + branches + capabilities | one organization, one shop, owner/verifier/catalog presets | organization/membership IDs |
| Catalog | universal Product/Variant/Listing | canonical product + listing; variant only when correctness-critical | optional variant reference |
| Inventory | realtime stock semantics | availability state + freshness timestamp + unknown | later feeds/reservations |
| Merchant tooling | full separate app | trusted controlled listing/QR operating path | API/capability contract |
| Ops | full case-management platform | named operators, minimal case/evidence log, runbook | stable case/action identities |
| Analytics | broad event warehouse | authoritative QR/release/discovery health events | versioned event registry |
| Realtime | broad subscriptions | only already-required user-private flows | authorized channel model |
| Ads | campaign/billing/ranking | inactive | exact listing and surface identities |
| Reward | ledger/funding/redemption | inactive | verified-purchase evidence boundary |
| Gamification | badges/levels/challenges/streaks | inactive | trusted-event vocabulary |
| Reputation | composite score/badges | ratings and counts remain explicit | future signal registry |
| CI | exhaustive platform matrix | exact risk gates; no silent skips | expandable acceptance matrix |

## Do not collapse

- Auth user, profile, merchant organization, membership and shop.
- Canonical Product, optional Variant and Shop Listing.
- QR session, verified purchase and review.
- Rating, merchant reputation and advertising.
- Domain event, security audit and analytics telemetry.

These separations prevent privilege, history and evidence corruption even when the
pilot implementation is lean.

## Complexity budget

The pilot may accept manual reconciliation and limited throughput. It may not accept
ambiguous authorization, destructive history rewrite, silent fallback, unverifiable
release artifacts or paid influence over organic trust.

`ARCHITECTURE_SIMPLIFICATION: PASS`
