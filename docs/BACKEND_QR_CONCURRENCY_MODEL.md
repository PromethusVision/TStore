# Backend QR Concurrency Model

**State:** PROPOSED SERIALIZATION CONTRACT

## Two-staff race

If two authorized staff members at the same shop confirm one token concurrently:

1. both authenticate and submit independent requests;
2. the server serializes on the QR session/business uniqueness boundary;
3. one request may transition `active → used` and create the transaction/items;
4. the loser observes the committed terminal state and receives the original
   safe outcome or an already-used conflict;
5. no second transaction, reward event, review right or notification is produced.

Wrong-shop staff never join the valid race; shop binding fails first. Revocation
or suspension observed before commit denies the affected request.

## Required database-level protections

- unique verified transaction per source QR session;
- conditional state transition or row lock under one transaction;
- item creation inside the winning transaction;
- idempotent downstream event identity;
- no reliance on client double-tap locks.

Locking mechanism is implementation-specific; correctness criteria above are not.
Contention should be bounded and observable without logging the token.

