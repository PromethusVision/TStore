# Minimum Operator Role Model

**State:** PROPOSED FOR OWNER REVIEW

## Goal

Use a small role set for navigability while granting sensitive actions as explicit capabilities. Avoid one role per queue and avoid one all-powerful daily account.

| Role | Primary purpose | Typical capabilities | Explicit exclusions |
|---|---|---|---|
| SUPPORT | Customer/merchant assistance and case triage | View assigned case, safe account/shop summary, request evidence, communicate reason, escalate | Verify/suspend, merge/split, policy change, audit export |
| MODERATOR | Listings, reviews, reports, ordinary abuse | Review content, restrict item, link cases, request correction | Merchant legal verification, catalog identity merge/split, root policy |
| MERCHANT_VERIFICATION | Merchant identity/shop/sector evidence | Review evidence, approve/expire verification within policy, escalate regulated cases | Catalog merge, review rating change, ad billing |
| CATALOG_REVIEWER | Canonical candidate/dedup/provenance | Approve candidate, request correction, high-confidence linkage proposal | Root taxonomy/policy change; high-risk split without second review |
| POLICY_REVIEWER | Sensitive products/merchants/ads and policy status | Apply owner-approved ruleset, evidence disposition, escalation | Invent policy, bypass legal/owner gate, arbitrary account access |
| SUPER_ADMIN / BREAK_GLASS | Recovery and rare cross-system containment | Time-bound emergency controls, role recovery, system kill switch | Routine case handling; permanent broad access by default |

## Consolidation guidance

- ADS review belongs to Policy Reviewer/Moderator capabilities until volume justifies specialization.
- QR fraud and reward abuse are specialized queues, not launch roles.
- Security incident response uses temporary incident capabilities and break-glass controls rather than a broad daily role.
- Catalog and policy approval may require two distinct people for merge/split or regulated decisions when staffing permits.
- In a one-person pilot, the same person may hold multiple roles, but action reasons, re-authentication, immutable audit, and retrospective sampling compensate.

## Role governance

Role assignments are effective-dated, scoped, approved, periodically reviewed, and removed promptly. A role name is not enough: the server evaluates action capability and subject scope on every request. No role grants arbitrary SQL, service-role credentials, password visibility, or silent audit editing.

## Open owner decisions

1. Which P0 actions require a second operator at pilot scale?
2. Is SUPER_ADMIN a standing assignment or break-glass only?
3. Who owns regulated/legal escalation outside the operator team?
4. What minimum independence is required for appeals?

`MINIMUM_ROLE_COUNT: 6`

`ROLE_MODEL_FINAL: NO`
