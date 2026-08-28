# Merchant App Simplification Review

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP113

## Simplify now

- Show `OWNER` and task-based `STAFF` presets; defer full role builder.
- Keep one active shop context and hide organization jargon for single-shop users.
- Use four core daily actions: QR, product search/add, price, availability.
- Do not require exact inventory; use known in/out/unknown/temporary.
- Allow only bulk availability in V1; defer bulk price/retire/branch sync.
- Dashboard is action-first; remove custom reports/charts/exports.
- Reviews are read/report; replies deferred.
- Service/mixed merchants may manage presence, not booking/service catalog.
- Listing media is optional and can defer if moderation/storage is not ready.
- Future ads/reward/gamification surfaces remain invisible.

## Complexity that cannot be removed

Organization/shop scope in backend, server authorization, catalog layer separation, QR atomicity/reconciliation, regulated fail-closed state, immutable review evidence and two-device acceptance are essential even if UI stays simple.

## Outcome

The 16 MUST capabilities remain commercially coherent; seven SHOULD capabilities can be staged without weakening security/trust.
