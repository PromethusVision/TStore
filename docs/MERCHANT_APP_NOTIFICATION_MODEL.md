# Merchant App Notification Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP49

## Event families

| Family | Examples | Default channel intent |
|---|---|---|
| SECURITY | New login, role revoked, suspicious access | Immediate in-app; external channel policy TBD |
| QR | Verified outcome, unresolved timeout, repeated denial | In-app operational |
| CATALOG | Candidate result, duplicate, correction, policy block | Inbox + action deep link |
| SHOP | Suspension, status/location review | High priority |
| REVIEW | New eligible review, report result | Normal; merchant reply future |
| ANALYTICS | Periodic summary | Optional/deferred |
| FUTURE_ADS | Campaign/policy/budget state | Future engine only |

## Contract

- Notification is a projection of authoritative state, not the authority.
- Deep link re-checks auth, membership, shop scope and object state.
- Deduplicate event/retry notifications; unread count is not business truth.
- Sensitive content is minimized on lock screen/external channels.
- Delivery failure does not reverse QR/catalog/shop state.

## Preferences

Security/policy-critical notifications may be non-optional subject to owner/legal decision. Marketing and summaries require independent opt controls.
