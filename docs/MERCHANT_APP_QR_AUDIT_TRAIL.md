# Merchant App QR Audit Trail

Status: **PROPOSED — NO SCHEMA IMPLEMENTATION**
Wave: 17 / WP36

## Audit events

- Token validation requested/result class.
- Confirmation requested, authoritative success/conflict/rejection.
- Replay, wrong-shop, expiry, permission and policy denials.
- Status reconciliation after timeout.
- Actor membership/shop scope changes relevant to dispute review.

## Minimum fields

- Event ID, server timestamp, request/idempotency identifier.
- Safe token fingerprint/session reference; never raw token.
- Actor auth reference and membership/role snapshot under restricted access.
- Organization/shop/branch scope.
- Result/reason class and linked verified transaction when successful.
- Client/app version and coarse network/result diagnostics when justified.

## Retention/access

- Ordinary staff sees only operational outcome necessary for assigned shop.
- Owner/support/security access is purpose-limited and audited.
- Immutable verified evidence is distinct from noisy scan-attempt telemetry.
- Retention periods and export/deletion obligations require privacy/legal owner decision.

## Invariants

Audit records do not grant review rights; verified evidence does. Merchant cannot edit/delete success evidence or relabel a denial as success.
