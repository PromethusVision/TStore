# Merchant App Sensitive Data Boundary

Status: **PROPOSED — SECURITY/PRIVACY REVIEW REQUIRED**
Wave: 17 / WP62

## Sensitive classes

- Auth credentials, session/refresh tokens and recovery artifacts.
- Merchant legal/verification evidence and private support contact.
- Staff membership/invitation/security activity.
- Raw QR tokens and restricted anti-abuse signals.
- Customer identity or individual behavioral events.
- Internal moderation notes, risk scores and policy evidence.
- Future billing/ad/reward financial data.

## Handling rules

- No server-only secret or admin credential in Flutter assets, logs or source.
- Encrypt in transit/at rest using platform controls; purpose-scoped access.
- Redact logs, crash reports, notification previews and support exports.
- Separate customer-visible, merchant-private and platform-restricted projections.
- Screenshots/clipboard for sensitive evidence should be minimized where feasible.
- Raw token/password/email is never placed in documentation/test CSV.

## Non-sensitive does not mean public

Merchant SKU, stock knowledge and internal activity may not be legally sensitive but remain private competitive/operational data and are never shared cross-merchant.
