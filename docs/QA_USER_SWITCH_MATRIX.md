# User Switch Matrix

**State:** PROPOSED

| From → To | Must clear | Must load | Negative proof |
|---|---|---|---|
| Guest → Customer A | guest pending auth navigation as defined | A profile/cart/wishlist/locations/chat/notifications | guest data not silently attached without policy |
| Customer A → Guest | A-scoped memory/storage/subscriptions | public discovery only | no A badge/cart/message flash |
| Customer A → Customer B | A state and in-flight generations | B state from authoritative sources | A result cannot publish into B |
| Customer → future Merchant | customer-only Cubits and routes | authorized org/shop/capabilities | profile role field cannot escalate |
| Merchant shop A → shop B | shop-A listing/QR/analytics scope | shop-B authorized projection | no cross-shop write/read |
| Operator case A → case B | purpose-bound PII/evidence view | assigned case fields | broad retained clipboard/cache/search |

## Async races

Delay every scoped repository response across logout/switch, then assert generation/subject checks reject it. Realtime channels, timers, pending navigation and local preferences are recreated or cleared according to explicit ownership.

## Current evidence

Customer cart/wishlist/session regressions exist locally. Merchant/operator scope remains future server/client work. Pre-login chat draft and guest Nearby policy remain owner decisions.

`OWNER_DECISION_REQUIRED: GUEST_DATA_PROMOTION_POLICIES`
