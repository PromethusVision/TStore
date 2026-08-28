# Backend Review Uniqueness Contract

**State:** CANONICAL LIFETIME RULE

The uniqueness subject is `customer + canonical product`. At most one active
review exists for that pair. Quantity, repeat purchases, shops and variants do not
multiply rights.

## Concurrency

- two create requests serialize under a database uniqueness boundary;
- same idempotent request returns the existing result;
- conflicting payload under one key is rejected;
- delete makes recreation possible under retained verified evidence, but does not
  create a second simultaneous active review;
- update increments revision and aggregate projection once.

## Product lineage

Merge may cause two predecessor reviews from the same customer to collide. They
must not be silently averaged/deleted. Split does not guess a child. Collision
presentation and survivor policy are `OWNER_DECISION_REQUIRED`; historical review
IDs and evidence remain auditable.

Database constraint/RPC authorization, not UI suppression, enforces the rule.

