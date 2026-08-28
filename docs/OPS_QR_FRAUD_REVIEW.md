# QR Fraud Review

**State:** PROPOSED — NO QR/RPC CHANGE

## Case classes

| Class | Signals | Safe response |
|---|---|---|
| REPLAY | token/transaction already consumed; repeated attempts | reject current attempt; preserve original; investigate source |
| WRONG_SHOP | confirmer shop differs from token-bound shop | reject; no fallback substitution |
| COLLUSION | coordinated customer/merchant false purchases | hold derived benefits; evidence-based fraud review |
| MASS_VERIFICATION | abnormal volume/timing/device/account pattern | rate/contain scoped capability; human review |
| STAFF_ABUSE | staff confirms without authority or across shop scope | revoke risky session/capability; merchant security case |
| FORWARDED_TOKEN | QR copied/shared remotely | expiry/shop/customer binding review; reject invalid |
| CONCURRENCY | simultaneous confirm attempts | exactly one authoritative result; others replay rejected |
| DEVICE/NETWORK_ERROR | legitimate uncertainty/late response | reconcile server state; never duplicate confirmation |

## Evidence

Immutable transaction/token IDs, creation/expiry/consume server times, customer/merchant/shop/staff identities, item/price snapshot, state transitions/RPC results, session/capability context, idempotency/concurrency evidence, device/network risk signals only where approved, and linked reports. Never store raw QR secret in operator notes.

## Decisions

`VALID_NO_ACTION`, `REJECT_ATTEMPT`, `HOLD_DERIVED_BENEFITS`, `RESTRICT_QR_CAPABILITY`, `MERCHANT/ACCOUNT_SECURITY_REVIEW`, `CORRECTION_REVIEW`, `ESCALATE`. A fraud suspicion alone does not erase a completed purchase.

## Boundary

QR review cannot manufacture transaction success, alter immutable purchase snapshot, or grant review/reward status. Corrections use the separate verified-purchase model.

`QR_FRAUD_REVIEW_FINAL: NO`

`CLIENT_QR_STATE_AUTHORITATIVE: NO`
