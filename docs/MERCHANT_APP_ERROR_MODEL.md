# Merchant App Error Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP55

| Class | Meaning | Retry | UX |
|---|---|---|---|
| NETWORK | Connectivity/transport failed | Only safe/idempotent operations | Preserve draft; connection guidance |
| AUTH | Session absent/expired | Re-auth then reconcile | Do not discard unknown writes |
| PERMISSION | Membership/capability/scope denied | No blind retry | Explain authorized shop/task boundary |
| POLICY | Shop/product/action blocked | No client bypass | Safe reason and remediation/support |
| NOT_FOUND | Target absent or no longer visible | Refresh context | Avoid leaking cross-shop existence |
| CONFLICT | Revision, duplicate or concurrent outcome | Read authoritative state | Compare/reconcile |
| VALIDATION | Input invalid/incomplete | After correction | Field-level plain Turkish |
| TEMPORARY | Server dependency unavailable | Bounded idempotent retry | Status and later retry |

## Result certainty

Every mutation error also carries outcome certainty: `NOT_SENT`, `REJECTED_NO_WRITE`, `COMMITTED`, or `UNKNOWN_REQUIRES_RECONCILIATION`. Generic “Bir hata oluştu” must not invite duplicate QR/listing/price operations.

## Safety

Messages never expose raw exceptions, tokens, internal IDs, another merchant's data or policy bypass detail. Logs use correlation IDs and safe reason classes.
