# Backend RLS Design Principles

**State:** PROPOSED — NO POLICY SQL

## Principles

1. Deny by default; add narrowly scoped operations with explicit purpose.
2. Authentication proves a principal, not row ownership or business capability.
3. Authorization is server-authoritative and evaluated on every request.
4. Customer ownership, merchant membership/shop scope and operator case capability
   are separate predicates.
5. `USING` read visibility and `WITH CHECK` resulting-row validity are both
   required for direct mutations.
6. Client-supplied owner, role, organization, shop or verification fields are not
   trusted.
7. Security-definer functions expose bounded operations, fix search path, validate
   caller and are not a general RLS bypass.
8. Public browsing exposes only active, policy-eligible fields through a deliberate
   projection; private columns do not become safe because the UI omits them.
9. Cross-shop and cross-customer access fail closed, including Realtime.
10. Revocation/suspension takes effect on the next server check; stale JWT claims
    cannot extend authority.
11. Service/admin credentials never enter Flutter or public Storage.
12. Policies, grants and RPC execute permissions are tested together.

## Direct table access vs RPC

Direct access is suitable for a simple one-row owner mutation where RLS and checks
fully express the invariant. Use a server RPC for multi-row atomicity, evidence,
idempotency, role/capability evaluation, privileged correction or bounded data
projection.

## Test obligations

For every protected operation test owner success, anonymous denial, other-customer
denial, sibling-shop denial, revoked staff, suspended merchant, malicious owner-ID
injection, stale revision, RPC execute grants and Realtime subscription leakage.
Denial behavior should not expose row existence.

No future matrix row grants implementation authority. Exact policies require a
separate migration task and Development verification.

