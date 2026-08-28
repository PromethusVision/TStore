# Merchant App Shop Lifecycle

Status: **PROPOSED — OWNER REVIEW REQUIRED; NO DB ENUM**  
Wave: 17 / WP13

## Conceptual states

| State | Customer visibility | Merchant operations |
|---|---|---|
| DRAFT | Hidden | Onboarding/profile edits |
| PENDING_REVIEW | Hidden | Safe corrections; no publication |
| ACTIVE | Visible subject to listing state | Normal authorized operations |
| TEMPORARILY_CLOSED | Visible with closure indication or reduced discovery | Maintenance; QR confirmation recommendation requires owner decision |
| SUSPENDED | Hidden/restricted by platform | No customer-affecting writes except remediation |
| CLOSED | Not discoverable as active | Historical evidence retained; no new QR/listings |
| REJECTED | Hidden | Appeal/support path only |

## Transition principles

- Transitions are server-authoritative, audited and reasoned.
- Merchant can request activation/temporary closure/closure; platform policy can suspend/reject.
- Closing a shop does not delete historical verified purchases or review evidence.
- Reactivation revalidates membership, location and applicable policy.
- Listing availability cannot make a suspended shop customer-visible.
- Cached ACTIVE state does not authorize QR or mutation after server state changes.

## Open decisions

- `LIFE-01 P0`: QR confirmation policy during `TEMPORARILY_CLOSED`.
- `LIFE-02 P1`: Customer visibility and message for permanently closed shops with historical reviews.
- `LIFE-03 P1`: Self-service reactivation eligibility.

