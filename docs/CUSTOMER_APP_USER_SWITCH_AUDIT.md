# Customer App User-switch and Logout Isolation Audit

Status: PASS WITH DEVICE-LOCAL PRIVACY DECISION

## Customer-owned state

| State | Isolation behavior |
| --- | --- |
| Cart V2 | Cleared synchronously; generation rejects old load/mutation; new user reloads. |
| Wishlist | Entity/ID caches cleared; generation rejects former-user result; new user reloads. |
| Navigation | Reset to Home, removing direct personalized-tab selection. |
| Profile/address/saved locations/reviews/purchases | Route-scoped; expiry removes stack; repositories resolve current session. |
| Notifications/chat | User-filtered repository queries/streams; subscriptions close with route/Cubit; unread resets for guest. |
| Recently viewed products | SharedPreferences key includes customer ID. |
| Nearby primary location | Route-scoped Cubit; leaving/resetting tab disposes loaded state. |

Widget/unit tests prove automatic expiry, user-initiated logout, same-user token refresh, and A→B Cart/Wishlist reset behavior.

## Device-local state decision (`P2`, `OWNER_DECISION_REQUIRED`)

Five recent search queries are device-wide because search is a guest feature. A pending pre-login product-chat draft is also device-wide and can live up to 24 hours, though it is validated, bounded, consumed/cleared on completion/cancel/error, and contains no Auth token. On a shared device these values can be visible to the next person.

Recommended before feature freeze: explicitly accept guest/device-local history semantics or require logout/account-switch clearing and a shorter pending-draft retention. Changing it now would be a product/privacy decision, not a deterministic bug fix.

`USER_SWITCH_AUDIT: PASS`
`CROSS_USER_SERVER_DATA_LEAK_FOUND: NO`
`OWNER_DECISION_REQUIRED: DEVICE_LOCAL_HISTORY_POLICY`
