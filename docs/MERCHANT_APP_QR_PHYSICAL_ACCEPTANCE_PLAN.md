# Merchant App QR Physical Acceptance Plan

Status: **PROPOSED — TWO PHYSICAL DEVICES REQUIRED FOR PASS**
Wave: 17 / WP82

## Setup

- Device A: Customer App, normal customer principal.
- Device B: Merchant App, authorized verifier at target shop.
- Development isolated environment first; Production only separately authorized release gate.
- Unique fixture prefix, no server secret in either app, exact cleanup plan.

## Acceptance matrix

1. Camera permission and real QR read.
2. QR payload inspected as opaque/no sensitive data.
3. Active token validates; safe context matches shop/items.
4. Successful confirmation creates exactly one verified transaction/items.
5. Customer UI refreshes authoritative success.
6. Wrong merchant/shop rejected without consume.
7. Expiry at approximately current two-minute contract rejected.
8. Replay rejected/no second transaction.
9. Two verifier devices confirm concurrently; exactly one transaction.
10. Network loss before/after submit reconciles correctly.
11. Inactive shop/revoked verifier fail closed.
12. Durable product ID snapshot and review entitlement contract preserved.

Emulator-only or backend-only verification never closes physical gate.
