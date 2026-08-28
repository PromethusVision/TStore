# Bulk Operations Safety

**State:** PROPOSED — BULK RUNTIME NOT AUTHORIZED

Bulk actions amplify one wrong assumption across many customers, merchants, products, listings, or cases.

## High-risk bulk examples

Suspension/restriction, delete/retire, verification expiry, product merge/reclassification, policy change, listing/media removal, role/access changes, reward/reputation correction, notification, audit/export, and case closure.

## Required gates

1. dedicated capability and case/change ticket;
2. exact environment and immutable target query/version;
3. dry-run with total and breakdown;
4. sample preview including edge/policy cases;
5. exclusion list and maximum cap;
6. idempotency and stale-version protection;
7. reason/evidence/policy version;
8. two-person candidate and fresh re-auth;
9. transaction/chunk/resume design;
10. reversal/superseding plan;
11. monitoring/stop threshold;
12. post-run count/hash reconciliation and communication.

## Prohibitions

No free-form Production SQL, wildcard “select all,” hidden target expansion, delete without recovery analysis, automatic retry of non-idempotent action, mixing environments, or proceeding when dry-run and apply counts diverge.

## Emergency action

A threat-derived scoped bulk containment may bypass cooldown, not authorization/audit/counts. Global kill switch is preferable to millions of row edits when it safely stops the capability.

`BULK_DELETE_DEFAULT: NO`

`BULK_ACTION_IMPLEMENTED: NO`
