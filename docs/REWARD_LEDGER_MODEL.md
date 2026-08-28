# Reward Ledger Model

Status: **PROPOSED CONCEPT — NO DB SCHEMA**
Wave: 18 / Workstream J

## Immutable event types

| Type | Meaning | Balance/progress effect |
|---|---|---|
| EARN | Eligible source produced units | Positive |
| ADJUST | Governed correction with reference/reason | Positive or negative delta |
| REVERSE | Prior entitlement invalidated | Negative, linked to original |
| REDEEM | Eligible entitlement consumed | Negative/consumed |
| EXPIRE | Terms-valid expiry | Negative/expired, history retained |

## Event envelope

Ledger event ID, customer/program/merchant/shop scope, source verified-event ID, rule/terms version, unit and delta, server timestamp, idempotency key, predecessor/correction reference, integrity/policy state and restricted actor/provenance.

## Invariants

- Entries append; prior facts are not overwritten/deleted to fix balance.
- Same source + rule cannot EARN twice.
- Balance/progress is a projection, not mutable source truth.
- REVERSE/ADJUST/EXPIRE cannot create or remove review rights by themselves.
- Merchant cannot write ledger entries directly or select customer balance.
- Negative/insufficient and concurrent redemption are blocked transactionally.

## Open decisions

Unit, funding/program owner, earning granularity, correction authority, expiry and account-deletion retention must precede schema design.
