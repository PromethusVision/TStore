# Production Data Test Policy

**State:** REQUIRED — NO PRODUCTION MUTATION AUTHORIZED

## Default

Production is not a test fixture. Automated tests may perform narrowly bounded anonymous/read-only smoke where the endpoint, artifact and query budget are explicitly allowlisted. They do not create accounts, carts, QR sessions, reviews, chat, notifications, Storage objects, ads, rewards or operator cases.

## Never automatic

- migration/seed/reset/backfill or cleanup;
- adversarial RLS, concurrency, rate or load testing;
- password/email delivery experiments;
- destructive lifecycle or account-deletion tests;
- broad exports, full-table counts or personal-data sampling;
- using real customers/merchants to validate a release.

## Exceptional controlled acceptance

A Production write requires a separate task with exact environment identity, release/change owner, synthetic principal/data, maximum impact, backup/rollback, monitoring, stop criteria and exact cleanup. Passing in Development is a prerequisite, not authorization.

## Demo data

Current `esenler_demo_v1` may be read through its public contract. It is governed Production demo content, not mutable QA data. Unexpected count/drift is reported; the test does not repair it.

## Analytics

If a separately approved Production smoke generates traffic, it must be marked at a trusted source and excluded from commercial, ad, reward and reputation metrics. Unmarked traffic is a data-quality incident.

`PRODUCTION_TEST_MUTATION: PROHIBITED_BY_DEFAULT`
