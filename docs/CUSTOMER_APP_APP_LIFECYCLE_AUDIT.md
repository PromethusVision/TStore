# Customer App Lifecycle Audit

Status: PASS

| Transition | Behavior |
| --- | --- |
| Cold start | Validated backend → Supabase → DI → launch loading → onboarding/Home; initial Auth URI inspected. |
| Warm Auth deep link | Root callback listeners process exact callback events and deduplicate navigation. |
| Background | Chat/navigation periodic unread refresh stops; camera/route resources remain route-owned. |
| Resume | Chat/unread state performs immediate silent reconciliation then restarts timers. |
| Return from location settings | Nearby rechecks service/permission only when a settings refresh was requested. |
| Session refresh | Same user remains loaded; account identity change clears customer-scoped local state. |
| Session expiry | Protected back stack is removed; customer state clears and a safe message appears. |
| Delayed async completion | Critical views/Cubits use mounted, generation, request-ID, or closed guards. |

Location is never tracked in the background. Realtime feature subscriptions are route/Cubit-owned and unsubscribe on close. No background service or push-notification lifecycle exists in Customer V1.

`APP_LIFECYCLE_AUDIT: PASS`
`BACKGROUND_LOCATION: NO`
`STALE_RESUME_BLOCKER: NO`
