# Merchant App User and Shop Switch Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP58

## Context dimensions

- Auth user/session.
- Merchant organization membership.
- Active shop/branch.
- Role/capability snapshot.

## Switch sequence

1. Detect dirty draft, in-flight mutation or unknown QR outcome.
2. Reconcile/cancel safely; never move it to new context.
3. Fetch server-authorized memberships/shops.
4. Select target explicitly and refresh capability/shop status.
5. Clear old scoped cache/navigation and load target projection.

## Boundaries

- Account switch requires clearing all private prior-account state.
- Staff cannot switch to shop merely because ID/deep link is known.
- Biometric/PIN quick unlock may protect local session but cannot mint server permissions.
- Background/foreground and token refresh revalidate revoked membership.
- Notification deep links may propose a context but cannot auto-authorize it.

Multi-organization user switching remains owner decision and may be deferred.
