# Merchant App QR Confirmation Context

Status: **PROPOSED — DATA MINIMIZED**  
Wave: 17 / WP35

## Merchant needs to see

- Active shop/branch.
- Safe product/variant display snapshot and item count.
- Quantity/sell unit and price/line context when present in authoritative session.
- Token/session status and expiry urgency.
- Clear statement: physical purchase verification, not payment.

## Merchant must not see by default

- Customer email, phone, UUID, address, exact profile or unrelated purchase history.
- Raw token, internal policy details or review entitlement internals.
- Another shop's private listing data.
- Payment credentials because payment is outside scope.

## Confirmation affordance

- Explicit primary action with target shop and total item count.
- Safe cancel/back creates no write.
- Large/ambiguous item sets require review rather than single accidental tap.
- Server response determines success; local animation cannot.

Whether customer display name is ever operationally necessary is `OWNER_DECISION_REQUIRED`; recommendation is omit in V1.

