# Customer App Resource Lifecycle Audit

Status: PASS

## Inventory/result

- Text editing controllers: disposed in Auth, profile, saved-location, review, chat, and search forms.
- Focus nodes: disposed in Home/full search; keyboard state is not retained after route disposal.
- Scroll/page controllers: route/Cubit-owned and disposed; onboarding Cubit closes its page controller.
- Timers: QR status/countdown, purchase retry, chat/unread refresh, verification cooldown, and settings timers are cancelled on close/dispose/background as applicable.
- Stream subscriptions: Auth listeners, chat, notifications, scanner, and repository realtime channels have cancellation paths.
- Camera: scanner stream/controller is cancelled/disposed with the verifier route.
- Lifecycle observers: Nearby, Chat, Conversations/Navigation register and remove themselves.
- Location: one-shot calls use bounded service futures; no background watcher is retained.

Delayed UI callbacks generally check `mounted`; critical Cubits check `isClosed`/generation where responses can arrive after disposal. The unreachable legacy postal Cubit lacks modern guards and must be remediated before any revival.

`RESOURCE_LIFECYCLE_AUDIT: PASS`
`ACTIVE_RESOURCE_LEAK_FOUND: NO`
