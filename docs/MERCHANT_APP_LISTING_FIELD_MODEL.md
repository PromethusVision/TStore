# Merchant App Listing Field Model

Status: **PROPOSED — NO SCHEMA IMPLEMENTATION**  
Wave: 17 / WP18

## Merchant-owned listing facts

| Field | Meaning | Validation |
|---|---|---|
| shop/branch relation | Local offer owner | Derived/authorized server-side, not trusted from client |
| canonical product/variant reference | What is offered | Active/eligible governed identity |
| merchant SKU | Private local identifier | Scoped uniqueness policy; never global identity |
| price/currency | Current merchant price claim | Positive/allowed precision, timestamped |
| availability state | Offer availability | Explicit semantic state |
| stock knowledge | Known in/out/unknown | Not fake exact inventory |
| sell unit/minimum/increment | Unit commerce semantics | Conditional by product/listing profile |
| local media | Shop-specific evidence/presentation | Rights, policy and moderation gates |
| merchant note | Operational note if justified | Private by default, minimized |

## Protected inherited facts

Canonical name, brand/model, taxonomy, durable product ID and governed shared attributes are read-only in listing editor. Merchant requests correction rather than mutating them.

## Versioning

- Mutations send listing ID, expected revision and idempotency key.
- Conflict returns current safe snapshot; it never silently overwrites a newer edit.
- Audit records actor, shop scope, before/after safe fields, reason class and timestamp.

## Customer projection

Customer receives only active/eligible canonical facts plus customer-visible listing price, availability, sell unit and approved media. Merchant SKU, private notes, provenance and staff identity stay private.

