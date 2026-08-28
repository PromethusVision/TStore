# Future Catalog Implementation Sequence

Status: **ANALYSIS-ONLY RECOMMENDATION — NO IMPLEMENTATION AUTHORITY**
Wave: 16, Work Package 49

| Phase | Entry condition | Work | PASS criteria | STOP criteria |
| --- | --- | --- | --- | --- |
| 1. Owner decisions | Wave 16 evidence accepted for review | Resolve P0 product/variant, review, purchase, merchant, variable-measure and policy decisions | Signed decision ledger; no contradictory root rules | Any unresolved P0 needed by schema |
| 2. Stable identity contract | Decisions complete | Finalize opaque IDs, aliases, predecessor/successor and field ownership | Contract tests/spec review | Identity conflated with taxonomy/listing |
| 3. Minimal schema design | Identity frozen | Design additive product/variant/listing/assertion/lifecycle model and compatibility bridge | Data impact/rollback/RLS review | Destructive rewrite or current-flow regression risk |
| 4. Development migration | Backup/test harness ready | Apply only to Development; migrate synthetic fixtures | Idempotent migration, RLS, rollback and clean-room pass | Partial apply, data loss or policy bypass |
| 5. Repository/domain layer | Development schema stable | Add read/write boundaries and compatibility mapping | Targeted/full tests and analyzer pass | Client authority exceeds field ownership |
| 6. Merchant catalog flow | Candidate/review owner assigned | Existing-first search, listing attach, candidate and duplicate prevention | 100-merchant matrix automated/accepted | Duplicate/policy gates bypassed |
| 7. Customer grouping | Catalog read model stable | Product/variant grouping, seller comparison, deep-link continuity | 150 search scenarios plus customer regressions pass | Listing cards duplicate products or stale action works |
| 8. Legacy/demo dry migration | Owner-final taxonomy and live inventory available | Read-only mapping, collision/impact report, Development rehearsal | Counts reconcile; review/QR/cart history preserved | Ambiguous split, missing backup, unmatched dependencies |
| 9. Production cutover plan | Development evidence and release gates pass | Backup, change window, additive apply, postflight and rollback rehearsal | Explicit Product Owner/Production approval | Any Production credential/project/backup uncertainty |
| 10. Controlled Production | Separate written authority | Apply exact reviewed artifacts and smoke | Identity/listing/search/QR/review postflight passes | Any count/RLS/policy/smoke mismatch |

Deferred automation (ML merge, full batch inventory, ads, rewards, broad regulated
catalog and external master synchronization) follows measured V1 needs. No phase may
infer permission to modify Production; each environment-changing phase requires its
own scoped task and safety approval.

`RUNTIME_IMPLEMENTATION_IN_THIS_WAVE: NO`
