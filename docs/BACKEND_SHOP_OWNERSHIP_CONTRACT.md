# Backend Shop Ownership Contract

**State:** PROPOSED EVOLUTION OF CURRENT OWNER FIELD

## Current truth

Canonical `shops.owner_user_id` plus merchant-role policies authorize current
owner operations. This remains active until a membership migration is complete.
Null ownership is valid for the customer-only demo dataset and grants no merchant
authority.

## Future truth

Shop control derives from an active organization membership with explicit shop
scope and capability. The organization-to-shop relation is server-managed.
Clients cannot set owner organization/user IDs, approve a transfer or claim an
unowned shop.

## Write rules

- creation/onboarding binds organization and shop atomically through a governed
  server contract;
- allowed profile/listing edits do not change ownership;
- transfer requires case/evidence, fresh authorization, impact preview and audit;
- suspension/revocation is effective before new shop writes;
- public shop visibility and merchant write eligibility are separate states.

## Migration compatibility

Existing non-null owners should receive deterministic owner memberships only
after collision checks. Rows with null or ambiguous owners stay unowned and fail
closed. During transition, server contracts may accept either the legacy owner
path or new membership only under an explicit versioned bridge—not an OR policy
left indefinitely.

## Open decision

Whether owner transfer changes merchant organization or only membership is
`OWNER_DECISION_REQUIRED`. Recommendation: preserve shop ID and record an audited
ownership transition when the physical shop remains continuous.
