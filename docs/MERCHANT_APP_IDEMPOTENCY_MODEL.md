# Merchant App Idempotency Model

Status: **PROPOSED — BACKEND CONTRACT REQUIRED**
Wave: 17 / WP57

| Operation | Idempotency identity | Reconciliation |
|---|---|---|
| QR confirmation | Token/session + request ID | Read terminal verification status |
| Price update | Listing + expected revision + request ID | Re-read current listing/revision |
| Availability update | Listing/batch + desired state + request ID | Read per-row outcomes |
| Listing create | Shop + canonical product/variant uniqueness + request ID | Return existing/new listing deterministically |
| Candidate submit | Candidate fingerprint + request ID | Return existing candidate/status |
| Onboarding submit | Draft/application ID + revision | Resume authoritative stage |
| Staff invitation | Org/shop + invite identity + request ID | Return current invite/membership state |

## Rules

- Idempotency keys are scoped to authenticated actor/organization operation and expire only under documented policy.
- Same key with different payload is rejected as conflict.
- Client-generated key does not authorize operation.
- Retries never skip current membership, policy or revision checks.
- Unknown timeout triggers read/reconcile before a new logical request.

Exactly-once business outcome is achieved by backend constraints/transactions, not network delivery promises.
