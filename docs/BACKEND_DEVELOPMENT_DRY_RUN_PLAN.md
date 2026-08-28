# Backend Development Dry-Run Plan

**State:** PLAN ONLY — NOT EXECUTED

1. Start from canonical 0001–0009 in an isolated clean-room database.
2. Load deterministic synthetic legacy/current fixtures covering null, collision,
   lifecycle, policy and maximum-cardinality samples.
3. Apply the proposed migration artifact exactly once, then repeat when
   idempotency is expected.
4. Run schema/constraint/grant/RLS/RPC inventories and old/new client contract tests.
5. Execute backfill dry run, partial interruption/resume and reconciliation counts.
6. Test N/N-1 Customer App plus proposed Merchant App caller overlap.
7. Run authorization negatives, concurrency, lock/runtime and query-plan checks.
8. Simulate rollback/forward correction and verify historical identities.
9. Exercise demo/real/test separation and no secret/PII leakage.
10. Produce signed-off evidence with exact commit, migration hash and unresolved rows.

Development remote use, if later authorized, follows exact project identity and
fixture cleanup. This document performs no local or remote database execution.
