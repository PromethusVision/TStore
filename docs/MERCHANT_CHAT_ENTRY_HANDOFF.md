# Merchant customer messaging access — integration handoff

Task branch: `agent/merchant-chat-entry-push`.

Base: integrated `33374066` (Merchant product-card photo repair). Work date:
23–24 October 2026. Integration Agent owns main merge. No hosted access/write.

## Problem and implementation

The production Merchant composition did not inject the existing chat repository
and exposed no customer conversation entry. The initial dashboard entry probe
failed (`.buildlog/chat-reproduced.log`). The completed tests use explicit Merchant
chat composition; unconfigured preview fixtures remain unchanged.

- Add Messages with actual unread count to the dashboard and Customer messages
  to Account. Preserve all five tabs. Refresh counts from the shared notification
  events and foreground reconciliation; no independent inbox or push system.
- Reuse the shared conversation list, thread, composer, read receipts, paging,
  send lock and Realtime implementation. Optional Merchant wording/icon parameters
  default to the unchanged Customer behavior. No Customer service-locator setup
  in Merchant; the runtime injects the existing repository explicitly.
- Create a separate repository instance per reader/route: the existing repository
  owns one Realtime subscription and must not be shared between simultaneous
  readers. The route wrapper fences operations and responses with the existing
  Merchant host authority revision, stable Auth session, owner and shop.
- A normal token renewal retains the current draft. A replacement session closes
  the private navigation scope and ignores stale results/events. Reads have a
  bounded deadline; pending writes are not reported as cancelled or auto-replayed.
- Already-read chat notifications remain actionable. The destination re-reads
  participant-owned conversation summaries before creating a composer. Unknown
  peers never acquire a composer, message read or read mutation. Other push events
  retain the inbox destination. A validated tap closes a nested route safely.
- Review found and reproduced a new event-state issue: after a fresh session and
  explicit provider reconnection, an equal notification was suppressed by the
  navigation notifier. `.buildlog/chat-reconnect-reproduced.log` contains the
  failing assertion. The notifier now emits validated events independently of its
  last selection; deduplication remains in the existing PushCoordinator. The new
  regression passes, including connection cleanup and re-enrollment.

## Contract and product boundaries

The existing `get_customer_conversations` and unread RPCs derive `auth.uid()` and
are participant based despite their historical names. No new SQL or profile-read
grant is needed. Their summaries do not return customer profile names: unknown
names appear as **Müşteri görüşmesi** with the existing last-message preview.
No invented names, raw account IDs, customer directory or arbitrary recipient
entry are added. Server RLS remains authoritative.

Canonical §12.5 and slices I2 record the owner-requested messaging repair and the
change from inbox-only to validated chat navigation. Default-OFF business/provider
capabilities and generic lock-screen copy remain unchanged. No dependency,
credentials, Firebase account, provider SDK or deployed worker was added.

## Verification

- Targeted Merchant repository/workflow/push and shared Customer chat tests:
  **121 PASS, 0 FAIL** (`.buildlog/chat-targeted-final.log`). Covers replies, pending
  duplicate taps, read failure/retry/deadline, same-account replacement, between-
  frame replacement, ordinary renewal, unread events and notification destinations.
- Full Flutter regression: **3697 PASS, 0 FAIL, 6 existing conditional SKIP**
  (`.buildlog/chat-full-verified.log`). No new skips or weakened tests.
- `flutter analyze --no-pub`: **PASS, no issues**
  (`.buildlog/chat-analyze-verified.log`).
- Existing service-dispatch contract: **29 PASS**, no real provider send
  (`.buildlog/chat-push-contract.log`).
- Dashboard and thread screenshots inspected at 390/320 px; thread states also
  exercised at 130% text. Private evidence: `.buildlog/chat-visual/`. No overflow
  exceptions; existing Customer goldens are unchanged.
- Customer + Merchant Android debug compile rehearsal: **PASS**; configuration
  and compatibility checks: **135 PASS, 0 FAIL, 0 SKIP**. Manifest, certificate,
  package identity, version and payload checks passed; sources stayed unchanged.
  Final evidence: `.buildlog/pilot-device/merchant-chat-delivery/pair.json`.
  Synthetic client inputs only; these are not distributable pilot APKs.
  Source SHA-256: `936a4d637e4cda41b3972d8d007f06a78d353703098ce14cce1be522d666bb71`.
  Customer APK SHA-256: `9131280de182621f4be4b5a434fcecfea333c626ff67797832edab7a80ec02aa`.
  Merchant APK SHA-256: `35a7fb429fb1f3b7106689ca0a2839dfaa6436a21004a89231a0ada8f1f2d8e3`.
- Added-line/new-file secret/PII scan and `git diff --check`: **PASS**.
  Logs and APKs remain ignored local artifacts.

The earlier `chat-full-final`/`chat-analyze-final`/`merchant-chat-final` runs were
interrupted by the execution environment and are not final acceptance evidence.
The subsequent `merchant-chat-verified` attempt refused a stale task-owned build
lock. Its process was confirmed absent before clearing that one lock. Only the
completed evidence paths listed above count for delivery.

## Integration and remaining acceptance

Shared areas: chat conversation cubit and views, Merchant runtime/service wiring,
Merchant root navigation/notification handling, canonical and slices documents.
No shared Customer Auth changes, migration, provider implementation or old golden
image edits. The primary checkout and previously delivered APK pair are preserved.

This package completes local Merchant messaging access, **not OS push delivery**.
The repository still uses `UnconfiguredMobilePushProvider`; real Firebase bindings,
trusted server dispatch and a deployed worker remain pending. Existing SQL proposals
are not assumed installed. See [concrete Development setup scope](MERCHANT_CHAT_PUSH_SETUP_SCOPE.md)
before any external setup or test sends. No Production/hosted Development access or
write and no migration apply occurred. Pilot opening is not declared.

Only necessary physical gates after integration and an approved installable build:

1. Customer sends a message; Merchant opens Messages, replies, and the Customer
   sees one reply. Reopen both conversations and confirm unread counts recover.
2. After separately approved provider setup, verify Android foreground/background/
   closed-app notification display and tap-to-conversation on the intended account.

The current task does not require the owner to be at the phones for integration.
