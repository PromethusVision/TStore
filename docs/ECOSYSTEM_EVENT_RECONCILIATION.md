# Ecosystem Domain / Analytics / Audit Event Reconciliation

| Event class | Authority | Examples | Can mutate business truth? |
|---|---|---|---|
| AUTHORITATIVE DOMAIN | committed server domain transition | QR consumed, verified purchase created, membership revoked | transition itself is truth |
| SERVER-DERIVED | deterministic projection from domain rows | review aggregate, listing health, reputation candidate | only through governed projector |
| CLIENT-OBSERVED | untrusted UX observation | view, search, tap, directions request | NO |
| ANALYTICS | minimized approved measurement envelope | eligible/render/impression, aggregate funnel | NO |
| AUDIT | immutable sensitive action evidence | operator decision, role change, catalog correction | NO; proves action/history |
| SOFT SIGNAL | intent with limited trust | wishlist, directions, listing view | NO |

## Rules

- A domain event is emitted after/with committed state and carries stable entity,
  version, environment and idempotency identity.
- Analytics delivery failure never rolls back or recreates domain facts.
- Audit evidence has restricted access/retention and cannot be replaced by product
  analytics.
- Generic client analytics cannot create verified purchase, review eligibility,
  Reward, reputation, campaign billing or Ops decisions.
- Correction/merge/split events reference lineage rather than rewriting history.
- Outbox infrastructure is deferred until durable asynchronous consumers justify
it; idempotent reconciliation remains mandatory either way.
