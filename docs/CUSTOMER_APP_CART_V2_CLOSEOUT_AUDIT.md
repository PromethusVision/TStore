# Customer App Cart V2 Closeout Audit

Status: PASS — physical QR completion remains external

## Canonical semantics

Cart V2 is a single-store preparation list for an in-person purchase. A cart item identifies a concrete `shop_product`; there is no online checkout, payment, shipping, or legacy order creation.

## Regression matrix

| Case | Result/evidence |
| --- | --- |
| Empty cart | Explicit discovery guidance; first item can establish the store. |
| Same-shop add | Canonical add succeeds and refreshes active items. |
| Different-shop add | Conflict state requires explicit replace decision. |
| Empty-cart different-shop regression | Backend/use-case contract treats the empty active cart safely; retained regression coverage. |
| Quantity plus/minus | Minimum 1 enforced; successful mutation refreshes without replacing content with a blank loading screen. |
| Remove/last removal/clear | Confirmation and mutation states are explicit; refreshed empty state is canonical. |
| Cart count | Derived from current Cart V2 items in the shared customer shell. |
| Logout/account switch | Local state clears; generation invalidates former-user loads/mutations. |
| Login restore | Root session listener loads the authenticated cart. |
| Inactive shop/listing/unavailable item | QR is blocked; item can be refreshed or safely removed. |
| Price/item-count change | Server snapshot requires customer reconfirmation before QR is shown. |
| Duplicate add/quantity/remove/clear/QR | Cubit or view operation locks suppress concurrent duplicate actions. |
| Refresh error | Existing visible items remain available with safe feedback where the view has a valid snapshot. |

## Commercial gate

QR session creation/status and customer completion UI have broad unit/widget coverage. Logical expiry/retry/reconciliation behavior is covered. A physical camera scan with two real devices, wrong merchant, replay, concurrent confirmation, durable product evidence, and customer refresh is still `PHYSICAL_TEST_REQUIRED`; this audit does not convert emulator/unit evidence into a physical PASS.

`CART_V2_CLOSEOUT_AUDIT: PASS`  
`SINGLE_STORE_SEMANTICS: PASS`  
`ONLINE_CHECKOUT_PRESENT: NO`  
`PHYSICAL_QR_GATE: BLOCKED`
