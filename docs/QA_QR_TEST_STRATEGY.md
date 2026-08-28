# QR Verified Purchase Test Strategy

**State:** PROPOSED — PHYSICAL GATE PRESERVED

| Layer | Required proof |
|---|---|
| Model/unit | opaque token handling, expiry display, immutable item/price snapshot mapping |
| Cubit/widget | one submit, loading lock, cancellation, timeout/unknown reconcile, disposed lifecycle |
| RPC | customer creates only own cart session; authorized merchant confirms exact shop |
| RLS/grants | token cannot expose arbitrary cart/customer data; clients cannot forge transaction |
| Concurrency | two overlapping confirmations produce exactly one verified transaction |
| Negative | replay, wrong shop, customer confirm, expired, revoked verifier, inactive shop, payload mismatch |
| Correction | no silent erase; approved superseding event preserves review/reputation history |
| Physical | real camera permission, two devices, scan, network loss, background/resume |

## Authoritative invariants

- Issuing, displaying or scanning a QR is not purchase proof.
- Server confirmation owns trusted time, actor/shop authorization and at-most-one outcome.
- Verified transaction items preserve canonical product, quantity and price snapshot despite later listing change.
- Unknown network outcome triggers authoritative read before a new logical attempt.
- Review eligibility derives from confirmed evidence and remains independent from rewards/ads.

## Current evidence

Local unit/widget and migration contracts plus an opt-in Development live harness exist. The full release gate still requires a current exact-artifact two-device run; emulator/backend-only PASS cannot close it.

`QR_AUTOMATED_CONTRACT: PARTIAL_EXISTING`

`QR_TWO_DEVICE_RELEASE_GATE: OPEN`
