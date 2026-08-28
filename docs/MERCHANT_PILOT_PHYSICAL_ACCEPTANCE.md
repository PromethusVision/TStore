# Merchant Pilot Physical Acceptance

State: `MANUAL GATE — NOT EXECUTED`

## Required setup

- Exact signed release-candidate Android artifact and recorded hash/build/commit/environment.
- Independent customer and merchant accounts/sessions on two physical devices.
- Two distinct verified shops for wrong-shop tests.
- Isolated synthetic Development fixtures; no Production mutation.
- Camera permission controls and controllable network conditions.

## Must-pass journeys

1. Merchant login, exact shop identity and active status.
2. Listing price/availability update reflected according to contract.
3. Customer creates QR from exact shop cart; merchant scans real screen with camera.
4. Preview matches shop/items/quantities/snapshot; explicit confirm succeeds once.
5. Replay, wrong merchant/shop, customer confirm and expired QR reject.
6. Real concurrent confirm from two authorized sessions yields one winner/one transaction.
7. Timeout after confirm reconciles to authoritative status without duplicate side effect.
8. Camera denied/denied forever, background/resume, screen lock, rotation and app restart behave safely.
9. Wi-Fi/mobile switch, slow network and disconnect during preview/confirm preserve truth.
10. Logout/user/shop change removes cached preview/history.

## Evidence

Record artifact hash, device/OS, accounts/shops as synthetic identifiers, timestamps, case/test IDs, expected/actual and server transaction correlation. Never record QR token, password or customer PII.

## Acceptance boundary

Windows compile, mocks or one-device scan cannot mark this gate PASS. Signed artifact and real devices remain future human work.
