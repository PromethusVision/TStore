# Manual Database Operation Risk

**State:** ANALYSIS — NO DATABASE OR SUPABASE ACTION

## Why routine SQL is unsafe

Arbitrary row edits bypass domain invariants, RLS/RPC intent, validation, version/conflict control, policy gates, audit reason/evidence, dependency impact, idempotency, appeals, and deterministic projection repair. A typo or broad predicate can create irreversible cross-system corruption.

## Highest-risk examples

- changing Auth/profile/merchant role or operator access;
- marking merchant verified or product policy allowed;
- editing/deleting QR/verified transactions;
- setting review/reputation/reward state;
- merging/splitting/reclassifying catalog identity;
- mass listing/suspension changes;
- changing ad budget/billing events;
- deleting audit, evidence, cases, or Storage objects;
- cross-environment/ref confusion.

## Future safe operation contract

Dedicated server-authoritative command; exact stable IDs/environment; authorization and case; precondition/revision; impact preview/count; reason/evidence/policy version; dry-run for bulk; transaction/idempotency; append-only audit; postcondition reconciliation; reversal/superseding path; independent review for high risk.

## Emergency break-glass

If manual database action is ever unavoidable during an explicitly authorized incident, require exact scope, peer/owner approval where possible, verified target environment, backup/rollback assessment, captured before/after query counts, no secret logging, and immediate audit/postmortem. This document does not authorize it.

## Recommendation

Use Supabase dashboard/SQL for read-only diagnosis within permission and for separately reviewed migrations—not routine case handling. Build the smallest safe operations command instead of teaching operators ad hoc SQL.

`ROUTINE_MANUAL_PRODUCTION_EDITS: PROHIBITED`

`DATABASE_TOUCHED: NO`
