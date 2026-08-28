# Sponsored Advertising Audit-Trail Model

**State:** CONCEPTUAL — NO SCHEMA, LOG PIPELINE OR RETENTION IMPLEMENTATION

## Auditable records

| Domain | Minimum conceptual record |
|---|---|
| Campaign | Create/edit/revision/submit/pause/resume/end, actor, time, reason |
| Target | Listing/product/shop identity and successor/remap history |
| Eligibility | Merchant/shop/listing/policy/budget checks and reason classes |
| Policy | Reviewer/system decision, evidence reference, expiry/revocation |
| Budget | Authorized/reserved/spent/credited/disputed state transitions |
| Ranking | Surface/context class, candidate IDs, hard-gate outcomes, selected target |
| Disclosure | Creative/disclosure variant shown and qualification result |
| Measurement | Raw event, idempotency, validation/invalid status, attribution revision |
| Enforcement | Pause/block/suspension/appeal/restore with authority |

## Identity and integrity

- immutable opaque IDs and revision references, not mutable names/slugs;
- actor type/ID and server time/source;
- append-only decision history or equivalent tamper-evident semantics;
- idempotency/replay detection;
- separate raw occurrence from later validity/classification;
- historical shop/listing/product snapshots only to the necessary degree;
- access controls separating merchant, policy, finance, fraud and support views.

## Privacy/security

Do not log secrets, raw credentials, payment material, full evidence documents,
unnecessary exact customer location, raw long-term query history or sensitive
profiling. Audit retention differs by purpose and requires privacy/legal/security
approval.

## Explainability

Internal reconstruction should answer: who changed what, which revision was
evaluated, why a target was eligible/rejected/served, which disclosure was shown and
how a metric/credit was classified. Customer/merchant explanations expose only
necessary safe reason classes.

`AD_DECISION_RECONSTRUCTABLE: REQUIRED`

`SECRETS_IN_AUDIT_LOG: PROHIBITED`

`RETENTION_FINALIZED: NO`
