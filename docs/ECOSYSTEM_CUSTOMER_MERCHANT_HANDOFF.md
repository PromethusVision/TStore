# Customer App Closeout to Merchant Capability Handoff

**State:** RECOMMENDED

## Entry criteria

- Working Customer App contracts remain backward compatible.
- Customer can identify canonical product, selected listing and intended shop.
- Auth/profile and account deletion contracts are stable.
- No release blocker is hidden behind future Merchant work.

## Handoff payload

| Customer-side fact | Merchant-side consumer | Rule |
|---|---|---|
| authenticated customer ID | QR validation | server-derived, never client-asserted |
| canonical product ID | verifier purchase item | durable historical snapshot |
| optional variant ID | listing/verification | nullable only when domain permits |
| listing/shop ID | exact-shop verifier | price/availability/listing ownership preserved |
| QR token | consume transaction | opaque, short-lived, single-use |
| callback/result state | customer refresh | retry-safe; UI is not authority |

## Minimum merchant receiver

A secure receiver needs authenticated membership, exact-shop verifier capability,
token validation/consumption, visible success/failure and audit correlation. It does
not require advanced dashboard analytics, campaigns, rewards, multi-branch transfer
or reputation badges.

## Compatibility gate

Merchant additions are additive. Older Customer builds must continue to browse and
must receive a safe unsupported/capability response instead of corrupting state.

`CUSTOMER_MERCHANT_HANDOFF: PASS`
