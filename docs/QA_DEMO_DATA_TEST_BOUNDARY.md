# Demo Data Test Boundary

**State:** CURRENT ESENLER DEMO CONTRACT AUDIT

## Current canonical demo

`esenler_demo_v1` contains 19 neighborhood centers, 4 categories, 20 products, 57 synthetic shops and 285 shop listings. It creates zero Auth users, QR transactions, reviews, chat, notifications or analytics rows. Names identify `[DEMO]` shops and no real business is represented.

## Permitted QA use

- deterministic generator/check and manifest/hash validation;
- local clean-room seed/idempotency/read/cleanup replay;
- Customer discovery, search, nearby, seller comparison and media fallback reads;
- controlled Production read-only smoke against exact counts/identities;
- visual acceptance that clearly treats records as synthetic.

## Prohibited use

- mutating Production demo records as generic test fixtures;
- attaching test Auth, QR, review, chat, reward, ad or reputation history;
- using demo discovery as evidence that owner-final taxonomy runtime is deployed;
- treating neighborhood-center coordinates as real shops or precise user location;
- broad cleanup after real dependencies appear.

## Isolation

Mutable journeys use separate run-scoped Development fixtures. Demo traffic is marked/excluded from commercial analytics. Production demo retirement or replacement requires its own impact analysis and explicit authorization.

`ESENLER_DEMO_MUTATED_IN_W22: NO`
