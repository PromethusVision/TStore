# Backend Development Acceptance Plan

**State:** PLAN ONLY — DEVELOPMENT NOT ACCESSED

## Entry gates

- integrated task branch, approved migration owner and immutable artifact hash;
- Development project identity independently verified and Production excluded;
- fresh migration/schema/data/Auth/Storage baseline and restore plan;
- clean-room migration, rollback/forward-repair and N/N-1 tests passing;
- disposable fixture namespace and exact cleanup contract approved.

## Acceptance sequence

1. Record authoritative preflight counts and migration ledger.
2. Apply the exact integrated migration through the approved mechanism.
3. Verify schema, grants, RLS, RPC signatures and intended backfill counts.
4. Run anon/customer/merchant/staff/operator positive and negative matrices.
5. Exercise idempotency and real two-connection concurrency.
6. Run current Customer build plus candidate Customer/Merchant builds.
7. Run physical two-device QR only when the wave changes that contract.
8. Validate audit/error/monitoring evidence without logging PII or tokens.
9. Clean exact disposable fixtures; verify residual counts.
10. Soak, record unexpected findings and decide forward/rollback before Production.

Any project mismatch, unexplained drift, cross-tenant access, duplicate verified
purchase, review eligibility regression, residual fixture or rollback uncertainty
is a STOP condition. This document grants no remote access or apply authority.
