# Merchant App Information Architecture

Status: **PROPOSED — NOT FINAL UI**
Wave: 17 / WP52

## Recommended V1 destinations

1. **Özet:** action-required and operational dashboard.
2. **Ürünler:** canonical search, listings, price/availability, candidates.
3. **QR:** prominent scan/confirm flow and safe recent outcomes.
4. **Yorumlar:** read/report; response only if later approved.
5. **Mağaza:** profile, location, status, staff/security/settings.

Notifications use a global inbox/access point. Active shop switch is global and persistent when multi-shop applies.

## Navigation rules

- QR remains reachable in one primary action from operational surfaces.
- Deep links resolve auth/membership/shop before content.
- A pending draft or unknown QR outcome blocks unsafe context switch with clear choice.
- Owner-only settings are hidden for clarity but still server-protected.
- Future ads/rewards do not occupy V1 primary navigation.

## Alternatives

A four-tab layout combining Reviews into Özet may reduce complexity for pilot. Exact tab count/order is `OWNER_DECISION_REQUIRED`; this document defines information boundaries only.
