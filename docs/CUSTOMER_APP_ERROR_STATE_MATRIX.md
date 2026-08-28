# Customer App Error State Matrix

Status: PASS WITH DEFERRED EXTERNAL STATES

Legend: `Y` explicit/covered, `N/A` not a meaningful state, `B` backend/manual boundary.

| Feature | Loading | Success | Empty | Error | Retry | Offline | Unauthorized | Not found |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Startup/onboarding | Y | Y | N/A | fail-open discovery / fail-closed config | build/config retry | B | N/A | N/A |
| Auth/recovery/confirmation | Y | Y | N/A | Y | Y | safe mapped | Y | invalid-link state |
| Profile | Y | Y | partial-safe | Y | Y | safe mapped | login/session path | missing-profile repair |
| Home/categories/products | Y | Y | Y | Y | Y | safe mapped | public | invalid IDs blocked |
| Seller/shop | Y | Y | Y | Y | Y | safe mapped | public/login for actions | invalid/inactive hidden |
| Search | Y | Y | Y | total/partial | Y | safe mapped | public | invalid result hidden |
| Nearby/location | Y | Y | Y | Y | Y | shops retained | policy open | unavailable location handled |
| Wishlist | Y | Y | Y | Y | reload/action retry | safe mapped | login gate | deleted product hidden |
| Cart V2 | Y | Y | Y | Y | refresh/action retry | snapshot retained | login/session path | unavailable item state |
| Saved locations | Y | Y | Y | Y | Y | safe mapped | login/session path | mutation failure preserved |
| Purchases/ratings | Y | Y | Y | Y | Y | safe mapped | login/session path | QR recovery bounded |
| Reviews | Y | Y | Y | Y | Y | safe mapped | guest/unverified distinct | deleted review refresh |
| QR session | Y | Y | N/A | expired/cancelled/connectivity | bounded renew/retry | QR retained when safe | login required | missing summary hides QR |
| Notifications | Y | Y | Y | top/append/action | Y | visible list retained | guest zero/login | deleted action target safe |
| Chat | Y | Y | Y | initial/action/refresh | Y | thread/draft retained | login required | shop enrichment safe |

Functional retry/state gaps were not reproduced in active routes. Visual consistency between older and newer empty/error components is `UI_KIT_DEFER`.

`ERROR_STATE_MATRIX: PASS`  
`FUNCTIONAL_RETRY_BLOCKER: NO`
