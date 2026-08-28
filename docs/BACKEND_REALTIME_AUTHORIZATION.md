# Backend Realtime Authorization

**State:** PROPOSED SECURITY CONTRACT

Authentication at subscription time is insufficient for a long-lived channel.
Authorization binds current user, membership/capability, exact customer/shop/case
scope, resource lifecycle and policy.

## Requirements

- private rows retain effective RLS/filter protection for delivery;
- topic/channel input cannot select another user's or shop's scope;
- token refresh, revocation, suspension and account switch close/re-authorize;
- payload contains only fields permitted for that purpose;
- delete/tombstone events do not expose a previously hidden row;
- client reconnect performs authoritative bounded read before trusting state;
- subscription denial and unusual cross-scope attempts create safe security
  signals without content/token logging.

Service/admin broadcast into customer clients is prohibited. Realtime never
authorizes a write and cannot serve as purchase/reward evidence.

