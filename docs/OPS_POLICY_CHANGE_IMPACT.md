# Policy Change Impact Model

**State:** PROPOSED — NO POLICY OR RUNTIME CHANGE

## Impact inventory

Merchant/shop verification, active sectors/capabilities, canonical products/variants, listings/media/claims, reviews/reports, QR/verified purchases, ads campaigns/budgets, rewards/reputation, search/discovery, open/closed cases/appeals, customer/merchant communications, imports/demo data, and monitoring.

## Change postures

| Change | Existing subjects |
|---|---|
| Stricter safety/emergency rule | scoped immediate hold where necessary; prioritized review |
| New evidence requirement | recheck window or immediate block by risk; owner decision |
| Relaxation | prospective reevaluation; no silent auto-approval |
| Clarification | apply only if semantics truly unchanged |
| Scope/jurisdiction change | exact affected-set recomputation |
| Faulty version rollback | superseding version plus case reconciliation |

## Required plan

Old/new versions, rationale/source, effective time, affected query and counts, risk classes, decision migration lane, merchant/customer notice, appeal, queue/staffing load, feature flags/kill switch, dry-run, rollback, and post-change reconciliation.

## Safety

Taxonomy move does not itself change policy. No broad manual SQL. Unknown mapping remains held/reviewed. Preserve historical decision/version. Avoid sending sensitive policy reasons or security detection details.

## Operational load

Estimate re-verification and moderation queue before activation; a policy cannot safely launch if no qualified reviewer exists. P0 safety may require immediate containment with later evidence review.

`POLICY_CHANGE_EXECUTED: NO`

`HISTORICAL_POLICY_REWRITE: NO`
