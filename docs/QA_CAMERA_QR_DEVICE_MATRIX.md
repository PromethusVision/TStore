# Camera and QR Device Matrix

**State:** PROPOSED — PHYSICAL TWO-DEVICE REQUIRED

| Dimension | Cases |
|---|---|
| Permission | not requested, allow, deny, deny forever, settings return, revoke while backgrounded |
| Camera hardware | rear camera, autofocus delay, low light, damaged/low-resolution camera where available |
| QR presentation | another phone, printed code, brightness low/high, rotation, partial/out-of-frame |
| Token | active, expired, malformed, replayed, wrong shop, revoked verifier |
| Network | offline before validation, drop during confirmation, timeout after unknown outcome |
| Lifecycle | scanner background/resume, app process recreation, duplicate route open |
| Concurrency | two verifier sessions truly overlap; one transaction maximum |

## Safety assertions

Scanner treats payload as opaque and never logs/displays raw token. It validates only through the server contract, throttles duplicate frames, releases camera/subscriptions on dispose and prevents two in-flight confirmation navigations.

## Minimum physical arrangement

Device A runs the exact Customer candidate and displays QR. Device B runs the authorized Merchant/verifier candidate or controlled verifier client. Wrong-shop/concurrency requires an additional independent merchant/session where practical. Fixture cleanup and immutable transaction evidence are recorded without secrets.

`CAMERA_QR_EMULATOR_ONLY_PASS_ALLOWED: NO`
