# Customer App Realtime Lifecycle Audit

Status: PASS

## Notifications

- A broadcast controller creates one uniquely named customer-filtered channel per listener lifecycle.
- Insert/update events are filtered by `user_id`, parsed safely, and deduplicated by notification ID.
- Controller cancellation unsubscribes the exact channel.
- Cubit refresh cancels the old subscription before clearing/reloading and `close` awaits cancellation.
- Realtime revision counters prevent old page data from undoing newer events.

## Chat

- Repository uses stream generation and current-session checks to invalidate a prior customer's/receiver's stream.
- Cubit starts at most one message subscription and cancels it on close/restart.
- Realtime messages merge by ID, preserving read-state updates without duplicates.
- Pagination/silent refresh snapshot reconciliation preserves newer realtime content.
- View timers pause in the background and resume with an immediate authoritative refresh.

Supabase's socket ownership is shared by the initialized client; feature channels are still explicitly unsubscribed. No duplicate active-subscription or memory-leak defect was reproduced.

`REALTIME_LIFECYCLE_AUDIT: PASS`
`DUPLICATE_SUBSCRIPTION_FOUND: NO`
