# High-Risk Operations Action Model

**State:** PROPOSED — NO PRIVILEGED ACTION IMPLEMENTATION

## Control ladder

| Risk level | Example | Minimum controls |
|---|---|---|
| R1 routine | assign case, request correction, add internal note | capability, case, reason, audit |
| R2 material | hide listing/review, expire verification, temporary restriction | impact preview, evidence, explicit confirmation, safe reason, appeal |
| R3 high | merchant suspension, regulated approval, verified-history correction, catalog merge | fresh re-authentication, before/after, evidence, dependency preview, two-person candidate, reversal plan |
| R4 critical | product split, permanent restriction, bulk action, role grant, audit export, kill switch | strong re-auth, distinct approver where possible, cooldown unless active incident, alert, limited scope, post-action review |

## Action envelope

Every R2–R4 request records:

- case and subject;
- operator/capability/session assurance;
- action and stable reason code;
- human explanation;
- evidence references and policy version;
- expected impacted entities;
- before/after or predecessor/successor state;
- confirmation timestamp;
- second reviewer or compensating-control reason;
- reversal/superseding path;
- immutable correlation/audit ID.

## Two-person review candidates

- regulated merchant approval or policy exception;
- canonical merge/split with active listings/reviews/purchases;
- permanent merchant/customer restriction;
- broad audit/PII export;
- operator role grant or break-glass activation;
- bulk suspension/retirement;
- verified-purchase correction that changes eligibility/reputation;
- policy change with active listing/campaign impact.

## Cooldown and emergency exception

Cooldown reduces accidental destructive action and allows cancellation. It must not delay containment of an active P0 security/privacy incident. Emergency bypass narrows scope and duration, requires break-glass, alerting, and mandatory retrospective review; it never suppresses evidence.

## Prohibitions

No generic “Are you sure?” alone, no free-text-only reason, no shared account, no silent hard delete, no client-authoritative approval, no self-approval where actor benefits, and no bulk action without preview/sample/count/rollback.

`HIGH_RISK_ACTIONS_FAIL_CLOSED: YES`

`TWO_PERSON_RULE_FINALIZED: NO`
