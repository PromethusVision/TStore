# Customer App Auth Guard Matrix

Status: PASS WITH ONE OWNER DECISION

| Surface/action | Guest result | Authenticated result | Guard layer | Result |
| --- | --- | --- | --- | --- |
| Home/category/product/shop discovery | Allowed | Allowed | Public-read contract | PASS |
| Nearby browse/current GPS | Allowed in current runtime | Allowed | Permission flow, no Auth guard | OWNER DECISION REQUIRED for intended personalization policy |
| Saved locations | Login/profile flow | User-owned CRUD | UI + repository/RLS | PASS |
| Wishlist tab | Login, then requested tab | User wishlist | navigation guard + repository/RLS | PASS |
| Product favorite action | Login prompt/return | Add/remove | action guard + RLS | PASS |
| Cart V2 tab/add | Login/return | Single-store cart | navigation/action + RPC/RLS | PASS |
| QR session creation | Blocked without customer | Short-lived customer token | Auth + backend RPC | PASS |
| Review create/edit/delete | Login; no write | Verified eligibility required | UI + canonical RPC | PASS |
| Profile/settings/customer data | Login/guest profile entry | Own data | navigation/view + RLS | PASS |
| Address CRUD | Login required | Own rows | view/repository + RLS | PASS |
| Purchase history/ratings | Login required | Own evidence | view/repository + RLS/RPC | PASS |
| Notifications/chat | Login required or empty safe state | Own rows/realtime | navigation/repository + RLS | PASS |
| Account deletion | Unavailable | Explicit typed confirmation | view + protected RPC | PASS |

## Consistency decision

Current code, customer help text, and prior Production smoke allow guests to see Nearby shops and optionally use device location. The Wave 16 brief describes personalized location/Nearby as intended to be login-gated only if canonical documentation confirms it. No owner-final document conclusively overrides the shipped behavior. Changing it would materially alter guest discovery, so it is not an authorized local fix.

Owner question: should anonymous users keep Nearby/current-device sorting while only saved locations remain account-scoped, or should opening Nearby itself require login?

Recommended: keep public Nearby discovery and gate only persistence/personalization. This matches the O2O discovery proposition and existing physical acceptance, but requires explicit owner confirmation.

`AUTH_GUARD_CONSISTENCY: PASS`  
`AUTH_GUARD_BYPASS_FOUND: NO`  
`OWNER_DECISION_REQUIRED: NEARBY_GUEST_POLICY`
