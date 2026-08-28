# Customer App Rapid-action and Double-submit Audit

Status: PASS

| Target | Protection/evidence |
| --- | --- |
| Login/signup/recovery/account deletion/logout | Auth loading/verification states and disabled buttons suppress parallel submit. |
| Product/category/shop navigation | Per-entity opening flags prevent duplicate routes. |
| Search | Debounce, duplicate-query check, and active request ID. |
| Location/saved location | Explanation/settings/capture/save/default/delete busy locks. |
| Wishlist | Favorite widget and list operation locks; guest login opens once. |
| Cart add/replace/quantity/remove/clear | Cubit exclusive flags plus view operation state. |
| QR create/renew/confirm/close/rating | Cubit/view state locks; success cannot be reconfirmed. |
| Review create/edit/delete/load-more | Cubit mutation lock and disabled form/confirmation state. |
| Notification actions | Per-ID sets and global bulk-action state. |
| Chat send/refresh/load-more | sending/active request locks. |

The active customer tests include rapid-tap cases for all commercial high-risk paths above. The unreachable postal address prototype is excluded; it must not be shipped without modern busy-state coverage.

`DOUBLE_ACTION_AUDIT: PASS`
`DUPLICATE_CRITICAL_WRITE_FOUND: NO`
