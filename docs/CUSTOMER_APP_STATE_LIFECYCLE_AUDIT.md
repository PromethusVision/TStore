# Customer App State Lifecycle Audit

Status: PASS

## Lifetimes

- Application-scope providers: Auth, product/category/brand/banner, Cart V2, Wishlist, onboarding, navigation, and banner carousel. They are created by `MultiBlocProvider` and disposed with `TStore`.
- Route-scope factories: search, Nearby, profile, saved locations, purchases, reviews/ratings, QR, chat, unread, and notifications. View `BlocProvider` ownership closes them on route disposal.
- Repositories/use cases/services are lazy singletons and should remain stateless or derive the current Auth user at call time.

## Session isolation

- `CustomerSessionListener` tracks active user ID, clears Cart/Wishlist/navigation on logout or account switch, and reloads only for the new customer.
- Repositories for notifications/chat and other customer tables capture/check the current user around async work; backend RLS is still authoritative.
- Route-scoped profile/notification/chat/review/address states disappear when automatic session expiry removes the back stack.
- Same-user token refresh does not unnecessarily clear local data.

## Resource/subscription lifecycle

- Chat and notification Cubits cancel stream subscriptions in `close`.
- Chat/Navigation views pause timers when backgrounded and restart/reconcile on resume.
- Nearby registers/removes its lifecycle observer and refreshes permission state only after settings flow.
- QR timers, scanner subscription/controller, text/focus/scroll controllers, and delayed retry timers have disposal paths.

No singleton Cubit registration, duplicate active realtime subscription, or proven cross-user state leak was found.

`STATE_LIFECYCLE_AUDIT: PASS`  
`CROSS_USER_GLOBAL_STATE_LEAK: NONE_FOUND`
