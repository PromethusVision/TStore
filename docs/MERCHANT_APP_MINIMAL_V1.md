# Merchant App Minimal V1

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP86

## Esenler pilot must-have — 16 capabilities

1. Secure auth/session and no environment fallback.
2. Merchant organization/shop membership resolution.
3. Explicit active shop context.
4. Server-side scoped roles/capabilities.
5. Guided onboarding with fail-closed policy state.
6. Customer-visible shop profile, location and lifecycle management.
7. Canonical catalog search.
8. Shop listing create/edit.
9. Price editing with revision/audit.
10. Honest availability semantics.
11. Missing/custom product candidate flow.
12. Barcode-assisted search without blind identity creation.
13. Physical QR scan/validation/confirmation.
14. QR expiry/wrong-shop/replay/concurrency/reconciliation behavior.
15. Security/activity history for critical operations.
16. Critical merchant notifications/action-required inbox.

## Pilot-safe simplification

Owner-first single-shop UX, optional narrow QR/catalog staff only if operations require it, no exact stock, no bulk price, no review reply, no ads/rewards/gamification, no online checkout/shipping/ERP.

## Non-negotiable gate

QR and authorization backend contracts, regulated fail-closed behavior, customer projection consistency, exact live-fixture cleanup and two-device physical acceptance.
