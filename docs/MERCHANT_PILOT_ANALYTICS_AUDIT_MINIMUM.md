# Merchant Pilot Analytics and Audit Minimum

State: `PROPOSED — ACTION-FIRST`

## Merchant-facing minimum

Gelişmiş chart gerekmez. Merchant şu operasyonel sinyalleri görebilir: active listing count, stale/unknown listing action count, son QR sonuçları, unresolved support case ve catalog candidate status. View, direction veya QR count “satış/gelir” olarak etiketlenmez.

## Internal health

Pilot ops gözlemi: active onboarded shop, merchant login success/failure, listing mutation success/conflict, stale listing rate, QR preview/confirm/reconcile result, replay/wrong-shop/expiry, critical client error, support volume/age ve policy holds.

## Audit minimum

High-risk event: immutable event ID, actor/role, shop/listing/session reference, action, timestamp, before/after or result class, reason/source, correlation ve policy/version. Raw QR token, password, auth token, customer email/phone veya exact location audit payloadına girmez.

## Separation

Product analytics, operator audit ve security telemetry aynı amaç gibi kullanılmaz. Test/demo traffic işaretlenir; dashboard metriği server authority'nin yerini tutmaz.

