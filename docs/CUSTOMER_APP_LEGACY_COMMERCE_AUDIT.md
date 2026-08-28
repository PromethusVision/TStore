# Customer App Legacy Commerce Audit

Status: PASS — O2O model preserved

## Canonical commercial model

EsnaftaVar Customer V1 discovers products and local shops, prepares a single-store Cart V2, shows a short-lived QR in store, and records a verified purchase only after merchant confirmation. It does not perform online payment, billing, shipping, fulfillment, or checkout.

## Code classification

| Area | Classification | Reason |
| --- | --- | --- |
| Cart V2 and QR | ACTIVE | Canonical in-person verification flow. |
| Verified transactions/history/ratings | ACTIVE | Evidence produced by QR confirmation, not online orders. |
| `lib/features/orders` | LEGACY / ISOLATED | No active DI, navigation, product/shop link, or customer route. |
| Legacy order tables/migration references | HISTORICAL | Retained for compatibility/audit; excluded from current review evidence. |
| Coupons view | FUTURE/INFORMATIONAL | No active discount/payment engine. |
| Return/refund tabs | PREPARATORY UI | Explicit safe informational state; no fulfillment/payment mutation. |

The architecture isolation test asserts that the legacy order package is absent from application wiring, no other library imports its screen, Cart V2 remains QR-based, and discovery does not navigate to legacy orders.

## Search results

Terms such as checkout/payment/shipping may occur in historical documentation, dependency/platform artifacts, or isolated skeleton code. No active customer route, service-locator binding, or Product/Shop action was found that creates an online order or payment.

Deletion is not performed: retained schema/data compatibility and historical evidence require a separate deprecation plan. Reconnection is prohibited without an owner-final product decision.

`LEGACY_COMMERCE_AUDIT: PASS`  
`ACTIVE_ONLINE_CHECKOUT: NO`  
`O2O_CONTRACT_PRESERVED: YES`
