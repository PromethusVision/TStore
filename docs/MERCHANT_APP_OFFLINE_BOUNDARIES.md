# Merchant App Offline Boundaries

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP56

## Cacheable read experiences

- Last authorized shop/profile summary with stale/offline label.
- Listing/catalog read snapshots with freshness.
- Draft form input without secrets or raw QR tokens.
- Previously confirmed activity summaries as history, not authority.

## Server-required operations

- QR validate/confirm and status reconciliation.
- Auth, membership, role, staff and shop switch authorization.
- Price/availability/listing/candidate mutation.
- Shop activation/location/status change.
- Review reporting/reply and policy evidence submission.

## Queue recommendation

Do not silently queue customer-affecting writes in V1. Preserve user input, reconnect, refresh revision/authorization and request explicit submit. Low-risk queued drafts may be considered later, but never QR confirmation.

## Cache isolation

Cache keys include auth user, organization and shop; logout/revoke/switch removes inaccessible scoped projections. Stale cache cannot reveal another staff member's former scope.
