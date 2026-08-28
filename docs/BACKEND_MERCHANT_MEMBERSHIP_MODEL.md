# Backend Merchant Membership Model

**State:** PROPOSED — NO SCHEMA

## Contract

A membership is the server-authoritative relationship between one Auth user and
one merchant organization. It carries lifecycle, capability set, shop scope,
effective interval and revision. Authentication or profile role alone never
creates membership.

## Minimum conceptual fields

- immutable membership, user and organization IDs;
- status and effective/revoked timestamps;
- capability profile plus explicit overrides if later approved;
- permitted shop IDs or organization-wide scope;
- revision, inviter/approver and audit reason;
- policy/version under which it was granted.

## Invariants

1. Active user, organization and membership are all required at mutation time.
2. Shop scope is explicit; missing scope denies rather than inheriting all shops.
3. Capability and lifecycle are rechecked on every server mutation and retry.
4. Invite acceptance cannot choose a broader role/scope than the issued grant.
5. Revocation blocks new work immediately; completed history retains actor and
   membership snapshot.
6. The same user may have separate memberships with isolated capabilities.

## Lifecycle

Invitation, activation, scope/capability revision, suspension, revocation and
expiry are audited transitions. Removing a membership from the UI is not
revocation. Re-invitation creates a new governed activation/revision; it does not
erase earlier history.

## Owner decisions

- organization-wide membership inheritance: recommend **deny by default**;
- invitation expiry and approval assurance: `OWNER_DECISION_REQUIRED`;
- whether one-person pilot ownership bypasses membership: recommend **no bypass**,
  use a seeded owner membership during migration.
