# Shared notification and push foundation V1

## Reused architecture

`NotificationEntity`, `NotificationRepositoryImpl`, `NotificationsCubit`, the
`notifications` table and the existing Realtime stream remain the only in-app
notification system. Existing order/chat records, read-state handling, ownership
checks and database triggers are preserved. No new business event or QR trigger
was introduced.

Customer and merchant share `NotificationAppRole`, `MobilePushProvider`,
`PushCoordinator`, device registry and preferences interfaces. Marketing starts
OFF. Customer notification settings expose service and marketing controls;
`NotificationPreferencesView` also accepts a merchant session. They currently
persist per account/role on the device and explicitly say they are not synced.
This is not a claim that mobile delivery is active or that required account/legal
notices can be disabled.

`NotificationEntity.engagementTarget` validates product/shop/category UUIDs,
bounded search queries and reward/messages/notifications targets. Existing
order/chat routes are preserved. Reward/messages/inbox destinations reuse their
existing screens through an auth gate; no payload can grant auth or a role.
`buildNotificationDestination(appRole: ...)` is shared; merchant order events
remain readable in the inbox instead of opening customer purchase history.
The legacy-named inbox widget accepts `appRole` for reuse by a merchant host.

## Prepared database and server contracts (not deployed)

`supabase/proposals/0016_engagement_foundation.sql` is an additive draft, outside
the automatic migration directory. It extends existing banners and adds:

- `push_devices`: installation UUID, user, app role, token, platform, enabled,
  last seen and creation/update timestamps. No client SELECT or direct writes.
- `notification_preferences`: own-row SELECT only; updates through an ownership
  checked RPC. Server defaults marketing to false.
- `push_deliveries`: server-only, unique notification/installation/role claim.
  No raw provider error, body or token is recorded in delivery outcomes.

The three callable RPCs derive user ID from `auth.uid()` and verify the current
profile role. All definer functions have `search_path=pg_catalog`, fully qualified
references and revoked PUBLIC/anon execution. A caller cannot register another
user, change their profile role, steal an active installation or list tokens.
Token collisions return a generic error. Token rotation replaces the same device
record; disabling is limited to its owner. No client notification INSERT grant
or canonical-table grant is added. Existing deployed migrations are unchanged.

`SupabasePushBackend` implements these contracts but defaults to undeployed and
is not registered for runtime use. The server-only dispatcher in
`tool/engagement/push_delivery.mjs` accepts a trusted notification ID, rechecks
the authoritative recipient/role/preferences/campaign and sends generic
lock-screen copy. Its store/provider ports are tested mocks, not a deployed
queue or endpoint. A store implementation must acquire the durable claim
atomically, recheck enabled ownership at dispatch, and update only that claim.
Uncertain/failed sends require controlled reconciliation, never blind duplicate
retry. Invalid tokens are disabled without retaining raw provider errors.

## External setup still required

**PUSH_PROVIDER_EXTERNAL_CONFIG: PENDING.** No Firebase mobile config or APNs
credentials were available. No Firebase dependency, platform build configuration,
server key or permission prompt was added. `UnconfiguredMobilePushProvider`
performs no network request and returns unavailable.

For a separately authorized integration:

1. Supply the matching Android/iOS Firebase app config and APNs setup; add the
   mobile SDK adapter only then. Preferred transport is FCM, with APNs via Firebase.
   Server access credentials must come from a server secret manager/environment.
2. Review/rehearse/deploy the draft database contract. Implement the trusted
   server store/queue and FCM provider, including rate limits and retry policy;
   no mobile client may call privileged FCM endpoints.
3. Generate/persist a random installation UUID locally. Wire one coordinator per
   authenticated app session; explicitly request permission from a user action.
   Serialize rotation; await `disable()` **before** logout/account switch. If
   revocation fails, do not reuse that token for a new identity. Server ownership
   and current profile role remain authoritative.
4. Reconcile local preferences before enabling delivery. Do not silently convert
   local marketing state into cross-device consent. Load server consent and
   obtain any required explicit opt-in. Handle denied OS permissions/settings.
5. Map cold-start/foreground taps to `PushOpenEvent`; fetch the existing record
   via the authenticated lookup, verify account/role again after awaits, then
   use the common destination builder. Integrate the same ports in the merchant
   entry point; this repository does not contain a separate merchant app shell.
6. Physically verify Android/iOS foreground, background, terminated, logout,
   account-switch, token-expiry and opt-out behavior with non-production fixtures
   before authorizing rollout.

Local validation uses only synthetic identities in in-memory PostgreSQL (PGlite
0.5.5) and mocked provider delivery. No Production or Development connection,
notification send, asset upload or deployment is part of this batch.
