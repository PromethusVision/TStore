# Backend Reward Ledger Boundary

**State:** PROPOSED FROM WAVE 18 — NO LEDGER/RPC

Reward is an economic/value-oriented system distinct from reviews, gamification,
reputation and ads. Its source of truth is an immutable ledger, not an analytics
counter or mutable balance.

## Conceptual entries

`EARN`, `ADJUST`, `REVERSE`, `REDEEM` and `EXPIRE` append a stable ledger event
with customer/program/merchant/shop scope, unit/delta, authoritative source event,
rule/terms version, idempotency identity and predecessor/correction reference.

## Invariants

- same source + evaluator/rule + subject cannot earn twice;
- balance/progress is a rebuildable projection;
- merchant/client/analytics cannot write balance or eligibility;
- concurrent redemption/expiry/reversal is transactionally ordered;
- insufficient/negative invalid outcomes fail closed;
- purchase confirmation succeeds independently of downstream reward processing;
- reward repeat/quantity semantics never multiply review rights;
- ad view/click/spend cannot manufacture reward evidence.

Unit, funding, program scope, purchase amount/quantity trust, redemption, expiry
and retention are `OWNER_DECISION_REQUIRED`; implementation must wait.

