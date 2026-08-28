# Merchant App QR Security Model

Status: **PROPOSED — SECURITY CONTRACT REQUIRED**  
Wave: 17 / WP29

## Threats and controls

| Threat | Required control | Failure behavior |
|---|---|---|
| Expired token | Server time and expiry | Reject; ask customer for new QR |
| Replay | Atomic one-time consume | Return already used; no second transaction |
| Wrong merchant/shop | Token-bound shop + actor authorization | Fail closed without sensitive detail |
| Concurrent staff | Serializable/atomic consume + idempotent result | Exactly one verified transaction |
| Rapid duplicate scan/tap | Client debounce plus server idempotency | Same authoritative result |
| Screenshot/forwarded token | Short TTL, correct shop binding, one-time use | Usability remains but fraud window limited |
| Client clock manipulation | Never trust client clock | Server decides expiry |
| Tampered client role/shop | Server membership/capability lookup | Deny and audit |
| Network timeout | Status reconciliation | Never invite blind repeat confirmation |
| Customer logout after issue | Server session/token contract decides | No client assumption |

## Data minimization

QR contains no email, customer UUID, item details, price or secret beyond opaque high-entropy token. Confirmation response exposes only operationally necessary context.

## P0 invariants

- Token consumption and verified transaction creation are one atomic authoritative operation.
- Authorization checks actor membership, capability, shop state and token shop binding.
- Immutable evidence cannot be edited by merchant.

