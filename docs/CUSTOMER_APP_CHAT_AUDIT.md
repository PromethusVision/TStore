# Customer App Chat Audit

Status: PASS FOR CUSTOMER IN-APP CHAT CONTRACT

## Conversation list

- Authenticated conversations load with real shop context; raw technical IDs are not shown if shop enrichment fails.
- Duplicate refresh is suppressed and silent-refresh failure keeps visible content.
- Unread count is refreshed only for an authenticated visible app and resets for guests.

## Thread behavior

- Messages are paginated and merged by stable identity with deterministic chronological presentation.
- Realtime updates replace the same message when read state changes rather than duplicating it.
- Late initial/older/silent refresh responses do not erase newer realtime messages.
- Subscription/controller/timer/scroll/text resources are cancelled or disposed.
- Empty messages and content over 1,000 characters are rejected before the repository.
- Send lock prevents double submit; failed send preserves the editable draft.
- Background lifecycle pauses periodic refresh and resume performs an immediate reconciliation.
- Product-origin chat opens an editable draft and never auto-sends it; abandoned/login-cancelled pending context is cleared.

Inactive/deleted shop handling is customer-safe at discovery/enrichment boundaries. End-to-end delivery against a live customer/merchant pair is outside this no-remote-write wave.

`CHAT_AUDIT: PASS`
`DUPLICATE_MESSAGE_PROTECTION: PASS`
`REMOTE_CHAT_FIXTURE: NO`
