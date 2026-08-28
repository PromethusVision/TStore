# Customer App Navigation Audit

Status: AUDITED — no deterministic route fix required

## Graph

```text
Production/Development entrypoint
  → TStore listeners
  → CustomerLaunchGate
      → first use: Onboarding → NavigationMenu
      → returning use: NavigationMenu

NavigationMenu
  0 Home (guest)
    → search → product details → seller comparison → shop details/chat
    → categories → subcategory/product list → product details
    → location/saved location
  1 Nearby (guest in current runtime)
    → shop details → product details
  2 Cart V2 (Auth guard)
    → QR customer session
  3 Wishlist (Auth guard)
    → product details
  4 Profile/Settings (Auth guard)
    → profile, addresses, purchases, ratings, notifications, chat,
      legal/privacy/support, account deletion

Root callback routes
  email confirmation → Home or Login with verified feedback
  password recovery → Update Password → Login
  automatic session expiry → NavigationMenu/Home + expiry message
```

Most transitions are direct `MaterialPageRoute` calls; no string route names or global generated router are present. Typed constructor arguments reduce missing-argument risk, while direct navigation makes a future content-deep-link expansion a centralized-routing project rather than a local fix.

## Guard matrix summary

- Bottom destinations 2–4 are guarded and preserve the requested destination after successful login.
- Guest cancellation keeps the current destination.
- Product favorite actions provide a login gate.
- Customer-owned data repositories also fail safely without a user ID.
- Nearby is intentionally reachable for guests in code and existing Production smoke evidence. Wave 16 language suggests login-gating personalized Nearby if canonical documentation confirms it; no owner-final rule resolves this conflict. Classified `OWNER_DECISION_REQUIRED`, unchanged.

## Static and test findings

| Risk | Result | Evidence |
| --- | --- | --- |
| Dead/duplicate named routes | PASS | No named-route registry; constructor call sites resolve statically. |
| Route loop | PASS | Callback listeners deduplicate callbacks; guarded login returns a Boolean result. |
| Back-stack invalidation | PASS | Automatic expiry uses `pushAndRemoveUntil`; normal child journeys use push/pop. |
| Guest redirect loss | PASS | Navigation widget tests cover success and cancellation. |
| Deep-link resume | PASS | Initial and live Auth callbacks are covered; physical Android confirmation/recovery previously passed. |
| Missing arguments | PASS | Typed constructors and analyzer. |
| Stale-context navigation | PASS WITH WATCH | Async call sites generally check `mounted`; no reproducible violation found. |
| Unreachable screen | CONDITIONAL | Legacy orders are deliberately unreachable; merchant-oriented surfaces are outside Customer V1. |

No route was deleted and no broad router refactor was justified.

`NAVIGATION_AUDIT: PASS`  
`DETERMINISTIC_NAVIGATION_BUG_FOUND: NO`  
`OWNER_DECISION_REQUIRED: NEARBY_GUEST_POLICY`
