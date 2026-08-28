# Customer App Coverage Model

**State:** PROPOSED — CURRENT EVIDENCE MAPPED

| Area | Unit/Cubit | Repository/contract | Widget/navigation | Backend/live | Physical/release |
|---|---|---|---|---|---|
| Auth | validation, duplicate submit, session generations | PKCE/callback/config/profile/RLS | login, signup, confirmation, recovery, launch gate | opt-in Development Auth/RLS | email link and callback on exact artifact |
| Profile | state and account switch | own-profile update/delete | view/edit/delete confirmation | controlled profile/RLS | account lifecycle smoke |
| Home | section state, dedup and stale data | product/category/banner mapping | loading/empty/error/navigation | anonymous catalog reads | visual/UI-kit acceptance |
| Search | normalization, generations, partial failure | multi-source query contract | input/results/navigation | Development contract if introduced | slow-network typing |
| Location | sorting, permission mapping, timeout | geocoder/location adapter | denied/forever/settings-return | no Production mutation | real GPS and network switch |
| Product | model, purchasability, media fallback | product/seller/listing reads | details/images/sellers/reviews | Production read-only smoke | phone/tablet rendering |
| Seller | price/availability selection | shop-listing ownership | comparison/contact/navigation | contract-only | stale listing behavior |
| Shop | state and identity | shop/listing projection | profile/products/actions | anonymous read | real call/map intent |
| Wishlist | auth guard, stale/user switch | own-item CRUD | favorite/login/retry | RLS regression | upgrade persistence |
| Cart | single-shop, mutation lock, session reset | cart/QR RPC mapping | quantities/conflict/QR sheet | isolated Development only | offline/resume and artifact |
| Address | validation, ownership, user switch | saved-location RLS | CRUD/forms | isolated Development only | permission/settings return |
| Review | one-active rule, mutation lock | eligibility/RPC/storage proof | list/submit/update/delete | opt-in review integration | verified journey linkage |
| QR | token/state/retry/expiry | immutable snapshot and confirmation contract | render/status/reconcile | real concurrency in Development | two-device camera mandatory |
| Notification | pagination/read/user switch | trusted notification projection | center/badge/navigation | Realtime Development opt-in | native push is future scope |
| Chat | thread/unread/realtime generations | participant/RLS/message mapping | conversation/thread/draft | Development Realtime opt-in | background/network switch |
| Navigation | selected tab/session routing | callback/deep-link contract | bottom nav, auth guards, duplicate navigation | none required | cold/warm deep link |

## Release gaps preserved

Final UI-kit visual acceptance, taxonomy runtime rollout, signed exact artifacts, iOS archive/TestFlight, physical location and physical two-device QR remain separate gates. Current local evidence must not close them.

`CUSTOMER_CORE_AUTOMATION_BASELINE: STRONG`

`PHYSICAL_QR_GATE: OPEN`
